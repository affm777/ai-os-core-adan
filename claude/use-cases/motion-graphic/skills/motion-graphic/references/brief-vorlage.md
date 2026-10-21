# Brief-Vorlage

Datei `videos/<slug>/brief/BRIEF.md`. Die Statuszeile steht immer in Zeile 3, weil der Wiedereinstieg danach sucht. Status ist `offen` oder `fertig`, dahinter der nächste Schritt.

Der Brief ist ein Produktionsauftrag, keine Stimmungsbeschreibung. Er hat sechs Blöcke: MARKE, FORMAT, BEATS, KAMERA, LOOK, PRÜFUNG. Zwischen zwei Marken (etwa ADAN e.V. und ADAN Impact) ändert sich nur der Block MARKE, alles andere bleibt gleich.

```markdown
# Brief: <Titel des Videos>

Stand <Datum>, Status: offen (nächster Schritt: <Rahmen | Look | Storyboard | Bauen | Vorschau | Endfassung>)

## 1. Worum es geht
Rohtext des Nutzers: <wörtlich, unverändert>
Verstanden: <drei Sätze: Thema, Zielgruppe, Kernbotschaft>
Story-Idee des Nutzers: <übernommen | keine, Bogen von Claude vorgeschlagen>

## 2. FORMAT
Kanal und Format: <9:16 | 16:9 | beide>, Länge: <s>, Tempo: <BPM, Standard 120>, Drop bei: <s oder keiner>
Stimme: <keine | eigene Datei (Pfad) | ElevenLabs>
Ton: <kein Ton | Geräusche ElevenLabs | Geräusche plus Musik ElevenLabs | eigene Musikdatei (Pfad) plus Geräusche>, Credits geschätzt: <Zahl>
Zeitquelle: film-vN/timeline.js (Bild und Klang lesen dieselbe Datei)

## 3. MARKE
Marke: <Name>, Style-Guide: <Pfad>
Farben, Schriften (lokal, Dateipfad), Logo (Pfad)
Bei Stilkarte held-baut zusätzlich: Held (Spielzeugform aus der Bildmarke), App (nachgebaute Oberfläche mit echten Feldnamen), Ergebnis (was gebaut wird), Bühne (Nachtglas | Studio hell)

## 4. Vorbilder
| Referenz | Look | Bewegung | Was wir übernehmen |
|---|---|---|---|
| referenzen/<datei> | ... | ... | ... |
Stilkarte (Pflicht, ohne sie kein Bau): <Karte aus muster/ und warum>
Rezept: <Rezept aus der Karte, welche Bausteine genutzt werden>

## 5. BEATS (Tor 1)
Kernaussage: <ein Satz>
Leitplanken: <was nicht behauptet wird, nur Zahlen und Namen aus dem Rohtext>

| Sekunde | Text | Was passiert (Bildidee) | Bewegung | Klang |
|---|---|---|---|---|
| 0 bis 1,5 | ... | ... | ... | ... |

Jede Zeile verändert sichtbar etwas. Jede Aktion mit Klang steht später mit derselben Zeit in timeline.js.

KAMERA: <Start weit oder nah, wem sie folgt, wo sie endet, letztes Bild als Plakat>
LOOK: <Bühne, Licht, Stilkarte in einem Satz, was ausdrücklich nicht passieren darf, etwa Lichtflecken auf Bildschirmen>

Abnahme: <Datum, „passt“ oder Korrekturen>

## 6. Fassungen
| Fassung | Datum | Datei | Feedback |
|---|---|---|---|
| v1 | ... | renders/v1/<datei>.mp4 | brief/FEEDBACK-v1.md |

## 7. Technik
HyperFrames <Version aus VERSION>, Auflösung, fps Vorschau 30 und Endfassung 60, Endfassung in final/
3D: <nein | ja, Three.js nach references/drei-d.md>
Übernommene Techniken aus dem Rezept der Karte (mindestens drei): <...>

## 8. PRÜFUNG
| Runde | Was gesehen | Fix mit Zahl | Messung |
|---|---|---|---|
| Stills r1 | ... | ... | Farbe Delta E, Lautheit |

Pflicht vor der Vorschau: Stills-Raster angesehen, Markenfarbe gemessen (farbe_pruefen.mjs), mit Ton Lautheitsverlauf und True Peak (lautheit.sh).
```
