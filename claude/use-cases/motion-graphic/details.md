# Ein Social-Media-Video aus deiner Beschreibung (Details)

Ergänzung zur [README](README.md) in diesem Ordner. Hier steht alles, was über die Schritt-für-Schritt-Anleitung hinausgeht.

## Inhalt

- [Überblick](#überblick)
- [Gut zu wissen](#gut-zu-wissen)
- [Voraussetzungen](#voraussetzungen)
- [Installation](#installation)
- [Erster Lauf](#erster-lauf)
- [Grenzen](#grenzen)
- [Nächste Ausbaustufe](#nächste-ausbaustufe)
- [Was im Bundle liegt](#was-im-bundle-liegt)

## Überblick

Mit diesem Use Case baut Claude ein kurzes animiertes Video (Motion Graphic) für Instagram, TikTok, LinkedIn oder eure Website. Du erzählst einfach, worum es gehen soll. Claude stellt ein paar gezielte Fragen, zeigt dir einen Ablaufplan (Storyboard) zum Abnicken, baut das Video, zeigt dir eine Vorschau und liefert nach deinem „passt“ die fertige Datei. Du siehst dabei keinen Code, nur Fragen, Tabellen und Videos.

## Gut zu wissen

- Der Skill wird einmal installiert und steht danach überall zur Verfügung, egal in welchem Ordner du gerade arbeitest. Du findest ihn danach auch im Dashboard unter Skills & Commands.

## Voraussetzungen

- Dein Setup ist installiert (Node ist damit schon da).
- ffmpeg, ein kleines Programm zum Verarbeiten von Videos. Fehlt es, sagt dir die Installation genau, was du eingeben musst (Mac `brew install ffmpeg`, Windows `winget install --id Gyan.FFmpeg -e`, danach Git Bash und Claude in einem neuen Fenster öffnen).
- Internet beim ersten Lauf. Die Installation lädt das Video-Werkzeug HyperFrames und einen Browser zum Rendern herunter (einmalig rund 250 MB inklusive der Python-Umgebung für Ton, etwa 5 bis 10 Minuten). Dabei kommen zehn HyperFrames-Skills mit, von denen motion-graphic vier nutzt. Die übrigen bleiben bewusst installiert, das ist in Ordnung.
- Für eine generierte Stimme oder Musik eine ElevenLabs-Anbindung. Ohne sie geht alles andere trotzdem, dann ohne Ton oder mit einer eigenen Audiodatei.

Zeitbedarf: Ein 15-Sekunden-Video dauert vom ersten Satz bis zur fertigen Datei etwa 20 bis 40 Minuten, das meiste davon arbeitet Claude allein. Das reine Rendern dauert nur wenige Minuten.

## Installation

Fehlt etwas (zum Beispiel ffmpeg), nennt dir Claude die eine Zeile, die du eingeben musst. Danach das Installationsskript einfach noch einmal laufen lassen. Starte am Ende eine neue Session, damit Claude den neuen Skill kennt.

## Erster Lauf

Öffne Claude in dem Ordner, in dem eure Videos liegen sollen (zum Beispiel ein Marketing-Ordner). Sag Claude:

```
Ich möchte ein kurzes Video für Instagram machen.
```

Das passiert dann:

1. Claude bittet dich, frei zu erzählen, worum es geht, für wen und ob du schon eine Idee für die Abfolge hast. Danach fasst Claude in drei Sätzen zusammen, was es verstanden hat.
2. Eine Fragerunde mit vier Klicks: Kanal und Format, Länge (etwa 15, 30 oder 60 Sekunden), Stimme, Musik.
3. Eine Runde zum Look. Für welche Marke ist das Video (ADAN e.V., ADAN Impact oder ADAN Careers)? Gibt es einen Style-Guide, ein Logo oder Farben? Gibt es Videos, Bilder oder Links, die dir gefallen? Ohne Vorbilder schlägt Claude zwei passende Stile vor und du wählst.
4. Du bekommst das Storyboard als Tabelle (Szene, Text, Bildidee, Bewegung, Sekunden) und sagst „passt“ oder was anders sein soll.
5. Claude baut das Video allein, prüft es selbst und öffnet dir die Vorschau.
6. Du sagst, was geändert werden soll, oder „passt“. Jede Änderung wird eine neue Fassung, die alte bleibt liegen.
7. Claude erstellt die Endfassung, öffnet sie und nennt dir, wo sie liegt.

Alles zu einem Video liegt im Ordner `videos/<name-des-videos>/`, die fertige Datei unter `final/`. Eure Markenangaben merkt sich Claude unter `brand/<marke>/`, beim nächsten Video musst du sie nicht noch einmal nennen.

Ist ein Video nicht fertig geworden, sag beim nächsten Mal einfach „Mach mit dem Video weiter“. Claude findet die Stelle, an der ihr aufgehört habt.

## Grenzen

- Claude verwendet nur, was du erzählst oder lieferst. Zahlen, Namen, Termine oder Webadressen werden nie erfunden.
- Vorbilder liefern nur Look und Bewegung. Fremde Logos, Bilder oder Texte kommen nicht ins Video.
- Eine generierte Stimme oder Musik kostet ElevenLabs-Credits. Claude nennt die Schätzung vorher und fragt.
- Gedacht für kurze Social-Media-Videos bis etwa 60 Sekunden, nicht für lange Filme oder Videos mit gefilmten Personen.

## Nächste Ausbaustufe

- Mehrere Varianten eines Videos parallel zur Auswahl.
- Eigene Lieblingsvideos als neue Stilvorlage im Skill speichern.
- Webfassungen mit Vorschaubild zum Einbau auf der Website.

## Was im Bundle liegt

```
motion-graphic/
├── README.md                          ← diese Anleitung
├── details.md                         ← Details und Beispiele zur Anleitung
├── install.sh                         ← Installation und Prüfung (Mac und Windows)
└── skills/
    └── motion-graphic/
        ├── SKILL.md                   ← die Arbeitsanleitung für Claude
        ├── VERSION                    ← feste Version des Video-Werkzeugs HyperFrames
        ├── references/                ← Storyboard-Vorlage, Qualitätsregeln, Animationstechniken, Ton
        ├── muster/                    ← fünf Stilvorlagen mit Übersicht
        ├── scripts/                   ← Hilfsprogramme (Werkzeug-Prüfung, Kontaktbogen, Ton-Mastering, Öffnen)
        └── .venv/                     ← entsteht bei der Installation, für Stimme und Musik
```
