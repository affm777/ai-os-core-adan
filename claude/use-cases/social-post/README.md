# Ein Kerntext, fertige Social-Visuals im ADAN-Look

Claude macht aus einer Headline und ein paar Sätzen fertige Bilder für Instagram und LinkedIn im Look von ADAN e.V., ADAN Impact oder ADAN Careers. Du prüfst die Vorschau und bekommst fertige PNG-Dateien, veröffentlichen machst du selbst.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

```
Vorher                                   Nachher
──────                                   ───────
Text in Figma oder Canva in eine      →  Text in den Chat, Marke und Format
Vorlage tippen, Größe je Format          anklicken, Vorschau ansehen, sagen
anpassen, Farben und Logo prüfen,        was anders sein soll. Fertige PNGs
für jede Sprache und jedes Format        für jedes Format und jede Sprache
von vorn                                 liegen unter social/ausgabe/
```

## Das brauchst du

- Dein Setup ist installiert. Playwright und Python sind darin schon enthalten.
- Google Chrome. Das Installationsskript prüft das.
- Kein Internet beim Erzeugen der Bilder, die Schrift Rubik liegt im Bundle.
- Unter Windows läuft alles in Git Bash, Sonderfälle stehen in [details.md](details.md).

## Schritt 1: Installieren

Sag Claude:
```
Hol zuerst mit git pull den neuesten Stand meines Setup-Repos ~/ai-os-core.

Führe dann das Installationsskript des Use-Case-Bundles "social-post" aus:
bash ~/ai-os-core/claude/use-cases/social-post/install.sh

Zeig mir danach in einfachen Worten, ob alles geklappt hat.
```

Starte danach eine neue Session, damit Claude den neuen Skill kennt.

## Schritt 2: Erster Lauf

Öffne Claude in dem Ordner, in dem deine Posts entstehen sollen. Ersetze die Zeile in spitzen Klammern durch deinen Text. Sag Claude:
```
Mach mir einen Social-Post aus diesem Text:

<hier deine Headline und ein, zwei Sätze einfügen>
```

Claude fragt dich dann:
- für welche Marke, welches Format und welche Vorlage (Statement, Info, Karussell)
- in welcher Sprache der Post sein soll
- ob die Aufteilung in Headline, Subline und Stichpunkte passt
- was an der Vorschau anders sein soll

## Schritt 3: So nutzt du es

**Text ändern.** Sag einfach, was anders sein soll.
```
Die Headline ist zu lang, mach sie kürzer. Und das Wort "gemeinsam" soll farbig sein.
```

**Weitere Formate.** Aus demselben Post macht Claude weitere Formate und Sprachen.
```
Mach daraus noch eine Story 9:16 und eine englische Fassung.
```

**Farbe ändern.** Claude bleibt bei den Markenfarben und fragt bei anderen Farben nach.
```
Der Hintergrund soll weiß sein statt orange.
```

**Eigene Marken-Dateien.** Leg offizielle Style-Guides und Logos unter `brand/<marke>/` ab. Dann gelten sie vor den Profilen im Skill.
```
Ich habe den offiziellen Style-Guide und die Logos für ADAN Careers unter brand/adan-careers/ abgelegt. Übernimm Farben, Schrift und Logos für meine Social-Posts.
```

## Das kommt dabei heraus

- `social/ausgabe/` mit fertigen PNG-Dateien, etwa `2026-10-22-adan-ev-ig-1x1-01.png`
- beim Karussell eine Datei je Seite (`-01`, `-02`, ...)
- `social/build/<datum>-<marke>-<format>/` mit Arbeitsstand und Vorschau
- Formate Instagram 1:1 und 4:5, Story 9:16, LinkedIn 1:1 und Karussell
- optional `brand/<marke>/` mit deinen eigenen Marken-Dateien

## Grenzen

- Kein Ersatz für Figma. Fotos, Illustrationen und freie Layouts machst du weiter dort.
- Die Marken-Guides sind vorläufig, ADAN Careers ist ein Platzhalter. Prüf Farben und Logo vor dem Veröffentlichen.
- Claude postet nichts, plant keine Veröffentlichungen und lädt nichts hoch.
- Die Texte (Captions, Hashtags) macht der Use Case content-adapter.

## Mehr dazu

Formate und Vorlagen im Detail, der Aufruf auf Englisch, Windows-Sonderfälle und alle Grenzen stehen in [details.md](details.md).
