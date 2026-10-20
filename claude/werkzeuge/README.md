# Werkzeuge

Ein Werkzeug ist ein Programm oder eine Anbindung, die Claude neue Fähigkeiten gibt oder die mehrere Use Cases brauchen. Use-Case-Bundles (`claude/use-cases/`) sind fertige Aufgabenpakete, Werkzeuge liegen eine Ebene darunter. Ein Beispiel: Das Videowerkzeug ffmpeg braucht der Use Case motion-graphic, es hilft aber auch bei jeder anderen Arbeit mit Videos.

## Welche Werkzeuge es gibt

- `codex`: holt OpenAI Codex als zweiten Coding-Agenten dazu, für Zweitmeinungen, Aufgaben im Projekt und Bilder, angemeldet über dein ChatGPT-Konto.
- `google-workspace-cli`: lässt Claude direkt in Gmail, Kalender, Drive, Docs und Sheets arbeiten.
- `ffmpeg`: verarbeitet Videos und Ton, Voraussetzung für den Use Case motion-graphic.

## So installierst du ein Werkzeug

Jeder Werkzeug-Ordner hat eine eigene `README.md` mit Voraussetzungen, Grenzen und einem Kasten „Sag Claude:". Den Kasten kopierst du in den Chat von Claude und schickst ihn ab. Claude installiert das Werkzeug dann selbst in der aktuellsten Version, prüft es und sagt dir in einfachen Worten, ob es geklappt hat.

Der allgemeine Satz dafür lautet so, `<name>` ersetzt du durch den Ordnernamen:

```
Installiere mir das Werkzeug <name> aus meinem Setup-Repo ~/ai-os-core, in der aktuellsten Version.
Lies dafür zuerst ~/ai-os-core/claude/werkzeuge/<name>/README.md und halte dich an die Schritte dort.
```

Die Werkzeuge kommen mit dem Setup-Repo mit, der Bootstrap installiert sie aber **nicht automatisch**. Du holst dir nur, was du wirklich brauchst. Bringt ein Werkzeug eigene Skills mit (`skills/`), kopiert die Installation sie nach `~/.claude/skills/`. Starte danach eine neue Claude-Session, damit Claude die neuen Skills kennt.

## Aktuell halten

Werkzeuge entwickeln sich schnell weiter. Sag Claude ab und zu „Bring meine Werkzeuge auf den neuesten Stand". Claude aktualisiert dann jedes installierte Werkzeug mit demselben Weg wie bei der Installation (auf dem Mac über Homebrew oder npm, unter Windows über winget oder npm).
