# Muster: Constellation Glow (Punkte, glühende Kurven, Farbwolken)

Quelle: Referenzvideo (Launch-Film eines Motion-Studios für eine KI-Suchfunktion), Bildschirmaufnahme vom 10.10.2026, rund 70 s, 16:9. Ausgewertet über Kontaktbögen mit 1 Bild je Sekunde.
Passt für: KI-Produkte und Software, bei denen „Denken“, Vernetzung oder Leichtigkeit gezeigt werden soll, Erklär- und Launch-Videos 45 bis 90 s, mit oder ohne Stimme. Das flüssigste Muster im Katalog („wie Wasser“).
Passt nicht für: nüchterne Fakten-Videos mit vielen Zahlen

## Bühne und Farbe
Drei Akte: dunkel (fast schwarzes Blaugrau) mit Punkten und Glühlinien, hell (Weiß mit zarten Regenbogen-Rändern) für Produkt-UI, wieder dunkel mit Neon-Glühkanten. Farben immer als weicher Verlauf (Blau, Rot, Gelb, Grün), nie als Fläche. Große unscharfe Farbwolken wandern hinter den Linien.

## Typografie
Kleine, ruhige Grotesk, oft nur ein bis drei Wörter je Bild, viel Raum. Zahl oder Schlüsselbegriff farbig im Satz („in 1 question“). Wörter sitzen an Punkten der Linien.

## Techniken
- Punkt-Konstellation (0 bis 8 s): Wörter erscheinen zwischen weißen Punkten, Punkte springen in neue Formationen (Kreis, Reihe aus fünf Punkten nach „plan“). Umsetzung: Punktpositionen je Beat als Liste, GSAP tweent alle Punkte gleichzeitig mit Stagger.
- Glühende Verbindungskurven (8 bis 20 s): Punkte verbinden sich zu Bézier-Kurven, Welle, Spirale, vierzackigem Stern mit konkaven Seiten. Strich mit Farbverlauf entlang der Länge, darunter unscharfe Kopie als Glow. Umsetzung: SVG-Pfad, `stroke-dashoffset` für das Zeichnen, `linearGradient` am Pfad, `feGaussianBlur` für den Schein.
- Wort-Welle (20 bis 24 s): Ein Satz verteilt sich auf die Punkte einer Sinuskurve, unter der Linie fließt ein unscharfer Farbstrom mit.
- Farbwolken: große unscharfe Kreise (blur 60 bis 120 px) in Markenfarben driften langsam, verschmelzen (Mischmodus screen).
- Weiche Regenbogen-Kanten (24 bis 40 s, hell): UI-Elemente mit verlaufendem Rand und weichem farbigem Schatten, Elemente fliegen in 3D gekippt durchs Bild.
- Rahmen-Morph: Rechteck mit Wort („Snap“) morpht zum Kreis („Film“) und weiter zur Suchleiste, der Rand behält den Verlauf. Umsetzung: `border-radius`, Breite und Höhe tweenen, Wort tauscht im Moment der kleinsten Form.
- Neon-Glühkanten (40 bis 60 s, dunkel): Eingabefelder mit leuchtendem Verlaufsrand, der um das Feld wandert (`conic-gradient` mit rotierendem Winkel), Eckklammern als Fokusrahmen, die sich zusammenziehen.
- Farbwirbel mit Chips: Begriffe in der Mitte, Such-Chips kreisen um einen wirbelnden Farbverlauf.
- Regenbogen-Bogen als Übergang: riesige farbige Kurve fegt durchs Bild und wird zur nächsten Form.
- Endkarte: Suchleiste schrumpft zum farbigen Logo-Zeichen.

## Tempo und Schnitt
Ruhig, ein Gedanke je 2 bis 3 s, fast keine harten Schnitte, alles verwandelt sich aus der vorigen Form. Musik trägt (Ton in der Aufnahme leise vorhanden, nicht ausgewertet).

## Übertragen
Übernehmbar: Punkt-Konstellation mit Wörtern, glühende Verlaufskurven, Wort-Welle, Farbwolken, Rahmen-Morph, Neon-Glühkanten, Bogen-Übergang. Nicht übertragen: Marke, Logo, Farbcode der Quelle (vier Markenfarben), Inhalte.

## Rezept

Aus der Karte und `references/motion-techniken.md` abgeleitet, Werte als Startpunkt, im Bau an Snapshots prüfen.

**Ebenen.** Dunkler Grund, dahinter große unscharfe Farbwolken (blur 60 bis 120 px, Mischmodus `screen`) in Markenfarben, die langsam driften. Darüber ein SVG für Punkte und Kurven, darüber der Text.

**Punkt-Konstellation.** Punktpositionen je Szene als Liste von Formationen (Kreis, Reihe, Welle). GSAP tweent alle Punkte gleichzeitig in die nächste Formation, mit Stagger. Wörter sitzen zwischen oder an den Punkten.

```js
FORMATIONEN[k].forEach((p, i) =>
  tl.to(punkte[i], { attr: { cx: p.x, cy: p.y }, duration: 0.9, ease: "power2.inOut" }, at + i * 0.02));
```

**Glühende Kurven.** SVG-Pfad mit `linearGradient` als Strich, zeichnet sich über `stroke-dashoffset` von Pfadlänge auf 0. Darunter eine breitere, unscharfe Kopie (`feGaussianBlur`) als Glow. Punkt an der Spitze über `getPointAtLength()`, Länge einmal beim Aufbau messen.

**Wort-Welle.** Wörter eines Satzes sitzen auf den Punkten einer Sinuskurve, darunter fließt ein unscharfer Farbstrom mit.

**Rahmen-Morph.** Rechteck mit Wort morpht zum Kreis und weiter zur nächsten Form (`border-radius`, Breite und Höhe tweenen, Verlaufsrand bleibt), das Wort tauscht im Moment der kleinsten Form.

**Neon-Kante.** Rand eines Felds als `conic-gradient`, dessen Winkel getweent wird, dazu weicher farbiger Schatten.

**Timing.** Ein Gedanke je 2 bis 3 s, fast keine harten Schnitte, jede Form verwandelt sich aus der vorigen. Wolken driften immer weiter, damit nichts still steht.
