# ffmpeg: Videos und Ton verarbeiten

ffmpeg ist ein kleines, kostenloses Programm, mit dem Claude Videos und Tonspuren zuschneiden, umwandeln und prüfen kann. Der Use Case motion-graphic braucht es zwingend.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

## Das brauchst du

- Dein Setup ist installiert. Auf dem Mac ist Homebrew damit vorhanden, unter Windows ist winget Teil von Windows 11.

## Schritt 1: Installieren

Sag Claude:
```
Installiere mir das Werkzeug ffmpeg aus meinem Setup-Repo ~/ai-os-core, in der aktuellsten Version.
Lies dafür zuerst ~/ai-os-core/claude/werkzeuge/ffmpeg/details.md und halte dich an die Schritte dort.
Sag mir am Ende in einfachen Worten, ob alles geklappt hat.
```

Unter Windows schließt du danach Git Bash und Claude einmal und öffnest beide neu, mehr in [details.md](details.md).

## Schritt 2: Erster Lauf

Sag Claude:
```
Prüf, ob ffmpeg funktioniert. Nenn mir die installierte Version.
```

## Schritt 3: So nutzt du es

**Verkleinern.** Zieh das Video ins Fenster und sag Claude:
```
Mach dieses Video kleiner, damit ich es per Mail verschicken kann.
```

**Ausschnitt.** Claude schneidet einen Teil heraus.
```
Schneide aus diesem Video die Sekunden 10 bis 25 heraus.
```

**Tonspur.** Claude holt den Ton aus einem Video.
```
Hol aus diesem Video die Tonspur als MP3.
```

## Das kommt dabei heraus

- Eine neue Datei neben dem Original. Das Original bleibt unverändert.

## Grenzen

- ffmpeg arbeitet nur mit Dateien auf deinem Rechner, nicht mit Videos aus dem Netz.
- Lange oder hochauflösende Videos brauchen ein paar Minuten Rechenzeit.

## Mehr dazu

Die Installationsschritte für Claude und alle Grenzen stehen in [details.md](details.md).
