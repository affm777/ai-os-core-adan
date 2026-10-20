---
name: codex-image
description: Generiert ein Bild über Codex' internen $imagegen-Skill (Bildmodell von OpenAI, läuft über das ChatGPT-Abo, kein API-Key), legt die PNG im Arbeitsordner ab und öffnet sie. Triggert bei "/codex-image", "codex bild", "bild mit codex generieren", "codex imagegen".
when_to_use: |
  Argument = Bildbeschreibung, optional Zieldateiname/Format. Default 16:9, Ablage im aktuellen Arbeitsverzeichnis. Trigger-Phrasen: "/codex-image", "codex bild", "bild mit codex generieren", "codex imagegen". NICHT für Print/PDF/Slide/Social-Visuals (das ist der designer-Skill) und NICHT für Web-UI.
allowed-tools: Bash(codex:*), Bash(open:*), Bash(start:*), Bash(ls:*), Bash(od:*), Bash(uname:*), Read
---

# Codex Image

Du erzeugst genau EIN Bild über den in Codex eingebauten `$imagegen`-Skill. Der Aufruf läuft über die installierte Codex CLI, angemeldet über das ChatGPT-Konto, kein API-Key nötig. Das Bild landet im aktuellen Arbeitsverzeichnis.

## Ablauf

0. **Codex vorhanden?** `codex --version`. Fehlt der Befehl, dem Nutzer sagen, dass das Werkzeug codex noch nicht installiert ist (Anleitung `~/ai-os-core/claude/werkzeuge/codex/README.md`). Dann stoppen. Fehlt die Anmeldung, den Nutzer bitten, in einem eigenen Terminal `codex login` auszuführen. Nie selbst anmelden.

1. **Bildwunsch bestimmen.** Motiv aus dem Argument nehmen. Fehlt es, kurz nachfragen (ein Satz), was abgebildet werden soll.

2. **Zieldateinamen festlegen.** Wenn der Nutzer einen Dateinamen nennt, diesen verwenden. Sonst aus dem Thema einen ASCII-Slug bilden, z.B. `<thema>.png`, abgelegt im aktuellen Ordner. Default-Seitenverhältnis 16:9, sofern nichts anderes gewünscht.

3. **Codex aufrufen.** `$imagegen` MUSS in doppelten Anführungszeichen mit Backslash escaped werden, sonst expandiert die Shell die Variable weg:
   ```bash
   codex exec --skip-git-repo-check -s workspace-write "Nutze deinen eingebauten \$imagegen-Skill. Erzeuge GENAU EIN Bild im Format 16:9. Motiv: <bildwunsch>. Speichere die Datei als '<datei>' im aktuellen Arbeitsverzeichnis. Führe KEINE weiteren Aktionen aus: keine Git-Operationen, keine Installationen, keine anderen Dateien anfassen." < /dev/null
   ```

4. **Prüfen.** Kontrollieren, dass die Datei erzeugt wurde und ein PNG ist (die ersten vier Bytes eines PNG sind `89 50 4e 47`, der Weg über `od` läuft auf Mac und in Git Bash gleich):
   ```bash
   ls -la "<datei>"
   od -An -tx1 -N4 "<datei>"
   ```
   Zeigt `od` nicht `89 50 4e 47`, dem Nutzer den Fehler zeigen und stoppen.

5. **Öffnen und anzeigen.** Auf dem Mac `open "<datei>"`, unter Windows (Git Bash, `uname -s` beginnt mit `MINGW` oder `MSYS`) `start "" "<datei>"`. Danach die Datei via Read dem Nutzer anzeigen.

6. **Kurzbestätigung** mit dem vollständigen Pfad der abgelegten PNG.

## Guards

- Immer nur `-s workspace-write`, NIE `--dangerously-bypass-approvals-and-sandbox`.
- `codex exec` IMMER mit `< /dev/null` aufrufen, sonst wartet Codex auf stdin und hängt still.
- Genau EIN Bild pro Aufruf.
- Kein Text im Bild, sofern nicht ausdrücklich gewünscht.
