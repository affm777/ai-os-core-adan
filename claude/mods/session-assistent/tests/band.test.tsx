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

test('Knöpfe stehen im Band, ohne Kontext-Hinweis', async ($, on) => {
  mock.clock(on)
  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ ...BAND, surface })
    expect(await ui.find({ key: 'btn-wrapup' })).toBeDefined()
    expect(await ui.find({ key: 'btn-dashboard' })).toBeDefined()
    expect(await ui.find({ type: 'Text', text: /Wrap-up und eine neue Session/ })).toBeUndefined()
    expect(await ui.find({ type: 'Text', text: /Cache/ })).toBeUndefined()
    await ui.unmount()
  }
})

test('Kontext-Hinweis ab 60 Prozent ersetzt die Knopfzeile, „Später" blendet ihn bis 75 Prozent aus', async ($, on) => {
  mock.clock(on)
  on('session.measure', (_$, e) => ({ changed: e.changed }))

  await $.session.measure(measure(55))
  let ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await ui.find({ type: 'Text', text: /Guter Zeitpunkt/ })).toBeUndefined()
  expect(await ui.find({ key: 'btn-wrapup' })).toBeDefined()
  await ui.unmount()

  await $.session.measure(measure(62))
  ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await ui.find({ type: 'Text', text: /Guter Zeitpunkt für einen Wrap-up/ })).toBeDefined()
  expect(await ui.find({ key: 'hint-wrapup' })).toBeDefined()
  expect(await ui.find({ key: 'btn-dashboard' })).toBeUndefined()
  await ui.press({ key: 'hint-later' })
  expect(await ui.find({ type: 'Text', text: /Guter Zeitpunkt/ })).toBeUndefined()
  expect(await ui.find({ key: 'btn-dashboard' })).toBeDefined()
  await ui.unmount()

  await $.session.measure(measure(80))
  const ui2 = await $.ui.mount({ ...BAND, surface: 'desktop' })
  expect(await ui2.find({ type: 'Text', text: /Jetzt einen Wrap-up machen/ })).toBeDefined()
  await ui2.unmount()
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
    expect(await ui.find({ key: 'btn-inbox' })).toBeDefined()
    await ui.unmount()
  }
})

test('Knöpfe starten wrap-up, aios-dashboard, sync-meetings und sort-inbox', async ($, on) => {
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
  await ui.press({ key: 'btn-meetings' })
  await ui.press({ key: 'btn-inbox' })
  expect(seen).toEqual(['wrap-up', 'aios-dashboard', 'brain:sync-meetings', 'brain:sort-inbox'])
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

test('Batterie zeigt Prozent und Tokens gegen das volle Modellfenster', async ($, on) => {
  mock.clock(on)
  on('session.measure', (_$, e) => ({ changed: e.changed }))

  // Ereignis meldet 40 Prozent (Kompaktierungsfenster), gezählt wird gegen 1M.
  await $.session.measure({ context: { window: 1_000_000, tokens: 230_000, percent: 40 }, rateLimits: [], changed: ['context' as const] })
  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ ...BAND, surface })
    expect(await ui.find({ type: 'Text', text: /▰▰▱▱▱▱▱▱ 23 % · 230k \/ 1M/ })).toBeDefined()
    await ui.unmount()
  }

  // Auch neben dem Kontext-Hinweis bleibt die Batterie sichtbar.
  await $.session.measure({ context: { window: 1_000_000, tokens: 800_000, percent: 95 }, rateLimits: [], changed: ['context' as const] })
  const ui = await $.ui.mount({ ...BAND, surface: 'desktop' })
  expect(await ui.find({ type: 'Text', text: /Jetzt einen Wrap-up machen/ })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: /80 % · 800k \/ 1M/ })).toBeDefined()
  await ui.unmount()
})

test('„Wrap-up & neue Session" gibt dem Wrap-up den Auftrag für die neue Session mit', async ($, on) => {
  mock.clock(on)
  noProject(on)
  on('session.measure', (_$, e) => ({ changed: e.changed }))
  const runs: { command: string; args: string }[] = []
  on('command.run', (_$, e) => {
    runs.push({ command: e.command, args: e.args })
    return { text: '' }
  })
  await $.session.measure(measure(65))
  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ ...BAND, surface })
    expect(await ui.find({ type: 'Text', text: /Guter Zeitpunkt für einen Wrap-up\./ })).toBeDefined()
    expect(await ui.find({ key: 'hint-wrapup' })).toBeDefined()
    await ui.press({ key: 'hint-wrapup-new' })
    await ui.unmount()
  }
  expect(runs.length).toBe(2)
  expect(runs[0]!.command).toBe('wrap-up')
  expect(runs[0]!.args).toMatch(/^Starte danach eine neue Session/)
})

test('Knopf-Wrap-up zieht die To-do-Bilanz, auch ohne eigenen command.run-Hook', async ($, on) => {
  mock.clock(on)
  noProject(on)
  const runs: string[] = []
  on('command.run', (_$, e) => {
    runs.push(e.args)
    return { text: '' }
  })
  on('tool.call', () => ({ result: { isError: false, text: 'ok' } }) as any)
  on('turn.complete', (_$, e) => ({ text: e.answer }))
  const ui1 = await $.ui.mount({ ...BAND, surface: 'terminal' })
  await ui1.press({ key: 'btn-wrapup' })
  await ui1.unmount()
  expect(runs).toEqual([''])
  await $.tool.call({ tool: 'Edit', file_path: '/projekt/.planning/STATE.md', old_string: 'a', new_string: 'b' } as any)
  await $.turn.complete({ answer: 'fertig', durationMs: 100, isAborted: false, turnId: 't-1', reason: 'answer' })
  const ui = await $.ui.mount({ ...BAND, surface: 'desktop' })
  expect(await ui.find({ type: 'Text', text: /To-do-Liste: 0 erledigt/ })).toBeDefined()
  await ui.unmount()
})
