# Muster: Held baut

Quelle: Methode aus dem Guide „Claude + Blender: Make 3D Motion Graphics From Code“ (AI Automation Society, nach dem Prompt-Aufbau von rari), übertragen auf Three.js in HyperFrames. Eigene Probe am 21.10.2026.
Passt für: Ankündigungen und Einladungen, bei denen etwas entsteht (Event-Karte, Programm, Angebot, Ergebnis eines Tools), 10 bis 20 s, Social mit Sound. Verspielt und trotzdem hochwertig.
Passt nicht für: ernste Themen, lange Erklärungen mit Sprecher, Videos mit vielen Fakten.

## Die Idee in einem Satz
Eine kleine Figur in Markenfarbe springt über eine nachgebaute Oberfläche, jeder Sprung drückt einen Knopf und baut sichtbar am Ergebnis, am Ende fällt die Oberfläche weg und nur das fertige Ergebnis bleibt.

## Vier Bausteine (MARKE-Block im Brief, nur er ändert sich zwischen Marken)
- **Held:** die Bildmarke als Spielzeugform. ADAN e.V.: gefaltetes Band als abgerundeter Körper in `#ED6326` mit Faltung in `#BF2806`. ADAN Impact: facettierter Körper aus Dreiecken in Teal `#00AB97` und Mint. Augen als zwei kleine dunkle Kugeln, mehr Gesicht nicht.
- **App:** eine nachgebaute Oberfläche zum Thema, mit echten Feldnamen in Alltagssprache (etwa „Titel“, „Datum“, „Ort“, „Anmelden“ oder „Text“, „Form“, „Glühen“, „Keyframe“). Keine echten Logos fremder Software, keine echten Namen.
- **Ergebnis:** was der Held baut. Jeder Sprung verändert es sichtbar (Titel tippt sich, Datum klappt auf, Farbe flutet, Knopf erscheint). Inhalte nur aus dem Rohtext.
- **Bühne:** „Nachtglas“ (schwarzer Glanzboden, leuchtende Paneele, für dunkle Looks und Impact) oder „Studio hell“ (Boden in der Hellfläche der Marke, weiches Licht, für ADAN e.V. mit Weiß als Grund).

## Beats (Richtwert für 12 s bei 120 BPM, ein Takt = 2 s)
| Sekunde | Was passiert | Klang |
|---|---|---|
| 0 bis 1,5 | Weite Einstellung, Paneele schweben, Held liegt flach im Bildschirm (2D) | Intro leise, Pad |
| 1,5 bis 2 | Held löst sich vom Bildschirm und springt in 3D heraus | `glas`, `pop` |
| 2 bis 8 | Je Takt ein bis zwei Sprünge auf Knöpfe, jeder baut am Ergebnis, Kamera folgt auf Heldenhöhe | `klick` je Landung, `ding` je fertigem Baustein |
| 4 | Drop: Ergebnis bekommt Farbe oder Licht, Musik voll | `riser` endet hier, `aufprall` |
| 8 bis 10 | Held reitet den Abspielkopf oder drückt den großen Knopf, das Ergebnis spielt einmal ab | `whoosh` |
| 10 bis 11 | Paneele schalten nacheinander ab und fallen | `powerdown` je Paneel |
| 11 bis 12 | Nur das Ergebnis bleibt, Kamera ruht, letztes Bild ist das Plakat | `schimmer`, Musik klingt aus |

## Rezept
- Technik nach `references/drei-d.md`: Three.js-Szene als Canvas unter einer DOM-Ebene für Endkarten-Text. Die App ist eine Canvas-Textur, das Ergebnis eine eigene Fläche (oder DOM-Ebene, wenn es am Ende als scharfer Text stehen muss).
- `timeline.js` mit `ui.knoepfe` (Pixelpositionen), `spruenge`, `kamera` und `klang`. Jede Landung hat einen Klang zur selben Zeit.
- Kamera: weit, folgt mit 0,15 s Verzögerung auf Heldenhöhe mit leicht flachem Blick, landet zum Schluss frontal auf dem Ergebnis.
- Sprünge 0,5 bis 0,7 s, Höhe 1,3-fache Heldengröße, Ducken und Federn bei jeder Landung. Zwischen zwei Sprüngen höchstens 0,6 s Pause, sonst steht der Film.
- Ergebnis wächst von Sprung zu Sprung, wie eine echte App: ein Keyframe setzt eine Pose, Abspielen spielt die Animation ab.

## Übertragen
Übernehmen: Spielzeugheld aus der eigenen Bildmarke, Knopfdruck als Ursache jeder Veränderung, Abgang der Oberfläche, Klang aus derselben Timeline. Nicht übernehmen: das Clawd-Maskottchen, After-Effects-Optik als Fremdmarke, Texte der Quelle.
