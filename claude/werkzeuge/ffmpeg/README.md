# ffmpeg: Videos und Ton verarbeiten

ffmpeg ist ein kleines, kostenloses Programm, mit dem Claude Videos und Tonspuren zuschneiden, umwandeln, zusammensetzen und prüfen kann. Du siehst davon nichts, Claude nutzt es im Hintergrund. Der Use Case motion-graphic braucht ffmpeg zwingend, es hilft aber bei jeder Arbeit mit Video und Audio, zum Beispiel wenn du ein Video verkleinern, einen Ausschnitt herausschneiden oder aus einem Video die Tonspur holen willst.

## Voraussetzungen

- Dein Setup ist installiert. Auf dem Mac ist Homebrew damit vorhanden, unter Windows ist winget Teil von Windows 11.

## Installieren

Sag Claude:

```
Installiere mir das Werkzeug ffmpeg aus meinem Setup-Repo ~/ai-os-core, in der aktuellsten Version.
Lies dafür zuerst ~/ai-os-core/claude/werkzeuge/ffmpeg/README.md und halte dich an die Schritte dort.
Sag mir am Ende in einfachen Worten, ob alles geklappt hat.
```

Das tut Claude dann:

1. Installiert ffmpeg in der aktuellsten Version. Auf dem Mac mit `brew install ffmpeg` (ist es schon da, bringt `brew upgrade ffmpeg` es auf den neuesten Stand). Unter Windows mit `winget install --id Gyan.FFmpeg -e --accept-source-agreements --accept-package-agreements` (ist es schon da, `winget upgrade --id Gyan.FFmpeg -e`).
2. Unter Windows bittet Claude dich danach, Git Bash und Claude einmal zu schließen und neu zu öffnen. Erst dann ist der neue Befehl bekannt.
3. Prüft mit `ffmpeg -version` und `ffprobe -version`, ob beide Teile gefunden werden. Danach nennt Claude dir die installierte Version.

## Grenzen

- ffmpeg arbeitet nur mit Dateien auf deinem Rechner, nicht mit Videos direkt aus dem Netz oder aus Cloud-Ordnern, die nicht heruntergeladen sind.
- Lange oder hochauflösende Videos brauchen Zeit und Speicherplatz. Ein paar Minuten Rechenzeit sind normal.
- Die Installation unter Windows braucht einmal einen Neustart von Git Bash. Wird `ffmpeg` danach immer noch nicht gefunden, gehört `$LOCALAPPDATA/Microsoft/WinGet/Links` in den PATH (Claude prüft das mit `ls "$LOCALAPPDATA/Microsoft/WinGet/Links"`), sonst hilft ein Neustart des Rechners.
- Zuschnitte und Umwandlungen ändern die Qualität. Claude legt deshalb immer eine neue Datei an und lässt das Original unverändert.
