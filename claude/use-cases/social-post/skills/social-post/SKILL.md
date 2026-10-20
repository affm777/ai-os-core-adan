---
name: social-post
description: Macht aus einem Kerntext fertige PNG-Social-Visuals im Look einer ADAN-Marke (ADAN e.V., ADAN Impact, ADAN Careers). Fragt Marke, Format (Instagram 1:1 und 4:5, Story 9:16, LinkedIn 1:1, Karussell mit 3 bis 5 Seiten), Kerntext und Sprache ab, rendert eine Vorschau aus HTML-Vorlagen per playwright-cli, verbessert Text und Farbe im Gespräch und legt die fertigen Bilder unter social/ausgabe/ ab. Der Nutzer sieht keinen Code. Postet nichts. Schlanke Spezialisierung des designer-Skills für Social-Posts.
when_to_use: |
  Trigger-Phrasen: "mach mir einen Instagram-Post", "bau mir ein Visual für LinkedIn", "Story für ADAN Careers", "Karussell zu diesem Text", "Social-Post im ADAN-Look", "mach daraus ein Bild für Instagram", "make me an Instagram post", "create a LinkedIn visual", "carousel for this text", "/social-post". Auch zum Nachbessern eines früheren Posts ("die Headline kürzer", "make the background white").
  NICHT für Texte ohne Bild (content-adapter), Videos (motion-graphic), Flyer, PDFs und Slides (designer) und nicht zum Posten oder Hochladen.
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion, Bash(bash:*), Bash(mkdir:*), Bash(ls:*), Bash(cp:*), Bash(date:*), Bash(open:*), Bash(explorer.exe:*), Bash(playwright-cli:*)
---

# Social-Post

Ergebnis: ein oder mehrere PNG-Bilder in Originalgröße der Plattform, im Arbeitsordner unter `social/ausgabe/<datum>-<marke>-<format>-NN.png`. Der Nutzer ist Designerin, Designer oder Social-Media-Koordination ohne Technik-Hintergrund. Er liefert Kerntext, Marke und Format, schaut sich die Vorschau an und sagt, was anders sein soll. Feinschliff macht er bei Bedarf in Figma oder Claude Design.

## Grundregeln

- **Sprache des Dialogs = Sprache des Nutzers.** Schreibt er Englisch, führst du das ganze Gespräch auf Englisch (Fragen, Rückmeldungen, Hinweise). Die Sprache des Posts fragst du getrennt ab.
- **Kein Code im Chat.** Keine HTML-, CSS- oder JSON-Ausschnitte zeigen. Der Nutzer sieht Fragen, Bildpfade und kurze Rückmeldungen.
- **Nichts erfinden.** Headline, Subline, Stichpunkte, Termine und Links stammen aus dem Text des Nutzers. Kürzen und umstellen ja, neue Fakten nie. Fehlt etwas (etwa ein Datum für den CTA), fragen.
- **Nichts löschen, nichts posten.** Kein `rm`. Eine neue Runde überschreibt nur die Vorschau im Build-Ordner. Kein Upload, kein Posting, keine Weitergabe.
- **Marken-Guides sind vorläufig.** Die Profile im Skill sind aus den Websites gemessen und nicht bestätigt, ADAN Careers ist ein Platzhalter. Beim ersten Post einer Marke in der Session einmal kurz darauf hinweisen.
- **Umlaute und ß** immer echt schreiben, in den Texten des Posts und im Chat.

## Pfade

- Skill-Ordner `S=~/.claude/skills/social-post` mit `templates/` (statement, info, karussell plus basis.css und basis.js), `marken/<slug>/` (STYLE-GUIDE.md, marke.css, logos.conf, logo/) und `scripts/` (vorbereiten.sh, render.sh).
- Arbeitsordner ist das aktuelle Verzeichnis. Dort entsteht:
  - `social/build/<datum>-<marke>-<format>[-<thema>]/` je Post ein Build-Ordner (index.html, inhalt.json, Kopien von CSS, Logos) plus `vorschau-NN.png`
  - `social/ausgabe/<datum>-<marke>-<format>-NN.png` die fertigen Bilder
- **Vorrang Arbeitsordner:** Liegt `brand/<slug>/STYLE-GUIDE.md` im Arbeitsordner, gilt dieser Guide vor dem im Skill. Liegt dort `brand/<slug>/marke.css` oder `brand/<slug>/logos.conf`, nimmt `vorbereiten.sh` diese automatisch.
- Marken-Slugs: `adan-ev`, `adan-impact`, `adan-careers`. Die Format-Slugs heißen `ig-1x1` (1080 x 1080), `ig-4x5` (1080 x 1350), `story-9x16` (1080 x 1920), `li-1x1` (1200 x 1200). Ein Karussell hat das Format `ig-1x1` (oder auf Wunsch `ig-4x5`, `li-1x1`).

## Ablauf

### 1. Fragen

Was schon in der Nachricht steht, fragst du nicht noch einmal. Den Rest in **einem** AskUserQuestion-Aufruf mit bis zu vier Fragen:

1. Marke: ADAN e.V. / ADAN Impact / ADAN Careers
2. Format: Instagram-Post 1:1 / Instagram 4:5 / Story 9:16 / LinkedIn 1:1 / Karussell (3 bis 5 Seiten, 1:1)
3. Vorlage (nur wenn kein Karussell): Statement (große Headline auf Markenfarbe) / Info (Headline, drei Stichpunkte, Call-to-Action auf Weiß)
4. Sprache des Posts: Deutsch / Englisch

Fehlt der Kerntext, frag danach in einem Satz: Headline (Pflicht), Subline (optional), Call-to-Action (optional), bei Info drei Stichpunkte, bei Karussell der Inhalt je Seite. Ist der Text lang, schlägst du selbst eine Aufteilung vor (Headline höchstens rund 8 Wörter, Subline höchstens rund 25 Wörter, Stichpunkt höchstens rund 10 Wörter, Karussell-Seite höchstens rund 35 Wörter) und zeigst sie als Klartext zur Bestätigung.

### 2. Vorbereiten

```bash
S=~/.claude/skills/social-post
bash "$S/scripts/vorbereiten.sh" <marke> <statement|info|karussell> social/build/<datum>-<marke>-<format>
```

Liegen im Arbeitsordner unter `brand/<slug>/logo/` eigene Logos, aber keine `brand/<slug>/logos.conf`, leg diese Datei an (Aufbau wie `$S/marken/<slug>/logos.conf`, Pfade relativ zu `brand/<slug>/`) und frag den Nutzer, welches Logo auf der Farbfläche stehen soll. Danach `vorbereiten.sh` erneut ausführen.

Meldet das Skript einen Guide im Arbeitsordner (`brand/<slug>/STYLE-GUIDE.md`), lies ihn und gleiche Farben und Schrift in `social/build/.../marke.css` damit ab (nur die `--sp-*`-Werte, Schlüssel nie umbenennen). Sag dem Nutzer in einem Satz, dass sein eigener Guide gilt.

### 3. inhalt.json schreiben

Mit dem Write-Tool nach `social/build/<...>/inhalt.json` (UTF-8, gültiges JSON). Felder:

| Feld | Vorlage | Inhalt |
|---|---|---|
| `vorlage` | alle | `statement`, `info` oder `karussell` |
| `format` | alle | Format-Slug, siehe oben |
| `sprache` | alle | `de` oder `en` |
| `kicker` | alle | kurze Zeile in Versalien über der Headline (Thema, Programm, Datum), optional |
| `headline` | alle | Hauptaussage, ein Wort darf in `*Sternchen*` stehen, es erscheint in Akzentfarbe |
| `subline` | statement, karussell (Titelseite) | optional |
| `cta` | statement, info, karussell (Abschluss) | Handlungsaufruf ohne Pfeil, der Pfeil kommt automatisch, optional |
| `absender` | alle | Website oder Handle unten rechts, zum Beispiel `ada-netzwerk.com`, optional |
| `punkte` | info | Liste mit genau drei kurzen Stichpunkten |
| `weiter` | karussell | Hinweis auf der Titelseite, etwa `Wischen` oder `Swipe` |
| `seiten` | karussell | 1 bis 3 Inhaltsseiten, je `{ "kicker", "headline", "text" }` oder statt `text` eine Liste `punkte` |
| `abschluss` | karussell | Satz auf der letzten Seite über dem CTA |
| `farben` | alle | optional, überschreibt `--sp-*`-Werte aus marke.css nur für diesen Post, etwa `{ "--sp-farbe-flaeche": "#BF2806" }` |

Ein Karussell hat damit 3 bis 5 Seiten (Titelseite, 1 bis 3 Inhaltsseiten, Abschluss). Seitenzahlen setzt die Vorlage selbst. Weiche Trennstellen in sehr langen Wörtern als `­` setzen, sonst bricht die Headline nur an Leerzeichen.

### 4. Vorschau rendern

```bash
bash "$S/scripts/render.sh" social/build/<name> social/build/<name>/vorschau
```

Das Skript startet einen lokalen Server, öffnet die Seite mit playwright-cli, wartet auf Schrift und Einpassung, macht je Seite ein PNG (`vorschau-01.png`, ...) und räumt Browser und Server wieder ab. Ausgabe lesen:

- `Schrift: Rubik NICHT geladen` heißt kein Internet, die Bilder nutzen die Systemschrift. Dem Nutzer sagen, für das Endbild bitte mit Internet neu rendern.
- `ÜBERLAUF` (Exit-Code 3) heißt, der Text passt auch verkleinert nicht. Kürzung vorschlagen, nicht still kürzen.
- Schriftgröße unter 85 Prozent: Text passt, wirkt aber gedrängt. Kürzere Headline vorschlagen.

**Sichtprüfung ist Pflicht.** Jede Vorschau mit dem Read-Tool ansehen, bevor du sie zeigst: Text lesbar, nichts abgeschnitten, Logo sichtbar, Umlaute korrekt, Kontrast ausreichend. Fällt dir etwas auf, erst selbst nachbessern.

### 5. Zeigen und Feedback

Nenne dem Nutzer den Pfad der Vorschau und biete an, sie zu öffnen (macOS `open <pfad>`, Windows `explorer.exe "<pfad mit Backslashes>"`). Frag dann knapp, was passt und was nicht. Typische Wünsche und was du änderst:

- Text kürzer, anders, andere Betonung: `inhalt.json` anpassen.
- Andere Farbe, etwa Hintergrund weiß statt Markenfarbe: `farben` in `inhalt.json` setzen, nur mit Farben aus dem Marken-Guide. Will der Nutzer eine Farbe außerhalb des Guides, kurz nachfragen und dann machen.
- Andere Vorlage oder anderes Format: neuer Build-Ordner, Inhalt übernehmen.
- Soll eine Änderung für alle künftigen Posts der Marke gelten, frag, ob du sie als `brand/<slug>/marke.css` im Arbeitsordner speichern sollst (Kopie aus dem Build-Ordner, dann dort ändern).

Nach jeder Änderung Schritt 4 wiederholen. Höchstens drei Runden ohne Rückfrage, dann fragen, ob der Rest in Figma oder Claude Design schneller geht.

### 6. Ablegen

Wenn der Nutzer zufrieden ist:

```bash
bash "$S/scripts/render.sh" social/build/<name> social/ausgabe/<datum>-<marke>-<format>
```

Gibt es Dateien mit dem Präfix schon, hänge `-v2`, `-v3` an das Präfix an, nie überschreiben. Zum Schluss nenne die Pfade der fertigen PNGs, die Pixelgröße und einen Satz zu den Grenzen (Brand-Guide vorläufig, Feinschliff in Figma oder Claude Design möglich).

## Windows (Git Bash)

- Die Skripte suchen selbst `python3`, `python` oder `py -3` (unter Windows ist `python3` oft nur ein Store-Platzhalter).
- Pfade für das Öffnen im Explorer mit Backslashes angeben, die Skripte selbst arbeiten mit normalen Schrägstrichen.
- Meldet `render.sh`, dass der Browser fehlt: `npx playwright install chromium` ausführen (lädt den Browser, dem Nutzer vorher sagen, dass gut 100 MB geladen werden).

## Was du nicht tust

- Keine Vorlagen im Skill-Ordner ändern. Anpassungen nur in der Kopie im Build-Ordner, `marke.css` oder `inhalt.json`.
- Keine Fotos, Stockbilder oder KI-Bilder einbauen. Bildwünsche an Figma oder Claude Design verweisen.
- Keine Farben, Logos oder Schriften erfinden, die nicht im Marken-Guide stehen.
- Nicht posten, nicht hochladen, keine Planungs-Tools anbinden.
