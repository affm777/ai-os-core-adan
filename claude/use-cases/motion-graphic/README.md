# Ein Social-Media-Video aus deiner Beschreibung

Claude baut aus deiner Beschreibung ein kurzes animiertes Video (Motion Graphic) für Instagram, TikTok, LinkedIn oder eure Website. Du nickst Storyboard und Vorschau ab und bekommst eine fertige MP4-Datei, Code siehst du dabei nicht. Claude postet und veröffentlicht nichts.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

## Installieren

Sag Claude:
```
Installier mir den Use Case motion-graphic: hol mit git pull den neuesten Stand von ~/ai-os-core, führ bash ~/ai-os-core/claude/use-cases/motion-graphic/install.sh aus, installier Fehlendes mit den Befehlen, die das Skript nennt, und sag mir in einfachen Worten, ob alles geklappt hat.
```

Fehlt unter Windows ffmpeg, gibst du `winget install --id Gyan.FFmpeg -e` selbst ein und öffnest danach Git Bash und Claude neu (Hilfe unter `claude/werkzeuge/ffmpeg/`).

Danach eine neue Session starten, damit Claude den Skill kennt.

## Loslegen

Öffne Claude in dem Ordner, in dem eure Videos liegen sollen. Sag Claude:
```
Ich möchte ein kurzes Video für Instagram machen.
```

Claude fragt alles Weitere selbst. Danach steuerst du mit einem Satz:

```
Die zweite Szene soll ruhiger sein.
Passt, mach die Endfassung.
Mach mit dem Video weiter.
```

Alles zu einem Video landet in `videos/<name-des-videos>/`, die fertige MP4-Datei unter `final/`, eure Markenangaben unter `brand/<marke>/`.

## Grenzen

- Claude verwendet nur, was du erzählst oder lieferst. Zahlen, Namen, Termine oder Webadressen werden nie erfunden, fremde Logos, Bilder oder Texte kommen nicht ins Video.
- Eine generierte Stimme oder Musik kostet ElevenLabs-Credits. Claude nennt die Schätzung vorher und fragt.
- Gedacht für kurze Social-Media-Videos bis etwa 60 Sekunden, nicht für lange Filme oder gefilmte Personen.

Zeitbedarf, Voraussetzungen (Internet und rund 250 MB beim ersten Lauf, ElevenLabs optional), Windows-Hinweise und der genaue Ablauf stehen in [details.md](details.md).
