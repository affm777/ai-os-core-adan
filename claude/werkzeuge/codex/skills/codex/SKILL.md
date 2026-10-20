---
name: codex
description: Gibt OpenAI Codex einen allgemeinen Auftrag im aktuellen Projekt (zweiter Coding-Agent, GPT-Modell). Standard read-only; nur mit Prefix "write:" im Argument darf Codex im Arbeitsordner schreiben (workspace-write). Triggert bei "/codex", "codex mach", "lass codex".
when_to_use: |
  Argument = der Auftrag. Ohne "write:"-Prefix strikt read-only (Analyse/Vorschlag). Mit führendem "write:" bekommt Codex Schreibrecht im aktuellen Ordner (workspace-write), danach werden die Änderungen gezeigt. Trigger-Phrasen: "/codex", "codex mach", "lass codex". NICHT triggern bei normalen Coding-Bitten an Claude selbst, nur wenn explizit an Codex delegiert werden soll.
allowed-tools: Bash(codex:*), Bash(git:*), Bash(ls:*), Bash(find:*), Read
---

# Codex

Du delegierst einen allgemeinen Auftrag an Codex (CLI, angemeldet über ChatGPT-Konto, kein API-Key) als zweiten Coding-Agenten im aktuellen Projekt. Standard ist read-only. Schreibrecht bekommt Codex nur bei explizitem "write:"-Prefix im Argument. Codex arbeitet im aktuellen Arbeitsordner, der Ordner muss kein Git-Repo sein.

## Ablauf

0. **Codex vorhanden?** `codex --version`. Fehlt der Befehl, dem Nutzer sagen, dass das Werkzeug codex noch nicht installiert ist (Anleitung `~/ai-os-core/claude/werkzeuge/codex/README.md`). Dann stoppen. Meldet ein Aufruf, dass keine Anmeldung besteht, den Nutzer bitten, in einem eigenen Terminal `codex login` auszuführen. Nie selbst anmelden.

1. **Auftrag und Modus bestimmen.** Beginnt das Argument mit `write:`, gilt der Schreibmodus. Sonst read-only.

2. **Read-only-Modus (Default):**
   ```bash
   codex exec --skip-git-repo-check -s read-only "<auftrag>" < /dev/null
   ```

3. **Write-Modus (nur bei "write:"-Prefix):** Zuerst dem Nutzer sagen, dass Codex jetzt Schreibrecht im aktuellen Ordner bekommt. Dann (Prefix "write:" aus dem Auftrag entfernen):
   ```bash
   codex exec --skip-git-repo-check -s workspace-write "<auftrag ohne write:-Prefix>. Keine Git-Pushes, keine Installationen außerhalb des Auftrags." < /dev/null
   ```
   Danach zeigen, was sich geändert hat. Im Git-Repo:
   ```bash
   git status --porcelain
   git diff --stat
   ```
   Ohne Git-Repo vorher und nachher `find . -newer <marker> -type f` beziehungsweise `ls -lt | head` nutzen und die geänderten Dateien nennen.

4. **Ergebnis zusammenfassen.** Prägnant, was Codex getan oder vorgeschlagen hat.

## Guards

- NIE `--dangerously-bypass-approvals-and-sandbox`.
- `codex exec` IMMER mit `< /dev/null` aufrufen. Ohne Umleitung wartet Codex auf stdin („Reading additional input from stdin...") und hängt still, besonders wenn der Aufruf in den Hintergrund wandert.
- Schreibmodus NUR bei explizitem "write:"-Prefix, sonst strikt read-only.
- Nach Writes immer die Änderungen zeigen.
- Keine Pushes.
- Läuft unter macOS (Terminal) und Windows (Git Bash) mit denselben Befehlen.
