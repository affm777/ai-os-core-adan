# Brief-Vorlage

Datei `videos/<slug>/brief/BRIEF.md`. Die Statuszeile steht immer in Zeile 3, weil der Wiedereinstieg danach sucht. Status ist `offen` oder `fertig`, dahinter der nächste Schritt.

```markdown
# Brief: <Titel des Videos>

Stand <Datum>, Status: offen (nächster Schritt: <Rahmen | Look | Storyboard | Bauen | Vorschau | Endfassung>)

## 1. Worum es geht
Rohtext des Nutzers: <wörtlich, unverändert>
Verstanden: <drei Sätze: Thema, Zielgruppe, Kernbotschaft>
Story-Idee des Nutzers: <übernommen | keine, Bogen von Claude vorgeschlagen>

## 2. Rahmen
Kanal und Format: <9:16 | 16:9 | beide>, Länge: <s>
Stimme: <keine | eigene Datei (Pfad) | ElevenLabs>, Musik: <keine | eigene Datei (Pfad) | ElevenLabs>

## 3. Marke
Marke: <Name>, Style-Guide: <Pfad>
Farben, Schriften (lokal, Dateipfad), Logo (Pfad)

## 4. Vorbilder
| Referenz | Look | Bewegung | Was wir übernehmen |
|---|---|---|---|
| referenzen/<datei> | ... | ... | ... |
Stilkarte (Pflicht, ohne sie kein Bau): <Karte aus muster/ und warum>
Rezept: <Rezept aus der Karte, welche Bausteine genutzt werden>

## 5. Storyboard (Tor 1)
Kernaussage: <ein Satz>
Leitplanken: <was nicht behauptet wird, nur Zahlen und Namen aus dem Rohtext>

| Szene | Text | Bildidee | Bewegung | Sekunden |
|---|---|---|---|---|
| 1 | ... | ... | ... | 0 bis 3 |

Abnahme: <Datum, „passt“ oder Korrekturen>

## 6. Fassungen
| Fassung | Datum | Datei | Feedback |
|---|---|---|---|
| v1 | ... | renders/v1/<datei>.mp4 | brief/FEEDBACK-v1.md |

## 7. Technik
HyperFrames <Version aus VERSION>, Auflösung, fps Vorschau 30 und Endfassung 60, Endfassung in final/
Übernommene Techniken aus dem Rezept der Karte (mindestens drei): <...>
```
