# Ein Text, alle Kanäle, mit Bild im ADAN-Look (Details)

Ergänzung zur [README](README.md) in diesem Ordner. Hier steht alles, was über die Schritt-für-Schritt-Anleitung hinausgeht.

## Inhalt

- [Überblick](#überblick)
- [Gut zu wissen](#gut-zu-wissen)
- [Voraussetzungen](#voraussetzungen)
- [Erster Lauf](#erster-lauf)
- [So sieht das Ergebnis aus](#so-sieht-das-ergebnis-aus)
- [Formate und Vorlagen](#formate-und-vorlagen)
- [Nachbessern und kopieren](#nachbessern-und-kopieren)
- [Stil-Korpus je Marke](#stil-korpus-je-marke)
- [Referenzen](#referenzen)
- [Eigene Marken-Dateien einbinden](#eigene-marken-dateien-einbinden)
- [Was die Verbotsliste verhindert](#was-die-verbotsliste-verhindert)
- [Umstieg von content-adapter und social-post](#umstieg-von-content-adapter-und-social-post)
- [Grenzen](#grenzen)
- [Nächste Ausbaustufe](#nächste-ausbaustufe)
- [Was im Bundle liegt](#was-im-bundle-liegt)

## Überblick

Mit diesem Use Case machst du aus einer Idee oder einem fertigen Text in einem Lauf alles, was du zum Veröffentlichen brauchst: je Kanal (LinkedIn, Instagram, Newsletter, Mail, Website) und Sprache (Deutsch, Englisch) einen fertigen Text und, wenn du willst, die Bilder für Instagram und LinkedIn im Look deiner ADAN-Marke. Claude schreibt nichts Neues dazu, sondern formt deinen Text für jeden Kanal um. Damit die Texte nach deiner Marke klingen und nicht nach Standard-KI, merkt sich Claude den Ton je Marke in einem Stil-Korpus. Code siehst du dabei nicht. Den Ton und die letzte Kontrolle behältst du, veröffentlichen machst du selbst.

## Gut zu wissen

- Du kannst Claude auf Deutsch oder auf Englisch ansprechen. Claude antwortet in deiner Sprache, die Sprachen der Texte wählst du getrennt.
- Der Skill wird einmal installiert und steht danach überall zur Verfügung, egal in welchem Ordner du gerade arbeitest. Du findest ihn danach auch im Dashboard unter Skills & Commands.
- Er ersetzt die beiden älteren Use Cases content-adapter (nur Texte) und social-post (nur Bilder).

## Voraussetzungen

- Dein Setup ist installiert. Playwright (der Browser, mit dem Claude die Bilder erzeugt) und Python sind darin schon enthalten.
- Google Chrome, nur für die Bilder. `install.sh` prüft das und nennt den Befehl zum Nachladen.
- Kein Internet beim Erzeugen der Bilder. Die Markenschrift Rubik liegt im Bundle.
- Optional 5 bis 10 eigene Texte je Marke (Posts, Newsletter, Website-Texte).
- Unter Windows läuft alles in Git Bash aus deinem Setup. Claude nimmt dort automatisch `python` oder `py -3` statt `python3`, öffnet Bilder im Explorer und kopiert über PowerShell, damit Umlaute heil bleiben. Fehlt der Browser zum Erzeugen der Bilder, lädt Claude ihn nach deinem Okay nach (gut 100 MB).

Zeitbedarf: Die sechs Fragen zum Ton beim allerersten Lauf dauern rund zwei Minuten. Danach dauert ein Text für alle fünf Kanäle in beiden Sprachen etwa 5 Minuten, jedes Bild rund eine Minute mehr. Das meiste davon arbeitet Claude allein.

## Erster Lauf

Öffne Claude in deinem Projektordner (zum Beispiel ein Kommunikations-Ordner). Beim ersten Lauf legt Claude dort den Ordner `content-und-social/` an und sagt dir, dass alles darin landet. Sag Claude:

```
Mach aus diesem Text Posts für meine Kanäle:

<hier deinen Text oder deine Idee einfügen>
```

Auf Englisch:

```
Turn this text into posts for my channels:

<paste your text or idea here>
```

Das passiert dann:

1. Ist dein Text nur eine kurze Idee, fragt Claude nach dem Kern in zwei, drei Sätzen.
2. Eine Fragerunde mit Klicks: Marke (ADAN e.V., ADAN Impact, ADAN Careers), Kanäle, Sprachen und ob Bilder dazukommen (Instagram und LinkedIn passend zu den Kanälen, Story 9:16, Karussell). Gibt es für die Marke gespeicherte Referenzen, fragt Claude zusätzlich, ob nach einer davon gearbeitet werden soll. Was schon in deiner Nachricht steht, fragt Claude nicht. Fehlen Aufruf, Link oder Termin, kommt danach eine kurze Frage dazu.
3. Beim allerersten Lauf sechs kurze Fragen zu deinem Ton (Du oder Sie, drei Wörter für deinen Ton, Humor, Emojis, Hashtags und je ein Text, der dir gefällt und nicht gefällt). Daraus entsteht der Stil-Korpus deiner Marke. Danach nie wieder.
4. Claude schreibt je Kanal und Sprache eine Fassung und prüft jede selbst: Steht jede Aussage in deinem Text? Ist etwas aus der Verbotsliste drin? Stimmt die Länge für den Kanal?
5. Hast du Bilder gewählt, sucht Claude die passende Vorlage aus (Statement, Info oder Karussell), sagt dir in einem Satz, welche und warum, baut die Bilder, schaut sie selbst an (Lesbarkeit, Logo, Umlaute, nichts abgeschnitten) und nennt dir die Pfade.
6. Du bekommst alle Texte im Chat zum Kopieren, unter jedem Text einen kurzen Design-Auftrag und die Pfade der Bilder. Fehlt etwas, das ein Kanal braucht (zum Beispiel ein Link oder ein Datum), steht an der Stelle im Text `[FEHLT: ...]`. Claude rät nie, und ins Bild kommt so eine Stelle gar nicht erst.
7. Passt alles, fragt Claude einmal, ob der Post als Referenz für künftige Posts gespeichert werden soll (siehe „Referenzen“).

## So sieht das Ergebnis aus

Zu jeder Fassung gehört ein Design-Auftrag. Aus ihm baut Claude das Bild, du kannst ihn aber auch direkt in Claude Design oder Figma nutzen. Farben, Schriften und Logo nennt er nicht, die kommen aus dem Design-System deiner Marke. Ein Beispiel:

```
Instagram, Deutsch, 812 Zeichen
──────────────────────────────
Neun Tandems haben sich beim Mentoring-Auftakt gefunden.
(... restlicher Post ...)

Design-Auftrag
Headline: Neun Tandems, ein Auftakt
Bildtext: Mentoring-Programm gestartet. Bewerbung für die nächste Runde bis [FEHLT: Datum]
Kicker: Mentoring-Programm
CTA: Jetzt bewerben
Format: Instagram 4:5 (1080 x 1350)
Kanal: Instagram
Marke: ADAN e.V.
Stimmung: Ruhig und zugewandt, Menschen im Gespräch statt Bühne und Applaus.

Bild: content-und-social/ausgabe/2026-10-22-mentoring-auftakt/bilder/adan-ev-ig-4x5-de-01.png
```

Im Bild steht in diesem Beispiel „Mentoring-Programm gestartet.“ ohne den Teil mit dem fehlenden Datum. Texte und Bilder eines Laufs liegen zusammen im Laufordner, alle Texte, Design-Aufträge und Bildpfade zusätzlich in dessen `uebersicht.md`.

## Formate und Vorlagen

| Format | Größe in Pixeln |
|---|---|
| Instagram-Post 1:1 | 1080 x 1080 |
| Instagram 4:5 | 1080 x 1350 |
| Story 9:16 | 1080 x 1920 |
| LinkedIn 1:1 | 1200 x 1200 |
| Karussell (3 bis 5 Seiten) | je Seite 1080 x 1080 |

Drei Vorlagen stehen bereit, Claude wählt selbst und du kannst jederzeit eine andere verlangen:

- **Statement:** große Headline auf der Markenfarbe, kleine Zeile darüber (Kicker), Logo unten. Für eine Kernaussage.
- **Info:** Headline, drei nummerierte Stichpunkte und ein Handlungsaufruf auf Weiß. Für Termin, Ort und Anmeldung.
- **Karussell:** Titelseite auf Markenfarbe, ein bis drei Inhaltsseiten mit Seitenzahl und eine Abschlussseite mit Handlungsaufruf.

Zu langer Text wird automatisch etwas kleiner gesetzt. Passt er trotzdem nicht, schlägt Claude eine Kürzung vor. Kopfbilder für Newsletter, Mail (2:1) und Website (16:9) baut der Skill nicht, dafür nimmst du den Design-Auftrag in Claude Design oder Figma.

## Nachbessern und kopieren

Sag zum Beispiel:

```
Die LinkedIn-Fassung auf Deutsch ist mir zu förmlich.
```

```
Auf dem Instagram-Bild soll der Hintergrund weiß sein statt orange.
```

```
Mach daraus noch eine Story 9:16.
```

Claude ändert nur, was du nennst. Die alte Textfassung bleibt im Unterordner `_alt/` liegen, fertige Bilder werden nie überschrieben (neue bekommen `-v2`). Das geht auch mit Läufen aus früheren Tagen. Sagst du dieselbe Art Korrektur ein zweites Mal (etwa wieder „zu förmlich“), fragt Claude, ob das als feste Regel in den Stil-Korpus soll. Bei den Bildern bleibt Claude bei den Farben aus dem Marken-Guide und fragt bei anderen Farben kurz nach.

Soll eine Fassung direkt in die Zwischenablage, sag einfach „Kopier mir die Instagram-Fassung auf Englisch“ oder „Kopier mir den Design-Auftrag für Instagram“. Unter Windows kopiert Claude über PowerShell, damit Umlaute heil bleiben. Einfügen geht in Word, im Browser und überall sonst mit Strg+V, nur im Git-Bash-Fenster selbst nicht, dort mit Rechtsklick und Einfügen oder mit Umschalt+Einfg. Bilder kopiert Claude nicht in die Zwischenablage, sondern nennt dir den Pfad oder öffnet den Ordner.

## Stil-Korpus je Marke

Jede Marke bekommt ihren eigenen Stil-Korpus unter `content-und-social/stil/<marke>/voice.md`. Beim allerersten Lauf entsteht er aus den sechs Fragen, zunächst als vorläufige Fassung. Für jede weitere Marke fragt Claude nicht noch einmal, sondern übernimmt die Grundwerte und baut den Korpus mit Beispieltexten aus. Mit fünf bis zehn eigenen Texten je Marke trifft Claude den Ton deutlich besser. Sag Claude:

```
Hier sind Beispieltexte für die Marke ADAN Careers: content-und-social/stil/adan-careers/beispiele/
```

Hast du vom Workshop-Team einen Ordner mit Startwerten je Marke bekommen (`content-und-social/brand/<marke>/voice/beispiele/` mit Texten von der Website und `voice-entwurf.md`), findet Claude ihn dort selbst und fragt beim ersten Lauf, ob er der Ausgangspunkt sein soll. Liegt er woanders, nennst du ihn:

```
Hier sind Beispieltexte für die Marke ADAN e.V.: <Pfad zum Ordner>/voice/beispiele/
Nimm <Pfad zum Ordner>/voice/voice-entwurf.md als Ausgangspunkt für den Stil-Korpus.
```

Claude liest die Dateien nur, kopiert oder verschiebt sie nicht. Du kannst den Korpus jederzeit selbst öffnen und ändern, deine Änderungen gelten immer vor allem anderen. Damit er nicht ausufert, hat er ein festes Budget (120 Zeilen, höchstens zehn gelernte Regeln, höchstens 20 eigene Verbote). Wird es mehr, legt Claude eine Sicherung in `_alt/` ab, fasst zusammen und fragt dich bei Widersprüchen.

## Referenzen

Ist ein Post gelungen, fragt Claude nach deiner Freigabe genau einmal, ob er als Referenz gespeichert werden soll, und bittet um einen Namen (zum Beispiel Career-Day-Ankündigung). Die Referenz liegt dann unter `content-und-social/referenzen/<marke>/<name>.md`. Sie beschreibt, wie der Post gebaut ist (Aufbau, Länge, Einstieg, Aufruf, Hashtags) und wie das Bild aussieht (Vorlage, Format, Kicker, Farben), mit dem freigegebenen Text als Beispiel und dem Pfad zum Bild.

Beim nächsten Lauf für dieselbe Marke fragt Claude, ob nach einer Referenz gearbeitet werden soll. Du kannst sie auch gleich nennen:

```
Mach aus diesem Text Posts für meine Kanäle, wie die Career-Day-Ankündigung:

<hier deinen Text einfügen>
```

Dann folgen Aufbau und Bild der Referenz, der Ton kommt weiter aus dem Stil-Korpus. Fakten aus der Referenz (Datum, Ort, Zahlen, Links) landen nie im neuen Post, die kommen nur aus deinem neuen Text. Eine Referenz aktualisierst du mit „Nimm diesen Post als neue Fassung der Referenz Career-Day-Ankündigung“, die alte Fassung bleibt in `_alt/` liegen.

## Eigene Marken-Dateien einbinden

Die Marken-Profile im Skill sind vorläufig, aus den Websites gemessen und nicht vom Verein bestätigt. ADAN Careers ist nur ein Platzhalter (Teal und Orange aus der Career-Day-Grafik). Sobald es offizielle Dateien gibt (Style-Guide, Logos, Farben), leg sie unter `content-und-social/brand/<marke>/` ab, zum Beispiel `content-und-social/brand/adan-careers/STYLE-GUIDE.md` und `content-und-social/brand/adan-careers/logo/`. Sag Claude:

```
Ich habe den offiziellen Style-Guide und die Logos für ADAN Careers unter content-und-social/brand/adan-careers/ abgelegt. Übernimm Farben, Schrift und Logos für meine Bilder.
```

Ab dann gilt dein Ordner vor den Profilen im Skill. Liegen dort Logos ohne Zuordnung, fragt Claude einmal, welches Logo auf die Farbfläche soll, und legt dafür eine kleine Datei `content-und-social/brand/<marke>/logos.conf` an. Soll eine Farbänderung für alle künftigen Bilder einer Marke gelten, speichert Claude sie auf Wunsch unter `content-und-social/brand/<marke>/marke.css`.

## Was die Verbotsliste verhindert

Typische KI-Texte erkennt man an immer gleichen Mustern. Claude prüft jede Fassung, jeden Design-Auftrag und damit jeden Bildtext dagegen und schreibt um, bis nichts mehr davon drin ist:

- Floskeln wie „In der heutigen schnelllebigen Welt“ oder „Lasst uns gemeinsam“
- Emojis als Aufzählungszeichen und drei Adjektive hintereinander
- rhetorische Fragen als Einstieg und Großbuchstaben zur Betonung
- Gedankenstriche, Hashtag-Teppiche und Sternchen oder Rauten, die auf LinkedIn und Instagram sichtbar wären

Eigene Verbotswörter trägst du im Stil-Korpus deiner Marke unter „Eigene Verbote“ ein.

## Umstieg von content-adapter und social-post

Hast du die älteren Use Cases schon genutzt, findet Claude die alten Ordner `content/`, `social/` und `brand/` in deinem Projekt und fragt einmal, ob sie nach `content-und-social/` umziehen sollen. Verschoben wird nur, gelöscht nie. Ein `content/voice.md` ohne Marke erkennt Claude und fragt, zu welcher Marke es gehört. Sagst du Nein, liest Claude die alten Ordner nur noch. Die alten Skills bleiben installiert, bis du sie selbst entfernst. Damit Claude nicht zwischen zwei Skills schwankt, sag im Zweifel „mit content-publisher“ dazu.

## Grenzen

- Claude verwendet nur, was in deinem Text oder deinen Antworten steht. Zahlen, Namen, Zitate, Termine oder Links werden nie erfunden.
- Die englische Fassung ist eine eigene Fassung für englische Leser, keine Wort-für-Wort-Übersetzung. Übersetzte Zitate sind gekennzeichnet.
- Kein Ersatz für Figma. Der Skill liefert saubere Standard-Bilder aus drei Vorlagen. Fotos, Illustrationen und freie Layouts machst du weiter in Figma oder Claude Design, dort auch den Feinschliff.
- Die Marken-Guides sind vorläufig, ADAN Careers ist ein Platzhalter. Prüf Farben und Logo, bevor ein Post veröffentlicht wird.
- Schrift ist Rubik (frei nutzbar unter der SIL Open Font License, liegt mit Lizenz unter `templates/fonts/`). Nutzt eure Marke eine andere Schrift, muss sie mit Lizenz unter `content-und-social/brand/` liegen.
- Nur Deutsch und Englisch. Videos macht der Use Case motion-graphic, Flyer und Slides der designer.
- Claude postet nichts, plant keine Veröffentlichungen und lädt nichts hoch.

## Nächste Ausbaustufe

- Vorlagen mit Foto (Bild plus Farbfläche), sobald Bildrechte und Motive geklärt sind.
- Offizielle Profile für ADAN Careers und bestätigte Guides für ADAN e.V. und ADAN Impact.
- Weitere Kanäle wie WhatsApp-Kanal oder Pressemitteilung als eigene Kanalkarten.
- Übergabe an Figma, damit fertige Bilder dort weiterbearbeitet werden können.

## Was im Bundle liegt

```
content-publisher/
├── README.md                          ← diese Anleitung
├── details.md                         ← Details und Beispiele zur Anleitung
├── install.sh                         ← Installation (Mac und Windows)
└── skills/
    └── content-publisher/
        ├── SKILL.md                   ← die Arbeitsanleitung für Claude
        ├── visuals.md                 ← wie Claude die Bilder baut
        ├── referenzen.md              ← wie Claude Referenzen speichert und anwendet
        ├── korpus.md                  ← wie Claude den Stil-Korpus aufbaut und pflegt
        ├── kanaele/                   ← Regeln je Kanal (LinkedIn, Instagram, Newsletter, Mail, Website)
        ├── verbotsliste.md            ← Muster, die nie in einen Text dürfen
        ├── voice-vorlage.md           ← Vorlage für den Stil-Korpus
        ├── templates/                 ← Bildvorlagen Statement, Info, Karussell mit Schrift Rubik
        ├── marken/                    ← Profile ADAN e.V., ADAN Impact, ADAN Careers (Guide, Farben, Logos)
        └── scripts/                   ← Prüfung der Texte, Vorbereiten und Erzeugen der Bilder
```

In deinem Projektordner entsteht beim ersten Lauf ein einziger Ordner:

```
content-und-social/
├── brand/<marke>/                     ← optional, deine eigenen Marken-Dateien
├── stil/<marke>/voice.md              ← Stil-Korpus je Marke, daneben _alt/ und beispiele/
├── referenzen/<marke>/<name>.md       ← gespeicherte Referenz-Posts
└── ausgabe/<datum>-<thema>/           ← ein Lauf: eine Datei je Fassung (etwa linkedin-de.txt), uebersicht.md, _alt/
    └── bilder/                        ← fertige PNG-Dateien (etwa adan-ev-ig-4x5-de-01.png, beim Karussell eine je Seite), Arbeitsstand in _build/
```
