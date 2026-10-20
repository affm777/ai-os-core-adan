---
name: codex-ask
description: Holt eine unabhängige Zweitmeinung von OpenAI Codex (GPT-Modell) zu Code oder Dateien im aktuellen Ordner, streng read-only (Codex darf nichts ändern). Für "was sagt ein zweites Modell dazu". Triggert bei "/codex-ask", "frag codex", "zweitmeinung von codex", "was sagt codex".
when_to_use: |
  Argument = die Frage/der Prompt. Read-only, Codex analysiert nur. Trigger-Phrasen: "/codex-ask", "frag codex", "zweitmeinung von codex", "was sagt codex". NICHT triggern, wenn der Nutzer die Frage an Claude selbst richtet, nur wenn explizit eine Codex/GPT-Zweitmeinung gewünscht ist.
allowed-tools: Bash(codex:*), Read
---

# Codex Ask

Du holst über die Codex CLI (angemeldet über ChatGPT-Konto, kein API-Key) eine unabhängige Zweitmeinung eines GPT-Modells zu Code oder Dateien im aktuellen Ordner. Strikt read-only, Codex darf nichts ändern. Der Ordner muss kein Git-Repo sein.

## Ablauf

0. **Codex vorhanden?** `codex --version`. Fehlt der Befehl, dem Nutzer sagen, dass das Werkzeug codex noch nicht installiert ist (Anleitung `~/ai-os-core/claude/werkzeuge/codex/README.md`). Dann stoppen. Fehlt die Anmeldung, den Nutzer bitten, in einem eigenen Terminal `codex login` auszuführen. Nie selbst anmelden.

1. **Frage bestimmen.** Die Frage oder den Prompt aus dem Argument nehmen. Fehlt sie, kurz nachfragen.

2. **Codex read-only aufrufen:**
   ```bash
   codex exec --skip-git-repo-check -s read-only "<frage>. Nur analysieren und antworten, nichts ändern." < /dev/null
   ```

3. **Antwort aufbereiten.** Die Codex-Antwort prägnant für den Nutzer zusammenfassen, nicht die Rohausgabe 1:1 dumpen. Kernaussage, dann relevante Punkte, dann wo Codex von deiner eigenen Einschätzung abweicht.

## Guards

- Immer `-s read-only`, kein Schreibzugriff.
- NIE `--dangerously-bypass-approvals-and-sandbox`.
- `codex exec` IMMER mit `< /dev/null` aufrufen, sonst wartet Codex auf stdin und hängt still.
- Läuft unter macOS (Terminal) und Windows (Git Bash) mit denselben Befehlen.
