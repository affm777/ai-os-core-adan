# Codex: ein zweiter Coding-Agent (Details)

Ergänzung zur [README](README.md) in diesem Ordner. Hier steht alles, was über die Schritt-für-Schritt-Anleitung hinausgeht.

## Inhalt

- [Überblick](#überblick)
- [Voraussetzungen](#voraussetzungen)
- [Installation: das tut Claude](#installation-das-tut-claude)
- [Anmelden (einmalig)](#anmelden-einmalig)
- [Erster Lauf](#erster-lauf)
- [Grenzen](#grenzen)

## Überblick

Codex ist der Coding-Agent von OpenAI. Mit diesem Werkzeug holt Claude ihn bei Bedarf dazu, ungefähr so, wie du einen Kollegen um eine zweite Meinung bittest. Claude bleibt dein Ansprechpartner, Codex arbeitet im Hintergrund zu. Angemeldet wird Codex über dein ChatGPT-Konto, einen API-Schlüssel brauchst du nicht.

Drei Skills kommen mit:

- `/codex-ask`: holt eine unabhängige Zweitmeinung zu Code oder Dateien im aktuellen Ordner. Codex liest nur und ändert nichts.
- `/codex`: gibt Codex einen Auftrag im aktuellen Projekt. Standard ist nur lesen, mit `write:` vor dem Auftrag darf Codex im aktuellen Ordner schreiben, danach zeigt Claude dir die Änderungen.
- `/codex-image`: erzeugt ein Bild über den Bildgenerator von Codex und legt es als PNG im aktuellen Ordner ab.

## Voraussetzungen

- Dein Setup ist installiert. Node.js und npm sind damit schon da.
- Ein ChatGPT-Konto mit Plus oder höher (Plus, Pro, Business, Enterprise oder Edu). Mit dem kostenlosen Konto klappt die Anmeldung, die Nutzung ist aber stark begrenzt.

## Installation: das tut Claude

Das tut Claude dann:

1. Holt mit `git -C ~/ai-os-core pull` den neuesten Stand deines Setup-Repos.
2. Installiert Codex in der aktuellsten Version mit `npm install -g @openai/codex@latest`. Ist Codex schon da, wird es damit auf den neuesten Stand gebracht.
3. Prüft mit `codex --version`, ob Codex gefunden wird.
4. Kopiert die drei Skills mit `bash ~/ai-os-core/claude/werkzeuge/codex/install.sh` nach `~/.claude/skills/`. Ältere Fassungen landen vorher in `~/.claude/backups/`, gelöscht wird nichts.
5. Prüft mit `codex login status`, ob du schon angemeldet bist. Wenn nicht, erklärt Claude dir die Anmeldung (nächster Abschnitt). Die Anmeldung machst du selbst, Claude gibt nie ein Passwort ein.

Starte danach eine neue Claude-Session, damit Claude die drei Skills kennt.

### Mac und Windows

Auf dem Mac läuft alles im Terminal. Unter Windows läuft es genauso in Git Bash, dort ist npm durch das Setup ebenfalls vorhanden. Meldet Windows nach der Installation `codex: command not found`, Git Bash einmal schließen und neu öffnen, damit der neue Befehl gefunden wird.

## Anmelden (einmalig)

Die Anmeldung braucht ein eigenes Terminalfenster, weil sich dabei der Browser öffnet. Öffne ein Terminal (Windows: Git Bash) und tippe:

```
codex login
```

Der Browser öffnet die Anmeldeseite von ChatGPT. Melde dich mit deinem ChatGPT-Konto an und bestätige den Zugriff. Danach steht im Terminal eine Erfolgsmeldung und du kannst das Fenster schließen. Öffnet sich kein Browser (zum Beispiel auf einem Rechner ohne Oberfläche), geht es mit `codex login --device-auth`. Dann zeigt das Terminal einen Code, den du auf der angezeigten Seite eingibst.

Ob es geklappt hat, prüft `codex login status`. Erwartet ist „Logged in using ChatGPT".

## Erster Lauf

Öffne Claude in einem beliebigen Projektordner und sag:

```
/codex-ask Was fällt dir an der Struktur dieses Ordners auf?
```

Claude fragt Codex, fasst die Antwort zusammen und sagt dir, wo Codex etwas anders sieht. Für ein Bild sag zum Beispiel `/codex-image ein ruhiges Büro mit Blick auf einen Park, Morgenlicht`.

## Grenzen

- Codex verbraucht das Kontingent deines ChatGPT-Abos. Ist es aufgebraucht, meldet Codex ein Limit und es geht erst nach der Wartezeit weiter.
- Codex arbeitet nur im aktuellen Ordner. Schreibrecht bekommt es nur mit `write:` vor dem Auftrag, Pushes und Installationen sind in den Skills ausgeschlossen.
- Die Skills schalten die Schutzschranken von Codex (Sandbox) nie ab.
- Unter Windows läuft Codex direkt in Git Bash. OpenAI entwickelt die Windows-Fassung noch aktiv weiter, in Einzelfällen hängt ein Aufruf. Dann hilft meist, Codex mit dem Installationsbefehl oben zu aktualisieren.
- Bilder entstehen über das ChatGPT-Abo, je Aufruf genau eines. Für Druck, Slides oder Social-Visuals ist der Skill designer da.
