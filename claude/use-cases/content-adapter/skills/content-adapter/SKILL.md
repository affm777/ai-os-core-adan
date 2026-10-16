---
name: content-adapter
description: Formt eine Idee oder einen fertigen Kerntext in Fassungen für LinkedIn, Instagram, Newsletter, Mail und Website um, auf Deutsch und Englisch, in der eigenen Tonalität aus einem Stil-Korpus (content/voice.md) und ohne AI-Slop. Erfindet nichts, markiert Fehlendes als [FEHLT: ...], prüft jede Fassung gegen eine Verbotsliste und legt alles im Arbeitsordner unter content/ausgabe/ ab. Baut auf Wunsch den Stil-Korpus aus eigenen Texten auf. Nutze diesen Skill IMMER, wenn ein vorhandener Text oder eine Idee für einen oder mehrere Kanäle aufbereitet werden soll, auch ohne das Wort „Content“.
when_to_use: |
  Trigger-Phrasen: "mach daraus einen LinkedIn-Post", "bereite das für Instagram auf", "schreib das für den Newsletter um", "mach daraus Posts für alle Kanäle", "Fassungen für LinkedIn und Website", "auf Englisch und Deutsch für Social Media", "Content adaptieren", "Stil-Korpus anlegen", "lern meinen Schreibstil", "hier sind Beispieltexte für meine Voice", "/content-adapter". Auch zum Nachbessern einer Fassung aus einem früheren Lauf ("mach die LinkedIn-Fassung kürzer").
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
- **Sichtbare Texte im Chat** auf Deutsch mit echten Umlauten.

## Pfade

- Skill-Ordner `S=~/.claude/skills/content-adapter`. Kanalkarten `$S/kanaele/<kanal>.md`, Verbotsliste `$S/verbotsliste.md`, Korpus-Vorlage `$S/voice-vorlage.md`, Prüfung `bash "$S/scripts/pruefen.sh" <laufordner>`.
- Arbeitsordner ist das aktuelle Verzeichnis. Nutzerdaten liegen nur dort, nie im Skill:
  - `content/voice.md` Stil-Korpus des Nutzers (Budget 120 Zeilen, 8 KB)
  - `content/_alt/` Sicherungen von voice.md vor jeder Verdichtung oder Neuableitung
  - `content/beispiele/` eigene Texte als Quelle für den Korpus
  - `content/ausgabe/YYYY-MM-DD-<slug>/` je Lauf `rohtext.md`, `<kanal>-<de|en>.txt`, `uebersicht.md`
- Kanalnamen in Dateinamen: `linkedin`, `instagram`, `newsletter`, `mail`, `website`.
- Plattform macOS oder Windows mit Git Bash. Keine weiteren Programme nötig.

## Ablauf

### 1. Korpus prüfen

`content/voice.md` im Arbeitsordner suchen (Glob, auch `**/content/voice.md` eine Ebene tiefer). Gefunden: lesen, Statuszeile merken, still weiter zu Schritt 2. Fehlt sie, nicht fragen, ob ein Korpus angelegt werden soll, sondern direkt mit dem Interview (1a) starten. Ankündigung in einem Satz:

> Bevor wir loslegen, sechs kurze Fragen zu deinem Ton (rund zwei Minuten), damit die Texte nach dir klingen.

### 1a. Erster Lauf: Interview

Zwei AskUserQuestion-Runden zu je drei Fragen.

Runde 1:
1. Anrede: Du, Sie, ihr (Mehrfachauswahl, falls je Kanal verschieden, Freitext über „Sonstiges“).
2. Ton: drei Wörter, die deinen Ton beschreiben (Optionen z. B. „sachlich, klar, ruhig“, „herzlich, direkt, locker“, „kurz, nahbar, humorvoll“, eigene über „Sonstiges“).
3. Humor: nein, leise, gern.

Runde 2:
4. Emoji: keine, sparsam (höchstens eins), gern.
5. Hashtags: keine, zwei bis drei, nach Kanalkarte.
6. Je ein Text, der dir gefällt oder nicht gefällt: „Füge ich ein“, „Nenne ich als Datei oder Link“, „Überspringen“.

Bei „Füge ich ein“ oder Datei kurz warten und beide Texte lesen. Daraus sofort eine erste `content/voice.md` nach `voice-vorlage.md` schreiben, mit der Statuszeile

`Stand: vorläufig, aus Interview vom <JJJJ-MM-TT>, 0 Belegtexte, <N> Regeln, 0 gelernte Regeln`

Belege sind die Antworten des Nutzers, gekennzeichnet als „(Interview)“. Was aus dem Text, der nicht gefällt, folgt, kommt als Muster unter „Eigene Verbote“ oder als Regel unter „Wörter, die du nie nutzt“. Danach genau ein Satz:

> Dein Ton wird deutlich besser, sobald ich fünf bis zehn eigene Texte von dir kenne. Sag dafür jederzeit „hier sind Beispieltexte für meine Voice“ und nenn Dateien oder einen Ordner.

Dann weiter zu Schritt 2. Bricht der Nutzer das Interview ab, ohne voice.md weiter (Kanalkarten allein, in der Übersicht „ohne Stil-Korpus erstellt“).

### 1b. Beispieltexte nachreichen (jederzeit, auch mitten in einem Lauf)

Auslöser: „hier sind Beispieltexte für meine Voice“, „lern meinen Stil aus diesen Texten“ oder Dateien, die erkennbar als Stilvorlage gemeint sind. Ein laufender Lauf wird dafür unterbrochen und danach an derselben Stelle fortgesetzt.

Eingefügte Texte als `content/beispiele/NN-<kurzname>.md` speichern, genannte Dateien nur lesen (nicht kopieren, nicht verschieben). Dann ableiten:

Anrede (Du, Sie, ihr), Satzlänge, Rhythmus, typische Einstiege, typische Schlüsse, wie über die Zielgruppe gesprochen wird, Wörter die der Nutzer nutzt, Wörter die er nie nutzt, Emoji-Praxis, Hashtag-Praxis, Humor ja oder nein, EN-Tonalität falls EN-Beispiele da sind.

Pro Regel höchstens zwei Originalzitate als Beleg, wörtlich und mit Quelldatei. Gibt es keine zwei Belege, steht dort „zu wenig Belege, vorläufig“ und die Regel ist weich formuliert. Nichts als Regel festschreiben, was nur einmal vorkommt.

Vor dem Schreiben eine Kopie nach `content/_alt/voice-<JJJJ-MM-TT>.md` (gibt es die schon, `-2` anhängen). Dann einarbeiten:
- Interview-Annahmen, die die Texte bestätigen, bekommen Textbelege statt „(Interview)“.
- Interview-Annahmen, denen die Texte widersprechen, werden ersetzt. Ausnahme Anrede und alles, was der Nutzer ausdrücklich gesagt hat: dann eine Frage stellen statt ersetzen.
- Neue Regeln aus den Texten kommen dazu, „Gelernte Regeln“ und „Eigene Verbote“ bleiben stehen.
- Statuszeile auf `Stand: belegt, <N> Texte, aktualisiert <JJJJ-MM-TT>, <R> Regeln, <G> gelernte Regeln` setzen (N = Zahl aller gelesenen Beispieltexte, R = Abschnitte mit Regel, G = Einträge unter „Gelernte Regeln“). Unter drei Texten zusätzlich sagen, dass der Korpus noch dünn ist.

Danach in höchstens zehn Zeilen zusammenfassen („So schreibst du, so habe ich es verstanden“, was sich gegenüber dem Interview geändert hat) und fragen, was falsch oder zu streng ist. Korrekturen sofort einschreiben, Korrekturen des Nutzers gehen jedem Beleg vor. Danach Budget prüfen (1c).

### 1c. Budget und Selbstverdichtung von voice.md

Budget: höchstens 120 Zeilen und 8 KB, höchstens zehn Einträge unter „Gelernte Regeln“, höchstens 20 Muster unter „Eigene Verbote“. Nach jeder Änderung an voice.md prüfen:

`wc -l < content/voice.md; wc -c < content/voice.md`

Gelernte Regeln zählen (Zeilen, die mit `- ` beginnen, im Abschnitt „Gelernte Regeln“), Muster im Block von „Eigene Verbote“ zählen. Ist eine Grenze überschritten:
1. Kopie nach `content/_alt/voice-<JJJJ-MM-TT>.md` (bei Bedarf `-2`).
2. Gelernte Regeln in die passenden Abschnitte einsortieren (Anrede, Satzlänge, Einstiege, Schlüsse, Wörter, Emoji, Hashtags, Humor, Englisch). Der Abschnitt „Gelernte Regeln“ ist danach leer bis auf Regeln, die nirgends passen.
3. Doppelte oder überlappende Regeln zu einer zusammenführen.
4. Je Regel höchstens zwei Belege, die kürzesten bleiben.
5. Eigene Verbote über 20 zu gemeinsamen Mustern zusammenfassen (z. B. `event|veranstaltung` statt zwei Zeilen), nichts weglassen.
6. Widersprechen sich zwei Regeln, nicht selbst entscheiden: eine Frage an den Nutzer mit beiden Regeln, erst nach der Antwort eintragen.
7. Statuszeile aktualisieren, erneut `wc` laufen lassen. Bleibt es über Budget, die längsten Abschnitte nennen und fragen, was gekürzt werden darf.

Ergebnis in einem Satz nennen: „Stil-Korpus verdichtet, vorher X Zeilen, nachher Y, Kopie in content/_alt/.“

### 2. Briefing

Rohtext oder Idee kommt frei im Chat oder als Datei. Wörter zählen.

**Nur eine Idee (unter 40 Wörtern):** vorher fragen, frei im Chat:

> Erzähl mir den Kern in zwei, drei Sätzen. Was ist passiert oder was wird angeboten, für wen und warum jetzt?

Danach eine Fragerunde (AskUserQuestion, genau eine Runde, höchstens vier Fragen):

1. Kanäle (Mehrfachauswahl): LinkedIn, Instagram, Newsletter, Mail, Website. Weil AskUserQuestion höchstens vier Optionen zeigt, Mail und Website als eine Option „Mail und Website“ anbieten, alles andere kommt über „Sonstiges“ als Freitext.
2. Sprachen: Deutsch, Englisch, beide.
3. Call-to-Action oder Link: „Link folgt / habe ich“ (dann Freitext), „Handlung ohne Link“ (z. B. Melden per Mail), „Kein Call-to-Action“.
4. Bild, Termin oder Deadline: „Bild vorhanden“, „Termin oder Deadline“ (Freitext), „Beides“, „Nichts davon“.

Antworten sind ab jetzt Teil der Wahrheit. Einen kurzen Slug festlegen (Kleinbuchstaben, Bindestriche, ohne Umlaute, höchstens fünf Wörter). Laufordner `content/ausgabe/<heute>-<slug>/` anlegen (existiert er, `-2` anhängen) und den Rohtext plus Briefing-Antworten wörtlich als `rohtext.md` speichern.

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
2. Jeden VERSTOSS beheben und erneut prüfen, bis keiner mehr da ist. HINWEISE einzeln ansehen (z. B. ist „ADAN“ kein Großschreib-Verstoß) und nur beheben, wenn sie zutreffen.
3. Selbst gegen die Faktenliste lesen, Satz für Satz. Jede Aussage, die nicht in der Liste steht, streichen oder in `[FEHLT]` umwandeln. Drei Adjektive in Reihe und rhetorische Fragen als Einstieg zusätzlich mit eigenem Blick prüfen, das Script findet nicht alle.

**`uebersicht.md`** im Laufordner: Kopfzeile mit Datum, Slug, Kanälen, Sprachen und Korpus-Status („Stil-Korpus belegt, N Texte“, „Stil-Korpus vorläufig aus Interview“ oder „ohne Stil-Korpus“). Dann alle Fassungen in Codeblöcken (dort darf Markdown stehen, die Kanaltexte selbst bleiben Klartext). Am Ende ein Prüfprotokoll: Ergebnis von `pruefen.sh`, Liste aller `[FEHLT]`-Stellen, Faktenliste mit dem Vermerk, welche Fakten in welchen Fassungen vorkommen.

**Ausgabe im Chat:** je Kanal und Sprache ein Block mit Überschrift (`LinkedIn, Deutsch, 1.104 Zeichen`) und dem Text in einem Codeblock zum Kopieren. Darunter in einer Zeile der Ablageort der Dateien und die offenen `[FEHLT]`-Stellen als kurze Liste. Am Ende die Zeile „Sag mir, was ich an welcher Fassung ändern soll, oder welche Fassung in die Zwischenablage soll.“ Steht die Statuszeile auf „vorläufig“, hängt an diese Zeile genau ein Halbsatz als Erinnerung („und schick mir gern ein paar eigene Texte, dann trifft es deinen Ton besser“). Nicht öfter, nicht als eigener Absatz.

### 4. Feedback

- Nur die genannte Fassung ändern. Die anderen bleiben unangetastet, auch wenn die Korrektur dort ebenfalls passen würde. Ist das so, einmal fragen, ob die anderen nachziehen sollen.
- Vor dem Überschreiben die bisherige Fassung nach `_alt/` kopieren (Grundregel), danach `pruefen.sh` erneut laufen lassen und `uebersicht.md` aktualisieren.
- Korrekturen im Gespräch nach Art merken (zu lang, zu förmlich, zu locker, zu werblich, Einstieg zu schwach, falsches Wort). Kommt dieselbe Art zum zweiten Mal, fragen:

> Das ist das zweite Mal „<Art>“. Soll ich das als feste Regel in deinen Stil-Korpus schreiben, damit es künftig gleich passt?

Bei Ja in `content/voice.md` unter „Gelernte Regeln“ eintragen (Datum, Regel in einem Satz, Anlass). Ein neues Verbotswort kommt unter „Eigene Verbote“. Ohne voice.md bei Ja die Datei aus `voice-vorlage.md` anlegen (Status vorläufig) und nur diese Regel eintragen. Danach Statuszeile aktualisieren und Budget prüfen (1c).

### 5. Zwischenablage (nur auf Wunsch)

Nur die genannte Fassung, nur aus der Datei, nie aus dem Chat-Text:
- macOS: `LANG=en_US.UTF-8 pbcopy < <datei>`, danach `LANG=en_US.UTF-8 pbpaste | head -3` und prüfen, dass Umlaute stimmen.
- Windows (Git Bash): `powershell.exe -NoProfile -Command "Get-Content -Raw -Encoding UTF8 '<datei>' | Set-Clipboard"`. Nicht `clip`, weil `clip` UTF-8-Umlaute ohne BOM verstümmelt. Prüfen mit `powershell.exe -NoProfile -Command "Get-Clipboard" | head -3`.
- Bei Kanälen mit Kennzeilen (Betreff, Überschrift) fragen, ob der ganze Block oder nur der Text kopiert werden soll.

## Was der Skill nicht tut

Nicht posten oder planen, keine Bilder erzeugen, keine weiteren Sprachen als DE und EN, keine Fakten recherchieren. Fragt der Nutzer danach, das kurz sagen und auf passende Skills verweisen (Bilder: designer, Video: motion-graphic).
