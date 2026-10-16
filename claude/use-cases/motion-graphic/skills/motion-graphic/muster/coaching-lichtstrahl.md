# Muster: Coaching Lichtstrahl (Kinetic Typo mit rotem Faden)

Quelle: eigenes Projekt, Erklärvideo eines AI-Coaching-Angebots für Kostenträger, Oktober 2026, rund 74 s, 16:9 und 9:16, 60 fps
Passt für: erklärende B2B- und Behördenvideos mit Stimme, Software oder Dienstleistung, die eine Lücke schließt; ruhige, vertrauenswürdige Tonalität
Passt nicht für: schnelle Social-Launches, verspielte Consumer-Produkte

## Bühne und Farbe
Zwei Bühnen: dunkel (Espresso #251A10 mit langsam driftendem Terrakotta- und Goldglühen) für Problem, Wendepunkt und Schluss, hell (Creme #FAF6F1) für Produkt- und Faktenszenen. Wechsel per Kreis-Wischblende aus dem Punkt des letzten Ereignisses. Akzent Gold #FCD089 für alles, was das Coaching tut.

## Typografie
Große Serife (Source Serif 4) für Schlüsselwörter, Grotesk (Hanken Grotesk) für Zeilen und Pillen. Wort-für-Wort-Einflug mit Unschärfe, Schlüsselwort riesig und leuchtend („Motivation“).

## Techniken
- Lichtstrahl als roter Faden: goldener SVG-Pfad mit Glow (unscharfe breite Kopie darunter), Funke als vierzackiger Stern an der Spitze, Partikel und Bokeh. Wird beim Wendepunkt „geboren“ und führt durch alle Szenen (in das Handy, auf den Plan, zwischen die Terminknoten, zum Ende auf das i der Wortmarke).
- Bedeutungs-Bewegung bei Negativem: Woche zerfällt in sieben Tage, „Motivation“ sinkt Buchstabe für Buchstabe, „Schwung“ fällt, „liegen“ kippt um.
- Wort-Walze für Kanäle (Chat, Sprache, Avatar), Sprachen-Morph (Hallo, Привіт, مرحبا).
- Zeitachse mit festen Terminknoten, dazwischen ein ruhiges, gleichmäßiges Lichtband (kein Auf und Ab).
- Anweisung tippt sich ein und läuft als Lichtimpuls den Strahl entlang zum Porträt.
- Deutschland aus Lichtpunkten, Pin am Rechenzentrum, Siegel dezent.
- Schluss als Spiegel des Problems: „Bewerbung“ wird gold, „rausgeht“ fliegt entlang des Strahls aus dem Bild, Kamera fährt zurück auf den ganzen Strahl.
- Endkarte: Funke landet auf dem i der Wortmarke, Partnerlogo, URL.

## Tempo und Schnitt
Bild auf die gemessenen Wortzeiten der Stimme gelegt, Bild startet 0,25 s vor dem ersten Wort. Jede Zeile mindestens 1,5 s ruhig. Szenen mit Aufbau, Atmen, Auflösung.

## Ton
Ruhige Frauenstimme (ElevenLabs, ein Take, ein Modell), Musik im Code (Klavier, Pads, Tonart D, rund 100 BPM, 15 dB unter Stimme), Effekte nur bei Funke schlägt ein, Bewerbung geht raus, Logo.

## Übertragen
Übernehmbar: zwei Bühnen hell/dunkel, roter Faden als durchgehendes Motiv, Bedeutungs-Bewegung, Schluss als Spiegel. Nicht übertragen: Farben des Vorbilds, Wortmarke, Inhalte.

## Rezept

Aus der Karte und `references/motion-techniken.md` abgeleitet, Werte als Startpunkt, im Bau an Snapshots prüfen.

**Ebenen.** Zwei Bühnen, dunkel (Problem, Wendepunkt, Schluss) mit langsam driftendem Glühen und hell (Fakten, Lösung). Wechsel per Kreis-Wischblende: `clip-path: circle()` wächst aus dem Punkt des letzten Ereignisses.

```js
tl.fromTo("#hell", { clipPath: `circle(0px at ${x}px ${y}px)` },
  { clipPath: `circle(2400px at ${x}px ${y}px)`, duration: 0.9, ease: "power2.inOut" }, at);
```

**Lichtstrahl als roter Faden.** Ein SVG-Pfad über mehrere Szenen, zeichnet sich über `stroke-dashoffset`. Glow als breitere unscharfe Kopie darunter, Funke an der Spitze über `getPointAtLength()`. Die Kamera (Container-Transform) folgt der Spitze. Der Strahl führt von Szene zu Szene und endet auf der Wortmarke.

**Bedeutungs-Bewegung.** Negative Wörter sinken, kippen oder zerfallen Buchstabe für Buchstabe. Ruhige, gleichmäßige Bewegung für Verlässlichkeit, Dynamik nur, wo sie gemeint ist.

**Typografie.** Große Serife für Schlüsselwörter, Grotesk für Zeilen und Pillen, Wort für Wort aus der Unschärfe. Wort-Walze für Aufzählungen (Begriffe rollen vertikal durch ein Fenster).

**Schluss als Spiegel.** Das Problemwort der ersten Szene kommt wieder und wird durch den Strahl verwandelt, Kamera fährt zurück auf den ganzen Strahl.

**Timing.** Mit Stimme startet jedes Bild 0,25 s vor dem ersten Wort, jede Zeile steht mindestens 1,5 s ruhig. Jede Szene mit Aufbau, Atmen, Auflösung, der Strahl bewegt sich immer weiter.
