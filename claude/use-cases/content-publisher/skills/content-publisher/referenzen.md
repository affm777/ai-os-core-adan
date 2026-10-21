# Referenzen speichern und anwenden

Teil des Skills content-publisher. Claude liest diese Datei, wenn ein Lauf freigegeben ist (Frage nach dem Speichern), wenn der Nutzer eine Referenz wählt oder nennt oder eine Referenz aktualisieren will. `C` steht für `content-und-social/` im Projektordner.

Eine Referenz hält fest, wie ein gelungener Post aufgebaut ist und aussieht, damit künftige Posts derselben Art so klingen und aussehen. Sie ist ein Muster, keine Faktenquelle. **Aus einer Referenz kommt nie ein Fakt (Datum, Ort, Zahl, Name, Link, Zitat) in einen neuen Post.**

## Speichern

Nach der Freigabe genau einmal fragen (Wortlaut in der SKILL.md, Schritt 7). Bei Ja:

1. Namen in einen Dateinamen umwandeln: Kleinbuchstaben, Bindestriche, ohne Umlaute (`career-day-ankuendigung`). Der Anzeigename mit Umlauten steht im Frontmatter.
2. Gibt es `C/referenzen/<marke>/<datei>.md` schon, fragen, ob die alte Fassung ersetzt werden soll (dann wie „Aktualisieren“) oder ein anderer Name gewünscht ist.
3. Datei aus den freigegebenen Fassungen und Visuals des Laufs schreiben, Aufbau unten. Höchstens rund 60 Zeilen. Als Beispiel steht nur **eine** Fassung im Wortlaut (bevorzugt LinkedIn oder Instagram in der ersten gewählten Sprache), die übrigen Kanäle nur als Muster-Zeile.
4. In einem Satz bestätigen: „Gespeichert als Referenz <Name> für <Marke>. Sag beim nächsten Mal einfach ‚wie die <Name>‘.“

## Aufbau

```markdown
---
name: Career-Day-Ankündigung
marke: adan-ev
datum: 2026-10-22
lauf: content-und-social/ausgabe/2026-10-22-career-day-2027
kanaele: [linkedin, instagram]
sprachen: [de, en]
vorlage: statement
format: ig-4x5
farben: {}            # nur Werte, die vom Marken-Guide abweichen, etwa {"--sp-farbe-flaeche": "#BF2806"}
---

## Textmuster
- Aufbau: (z. B. Hook mit Anlass und Jahr, zwei kurze Absätze, Aufruf als eigener Satz)
- Länge je Kanal: (z. B. LinkedIn rund 900 Zeichen, Instagram rund 160 Wörter)
- Einstieg: (Art des ersten Satzes, nicht der Wortlaut)
- CTA-Form: (z. B. Imperativ plus „Link im ersten Kommentar“)
- Hashtags: (Anzahl je Kanal, Position)
- Weitere Kanäle: (je Kanal eine Zeile, falls abweichend)

## Beispiel (freigegebene Fassung, nur als Muster)
(Wortlaut einer Fassung, Kanal und Sprache in der ersten Zeile)

## Bildmuster
- Vorlage: statement
- Format: ig-4x5
- Kicker: ja oder nein (und welche Art, etwa Programmname)
- Headline: Wortzahl, hervorgehobenes Wort ja oder nein
- Subline oder Punkte: Wortzahl
- CTA im Bild: ja oder nein
- Farben: wie Marken-Guide oder Abweichung

## Beispiel-PNG
content-und-social/ausgabe/<lauf>/bilder/<marke>-<format>-<sprache>-01.png
```

Gab es im Lauf keine Visuals, bleiben Bildmuster und Beispiel-PNG mit „keine Visuals im Lauf“ stehen.

## Anwenden

- Fragerunde und Nennung in der Nachricht stehen in der SKILL.md, Schritt 1. Bei mehr als drei Referenzen einer Marke die drei neuesten (Frontmatter `datum`) als Optionen, alle weiteren über „Sonstiges“.
- Referenz lesen. **Textmuster** gilt vor der Kanalkarte (Länge, Aufbau, Einstieg, CTA-Form, Hashtag-Zahl). Verbotsliste und Rohtext gehen weiter vor, der Korpus bestimmt den Ton. Grenzen der Kanalkarte, die Plattformen erzwingen (etwa Link nie im LinkedIn-Post), bleiben.
- **Bildmuster** gilt vor der eigenen Vorlagenwahl: dieselbe Vorlage, dasselbe Format (wenn der Nutzer kein anderes gewählt hat), Kicker und CTA wie in der Referenz, sofern der Rohtext den Stoff dafür hergibt, `farben` aus dem Frontmatter in `inhalt.json`. Im Chat in einem Satz sagen: „Ich arbeite nach der Referenz <Name>.“
- Das Beispiel nur für Aufbau und Rhythmus nutzen. Wörter oder Sätze daraus nicht übernehmen, außer sie stehen auch im neuen Rohtext.
- Wählt der Nutzer Kanäle, die in der Referenz fehlen, gelten für diese die Kanalkarten.

## Aktualisieren

Auslöser etwa „nimm diesen Post als neue Fassung der Referenz X“ oder „die Referenz X soll künftig ohne Kicker sein“. Alte Datei nach `C/referenzen/<marke>/_alt/<datei>-<JJJJ-MM-TT>.md` verschieben (mv, bei Bedarf `-2`), dann neu schreiben, aus dem genannten Lauf oder mit der genannten Änderung. Ein Satz Bestätigung mit dem, was sich geändert hat.

## Grenzen

Höchstens rund 60 Zeilen je Referenz. Wird eine länger, das Beispiel kürzen (Hashtags und Kommentarzeile weglassen), nie die Muster. Referenzen nie löschen, nur nach `_alt/` verschieben.
