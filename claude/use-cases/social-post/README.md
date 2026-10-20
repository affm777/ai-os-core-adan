# Ein Kerntext, fertige Social-Visuals im ADAN-Look

Mit diesem Use Case machst du aus einer Headline und ein paar Sätzen fertige Bilder für Instagram und LinkedIn, im Look von ADAN e.V., ADAN Impact oder ADAN Careers. Du sagst Claude, was draufstehen soll, welche Marke und welches Format. Claude baut daraus eine Vorschau und du sagst, was anders sein soll. Am Ende liegen die PNG-Dateien in Originalgröße in deinem Ordner. Code siehst du dabei nicht. Claude postet nichts, das Veröffentlichen machst du selbst.

```
Vorher                                   Nachher
──────                                   ───────
Text in Figma oder Canva in eine      →  Text in den Chat, Marke und Format
Vorlage tippen, Größe je Format          anklicken, Vorschau ansehen, sagen
anpassen, Farben und Logo prüfen,        was anders sein soll. Fertige PNGs
für jede Sprache und jedes Format        für jedes Format und jede Sprache
von vorn                                 liegen unter social/ausgabe/
```

## Konventionen in dieser Anleitung

- Steht hier **„Sag Claude:"**, kopierst du den grauen Kasten darunter in die Chateingabe von Claude und schickst ihn ab.
- Du kannst Claude auf Deutsch oder auf Englisch ansprechen. Claude antwortet in deiner Sprache, die Sprache des Posts wählst du getrennt.
- Der Skill wird einmal installiert und steht danach überall zur Verfügung, egal in welchem Ordner du gerade arbeitest. Du findest ihn danach auch im Dashboard unter Skills & Commands.

## Was du bekommst

| Format | Größe in Pixeln |
|---|---|
| Instagram-Post 1:1 | 1080 x 1080 |
| Instagram 4:5 | 1080 x 1350 |
| Story 9:16 | 1080 x 1920 |
| LinkedIn 1:1 | 1200 x 1200 |
| Karussell (3 bis 5 Seiten) | je Seite 1080 x 1080 |

Drei Vorlagen stehen bereit:

- **Statement:** große Headline auf der Markenfarbe, kleine Zeile darüber (Kicker), Logo unten.
- **Info:** Headline, drei nummerierte Stichpunkte und ein Handlungsaufruf (Call-to-Action) auf Weiß.
- **Karussell:** Titelseite auf Markenfarbe, ein bis drei Inhaltsseiten mit Seitenzahl und eine Abschlussseite mit Handlungsaufruf.

Zu langer Text wird automatisch etwas kleiner gesetzt. Passt er trotzdem nicht, schlägt Claude eine Kürzung vor.

## Voraussetzungen

- Dein Setup ist installiert. Playwright (der Browser, mit dem Claude die Bilder erzeugt) und Python sind darin schon enthalten.
- Google Chrome, damit Playwright die Bilder erzeugen kann. `install.sh` prüft das und nennt den Befehl zum Nachladen.
- Kein Internet beim Erzeugen der Bilder. Die Markenschrift Rubik liegt im Bundle.
- Unter Windows läuft alles in Git Bash aus deinem Setup. Claude nimmt dort automatisch `python` oder `py -3` statt `python3` und öffnet die Vorschau im Explorer (Pfade mit Backslashes). Fehlt der Browser zum Erzeugen der Bilder, lädt Claude ihn nach deinem Okay nach (gut 100 MB).

Zeitbedarf: Ein Post von der ersten Frage bis zur Vorschau dauert rund zwei Minuten, jede Änderungsrunde rund eine Minute.

## Schritt 1: Installieren

Sag Claude:

```
Hol zuerst mit git pull den neuesten Stand meines Setup-Repos ~/ai-os-core.

Führe dann das Installationsskript des Use-Case-Bundles "social-post" aus:
bash ~/ai-os-core/claude/use-cases/social-post/install.sh

Zeig mir danach in einfachen Worten, ob alles geklappt hat.
```

Starte danach eine neue Session, damit Claude den neuen Skill kennt.

## Schritt 2: Erster Post

Öffne Claude in dem Ordner, in dem deine Social-Posts entstehen sollen (zum Beispiel ein Kommunikations-Ordner). Sag Claude:

```
Mach mir einen Social-Post aus diesem Text:

<hier deine Headline und ein, zwei Sätze einfügen>
```

Auf Englisch geht genauso:

```
Make me a social post from this text:

<paste your headline and one or two sentences here>
```

Das passiert dann:

1. Claude fragt mit ein paar Klicks nach Marke (ADAN e.V., ADAN Impact, ADAN Careers), Format, Vorlage und Sprache des Posts.
2. Ist dein Text länger, schlägt Claude eine Aufteilung in Headline, Subline, Stichpunkte und Handlungsaufruf vor. Du bestätigst oder änderst.
3. Claude erzeugt eine Vorschau, schaut sie selbst an (Lesbarkeit, Logo, Umlaute, nichts abgeschnitten) und nennt dir den Pfad. Auf Wunsch öffnet Claude das Bild für dich.
4. Du sagst, was passt und was nicht. Claude ändert und zeigt die nächste Vorschau.
5. Bist du zufrieden, legt Claude die fertigen Bilder ab, zum Beispiel `social/ausgabe/2026-10-22-adan-ev-ig-1x1-01.png`. Beim Karussell gibt es je Seite eine Datei (`-01`, `-02`, ...).

## Schritt 3: Nachbessern

Sag zum Beispiel:

```
Die Headline ist zu lang, mach sie kürzer. Und das Wort "gemeinsam" soll farbig sein.
```

```
Mach daraus noch eine Story 9:16 und eine englische Fassung.
```

```
Der Hintergrund soll weiß sein statt orange.
```

Claude bleibt bei den Farben aus dem Marken-Guide. Wünschst du eine Farbe außerhalb davon, fragt Claude kurz nach. Soll eine Änderung für alle künftigen Posts einer Marke gelten, sag es. Claude speichert sie dann in deinem Arbeitsordner unter `brand/<marke>/marke.css`.

## Schritt 4: Eigene Marken-Dateien einbinden

Die Marken-Profile im Skill sind vorläufig, aus den Websites gemessen und nicht vom Verein bestätigt. ADAN Careers ist nur ein Platzhalter (Teal und Orange aus der Career-Day-Grafik). Sobald es offizielle Dateien gibt (Style-Guide, Logos, Farben), leg sie in deinem Arbeitsordner unter `brand/<marke>/` ab, zum Beispiel `brand/adan-careers/STYLE-GUIDE.md` und `brand/adan-careers/logo/`. Sag Claude:

```
Ich habe den offiziellen Style-Guide und die Logos für ADAN Careers unter brand/adan-careers/ abgelegt. Übernimm Farben, Schrift und Logos für meine Social-Posts.
```

Ab dann gilt dein Ordner vor den Profilen im Skill.

## Grenzen

- Kein Ersatz für Figma. Der Skill liefert saubere Standard-Posts aus drei Vorlagen. Fotos, Illustrationen und freie Layouts machst du weiter in Figma oder Claude Design, dort auch den Feinschliff.
- Die Marken-Guides sind vorläufig, ADAN Careers ist ein Platzhalter. Prüf Farben und Logo, bevor ein Post veröffentlicht wird.
- Schrift ist Rubik (frei nutzbar unter der SIL Open Font License, liegt mit Lizenz unter `templates/fonts/`). Nutzt eure Marke eine andere Schrift, muss sie mit Lizenz im `brand/`-Ordner liegen.
- Claude postet nichts, plant keine Veröffentlichungen und lädt nichts hoch.
- Die Texte selbst (Captions, Hashtags) macht der Use Case content-adapter. Beide lassen sich hintereinander nutzen: erst die Texte je Kanal, dann die Bilder dazu.

## Nächste Ausbaustufe

- Vorlagen mit Foto (Bild plus Farbfläche), sobald Bildrechte und Motive geklärt sind.
- Offizielle Profile für ADAN Careers und bestätigte Guides für ADAN e.V. und ADAN Impact.
- Übergabe an Figma, damit fertige Posts dort weiterbearbeitet werden können.

## Was im Bundle liegt

```
social-post/
├── README.md                          ← diese Anleitung
├── install.sh                         ← Installation (Mac und Windows)
└── skills/
    └── social-post/
        ├── SKILL.md                   ← die Arbeitsanleitung für Claude
        ├── templates/                 ← Vorlagen Statement, Info, Karussell
        ├── marken/                    ← Profile ADAN e.V., ADAN Impact, ADAN Careers (Guide, Farben, Logos)
        └── scripts/                   ← Vorbereiten und Erzeugen der Bilder
```

In deinem Arbeitsordner entsteht beim ersten Lauf:

```
social/
├── build/<datum>-<marke>-<format>/    ← Arbeitsstand je Post mit Vorschau
└── ausgabe/                           ← fertige PNG-Dateien
brand/<marke>/                         ← optional, deine eigenen Marken-Dateien
```
