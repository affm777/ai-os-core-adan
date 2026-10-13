// Mod „Session-Assistent": nimmt Nicht-Technikern das Merken von Befehlen ab.
// Kontext-Batterie mit Cache-Restzeit, To-do-Bilanz nach dem Wrap-up,
// offene To-dos im Band, Knöpfe für Wrap-up, Dashboard, Meetings holen und Eingang sortieren.
// Kein Netzwerk, keine Connectoren, kein Vault-Zugriff.

import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Bilanz } from '../types'


const contextPercent = atom({ plugin: 'session-assistent', key: 'contextPercent' } as const, 0)
const lastTurnAt = atom({ plugin: 'session-assistent', key: 'lastTurnAt' } as const, 0)
const cacheTtlMs = atom({ plugin: 'session-assistent', key: 'cacheTtlMs' } as const, 0)
const cacheFile = atom({ plugin: 'session-assistent', key: 'cacheFile' } as const, '')
const cacheOff = atom({ plugin: 'session-assistent', key: 'cacheOff' } as const, false)
const todoSnapshot = atom({ plugin: 'session-assistent', key: 'todoSnapshot' } as const, [] as string[])
const openTodos = atom({ plugin: 'session-assistent', key: 'openTodos' } as const, -1)
const wrapup = atom({ plugin: 'session-assistent', key: 'wrapup' } as const, { isRunning: false, hasWritten: false })
const bilanz = atom({ plugin: 'session-assistent', key: 'bilanz' } as const, null as Bilanz | null)

// Schwellen der Kontext-Anzeige: grün darunter, orange ab WARN, rot ab HOT.
const CONTEXT_WARN = 50
const CONTEXT_HOT = 70
const BATTERY_CELLS = 8
// Lebensdauer des Prompt-Caches (Option cacheTtl im Manifest).
const TTL_MS: Record<string, number> = { '5m': 5 * 60_000, '1h': 60 * 60_000 }
const TTL_DEFAULT = '1h'
// Takt, in dem die Cache-Restzeit neu gezeichnet wird.
const TICK_MS = 30_000
const TODO_RE = /^- \[ \] /

// ---------- Kontext-Anzeige ----------

export function battery(pct: number): string {
  const filled = Math.round((Math.min(100, Math.max(0, pct)) / 100) * BATTERY_CELLS)
  return '▰'.repeat(filled) + '▱'.repeat(BATTERY_CELLS - filled)
}

export function contextColor(pct: number): 'success' | 'warning' | 'error' {
  if (pct >= CONTEXT_HOT) return 'error'
  if (pct >= CONTEXT_WARN) return 'warning'
  return 'success'
}

export function cacheText(now: number, last: number, ttl: number): string | null {
  if (last <= 0 || ttl <= 0) return null
  return cacheLeftText(last + ttl - now)
}

function cacheLeftText(leftMs: number): string {
  if (leftMs <= 0) return 'Cache kalt'
  const min = Math.ceil(leftMs / 60_000)
  return min < 1 ? 'Cache < 1 min' : `Cache ${min} min`
}

// Brücken-Datei der Statuszeile (aios-statusline.js schreibt prompt_cache je
// Session nach ~/.claude/prompt-cache/<session-id>.json). Sie trägt die echte
// TTL und Ablaufzeit, die Claude Code aus den API-Antworten berechnet, auch
// nach dem Wechsel auf 5 Minuten bei Extra Usage. Fehlt sie, zählt der Mod selbst.
type Bridge = { ttl: string | null; expires_at: number | null; warm: boolean }

export function parseBridge(text: string): Bridge | null {
  try {
    const v = JSON.parse(text) as Partial<Bridge>
    return {
      ttl: typeof v.ttl === 'string' ? v.ttl : null,
      expires_at: typeof v.expires_at === 'number' ? v.expires_at : null,
      warm: v.warm === true,
    }
  } catch {
    return null
  }
}

async function readBridge($: EngineInterface, file: string): Promise<Bridge | null> {
  if (file === '' || !(await $.fs.exists(file))) return null
  return parseBridge(await $.fs.read(file))
}

async function bridgePath($: EngineInterface): Promise<string> {
  const home = await $.env.get('HOME') ?? await $.env.get('USERPROFILE')
  const id = await $.session.id()
  if (!home || !id || !/^[A-Za-z0-9._-]+$/.test(id)) return ''
  return `${home}/.claude/prompt-cache/${id}.json`
}

function ttlFromOption(value: unknown): number {
  const key = typeof value === 'string' && value in TTL_MS ? value : TTL_DEFAULT
  return TTL_MS[key] ?? TTL_MS[TTL_DEFAULT]!
}

async function touchCache($: EngineInterface): Promise<void> {
  const now = await $.clock.now()
  await update($, lastTurnAt, () => now)
}

// ---------- To-do-Liste lesen ----------

async function todoPath($: EngineInterface): Promise<string | null> {
  // Projektwurzel, nicht das Arbeitsverzeichnis: ein `cd` in einem
  // Shell-Befehl verschiebt sonst die Suche in einen Unterordner ohne TODO.md.
  const root = await $.session.root()
  for (const rel of ['.planning/TODO.md', 'TODO.md']) {
    const path = `${root}/${rel}`
    if (await $.fs.exists(path)) return path
  }
  return null
}

async function readOpenTodos($: EngineInterface): Promise<string[]> {
  const path = await todoPath($)
  if (path === null) return []
  const text = await $.fs.read(path)
  return text.split('\n').filter(line => TODO_RE.test(line))
}

function todoKey(line: string): string {
  // Erste 40 Zeichen des Textes ohne Checkbox, dient als Kennung für „geändert".
  return line.replace(TODO_RE, '').trim().slice(0, 40).toLowerCase()
}

function compare(before: string[], after: string[]): Bilanz {
  const beforeSet = new Set(before)
  const afterSet = new Set(after)
  const beforeKeys = new Map(before.map(l => [todoKey(l), l]))
  const afterKeys = new Map(after.map(l => [todoKey(l), l]))
  let done = 0
  let changed = 0
  let added = 0
  for (const line of before) {
    if (afterSet.has(line)) continue
    if (afterKeys.has(todoKey(line))) changed += 1
    else done += 1
  }
  for (const line of after) {
    if (beforeSet.has(line)) continue
    if (beforeKeys.has(todoKey(line))) continue
    added += 1
  }
  return { done, changed, added }
}

function todoText(n: number): string {
  if (n === 0) return 'keine offenen To-dos'
  return n === 1 ? '1 offenes To-do' : `${n} offene To-dos`
}

async function refreshTodos($: EngineInterface): Promise<string[]> {
  const lines = await readOpenTodos($)
  await update($, openTodos, () => lines.length)
  // Frühere Fassung hielt die Zahl in der Statuszeile; die bleibt nach einem
  // Hot Reload sonst stehen, deshalb hier ausdrücklich leeren.
  $.ui.status(undefined)
  $.ui.invalidate('ui.render')
  return lines
}

// ---------- Registrierung ----------

export const register: Register = (on, options) => {
  on('session.start', async ($, e, next) => {
    await update($, cacheTtlMs, () => ttlFromOption(options.cacheTtl))
    const file = await bridgePath($)
    await update($, cacheFile, () => file)
    const lines = await refreshTodos($)
    await update($, todoSnapshot, () => lines)
    // Cache-Restzeit läuft als Countdown, das Band zeichnet nur auf Anstoss.
    $.clock.every(TICK_MS, () => $.ui.invalidate('ui.render'))
    return next(e)
  })

  // 1. Kontext-Anzeige: Füllstand nach jedem Turn merken.
  on('session.measure', async ($, e, next) => {
    // Bewusst gegen das volle Modellfenster (Entscheidung 13.10.): das
    // Kompaktierungsfenster ist je Nutzer anders (Env, Settings, Experiment),
    // die Desktop-App zeigt deshalb eine etwas höhere Zahl.
    const pct = e.context.percent
    if (typeof pct === 'number') {
      const prev = await read($, contextPercent)
      await update($, contextPercent, () => pct)
      // Das Band zeichnet nur auf Anstoss neu; ohne invalidate bliebe die
      // Anzeige bis zum nächsten Ereignis stehen.
      if (prev !== pct) $.ui.invalidate('ui.render')
    }
    return next(e)
  })

  // Ein Modellwechsel verrät die tatsächliche Cache-Lebensdauer und macht den
  // Cache kalt (die Anfrage läuft danach auf einem anderen Modell).
  on('classic.PostModelSwitch', async ($, e, next) => {
    const ttl = TTL_MS[e.cache_ttl]
    if (ttl !== undefined) await update($, cacheTtlMs, () => ttl)
    await update($, lastTurnAt, () => 0)
    $.ui.invalidate('ui.render')
    return next(e)
  })

  // 2. To-do-Bilanz: Wrap-up erkennen (getippt oder per Knopf) und das
  // Schreiben der To-do-Liste beobachten.
  on('command.run', { command: 'wrap-up' }, async ($, e, next) => {
    await update($, wrapup, () => ({ isRunning: true, hasWritten: false }))
    await update($, bilanz, () => null)
    return next(e)
  })

  on('tool.call', async ($, e, next) => {
    // Jeder Tool-Aufruf der Hauptschleife folgt auf eine Modell-Anfrage, die
    // den Prompt-Cache frisch hält. Stempel vor dem Tool, sonst zählt bei
    // langen Tools die Tool-Dauer fälschlich als Cache-Zeit.
    if (e.agentId === undefined) await touchCache($)
    const ran = await next(e)
    if (e.agentId !== undefined) return ran
    // Schreibt das Wrap-up die To-do-Liste?
    if (e.tool === 'Edit' || e.tool === 'Write') {
      const path = String((e as any).file_path ?? '')
      if (/(^|\/)TODO\.md$/.test(path)) {
        const w = await read($, wrapup)
        if (w.isRunning) await update($, wrapup, () => ({ isRunning: true, hasWritten: true }))
      }
    }
    return ran
  })

  on('turn.complete', async ($, e, next) => {
    // Nur die Hauptschleife: Cache-Zeit, To-dos neu zählen, Wrap-up-Bilanz ziehen.
    if (e.agentId !== undefined) return next(e)
    await touchCache($)
    // Kamen in diesem Turn weder gelesene noch geschriebene Cache-Tokens,
    // ist Caching aus oder wird nicht gemeldet. Ohne usage bleibt der Stand.
    if (e.usage !== undefined) {
      const off = e.usage.cache_read_input_tokens + e.usage.cache_creation_input_tokens === 0
      await update($, cacheOff, () => off)
    }
    const lines = await refreshTodos($)
    const w = await read($, wrapup)
    if (w.isRunning && w.hasWritten) {
      const before = await read($, todoSnapshot)
      await update($, bilanz, () => compare(before, lines))
      await update($, todoSnapshot, () => lines)
      await update($, wrapup, () => ({ isRunning: false, hasWritten: false }))
    }
    return next(e)
  })

  // 1, 2, 5: alles im Band über dem Prompt.
  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.props.hasSurvey) return next(e)

    const pct = await read($, contextPercent)
    const last = await read($, lastTurnAt)
    // Vor session.start (Hot Reload, Test) steht noch kein Wert im State.
    const ttl = (await read($, cacheTtlMs)) || ttlFromOption(options.cacheTtl)
    const off = await read($, cacheOff)
    const bridge = await readBridge($, await read($, cacheFile))
    const card = await read($, bilanz)
    const todos = await read($, openTodos)
    const now = await $.clock.now()

    const color = contextColor(pct)
    const isHot = color === 'error'
    // Reihenfolge: Brücken-Datei (Messung), sonst eigener Zähler (Schätzung).
    let cache: string | null
    if (bridge !== null && bridge.expires_at !== null) {
      cache = cacheLeftText(bridge.expires_at * 1000 - now)
    } else if (bridge !== null && !bridge.warm) {
      cache = 'Cache kalt'
    } else {
      cache = cacheText(now, last, ttl)
    }
    if (off && last > 0) cache = 'Cache aus'
    // Standard aus (Entscheidung 13.10.): die Zahl ist in der Desktop-App nur
    // eine Schätzung und verwirrt Teilnehmer. Option showCache schaltet sie zu.
    if (options.showCache !== true) cache = null

    const { Box, Text, Button } = $.ui.resolve(e)

    return (
      <Box flexDirection="column">
        {card !== null && (
          <Box flexDirection="row" gap={1}>
            <Text>
              To-do-Liste: {card.done} erledigt · {card.changed} überarbeitet · {card.added} neu
            </Text>
            <Button key="card-ok" label="Ok" dimColor onPress={() => update($, bilanz, () => null)} />
          </Box>
        )}

        {/* Schmale Bänder (Terminal-Tab mit 40 Spalten): Elemente umbrechen als
            Ganzes, nie zeichenweise, deshalb flexWrap am Band und flexShrink 0
            je Element. */}
        <Box flexDirection="row" flexWrap="wrap" columnGap={1}>
          <Box flexShrink={0}>
            <Button
              key="btn-wrapup"
              label="Wrap-up"
              variant={isHot ? 'primary' : undefined}
              dimColor={!isHot}
              onPress={() => void $.command.run({ command: 'wrap-up' })}
            />
          </Box>
          <Box flexShrink={0}>
            <Button
              key="btn-dashboard"
              label="Dashboard"
              dimColor
              onPress={() => void $.command.run({ command: 'aios-dashboard' })}
            />
          </Box>
          <Box flexShrink={0}>
            <Button
              key="btn-meetings"
              label="Meetings holen"
              dimColor
              onPress={() => void $.command.run({ command: 'brain:sync-meetings' })}
            />
          </Box>
          <Box flexShrink={0}>
            <Button
              key="btn-inbox"
              label="Eingang sortieren"
              dimColor
              onPress={() => void $.command.run({ command: 'brain:sort-inbox' })}
            />
          </Box>
          {todos >= 0 && (
            <Box flexShrink={0}>
              <Text dimColor>{todoText(todos)}</Text>
            </Box>
          )}
          {cache !== null && (
            <Box flexShrink={0}>
              <Text dimColor>{cache}</Text>
            </Box>
          )}
          <Box flexShrink={0}>
            <Text color={color} bold={isHot}>
              {battery(pct)} {pct} %
            </Text>
          </Box>
        </Box>
      </Box>
    )
  })
}
