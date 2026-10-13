import { expect, mock, test } from 'claude-code/testing'
import type { On } from 'claude-code'

const BAND = {
  plugin: 'session-assistent',
  component: 'AbovePrompt',
  props: { hasSurvey: false, isWorking: false, maxRows: 10, bodyColumns: 100, scroll: { offset: 0, bodyRows: 9 }, view: {} },
} as const

const MIN = 60_000

function noProject(on: On) {
  on('session.root', () => ({ value: '/projekt' }))
  on('fs.exists', () => ({ value: false }))
}

function measure(percent: number) {
  return { context: { window: 200000, tokens: Math.round(200000 * percent / 100), percent }, rateLimits: [], changed: ['context' as const] }
}

test('Knöpfe Wrap-up und Dashboard stehen im Band, Batterie bei 0 Prozent grün', async ($, on) => {
  mock.clock(on)
  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ ...BAND, surface })
    expect(await ui.find({ key: 'btn-wrapup' })).toBeDefined()
    expect(await ui.find({ key: 'btn-dashboard' })).toBeDefined()
    const bat = await ui.find({ type: 'Text', text: /▱▱▱▱▱▱▱▱ 0 %/ })
    expect(bat).toBeDefined()
    expect(bat?.props.color).toBe('success')
    expect(await ui.find({ type: 'Text', text: /Cache/ })).toBeUndefined()
    await ui.unmount()
  }
})

test('Batterie zeigt Füllstand und Farbe bei 30, 55 und 75 Prozent', async ($, on) => {
  mock.clock(on)
  on('session.measure', (_$, e) => ({ changed: e.changed }))
  const cases = [
    { pct: 30, text: /▰▰▱▱▱▱▱▱ 30 %/, color: 'success', hot: false },
    { pct: 55, text: /▰▰▰▰▱▱▱▱ 55 %/, color: 'warning', hot: false },
    { pct: 75, text: /▰▰▰▰▰▰▱▱ 75 %/, color: 'error', hot: true },
  ] as const
  for (const c of cases) {
    await $.session.measure(measure(c.pct))
    for (const surface of ['terminal', 'desktop'] as const) {
      const ui = await $.ui.mount({ ...BAND, surface })
      const bat = await ui.find({ type: 'Text', text: c.text })
      expect(bat).toBeDefined()
      expect(bat?.props.color).toBe(c.color)
      const wrap = await ui.find({ key: 'btn-wrapup' })
      expect(wrap?.props.variant === 'primary').toBe(c.hot)
      await ui.unmount()
    }
  }
})

test('Cache-Restzeit läuft ab dem letzten Turn herunter und meldet kalt', { options: { showCache: true } }, async ($, on) => {
  const clock = mock.clock(on, { now: 10 * MIN })
  noProject(on)
  on('turn.complete', (_$, e) => ({ text: e.answer }))

  await $.turn.complete({ answer: 'ok', durationMs: 100, isAborted: false, turnId: 't-1', reason: 'answer' })
  const ui1 = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await ui1.find({ type: 'Text', text: /Cache 60 min/ })).toBeDefined()
  await ui1.unmount()

  await clock.advance(18 * MIN)
  const ui2 = await $.ui.mount({ ...BAND, surface: 'desktop' })
  expect(await ui2.find({ type: 'Text', text: /Cache 42 min/ })).toBeDefined()
  await ui2.unmount()

  await clock.advance(43 * MIN)
  const ui3 = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await ui3.find({ type: 'Text', text: /Cache kalt/ })).toBeDefined()
  await ui3.unmount()
})

test('Option cacheTtl 5m verkürzt den Countdown', { options: { showCache: true, cacheTtl: '5m' } }, async ($, on) => {
  const clock = mock.clock(on, { now: MIN })
  noProject(on)
  on('turn.complete', (_$, e) => ({ text: e.answer }))
  await $.turn.complete({ answer: 'ok', durationMs: 100, isAborted: false, turnId: 't-1', reason: 'answer' })
  await clock.advance(2 * MIN)
  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await ui.find({ type: 'Text', text: /Cache 3 min/ })).toBeDefined()
  await ui.unmount()
})

test('Brücken-Datei der Statuszeile hat Vorrang vor dem eigenen Zähler', { options: { showCache: true } }, async ($, on) => {
  const clock = mock.clock(on, { now: 100 * MIN })
  const file = '/home/tester/.claude/prompt-cache/sess-1.json'
  on('env.get', (_$, e) => ({ value: e.name === 'HOME' ? '/home/tester' : undefined }))
  on('session.id', () => ({ value: 'sess-1' }))
  on('session.root', () => ({ value: '/projekt' }))
  on('fs.exists', (_$, e) => ({ value: e.path === file }))
  on('fs.read', (_$, e) => ({ value: e.path === file ? JSON.stringify({ ttl: '5m', expires_at: (100 * MIN) / 1000 + 180, warm: true }) : '' }))
  on('session.start', (_$, e) => ({ cwd: e.cwd }))
  on('turn.complete', (_$, e) => ({ text: e.answer }))

  await $.session.start({ cwd: '/projekt', surface: 'terminal', isInteractive: true })
  await $.turn.complete({ answer: 'ok', durationMs: 100, isAborted: false, turnId: 't-1', reason: 'answer' })
  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  // Eigener Zähler sagte 60 min, die Datei sagt 3 min.
  expect(await ui.find({ type: 'Text', text: /Cache 3 min/ })).toBeDefined()
  await ui.unmount()
  await clock.advance(4 * MIN)
  const ui2 = await $.ui.mount({ ...BAND, surface: 'desktop' })
  expect(await ui2.find({ type: 'Text', text: /Cache kalt/ })).toBeDefined()
  await ui2.unmount()
})

test('Turn ohne Cache-Tokens zeigt „Cache aus"', { options: { showCache: true } }, async ($, on) => {
  mock.clock(on, { now: MIN })
  noProject(on)
  on('turn.complete', (_$, e) => ({ text: e.answer }))
  await $.turn.complete({
    answer: 'ok', durationMs: 100, isAborted: false, turnId: 't-1', reason: 'answer',
    usage: { model: 'm', input_tokens: 10, output_tokens: 5, cache_read_input_tokens: 0, cache_creation_input_tokens: 0 },
  })
  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await ui.find({ type: 'Text', text: /Cache aus/ })).toBeDefined()
  await ui.unmount()
})

test('Modellwechsel übernimmt die TTL aus dem Ereignis und macht den Cache kalt', { options: { showCache: true } }, async ($, on) => {
  const clock = mock.clock(on, { now: MIN })
  noProject(on)
  on('turn.complete', (_$, e) => ({ text: e.answer }))
  on('classic.PostModelSwitch', () => ({}))
  await $.turn.complete({ answer: 'ok', durationMs: 100, isAborted: false, turnId: 't-1', reason: 'answer' })
  await $.classic.PostModelSwitch({
    from_model: 'a', to_model: 'b', requested_model: 'b', source: 'command',
    context_tokens: 1000, prompt_cache_warm: true, cache_ttl: '5m', estimated_cache_write_usd: 0.01, pricing: 'catalog',
  } as any)
  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await ui.find({ type: 'Text', text: /Cache/ })).toBeUndefined()
  await ui.unmount()
  await $.turn.complete({ answer: 'ok', durationMs: 100, isAborted: false, turnId: 't-2', reason: 'answer' })
  await clock.advance(2 * MIN)
  const ui2 = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await ui2.find({ type: 'Text', text: /Cache 3 min/ })).toBeDefined()
  await ui2.unmount()
})

test('Ohne Option showCache steht kein Cache im Band (Standard für Teilnehmer)', async ($, on) => {
  mock.clock(on, { now: MIN })
  noProject(on)
  on('turn.complete', (_$, e) => ({ text: e.answer }))
  await $.turn.complete({ answer: 'ok', durationMs: 100, isAborted: false, turnId: 't-1', reason: 'answer' })
  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ ...BAND, surface })
    expect(await ui.find({ type: 'Text', text: /Cache/ })).toBeUndefined()
    expect(await ui.find({ type: 'Text', text: /0 %/ })).toBeDefined()
    await ui.unmount()
  }
})

test('Knöpfe starten die Befehle wrap-up und aios-dashboard', async ($, on) => {
  mock.clock(on)
  const seen: string[] = []
  on('command.run', (_$, e) => {
    seen.push(e.command)
    return { text: '' }
  })
  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  await ui.press({ key: 'btn-wrapup' })
  expect(seen).toEqual(['wrap-up'])
  await ui.press({ key: 'btn-dashboard' })
  expect(seen).toEqual(['wrap-up', 'aios-dashboard'])
  await ui.unmount()
})

test('Zahl offener To-dos kommt aus der Projektwurzel, nicht aus dem Arbeitsverzeichnis', async ($, on) => {
  mock.clock(on)
  on('session.root', () => ({ value: '/projekt' }))
  on('session.cwd', () => ({ value: '/projekt/repo/unterordner' }))
  on('fs.exists', (_$, e) => ({ value: e.path === '/projekt/.planning/TODO.md' }))
  on('fs.read', () => ({ value: '# TODO\n\n- [ ] eins\n- [ ] zwei\n- [x] erledigt\n- [ ] drei\n' }))
  on('turn.complete', (_$, e) => ({ text: e.answer }))

  await $.turn.complete({ answer: 'ok', durationMs: 100, isAborted: false, turnId: 't-2', reason: 'answer' })
  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await ui.find({ type: 'Text', text: /3 offene To-dos/ })).toBeDefined()
  await ui.unmount()
})
