# Stil-Korpus aufbauen und pflegen

Teil des Skills content-adapter. Claude liest diese Datei nur, wenn ein Korpus fehlt (Interview), Beispieltexte nachgereicht werden oder voice.md über Budget liegt. Danach geht es an der Stelle in der SKILL.md weiter, an der der Lauf unterbrochen wurde. Pfade und Mehrere-Marken-Regel stehen in der SKILL.md unter „Pfade“.

## Erster Lauf: Interview

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

Dann weiter mit Schritt 2 der SKILL.md. Bricht der Nutzer das Interview ab, ohne voice.md weiter (Kanalkarten allein, in der Übersicht „ohne Stil-Korpus erstellt“).

## Beispieltexte nachreichen (jederzeit, auch mitten in einem Lauf)

Auslöser: „hier sind Beispieltexte für meine Voice“, „lern meinen Stil aus diesen Texten“ oder Dateien, die erkennbar als Stilvorlage gemeint sind. Ein laufender Lauf wird dafür unterbrochen und danach an derselben Stelle fortgesetzt.

Nennt der Nutzer eine Marke („Beispieltexte für die Marke ADAN Careers“), gilt der Korpus dieser Marke, fehlt er, wird `content/stil/<marke>/` angelegt. Gibt es mehrere Marken und keine ist genannt, zuerst nach der Marke fragen. Kommt eine zweite Marke dazu und es gibt noch ein `content/voice.md` ohne Marke, fragen, zu welcher Marke es gehört, es nach `content/stil/<marke>/voice.md` kopieren und das Original nach `content/_alt/voice-<JJJJ-MM-TT>.md` verschieben (nie löschen).

Eingefügte Texte als `content/beispiele/NN-<kurzname>.md` speichern, genannte Dateien nur lesen (nicht kopieren, nicht verschieben). Nennt der Nutzer einen fertigen Korpus-Entwurf im Aufbau von `voice-vorlage.md` (etwa `voice-entwurf.md`), ist er der Ausgangspunkt für den aktiven Korpus und wird mit den Belegen aus den Texten abgeglichen. Dann ableiten:

Anrede (Du, Sie, ihr), Satzlänge, Rhythmus, typische Einstiege, typische Schlüsse, wie über die Zielgruppe gesprochen wird, Wörter die der Nutzer nutzt, Wörter die er nie nutzt, Emoji-Praxis, Hashtag-Praxis, Humor ja oder nein, EN-Tonalität falls EN-Beispiele da sind.

Pro Regel höchstens zwei Originalzitate als Beleg, wörtlich und mit Quelldatei. Gibt es keine zwei Belege, steht dort „zu wenig Belege, vorläufig“ und die Regel ist weich formuliert. Nichts als Regel festschreiben, was nur einmal vorkommt.

Vor dem Schreiben eine Kopie nach `content/_alt/voice-<JJJJ-MM-TT>.md` (gibt es die schon, `-2` anhängen). Dann einarbeiten:
- Interview-Annahmen, die die Texte bestätigen, bekommen Textbelege statt „(Interview)“.
- Interview-Annahmen, denen die Texte widersprechen, werden ersetzt. Ausnahme Anrede und alles, was der Nutzer ausdrücklich gesagt hat: dann eine Frage stellen statt ersetzen.
- Neue Regeln aus den Texten kommen dazu, „Gelernte Regeln“ und „Eigene Verbote“ bleiben stehen.
- Statuszeile auf `Stand: belegt, <N> Texte, aktualisiert <JJJJ-MM-TT>, <R> Regeln, <G> gelernte Regeln` setzen (N = Zahl aller gelesenen Beispieltexte, R = Abschnitte mit Regel, G = Einträge unter „Gelernte Regeln“). Unter drei Texten zusätzlich sagen, dass der Korpus noch dünn ist.

Danach in höchstens zehn Zeilen zusammenfassen („So schreibst du, so habe ich es verstanden“, was sich gegenüber dem Interview geändert hat) und fragen, was falsch oder zu streng ist. Korrekturen sofort einschreiben, Korrekturen des Nutzers gehen jedem Beleg vor. Danach Budget prüfen (Abschnitt „Budget“ unten).

## Budget und Selbstverdichtung von voice.md

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
