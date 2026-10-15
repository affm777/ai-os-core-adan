# Mod „Session-Assistent"

Claude-Code-Mod (Plugin mit Funktions-Hooks), gebaut gegen Claude Code 2.1.295. Nimmt Nicht-Technikern das Merken von Befehlen ab.

## Was er zeigt

- Kontext-Hinweis über dem Prompt ab 60 Prozent Füllstand (dezent) und ab 75 Prozent (hervorgehoben), mit Knöpfen „Wrap-up" und „Später". Der Hinweis ersetzt die Knopfzeile, „Später" blendet ihn bis zur nächsten Schwelle aus. Rechts im Band steht immer die Kontext-Batterie, etwa „▰▰▱▱▱▱▱▱ 23 % · 230k / 1M“, gerechnet gegen das volle Modellfenster, nicht gegen die Kompaktierungsgrenze (grün, ab 60 Prozent orange, ab 75 Prozent rot). Seit dem 15.10. wieder im Band, weil die Desktop-App das Kontextfenster nicht mehr im Nutzungs-Popover zeigt.
- Optional (Option `showCache`, Standard aus) eine Cache-Restzeit, etwa „Cache 42 min", bis der Prompt-Cache abläuft, danach „Cache kalt". Standard aus, weil der Wert in der Desktop-App nur eine Schätzung ist. Quelle ist die Brücken-Datei `~/.claude/prompt-cache/<session-id>.json`, die das Statuszeilen-Skript `aios-statusline.js` aus dem Objekt `prompt_cache` schreibt (echte TTL und Ablaufzeit von Claude Code, ab 2.1.251, auch nach dem Wechsel auf 5 Minuten bei Extra Usage). Fehlt die Datei, zählt der Mod selbst ab der letzten Modell-Anfrage mit der Option `cacheTtl` (`1h` Standard, `5m`), ein Modellwechsel korrigiert die TTL aus dem Hook-Ereignis. Kamen in einem Turn keine Cache-Tokens, steht dort „Cache aus".
- To-do-Bilanz nach dem Wrap-up: „N erledigt · N überarbeitet · N neu", Vergleich der To-do-Liste gegen den Stand beim Session-Start.
- Zahl offener To-dos im Band neben den Knöpfen (`- [ ]` in `.planning/TODO.md`, Fallback `TODO.md` in der Projektwurzel). Nicht in der Statuszeile, weil Claude Code dort den Mod-Namen als Label vorsetzt.
- Knöpfe „Wrap-up", „Dashboard", „Meetings holen" und „Eingang sortieren" (starten `wrap-up`, `aios-dashboard`, `brain:sync-meetings` und `brain:sort-inbox`).

Kein Netzwerk, keine Connectoren, kein Zugriff auf das Second Brain.

## Laden

Standardweg (Teilnehmer): `bootstrap.sh` kopiert den Ordner nach `~/.claude/skills/session-assistent/`. Claude Code lädt jeden Ordner dort, der eine `.claude-plugin/plugin.json` trägt, in jeder Session als Plugin, ohne Eintrag in `settings.json`, ohne Marketplace, auf Mac und Windows gleich. Abschalten mit `claude plugin disable session-assistent@skills-dir` oder durch Löschen des Ordners.

Entwicklung: im `env`-Block von `~/.claude/settings.json` den Repo-Ordner nennen, dann überspringt der Bootstrap die Kopie (sonst liefe jeder Hook doppelt).

```json
"env": { "CLAUDE_CODE_PLUGIN_DIRS": "/absoluter/pfad/zu/claude/mods/session-assistent" }
```

Wirkt ab der nächsten neuen Session, im Terminal und im Desktop-Code-Tab, nicht unter WSL. Mehrere Ordner mit dem Pfadtrenner des Systems trennen (macOS `:`, Windows `;`).

Alternative ohne Bootstrap: Marketplace-Datei neben `plugin.json` und `/plugin install session-assistent@<marketplace>` im Terminal (im Code-Tab nicht verfügbar).

## Prüfen

```bash
claude plugin validate claude/mods/session-assistent
claude plugin test claude/mods/session-assistent
```

Der Ordner `.claude-plugin/types/` und `tsconfig.json` werden beim Laden vom Engine-Lader erzeugt und sind nicht versioniert.

## Grenzen

- Die Mod-API ist „early access" und ändert sich zwischen Releases. Nach einem Claude-Code-Update `validate` und `test` wiederholen.
- Mods laufen ohne Sandbox mit vollen Nutzerrechten. Abschalten per `--safe-mode` oder `disableAllHooks`.
