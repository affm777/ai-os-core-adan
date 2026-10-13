// Vertrag der Session-Werte des Mods „session-assistent".
// Jeder Wert in $.state steht hier, claude plugin validate prüft dagegen.

/** Bilanz der To-do-Liste nach einem Wrap-up. */
export type Bilanz = {
  done: number
  changed: number
  added: number
}

declare module 'claude-code' {
  interface PluginState {
    'session-assistent': {
      /** Kontextfüllstand in Prozent, 0 bis 100. */
      contextPercent: number
      /** Zeitpunkt (ms seit Epoche) der letzten Modell-Anfrage der Hauptschleife, 0 vor der ersten. */
      lastTurnAt: number
      /** Lebensdauer des Prompt-Caches in Millisekunden (Rückfall ohne Brücken-Datei). */
      cacheTtlMs: number
      /** Pfad der Brücken-Datei, die die Statuszeile je Session schreibt, '' ohne. */
      cacheFile: string
      /** Ob die letzte Antwort der Hauptschleife ohne Cache-Tokens kam (Caching aus). */
      cacheOff: boolean
      /** Zeilen der TODO.md beim Session-Start (nur offene To-dos). */
      todoSnapshot: string[]
      /** Anzahl offener To-dos nach dem letzten Lesen. */
      openTodos: number
      /** Ob gerade ein Wrap-up läuft und die To-do-Liste geschrieben wurde. */
      wrapup: { isRunning: boolean; hasWritten: boolean }
      /** Letzte Bilanz nach einem Wrap-up, null ohne. */
      bilanz: Bilanz | null
    }
  }
}
