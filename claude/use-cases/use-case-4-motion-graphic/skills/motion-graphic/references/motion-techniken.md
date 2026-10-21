# Grundstock flüssiger Motion-Techniken

Techniken für ein „wie Wasser“-Gefühl. Jede mit Wirkung und Umsetzung in HyperFrames (HTML, SVG, GSAP, seek-safe). Vor dem Bau `/hyperframes-animation` laden, falls installiert (dort stehen Eases, Blueprints und Runtime-Adapter), sonst reichen die Referenzen von `/hyperframes`.

## Grundprinzipien

- **Ease-out für Ankommen, Ease-in für Gehen, Ease-in-out für Kamerafahrten.** Bewährt: `power3.out`, `expo.out` für Einflüge, `power2.inOut` für Fahrten. Nie `linear` außer bei Dauerdrift.
- **Überlappende Bewegung (Overlapping Action):** Teile eines Objekts starten versetzt (Stagger 0,03 bis 0,08 s je Wort oder Buchstabe). Das wirkt organisch statt mechanisch.
- **Nachschwingen (Follow-through):** Nach dem Stopp schwingt etwas leicht über und federt zurück (`back.out(1.4)` oder kleine Gegenbewegung). Sparsam, sonst wirkt es verspielt.
- **Atmen:** Stehende Elemente bewegen sich minimal weiter (Scale 1,00 auf 1,02, langsame Drift). Ein komplett stehendes Bild wirkt tot.
- **Ein Blickpunkt:** Pro Moment bewegt sich nur das, wohin das Auge soll.

## Flüssig und organisch

- **Gooey / Metaball (Tropfen, die verschmelzen):** SVG-Filter `feGaussianBlur` (stdDeviation 8 bis 14) plus `feColorMatrix` mit Alpha-Kontrast (`0 0 0 18 -7`). Kreise in einer Gruppe mit diesem Filter verschmelzen bei Annäherung und reißen beim Auseinanderziehen wie Flüssigkeit. Einsatz: Elemente fließen zusammen (Daten bündeln, Team, Integration).
- **Formen-Morphing:** SVG-Pfade mit gleicher Punktzahl per GSAP-Tween auf `d` (ohne MorphSVG-Plugin: Pfade vorab auf gleiche Struktur bringen) oder Kreis zu Rechteck über `border-radius` und Größe. Einsatz: ein Symbol wird zum nächsten (Problem-Icon wird Lösungs-Icon).
- **Flüssige Wischblende:** Kreis- oder Blob-`clip-path` wächst aus einem Punkt (dem Ort des letzten Ereignisses), statt hart zu schneiden.
- **Welle und Verdrängung:** SVG `feTurbulence` plus `feDisplacementMap` mit animierter `baseFrequency` oder `seed`-Schritt pro Frame (deterministisch). Einsatz: kurz, als Übergangsmoment, nicht dauerhaft.
- **Partikel und Bokeh:** Punkte mit geseedetem PRNG, Weg über die Zeit berechnet (seek-safe), Unschärfe und Deckkraft nach Tiefe gestaffelt.

## Linien, Graphen, Strahlen

- **Wachsende Linie:** `stroke-dasharray` = Pfadlänge, `stroke-dashoffset` von Länge auf 0. Glow über zweite, breitere, unscharfe Kopie darunter. Funke oder Punkt an der Spitze über `getPointAtLength()`.
- **Lichtstrahl als roter Faden:** Pfad über mehrere Szenen, Kamera folgt der Spitze. Siehe Musterkarte `coaching-lichtstrahl.md`.
- **Punkt-Konstellation:** Wörter zwischen Punkten, die je Beat in neue Formationen springen und sich zu glühenden Kurven verbinden (Welle, Spirale, Stern). Strich mit `linearGradient`, Glow als unscharfe Kopie. Siehe `constellation-glow.md`.
- **Wort-Welle:** Wörter eines Satzes sitzen auf den Punkten einer Sinuskurve, darunter fließt ein unscharfer Farbstrom.
- **Neon-Glühkante:** Rand eines Eingabefelds als wandernder `conic-gradient` (Winkel tweenen), dazu weicher farbiger Schatten.
- **Graph und Zahl:** Balken oder Linie wächst, Zahl zählt synchron hoch (Zählwalze ohne störende Zwischenwerte, eher nur die letzten Stellen rollen). Werte erst zeigen, wenn die Achse steht.

## Typografie

- **Wort-für-Wort-Einflug mit Unschärfe:** Jedes Wort von `filter: blur(12px)`, `opacity 0`, `y 20` auf scharf. Akzentwort in Markenfarbe.
- **Zeichen-Zerfall (Decode/Scramble):** Buchstaben werden zu zufälligen Zeichen (geseedet), fliegen auseinander und ordnen sich zum nächsten Satz. Siehe Musterkarte `dark-launch.md`.
- **Wort-Walze:** Begriffe rollen vertikal durch ein Fenster (Chat, Sprache, Avatar), der aktive steht ruhig.
- **Tipp-Zoom:** Kamera springt extrem nah an getippten Text (bildschirmfüllende Buchstaben, Verlaufs-Cursor), dann Rückzoom auf das Feld. Siehe `bright-saas.md`.
- **Wort-Wand:** ein Begriff als blasse Textur in vielen Zeilen, die gegeneinander gleiten, eine Zeile leuchtet in Markenfarben.
- **Verlaufsschrift:** Schlüsselbegriff mit Farbverlauf in der Schrift (`background-clip: text`), kleines Funkeln am Wortende.
- **Gewicht als Bedeutung:** Wort sinkt, kippt oder verblasst, wenn die Aussage negativ ist („liegen“ kippt um).

## Kamera und Schnitt

- **Match Cut:** Form am Ende einer Szene = Form am Anfang der nächsten (Kreis wird Knopf wird Planet). Der Blick bleibt an derselben Stelle.
- **Kamerafahrt per Container-Transform:** Ganze Bühne als Gruppe skalieren und verschieben, Ebenen mit unterschiedlichem Faktor (Parallax).
- **Rack-Focus:** Ergebnis aus der Unschärfe scharf ziehen (blur 20 auf 0 plus leichtes Scale 1,06 auf 1).
- **Rahmen-Morph:** Rechteck mit Wort morpht zu Kreis und weiter zur nächsten UI-Form, der Verlaufsrand bleibt, das Wort tauscht im Moment der kleinsten Form.
- **Fortschritts-Checkliste:** Schritte mit Ladekreis, der zum Haken wird, nächster Schritt rückt nach, am Ende eine Pille „fertig“. Zeigt Automatisierung ohne Erklärung.
- **Bogen-Übergang:** riesige farbige Kurve fegt durchs Bild und wird zur nächsten Form.
- **3D-Kartenwolke:** viele Screens mit `perspective` und gestaffeltem `translateZ`, Kamera fliegt hindurch.

## Motion Blur

- Echter Bewegungsunschärfe-Eindruck in der Endfassung über Subframe-Akkumulation (vier Zwischenbilder pro Frame mitteln), falls die HyperFrames-Version das anbietet (`npx hyperframes docs rendering`). Sonst gezielter `blur` in Bewegungsrichtung auf schnelle Elemente.
