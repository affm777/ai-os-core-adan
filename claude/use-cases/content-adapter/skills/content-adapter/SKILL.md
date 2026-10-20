---
name: content-adapter
description: Formt eine Idee oder einen fertigen Kerntext in Fassungen für LinkedIn, Instagram, Newsletter, Mail und Website um, auf Deutsch und Englisch, in der eigenen Tonalität aus einem Stil-Korpus (content/voice.md, bei mehreren Marken je Marke content/stil/<marke>/voice.md) und ohne AI-Slop. Erfindet nichts, markiert Fehlendes als [FEHLT: ...], prüft jede Fassung gegen eine Verbotsliste und liefert zu jeder Fassung einen kurzen Design-Auftrag fürs Bild und legt alles im Arbeitsordner unter content/ausgabe/ ab. Baut auf Wunsch den Stil-Korpus aus eigenen Texten auf. Nutze diesen Skill IMMER, wenn ein vorhandener Text oder eine Idee für einen oder mehrere Kanäle aufbereitet werden soll, auch ohne das Wort „Content“.
when_to_use: |
  Trigger-Phrasen: "mach daraus einen LinkedIn-Post", "bereite das für Instagram auf", "schreib das für den Newsletter um", "mach daraus Posts für alle Kanäle", "Fassungen für LinkedIn und Website", "auf Englisch und Deutsch für Social Media", "Content adaptieren", "Stil-Korpus anlegen", "lern meinen Schreibstil", "hier sind Beispieltexte für meine Voice", "Stil-Profil für Marke X anlegen", "turn this into a LinkedIn post", "adapt this for all channels", "here are sample texts for my voice", "/content-adapter". Auch zum Nachbessern einer Fassung aus einem früheren Lauf ("mach die LinkedIn-Fassung kürzer").
  NICHT für Bilder, Flyer oder Slides (designer-Skill), Videos (motion-graphic), Antworten auf echte Mails im Postfach (mail- oder posteingang-Skills) und nicht zum direkten Posten in Kanäle.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Content-Adapter

Ergebnis: je gewähltem Kanal und gewählter Sprache eine fertige Fassung als Text zum Kopieren, im Chat und als Datei unter `content/ausgabe/YYYY-MM-DD-<slug>/`. Der Nutzer ist Content-Designerin oder Content-Designer ohne Technik-Hintergrund. Er liefert Rohtext oder Idee, beantwortet eine Fragerunde und korrigiert. Ton und finale Kontrolle bleiben beim Menschen.

Der Skill ist kein Textgenerator, er formt um. **Der Rohtext ist Wahrheit.**

## Grundregeln

- **Nichts erfinden.** Keine Zahlen, Namen, Zitate, Termine, Orte, Links oder Behauptungen, die nicht im Rohtext oder in den Briefing-Antworten stehen. Braucht ein Kanal etwas, das fehlt (Link, Datum, Ansprechperson), steht `[FEHLT: <was>]` im Text. Nie raten, nie „beispielhaft“ füllen.
- **Keine Wertung dazudichten.** Aus „neun Tandems haben sich gefunden“ wird nicht „ein voller Erfolg“. Gefühle, Wirkung und Superlative nur, wenn der Rohtext sie nennt.
- **Zitate wörtlich.** In der EN-Fassung übersetzte Zitate mit `(translated)` kennzeichnen, nichts kürzen, was den Sinn ändert.
- **Verbotsliste gilt immer.** `verbotsliste.md` im Skill plus der Abschnitt „Eigene Verbote“ in `content/voice.md`. Kein Gedankenstrich (weder „–“ noch „—“ noch ein Bindestrich mit Leerzeichen als Strich).
- **Kanaltexte sind Klartext.** Keine Sternchen, Rauten als Überschrift, Markdown-Listen oder Fettschrift in den `.txt`-Dateien. Zwischenüberschriften bei Website und Newsletter als eigene Zeile ohne Zeichen davor.
- **Deutsch und Englisch sind eigene Fassungen.** Erst die DE-Fassung, dann die EN-Fassung aus dem Rohtext neu gebaut, nicht Satz für Satz übersetzt. Englisch folgt den EN-Besonderheiten der Kanalkarte.
- **Nichts löschen.** Kein `rm`. Gibt es den Ausgabeordner eines Tages schon, wird ein neuer mit `-2`, `-3` angelegt. Überarbeitete Fassungen ersetzen die Datei im selben Lauf, die alte Fassung wandert vorher nach `_alt/<kanal>-<sprache>-vN.txt` im Laufordner.
- **Dialog in der Sprache des Nutzers.** Fragen, Hinweise und Zusammenfassungen (auch in AskUserQuestion und die festen Sätze unten) laufen in der Sprache, in der der Nutzer schreibt, etwa Englisch, die Fassungen bleiben DE und EN wie gewählt und deutsche Chat-Texte stehen mit echten Umlauten.

## Pfade

- Skill-Ordner `S=~/.claude/skills/content-adapter`. Kanalkarten `$S/kanaele/<kanal>.md`, Verbotsliste `$S/verbotsliste.md`, Korpus-Vorlage `$S/voice-vorlage.md`, Korpus-Pflege `$S/korpus.md`, Prüfung `bash "$S/scripts/pruefen.sh" <laufordner>`.
- Arbeitsordner ist das aktuelle Verzeichnis. Nutzerdaten liegen nur dort, nie im Skill:
  - `content/voice.md` Stil-Korpus des Nutzers (Budget 120 Zeilen, 8 KB)
  - `content/_alt/` Sicherungen von voice.md vor jeder Verdichtung oder Neuableitung
  - `content/beispiele/` eigene Texte als Quelle für den Korpus
  - `content/ausgabe/YYYY-MM-DD-<slug>/` je Lauf `rohtext.md`, `<kanal>-<de|en>.txt`, `uebersicht.md`
- **Mehrere Marken.** Schreibt der Nutzer für mehr als eine Marke, hat jede Marke einen eigenen Korpus unter `content/stil/<marke>/` mit `voice.md`, `_alt/` und `beispiele/` (Marken-Slug in Kleinbuchstaben mit Bindestrichen, z. B. `adan-ev`, `adan-impact`, `adan-careers`). Alles, was diese Anleitung zu `content/voice.md`, `content/_alt/` und `content/beispiele/` sagt, gilt dann für die Ordner der gewählten Marke (aktiver Korpus). Ausgaben bleiben gemeinsam unter `content/ausgabe/`.
- Kanalnamen in Dateinamen: `linkedin`, `instagram`, `newsletter`, `mail`, `website`.
- Plattform macOS oder Windows mit Git Bash. Keine weiteren Programme nötig.

## Ablauf

### 1. Korpus prüfen

`content/voice.md` und `content/stil/*/voice.md` im Arbeitsordner suchen (Glob, auch eine Ebene tiefer). Bei genau einem gefundenen Korpus diesen lesen, Statuszeile merken, still weiter zu Schritt 2. Bei mehreren Marken-Korpora noch keinen lesen, die Marke wird im Briefing gewählt (Schritt 2). Fehlt sie, nicht fragen, ob ein Korpus angelegt werden soll, sondern direkt mit dem Interview (1a) starten. Ankündigung in einem Satz:

> Bevor wir loslegen, sechs kurze Fragen zu deinem Ton (rund zwei Minuten), damit die Texte nach dir klingen.

### 1a. Korpus aufbauen und pflegen

Interview beim ersten Lauf, Beispieltexte nachreichen (jederzeit, auch mitten in einem Lauf, Auslöser „hier sind Beispieltexte für meine Voice“, „lern meinen Stil aus diesen Texten“ oder Dateien, die erkennbar als Stilvorlage gemeint sind) sowie Budget und Selbstverdichtung von voice.md stehen in `$S/korpus.md`. Diese Datei lesen, sobald einer der Fälle eintritt, dann an derselben Stelle weiter.

### 2. Briefing

Rohtext oder Idee kommt frei im Chat oder als Datei. Wörter zählen.

**Nur eine Idee (unter 40 Wörtern):** vorher fragen, frei im Chat:

> Erzähl mir den Kern in zwei, drei Sätzen. Was ist passiert oder was wird angeboten, für wen und warum jetzt?

**Marke (nur bei mehreren Marken-Korpora):** vor der Fragerunde eine eigene AskUserQuestion mit einer Frage „Für welche Marke ist der Text?“, Optionen sind die vorhandenen Ordner unter `content/stil/`. Nennt der Nutzer die Marke schon in seiner Nachricht eindeutig, entfällt die Frage. Danach nur den Korpus dieser Marke lesen.

Danach eine Fragerunde (AskUserQuestion, genau eine Runde, höchstens vier Fragen):

1. Kanäle (Mehrfachauswahl): LinkedIn, Instagram, Newsletter, Mail, Website. Weil AskUserQuestion höchstens vier Optionen zeigt, Mail und Website als eine Option „Mail und Website“ anbieten, alles andere kommt über „Sonstiges“ als Freitext.
2. Sprachen: Deutsch, Englisch, beide.
3. Call-to-Action oder Link: „Link folgt / habe ich“ (dann Freitext), „Handlung ohne Link“ (z. B. Melden per Mail), „Kein Call-to-Action“.
4. Bild, Termin oder Deadline: „Bild vorhanden“, „Termin oder Deadline“ (Freitext), „Beides“, „Nichts davon“.

Antworten sind ab jetzt Teil der Wahrheit. Einen kurzen Slug festlegen (Kleinbuchstaben, Bindestriche, ohne Umlaute, höchstens fünf Wörter). Laufordner `content/ausgabe/<heute>-<slug>/` anlegen (existiert er, `-2` anhängen) und den Rohtext plus Briefing-Antworten (samt Marke, falls gewählt) wörtlich als `rohtext.md` speichern.

### 3. Erzeugen

Vorher lesen: die Kanalkarten der gewählten Kanäle, `verbotsliste.md`, `content/voice.md` falls vorhanden. Bei Widerspruch gilt voice.md vor Kanalkarte, Verbotsliste vor beiden, Rohtext vor allem.

**Faktenliste.** Zuerst still alle Aussagen des Rohtexts als nummerierte Liste festhalten (Wer, Was, Wann, Wo, Zahlen, Zitate, Aufruf). Jede Fassung darf nur diese Fakten verwenden, umformulieren, kürzen, weglassen. Pro Kanal prüfen, was die Kanalkarte verlangt und nicht in der Liste steht, das wird `[FEHLT: ...]`.

**Je Kanal und Sprache eine Fassung** nach Kanalkarte (Länge, Aufbau, Absatzregeln, Hashtags, Emoji, Link). Ohne voice.md gelten die Standardwerte der Kanalkarte, Anrede dann Sie für Newsletter, Mail und Website und neutral ohne direkte Anrede für LinkedIn und Instagram. Hashtags nur aus Begriffen, die im Rohtext vorkommen oder ihn direkt beschreiben, keine Trend-Hashtags. Gibt der Rohtext für die Mindestlänge eines Kanals nicht genug her, bleibt die Fassung kürzer. Nie auffüllen, in der Übersicht vermerken.

**Dateien schreiben** als UTF-8 ohne Markdown: `<kanal>-<de|en>.txt`. Aufbau mehrteiliger Kanäle mit festen Kennzeilen, damit der Nutzer weiß, was wohin gehört:
- Newsletter: `Betreff:`, `Vorschautext:`, Leerzeile, Text.
- Mail: `Betreff:`, Leerzeile, Text, `[SIGNATUR]`.
- Website: `Überschrift:`, `Teaser:`, `Meta-Beschreibung:`, Leerzeile, Fließtext mit Zwischenüberschriften als eigene Zeilen.
- LinkedIn: Post, danach Leerzeile und `Erster Kommentar:` mit dem Link oder `[FEHLT: Link]`, nur wenn es einen Link-Aufruf gibt.
- EN-Fassungen nutzen die englischen Kennzeilen (`Subject:`, `Preview text:`, `Headline:`, `Teaser:`, `Meta description:`, `First comment:`, `[SIGNATURE]`).

**Prüfen, bevor der Nutzer etwas sieht.**
1. `bash "$S/scripts/pruefen.sh" content/ausgabe/<lauf>` ausführen. Das Script prüft Verbotsliste, Gedankenstriche, Markdown-Zeichen, Emoji als Aufzählung, Hashtag-Anzahl, Großschreibung, Fragezeilen am Anfang, Längen und zählt `[FEHLT]`. Steht im Abschnitt „Eigene Verbote“ von voice.md ein Begriff, wird er mit `--zusatz content/voice.md` mitgeprüft.
2. Jeden VERSTOSS beheben und erneut prüfen, bis keiner mehr da ist. HINWEISE einzeln ansehen und nur beheben, wenn sie zutreffen. Abkürzungen aus dem Block `abkuerzungen` der Verbotsliste (und aus voice.md mit `--zusatz`) meldet das Script nicht als Großschreibung.
3. Selbst gegen die Faktenliste lesen, Satz für Satz. Jede Aussage, die nicht in der Liste steht, streichen oder in `[FEHLT]` umwandeln. Drei Adjektive in Reihe und rhetorische Fragen als Einstieg zusätzlich mit eigenem Blick prüfen, das Script findet nicht alle.

**Design-Auftrag je Fassung.** Zu jeder Fassung (Kanal und Sprache) einen kurzen Auftrag fürs Bild schreiben, den der Nutzer in Claude Design, Figma oder den Skill `social-post` übergeben kann. Klartext mit festen Kennzeilen in dieser Reihenfolge, in der Sprache der Fassung:
- `Headline:` höchstens sechs Wörter, nur aus der Faktenliste.
- `Bildtext:` höchstens 20 Wörter, nur aus der Faktenliste, sonst `[FEHLT: ...]`.
- `Format:` LinkedIn 1:1 (1200 x 1200), Instagram 4:5 (1080 x 1350), Newsletter und Mail Kopfbild 2:1 (1200 x 600, nicht in social-post, Claude Design oder Figma), Website 16:9 (1920 x 1080, nicht in social-post, Claude Design oder Figma). Nennt das Briefing ein anderes Format (etwa Story 9:16, Karussell), gilt das.
- `Kanal:` und `Marke:` (ohne Marken-Korpus der Name aus dem Rohtext oder `[FEHLT: Marke]`).
- `Stimmung:` ein Satz aus Rohtext und Korpus, ohne neue Fakten.
Verbotsliste, Gedankenstrich-Regel und die Wortgrenzen gelten auch hier. Nach dem Schreiben von `uebersicht.md` pruefen.sh erneut laufen lassen, es prüft dann den Abschnitt „Design-Aufträge“ mit. Farben, Schriften und Logos nennt der Auftrag nicht, die kommen aus dem Design-System der Marke.

**`uebersicht.md`** im Laufordner: Kopfzeile mit Datum, Slug, Marke (falls gewählt), Kanälen, Sprachen und Korpus-Status („Stil-Korpus belegt, N Texte“, „Stil-Korpus vorläufig aus Interview“ oder „ohne Stil-Korpus“). Dann alle Fassungen in Codeblöcken (dort darf Markdown stehen, die Kanaltexte selbst bleiben Klartext). Danach der Abschnitt `## Design-Aufträge` mit je einem Codeblock pro Fassung, überschrieben mit Kanal und Sprache. Am Ende ein Prüfprotokoll mit dem Ergebnis von `pruefen.sh`, der Liste aller `[FEHLT]`-Stellen und der Faktenliste mit dem Vermerk, welche Fakten in welchen Fassungen vorkommen.

**Ausgabe im Chat:** je Kanal und Sprache ein Block mit Überschrift (`LinkedIn, Deutsch, 1.104 Zeichen`) und dem Text in einem Codeblock zum Kopieren, direkt darunter der Design-Auftrag als eigener kurzer Codeblock. Darunter in einer Zeile der Ablageort der Dateien und die offenen `[FEHLT]`-Stellen als kurze Liste. Am Ende die Zeile „Sag mir, was ich an welcher Fassung ändern soll, oder welche Fassung in die Zwischenablage soll.“ Steht die Statuszeile auf „vorläufig“, hängt an diese Zeile genau ein Halbsatz als Erinnerung („und schick mir gern ein paar eigene Texte, dann trifft es deinen Ton besser“). Nicht öfter, nicht als eigener Absatz.

### 4. Feedback

- Nur die genannte Fassung ändern. Die anderen bleiben unangetastet, auch wenn die Korrektur dort ebenfalls passen würde. Ist das so, einmal fragen, ob die anderen nachziehen sollen.
- Vor dem Überschreiben die bisherige Fassung nach `_alt/` kopieren (Grundregel), danach `pruefen.sh` erneut laufen lassen und `uebersicht.md` aktualisieren. Ändert sich dabei ein Fakt oder die Headline-Grundlage, den Design-Auftrag dieser Fassung mitziehen.
- Korrekturen im Gespräch nach Art merken (zu lang, zu förmlich, zu locker, zu werblich, Einstieg zu schwach, falsches Wort). Kommt dieselbe Art zum zweiten Mal, fragen:

> Das ist das zweite Mal „<Art>“. Soll ich das als feste Regel in deinen Stil-Korpus schreiben, damit es künftig gleich passt?

Bei Ja in `content/voice.md` unter „Gelernte Regeln“ eintragen (Datum, Regel in einem Satz, Anlass). Ein neues Verbotswort kommt unter „Eigene Verbote“. Ohne voice.md bei Ja die Datei aus `voice-vorlage.md` anlegen (Status vorläufig) und nur diese Regel eintragen. Danach Statuszeile aktualisieren und Budget prüfen (`$S/korpus.md`).

### 5. Zwischenablage (nur auf Wunsch)

Nur die genannte Fassung, nur aus der Datei, nie aus dem Chat-Text. Ein Design-Auftrag kommt aus seinem Block im Abschnitt „Design-Aufträge“ von `uebersicht.md` (ohne Codeblock-Zeichen), vorher als `_alt/design-<kanal>-<sprache>.tmp` im Laufordner ablegen und von dort kopieren:
- macOS: `LANG=en_US.UTF-8 pbcopy < <datei>`, danach `LANG=en_US.UTF-8 pbpaste | head -3` und prüfen, dass Umlaute stimmen.
- Windows (Git Bash): `powershell.exe -NoProfile -Command "Get-Content -Raw -Encoding UTF8 '<datei>' | Set-Clipboard"`, `<datei>` als Pfad relativ zum Arbeitsordner (oder mit `cygpath -w` umgewandelt, PowerShell versteht `/c/...` nicht). Nicht `clip`, weil `clip` UTF-8-Umlaute ohne BOM verstümmelt. Prüfen mit `powershell.exe -NoProfile -Command "[Console]::OutputEncoding=[Text.Encoding]::UTF8; Get-Clipboard" | head -3`. Dem Nutzer dazu sagen, dass Strg+V in Git Bash nicht einfügt (Rechtsklick und Einfügen oder Umschalt+Einfg), in anderen Programmen geht Strg+V normal.
- Bei Kanälen mit Kennzeilen (Betreff, Überschrift) fragen, ob der ganze Block oder nur der Text kopiert werden soll.

## Was der Skill nicht tut

Nicht posten oder planen, keine Bilder erzeugen (nur den Design-Auftrag dafür), keine weiteren Sprachen als DE und EN, keine Fakten recherchieren. Fragt der Nutzer danach, das kurz sagen und auf passende Skills verweisen (Bilder über social-post oder designer, Video über motion-graphic).
