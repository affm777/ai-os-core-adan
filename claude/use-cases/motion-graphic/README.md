# Ein Social-Media-Video aus deiner Beschreibung

Claude baut aus deiner Beschreibung ein kurzes animiertes Video (Motion Graphic) für Instagram, TikTok, LinkedIn oder eure Website. Du nickst Storyboard und Vorschau ab und bekommst eine fertige MP4-Datei, Code siehst du dabei nicht.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

```
Du                           Claude                          Ergebnis
──                           ──────                          ────────
erzählst frei, worum      →  fragt Format, Länge, Ton,    →  fertige MP4-Datei
es gehen soll                Marke und Vorbilder ab,         in 9:16 (Reel) und auf
                             zeigt Storyboard und            Wunsch 16:9, alte
                             Vorschau zur Freigabe           Fassungen bleiben liegen
```

## Das brauchst du

- Dein Setup ist installiert (Node ist damit schon da).
- Das Werkzeug ffmpeg (`claude/werkzeuge/ffmpeg/`). Unter Windows öffnest du danach Git Bash und Claude neu, mehr in [details.md](details.md).
- Internet beim ersten Lauf. Die Installation lädt einmalig rund 250 MB.
- Optional eine ElevenLabs-Anbindung für Stimme oder Musik. Soundeffekte und Beat gehen auch ohne, kostenlos.

## Schritt 1: Installieren

Sag Claude:
```
Hol zuerst mit git pull den neuesten Stand meines Setup-Repos ~/ai-os-core.

Führe dann das Installationsskript des Use-Case-Bundles "motion-graphic" aus:
bash ~/ai-os-core/claude/use-cases/motion-graphic/install.sh

Zeig mir danach in einfachen Worten, ob alles geklappt hat oder was mir noch fehlt.
```

Starte danach eine neue Session, damit Claude den neuen Skill kennt.

## Schritt 2: Erster Lauf

Öffne Claude in dem Ordner, in dem eure Videos liegen sollen. Sag Claude:
```
Ich möchte ein kurzes Video für Instagram machen.
```

Claude fragt dich dann:
- worum es geht, für wen und ob du schon eine Idee für die Abfolge hast
- nach Kanal und Format, Länge, Stimme, Musik und Effekten
- für welche Marke das Video ist und ob es Vorbilder gibt, die dir gefallen
- ob Storyboard und Vorschau passen

## Schritt 3: So nutzt du es

**Ändern.** Nach jeder Vorschau sagst du, was anders sein soll. Jede Änderung wird eine neue Fassung, die alte bleibt liegen.
```
Die zweite Szene soll ruhiger sein.
```

**Freigeben.** Passt die Vorschau, erstellt Claude die Endfassung und nennt dir, wo sie liegt.
```
Passt, mach die Endfassung.
```

**Weitermachen.** Ist ein Video nicht fertig geworden, findet Claude die Stelle, an der ihr aufgehört habt.
```
Mach mit dem Video weiter.
```

## Das kommt dabei heraus

- `videos/<name-des-videos>/` mit allem zu einem Video, alte Fassungen bleiben liegen
- `videos/<name-des-videos>/final/` mit der fertigen MP4-Datei
- `brand/<marke>/` mit euren Markenangaben, beim nächsten Video musst du sie nicht noch einmal nennen

## Grenzen

- Claude verwendet nur, was du erzählst oder lieferst. Zahlen, Namen, Termine oder Webadressen werden nie erfunden.
- Vorbilder liefern nur Look und Bewegung. Fremde Logos, Bilder oder Texte kommen nicht ins Video.
- Eine generierte Stimme oder Musik kostet ElevenLabs-Credits. Claude nennt die Schätzung vorher und fragt.
- Gedacht für kurze Social-Media-Videos bis etwa 60 Sekunden, nicht für lange Filme oder gefilmte Personen.

## Mehr dazu

Zeitbedarf, die Voraussetzungen in Langform, Windows-Hinweise und der genaue Ablauf stehen in [details.md](details.md).
