# Codex: Installationsanleitung für Claude

Ergänzung zur [README](README.md). Diese Datei richtet sich an Claude, der Nutzer muss sie nicht lesen. Antworte dem Nutzer in einfachen Worten, ohne Fachbegriffe wie Sandbox, npm oder PATH.

## Installation

1. `git -C ~/ai-os-core pull` (fehlt `~/ai-os-core`: `git clone https://github.com/affm777/ai-os-core-adan.git ~/ai-os-core`).
2. `npm install -g @openai/codex@latest` installiert oder aktualisiert Codex.
3. `codex --version` prüfen. Unter Windows nach `codex: command not found` den Nutzer bitten, Git Bash bzw. Claude neu zu starten, dann erneut prüfen.
4. `bash ~/ai-os-core/claude/werkzeuge/codex/install.sh` kopiert die Skills `codex`, `codex-ask` und `codex-image` nach `~/.claude/skills/`. Ältere Fassungen landen in `~/.claude/backups/`, gelöscht wird nichts.
5. `codex login status` prüfen. Erwartet ist „Logged in using ChatGPT“. Sonst den Nutzer bitten, einmalig selbst im Terminal (Windows: Git Bash) `codex login` auszuführen und sich im Browser anzumelden. Öffnet sich kein Browser, geht es mit `codex login --device-auth` (Code auf der angezeigten Seite eingeben). Nie selbst anmelden, nie ein Passwort eingeben.
6. Dem Nutzer sagen, dass er eine neue Session starten soll, damit die Skills geladen werden.

## Skills

- `codex-image`: genau ein Bild über den Bildgenerator von Codex, als PNG im aktuellen Ordner.
- `codex`: Auftrag an Codex im aktuellen Ordner, etwa einen Text überarbeiten. Standard nur lesen, Schreibrecht nur mit `write:` vor dem Auftrag.
- `codex-ask`: Zweitmeinung, Codex liest nur.

## Grenzen

- Nutzung läuft über das Kontingent des ChatGPT-Abos. Bei Limit-Meldung dem Nutzer sagen, dass es nach der Wartezeit weitergeht.
- Die Skills schalten die Schutzschranken von Codex nie ab, keine Pushes, keine Installationen aus einem Auftrag heraus.
- Windows: Codex läuft in Git Bash. Hängt ein Aufruf, zuerst Codex mit Schritt 2 aktualisieren.
- Für Druck, Slide-Decks oder fertige Social-Visuals ist der Skill `designer` zuständig, `codex-image` liefert nur das einzelne Bild.
