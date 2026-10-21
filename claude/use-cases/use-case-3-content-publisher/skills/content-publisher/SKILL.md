---
name: content-publisher
description: Macht aus einer Idee oder einem Kerntext Fassungen für LinkedIn, Instagram, Newsletter, Mail und Website (DE und EN) im Ton einer ADAN-Marke und auf Wunsch im selben Lauf die PNG-Visuals dazu (Instagram, Story, LinkedIn, Karussell). Erfindet nichts, markiert Fehlendes als [FEHLT: ...], prüft gegen eine Verbotsliste, arbeitet nach gespeicherten Referenz-Posts und legt alles unter content-und-social/ ab. Postet nichts.
when_to_use: |
  Trigger-Phrasen: "ich muss einen neuen Post planen", "ich brauche einen Post für LinkedIn", "Social-Media-Post", "Newsletter-Text", "mach daraus Posts für alle Kanäle", "Mach aus diesem Text Posts für meine Kanäle", "Instagram-Post mit Bild", "LinkedIn-Post mit Visual", "Karussell zu diesem Text", "wie die Career-Day-Ankündigung", "speicher das als Referenz", "hier sind Beispieltexte für meine Voice", "I need to plan a new post", "turn this into posts with visuals", "turn this into posts for my channels", "make me an Instagram post", "/content-publisher". Auch zum Nachbessern einer Fassung oder eines Visuals aus einem früheren Lauf ("die LinkedIn-Fassung kürzer", "make the background white").
  NICHT für Videos (motion-graphic), Flyer, PDFs und Slides (designer), Antworten auf echte Mails im Postfach (posteingang-triage) und nicht zum Posten oder Hochladen.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Content-Publisher

Ergebnis eines Laufs: je gewähltem Kanal und gewählter Sprache eine fertige Fassung zum Kopieren, zu jeder Fassung ein Design-Auftrag und, wenn gewünscht, fertige PNG-Visuals. Texte und Bilder eines Laufs liegen zusammen in `content-und-social/ausgabe/YYYY-MM-DD-<slug>/`. Nutzer sind Content-Design und Social-Media-Koordination ohne Technik-Hintergrund. Sie liefern Rohtext oder Idee, beantworten eine Fragerunde und korrigieren. Ton und finale Kontrolle bleiben beim Menschen. Der Skill formt um, er dichtet nicht. **Der Rohtext ist Wahrheit.**

## Grundregeln

- **Nichts erfinden.** Das gilt auch für Antworten aus der Fragerunde: Eine Option darf keinen Fakt mitbringen, den der Nutzer nicht gesagt hat (etwa „Adresse steht in der Bio“, „Link im ersten Kommentar“). Fehlt die Adresse oder der Link, bleibt es bei „per Mail“ oder `[FEHLT: ...]`, und ein Hinweis auf Bio oder Kommentar kommt nur, wenn der Nutzer ihn nennt. Keine Zahlen, Namen, Zitate, Termine, Orte, Links oder Behauptungen, die nicht im Rohtext oder in den Antworten stehen. Fehlt etwas, das ein Kanal braucht, steht `[FEHLT: <was>]` im Text. Nie raten. In ein Bild kommt nie ein `[FEHLT]`, die Stelle bleibt dort weg. Aus einer Referenz kommt nie ein Fakt in einen neuen Post.
- **Keine Wertung dazudichten.** Gefühle, Wirkung und Superlative nur, wenn der Rohtext sie nennt. Zitate wörtlich, in EN übersetzte Zitate mit `(translated)`.
- **Verbotsliste gilt immer**, für Texte, Design-Aufträge und Bildtexte: `$S/verbotsliste.md` plus „Eigene Verbote“ im Korpus. Kein Gedankenstrich (weder „–“ noch „—“ noch ein Bindestrich mit Leerzeichen als Strich).
- **Kanaltexte sind Klartext.** Kein Markdown in den `.txt`-Dateien.
- **Deutsch und Englisch sind eigene Fassungen**, die EN-Fassung wird aus dem Rohtext neu gebaut, nicht Satz für Satz übersetzt.
- **Nichts löschen, nichts posten.** Kein `rm`. Ältere Fassungen wandern nach `_alt/`, belegte Namen bekommen `-2` oder `-v2`. Umzüge nur mit `mv`. Kein Upload, kein Posting, keine Planung.
- **Kein Code im Chat.** Keine HTML-, CSS-, JSON- oder Shell-Ausschnitte und keine Befehle zeigen, auch nicht zum Öffnen, Kopieren oder Installieren. Was ein Befehl tun soll, bietet Claude in einem Satz an und führt es nach einem Ja selbst aus. Der Nutzer sieht Fragen, Texte, Bildpfade und kurze Rückmeldungen.
- **Dialog in der Sprache des Nutzers.** Schreibt er Englisch, laufen Fragen (auch in AskUserQuestion), Hinweise und Zusammenfassungen auf Englisch. Die Sprachen der Fassungen wählt er getrennt. Deutsche Texte immer mit echten Umlauten und ß.
- **Marken-Guides sind vorläufig.** Die Profile im Skill sind aus den Websites gemessen, ADAN Careers ist ein Platzhalter. Beim ersten Visual einer Marke in der Session einmal kurz darauf hinweisen.

## Pfade

- Skill-Ordner `S=~/.claude/skills/content-publisher`: `kanaele/<kanal>.md`, `verbotsliste.md`, `voice-vorlage.md`, `korpus.md` (Korpus aufbauen und pflegen), `visuals.md` (Bilder bauen), `referenzen.md` (Referenzen speichern und anwenden), `scripts/pruefen.sh`, `scripts/vorbereiten.sh`, `scripts/render.sh`, `templates/`, `marken/<slug>/` (STYLE-GUIDE.md, marke.css, logos.conf, logo/).
- Projektordner ist das aktuelle Verzeichnis. Alles, was der Skill anlegt oder liest, liegt dort unter **`content-und-social/`** (kurz `C`), nie im Skill:
  - `C/brand/<marke>/` optional, eigene Marken-Dateien (STYLE-GUIDE.md, logo/, marke.css, logos.conf, voice/). **Vorrang** vor `$S/marken/<marke>/`.
  - `C/stil/<marke>/voice.md` Stil-Korpus je Marke, daneben `_alt/` und `beispiele/`.
  - `C/referenzen/<marke>/<name>.md` gespeicherte Referenz-Posts, daneben `_alt/`.
  - `C/ausgabe/YYYY-MM-DD-<slug>/` je Lauf `rohtext.md`, `<kanal>-<de|en>.txt`, `uebersicht.md`, `_alt/` und `bilder/` (darin `_build/<format>-<sprache>/` als Arbeitsstand je Visual und die fertigen PNGs `<marke>-<format>-<sprache>-NN.png`).
- Skripte immer aus dem Projektordner aufrufen, `vorbereiten.sh` sucht `content-und-social/brand/<marke>/` relativ dazu.
- Marken-Slugs `adan-ev`, `adan-impact`, `adan-careers`. Kanäle `linkedin`, `instagram`, `newsletter`, `mail`, `website`. Format-Slugs `ig-1x1`, `ig-4x5`, `story-9x16`, `li-1x1`, Karussell auf `ig-1x1`.
- Plattform macOS oder Windows mit Git Bash.

## Ablauf

### 0. Arbeitsordner

Fehlt `content-und-social/`, beim ersten Lauf anlegen und in einem Satz sagen: „Alles aus diesem Skill, Texte, Bilder, Stil und Referenzen, landet im Ordner content-und-social/ hier im Projekt.“

Liegen auf Projektebene alte Ordner `content/`, `social/` oder `brand/` (aus content-adapter oder social-post), **einmal** fragen, ob sie nach `content-und-social/` umziehen sollen. Bei Ja nur mit `mv`: `brand/<marke>/` nach `C/brand/<marke>/`, `content/stil/<marke>/` nach `C/stil/<marke>/`, `content/ausgabe/<lauf>/` nach `C/ausgabe/<lauf>/`, `social/` als Ganzes nach `C/ausgabe/_social-alt/` (alte Bilder bleiben so auffindbar). Ein `content/voice.md` ohne Marke nach `korpus.md` (Umzug) behandeln. Existiert ein Ziel schon, nicht überschreiben, sondern fragen. Bei Nein die alten Ordner nur lesen und nichts mehr hineinschreiben.

### 1. Fragerunde

Rohtext oder Idee kommt frei im Chat oder als Datei. Unter 40 Wörtern zuerst frei fragen: „Erzähl mir den Kern in zwei, drei Sätzen. Was ist passiert oder was wird angeboten, für wen und warum jetzt?“

Dann **eine** AskUserQuestion mit höchstens vier Fragen. Was schon in der Nachricht steht, wird nicht gefragt:

1. Marke: ADAN e.V. / ADAN Impact / ADAN Careers.
2. Kanäle (Mehrfachauswahl): LinkedIn / Instagram / Newsletter / Mail und Website (weitere über „Sonstiges“).
3. Sprachen: Deutsch / Englisch / beide.
4. Visuals dazu? (Mehrfachauswahl): Nein, nur Text / Ja, passend zu den Kanälen (Instagram 4:5, LinkedIn 1:1) / Story 9:16 / Karussell (3 bis 5 Seiten). In der Beschreibung der zweiten Option sagen, dass Instagram 1:1 über „Sonstiges“ geht.

**Referenz:** Steht die Marke schon fest (in der Nachricht) und gibt es `C/referenzen/<marke>/*.md`, kommt eine Frage „Nach einer Referenz arbeiten?“ dazu, Optionen die Namen der höchstens drei neuesten Referenzen plus „Ohne Referenz“. Wird die Marke erst in der Runde gewählt und hat sie Referenzen, diese Frage direkt danach als eigene kurze AskUserQuestion. Nennt der Nutzer die Referenz schon („wie die Career-Day-Ankündigung“), entfällt die Frage. Sind dadurch mehr als vier Fragen nötig, Kanäle und Sprachen der Referenz als Vorschlag in die Frage schreiben und die Referenzfrage nachziehen. Details in `$S/referenzen.md`.

Ist eine Frage frei, weil die Antwort schon in der Nachricht stand, kommt an ihre Stelle Call-to-Action oder Link: „Link folgt / habe ich“ (Freitext), „Handlung ohne Link“, „Kein Call-to-Action“. Sonst danach in **einem** Satz frei fragen, nur was im Rohtext fehlt: „Gibt es einen Aufruf mit Link und einen Termin oder eine Deadline? Wenn nicht, schreib einfach nein.“

Antworten sind ab jetzt Teil der Wahrheit. Slug festlegen (Kleinbuchstaben, Bindestriche, ohne Umlaute, höchstens fünf Wörter), Laufordner `C/ausgabe/<heute>-<slug>/` anlegen (existiert er, `-2`) und Rohtext plus alle Antworten (auch die gewählte Referenz) wörtlich als `rohtext.md` speichern.

### 2. Korpus der Marke

`C/stil/<marke>/voice.md` suchen (Glob).
- **Da:** lesen, Statuszeile merken, still weiter.
- **Noch gar kein Korpus im Projekt** (weder `C/stil/*/voice.md` noch ein altes `content/voice.md`): allererster Lauf. Ein Satz („Bevor ich schreibe, sechs kurze Fragen zu deinem Ton, rund zwei Minuten.“), dann Interview nach `$S/korpus.md` und daraus `C/stil/<marke>/voice.md`. Liegt `C/brand/<marke>/voice/voice-entwurf.md` vor, vorher fragen, ob er der Ausgangspunkt sein soll. Bei Ja entfällt das Interview und `korpus.md` „Beispieltexte nachreichen“ gilt.
- **Andere Marken haben schon einen Korpus, diese nicht:** kein zweites Interview. Gibt es `C/brand/<marke>/voice/voice-entwurf.md` (und `voice/beispiele/`), daraus nach `korpus.md` aufbauen. Sonst `voice.md` aus `voice-vorlage.md` anlegen, Anrede, Emoji, Hashtags und Humor aus dem vorhandenen Korpus übernehmen und als „(Interview, übernommen von <marke>)“ kennzeichnen, Status vorläufig. In einem Satz sagen.

**Dateien aus dem Chat einsortieren.** Zieht der Nutzer Dateien ins Fenster oder nennt Pfade („hier sind Marken-Dateien und Beispieltexte“), fragt Claude nur nach der Marke, falls sie nicht genannt ist, und legt selbst ab: Logos und Bilder nach `C/brand/<marke>/logo/` (dann `logos.conf` nach dem Muster in `$S/marken/<marke>/` anlegen und fragen, welches Logo auf die Farbfläche gehört), Style-Guides, Farb- oder Schriftangaben als oder in `C/brand/<marke>/STYLE-GUIDE.md` (PDF oder Bild vorher lesen und die Werte in den Guide übertragen, Original daneben ablegen), Texte als Beispiele nach `C/stil/<marke>/beispiele/` und sofort nach `korpus.md` einarbeiten. Am Ende in zwei Sätzen sagen, was wo liegt und was daraus gelernt wurde. Nichts löschen, Dateien nur kopieren.

Beispieltexte nachreichen, Budget und Selbstverdichtung stehen ebenfalls in `$S/korpus.md`. Gibt der Nutzer einen fertigen Post als Vorbild („so sollen unsere Posts aussehen“), ist das beides: Beleg für den Korpus und Kandidat für eine Referenz. Dann nach dem Einarbeiten fragen, ob er auch als Referenz (Aufbau, Länge, Bildmuster) gespeichert werden soll, Name wie in `$S/referenzen.md`. Diese Datei lesen, sobald einer der Fälle eintritt.

### 3. Texte erzeugen

Vorher lesen: Kanalkarten der gewählten Kanäle, `verbotsliste.md`, den Korpus der Marke und, falls gewählt, die Referenz. Rangfolge: Rohtext vor Verbotsliste vor Referenz-Textmuster vor Korpus vor Kanalkarte. Der Korpus bestimmt den Ton auch mit Referenz.

**Faktenliste.** Still alle Aussagen des Rohtexts nummeriert festhalten (Wer, Was, Wann, Wo, Zahlen, Zitate, Aufruf). Jede Fassung darf nur diese Fakten nutzen, umformulieren, kürzen, weglassen. Was eine Kanalkarte verlangt und nicht in der Liste steht, wird `[FEHLT: ...]`.

**Je Kanal und Sprache eine Fassung** nach Kanalkarte oder Referenz-Textmuster (Länge, Aufbau, Einstieg, CTA-Form, Hashtags, Emoji, Link). Ohne belegten Korpus gelten die Standardwerte der Karte. Hashtags nur aus Begriffen des Rohtexts. Reicht der Rohtext nicht für die Mindestlänge, bleibt die Fassung kürzer, nie auffüllen, in der Übersicht vermerken.

**Dateien** `<kanal>-<de|en>.txt` als UTF-8 ohne Markdown, mit festen Kennzeilen:
- Newsletter: `Betreff:`, `Vorschautext:`, Leerzeile, Text.
- Mail: `Betreff:`, Leerzeile, Text, `[SIGNATUR]`.
- Website: `Überschrift:`, `Teaser:`, `Meta-Beschreibung:`, Leerzeile, Fließtext mit Zwischenüberschriften als eigene Zeilen.
- LinkedIn: Post, bei Link-Aufruf danach Leerzeile und `Erster Kommentar:` mit Link oder `[FEHLT: Link]`.
- EN mit englischen Kennzeilen (`Subject:`, `Preview text:`, `Headline:`, `Teaser:`, `Meta description:`, `First comment:`, `[SIGNATURE]`).

**Design-Auftrag je Fassung**, Klartext in der Sprache der Fassung, Kennzeilen in dieser Reihenfolge:
- `Headline:` höchstens sechs Wörter, nur aus der Faktenliste.
- `Bildtext:` höchstens 20 Wörter, nur aus der Faktenliste, sonst `[FEHLT: ...]`.
- `Kicker:` optional, höchstens vier Wörter (Programm, Anlass, Datum aus dem Rohtext). Fehlt der Stoff, Zeile weglassen.
- `CTA:` optional, die Handlung aus dem Briefing in höchstens fünf Wörtern, sonst Zeile weglassen.
- `Format:` das gewählte Visual-Format (Karussell für LinkedIn als „Karussell LinkedIn (PDF, 1080 x 1080 je Seite)“, für Instagram als „Karussell Instagram (PNG je Seite)“), sonst LinkedIn 1:1 (1200 x 1200), Instagram 4:5 (1080 x 1350), Newsletter und Mail Kopfbild 2:1 (1200 x 600), Website 16:9 (1920 x 1080). 2:1 und 16:9 baut dieser Skill nicht, die gehen in Claude Design oder Figma.
- `Kanal:`, `Marke:`, `Stimmung:` (ein Satz aus Rohtext und Korpus, ohne neue Fakten).
Farben, Schriften und Logos nennt der Auftrag nicht.

**`uebersicht.md`** im Laufordner: Kopfzeile (Datum, Slug, Marke, Kanäle, Sprachen, Visuals, Referenz, Korpus-Status), alle Fassungen in Codeblöcken, Abschnitt `## Design-Aufträge` mit je einem Codeblock pro Fassung (überschrieben mit Kanal und Sprache), bei Visuals Abschnitt `## Visuals` mit Vorlage, Format, Sprache und PNG-Pfaden, am Ende Prüfprotokoll (Ergebnis von pruefen.sh, alle `[FEHLT]`-Stellen, Faktenliste mit Vermerk, welche Fakten in welchen Fassungen stehen).

**Prüfen, bevor der Nutzer etwas sieht.**
1. `bash "$S/scripts/pruefen.sh" content-und-social/ausgabe/<lauf> --zusatz content-und-social/stil/<marke>/voice.md` (ohne Korpus ohne `--zusatz`). Nach dem Schreiben von `uebersicht.md` erneut, dann prüft es die Design-Aufträge mit.
2. Jeden VERSTOSS beheben und neu prüfen, bis keiner mehr da ist. HINWEISE einzeln ansehen und nur beheben, wenn sie zutreffen. Eine Länge, die bewusst der Referenz folgt, ist kein Fehler.
3. Selbst Satz für Satz gegen die Faktenliste lesen. Drei Adjektive in Reihe und rhetorische Fragen als Einstieg zusätzlich mit eigenem Blick prüfen.

### 4. Visuals (nur wenn gewählt)

`$S/visuals.md` lesen und danach arbeiten. Kurz: Vorlage selbst wählen und in einem Satz sagen (Statement für eine Kernaussage, Info für drei klare Punkte mit Aufruf, Karussell nur wenn gewählt, mit Referenz deren Bildmuster), auf Wunsch eine andere. Je Format und Sprache `vorbereiten.sh` nach `bilder/_build/<format>-<sprache>/`, `inhalt.json` aus dem Design-Auftrag, `render.sh` in die Vorschau, jede Vorschau mit Read ansehen und selbst nachbessern. Fertige PNGs erst nach Freigabe nach `bilder/`. Ein Karussell für LinkedIn bekommt zusätzlich eine PDF mit allen Seiten (`scripts/pdf.sh`), denn LinkedIn nimmt Karussells nur als PDF-Dokument.

### 5. Ausgabe im Chat

Je Kanal und Sprache ein Block mit Überschrift (`LinkedIn, Deutsch, 1.104 Zeichen`) und dem Text in einem Codeblock zum Kopieren, darunter der Design-Auftrag als eigener kurzer Codeblock. Bei Visuals danach je Bild (und je Karussell-PDF) eine Zeile mit Format, Sprache und Pfad. Öffnen nur als Angebot in einem Satz („Soll ich dir den Bildordner öffnen?“) und nach einem Ja selbst ausführen (macOS `open "<pfad>"`, Windows `explorer.exe "$(cygpath -w "<pfad>")"`), den Befehl nie zeigen. Darunter in einer Zeile der Laufordner und die offenen `[FEHLT]`-Stellen als kurze Liste. Am Ende: „Sag mir, was ich an welcher Fassung oder welchem Bild ändern soll, oder was in die Zwischenablage soll.“ Ist der Korpus vorläufig, hängt genau ein Halbsatz an („und schick mir gern ein paar eigene Texte, dann trifft es deinen Ton besser“).

Ohne Visuals endet der Lauf nach Schritt 6 und 7. Der Design-Auftrag lässt sich in Claude Design oder Figma nutzen, oder der Nutzer sagt später „mach mir das Bild dazu“, dann Schritt 4 für diesen Lauf.

### 6. Feedback und Nachbessern

- Gilt auch für Läufe aus früheren Sessions: den Laufordner unter `C/ausgabe/` suchen, bei mehreren Treffern kurz fragen.
- Nur die genannte Fassung oder das genannte Bild ändern. Würde die Korrektur anderswo auch passen, einmal fragen, ob die anderen nachziehen sollen.
- Text: alte Fassung nach `_alt/<kanal>-<sprache>-vN.txt`, ändern, pruefen.sh erneut, `uebersicht.md` aktualisieren. Ändert sich die Headline-Grundlage, Design-Auftrag mitziehen und ein vorhandenes Visual dieser Fassung neu rendern.
- Bild: nach `visuals.md` (Abschnitt Feedback), höchstens drei Runden ohne Rückfrage, dann fragen, ob der Rest in Figma oder Claude Design schneller geht.
- Korrekturen nach Art merken (zu lang, zu förmlich, zu locker, zu werblich, Einstieg zu schwach, falsches Wort). Beim zweiten Mal derselben Art fragen: „Das ist das zweite Mal „<Art>“. Soll ich das als feste Regel in deinen Stil-Korpus schreiben?“ Bei Ja unter „Gelernte Regeln“ im Korpus der Marke (Datum, Regel, Anlass), ein Verbotswort unter „Eigene Verbote“. Danach Budget prüfen (`korpus.md`).

### 7. Als Referenz speichern (nach Freigabe)

Sagt der Nutzer, dass der Lauf passt (Text oder Visual freigegeben), **genau einmal** fragen: „Soll ich diesen Post als Referenz speichern, damit künftige Posts so aussehen und klingen? Wenn ja, gib ihm einen Namen (zum Beispiel Career-Day-Ankündigung).“ Bei Ja `C/referenzen/<marke>/<name>.md` nach `$S/referenzen.md` anlegen. Bei Nein nicht wieder fragen. Auf Zuruf („nimm diesen Post als neue Fassung der Referenz X“) die alte nach `C/referenzen/<marke>/_alt/` verschieben und neu schreiben.

### 8. Zwischenablage (nur auf Wunsch)

Nur die genannte Fassung, nur aus der Datei, nie aus dem Chat-Text. Ein Design-Auftrag kommt aus seinem Block in `uebersicht.md` (ohne Codeblock-Zeichen), vorher als `_alt/design-<kanal>-<sprache>.tmp` im Laufordner ablegen. Bei Kanälen mit Kennzeilen fragen, ob der ganze Block oder nur der Text kopiert werden soll.
- macOS: `LANG=en_US.UTF-8 pbcopy < <datei>`, danach `LANG=en_US.UTF-8 pbpaste | head -3` und Umlaute prüfen.
- Windows (Git Bash): `powershell.exe -NoProfile -Command "Get-Content -Raw -Encoding UTF8 '<datei>' | Set-Clipboard"`, Pfad relativ zum Projektordner oder per `cygpath -w`. Nie `clip` (verstümmelt Umlaute). Prüfen mit `powershell.exe -NoProfile -Command "[Console]::OutputEncoding=[Text.Encoding]::UTF8; Get-Clipboard" | head -3`. Dem Nutzer sagen: Strg+V fügt im Git-Bash-Fenster nicht ein (Rechtsklick und Einfügen oder Umschalt+Einfg), überall sonst schon.
- PNGs und PDFs kommen nicht in die Zwischenablage, dafür den Pfad nennen und anbieten, den Ordner zu öffnen (wie in Schritt 5, nach einem Ja selbst ausführen).

## Was der Skill nicht tut

Nicht posten, hochladen oder planen. Keine weiteren Sprachen als DE und EN, keine Fakten recherchieren. Keine Fotos, Stockbilder oder KI-Bilder, keine Farben, Logos oder Schriften außerhalb des Marken-Guides, keine Änderungen an Vorlagen im Skill-Ordner. Fragt der Nutzer danach, kurz sagen und verweisen (Videos motion-graphic, Flyer und Slides designer, Fotos und freie Layouts Figma oder Claude Design).
