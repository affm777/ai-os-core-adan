# Muster: Helle Konstellation mit Kamerafahrt

Quelle: eigenes Projekt, AIOS-Promo-Video Frankfurt (Oktober 2026), 62 s, 16:9 und eigene 9:16-Komposition.
Passt für: Workshop-, Dienstleistungs- und Software-Promos mit Sprecher, 45 bis 75 s, wenn ein „System“, Vernetzung oder Wissen gezeigt werden soll. Helle, warme Marken (Creme, Orange).
Passt nicht für: dunkle Tech-Launches (dafür `dark-launch.md`), Videos mit vielen Screens oder Zahlen-Tabellen.

## Bühne und Farbe
Creme-Hintergrund mit großen, langsam treibenden Farbwolken (Orange, Pink) mit Parallaxe. Punkte in Schwarz, Orange, Pink. Ein Akzent (Orange) für Schlüsselwörter und den Kern. Alles in einem 3D-Raum: Canvas-Partikel und DOM-Ebenen (Text, Karten, App) hängen an derselben Kamera.

## Typografie
Serif-Headlines (Instrument Serif) mit kursivem Akzentwort in Orange, Mono für Labels und Uhrzeit (Geist Mono), Grotesk für UI. Einflug Wort für Wort mit Unschärfe (`blur 12 auf 0`, `y 30 auf 0`, 0,55 s), Abgang mit `blur 10`, `y -24`.

## Techniken
- Kamerafahrt (ganzer Film): Keyframe-Liste `[zeit, x, y, z]` relativ zu Wort-Cues, monotone Hermite-Interpolation, leichte Roll-Bewegung auf Übergängen. Szenen liegen als Ebenen hintereinander, die Kamera fliegt von Szene zu Szene.
- Kalender aus Punkten (Beat 1): Woche als Punktraster, Termine füllen sich auf „Meetings, Mails, Entscheidungen“, Welle zieht durch, ein Punkt hebt sich heraus („Nur nicht dir“).
- Themen-Cluster (Beat 2): Punktwolken mit Pillen-Labels, Stakeholder-Namen fliegen ein, alles fällt zur Uhr zusammen, Uhr rollt von 17:30 auf 22:47, Abenddämmerung über die Bühne.
- Zeichen in Kreisen (Beat 3): Code-Zeichen in gestrichelten Punktkreisen, „KI-Tool“ wird durchgestrichen und zerfällt, Punkt hinter „System“ wird zum Kern.
- Pulsierender Kern mit Tool-Netz (Beat 4): Kern aus Punktring, Tool-Logos auf einem Halbkreis, glühende Kurven mit fließenden Punkten zum Kern, Second-Brain-Pillen unten. Labels auf heller Pille.
- Nachgebaute App mit Flug ins Wissen (Beat 5): Frage wird getippt, Kamera fliegt in eine Wissenswolke, Firma X wird markiert, vier Stränge (Personen, Meetings, Entscheidungen, Learnings) leuchten nacheinander und fließen als Antwort zurück.
- Beleg (Beat 6): Testimonial-Laufband, eine Karte zoomt heran, Zitat unterstrichen, rechts „gleiche Zeit“: ein Block gegen fünf Blöcke.
- Kernteam (Beat 7): Rollenkarten erscheinen nacheinander, Partikel tauschen sich erst aus, wenn beide Karten stehen, Übergang in einen Graphen Erfolg über Zeit mit Marker.
- Endkarte: Logo aus Partikeln, dann DOM, langsamer Zoom als eigene Grafikebene (`will-change`), URL tippt sich, Kontaktzeile blendet ein.

## Tempo und Schnitt
Keine harten Schnitte, nur Kamerafahrten von 0,6 bis 1,5 s auf Satzanfängen. Bild steht zwischen den Fahrten 2 bis 5 s ruhig mit atmender Bewegung. Satzpausen 0,5 bis 1,2 s.

## Ton
Sprecher (ElevenLabs, warm, souverän), ruhige Piano-Musik mit leichtem Puls ab dem Wendepunkt, mindestens 15 dB unter der Stimme. Drei Effekte: Platsch auf „System“, Herzschlag am Kern, Glockenton auf der Endkarte.

## Übertragen
Übernehmen: Kamera-im-Raum-Prinzip, Punktsprache mit wenigen Farben, Kern als lebendes System, Endkarten-Aufbau. Nicht übernehmen: AIOS-Marke, Testimonials, Namen und Workshop-Daten.

## Rezept

Nachbaubar ohne Originalcode. Farben immer aus der Marke, hier nur Rollen (Grund hell, Tinte, ein Akzent).

**Ebenen (von hinten nach vorn).** Hintergrund als heller Radialverlauf. Zwei bis drei Farbwolken als große Kreise (1200 bis 1400 px, Radialverlauf mit Deckkraft 0,25 nach 0). Ein Canvas in voller Bildgröße für alle Punkte und Linien. Darüber je Szene eine Textebene (`div` in Bildgröße, `transform-origin: 0 0`, zu Beginn `visibility: hidden`). Endkarte als eigene Ebene.

**Welt und Stationen.** Jede Szene ist eine Station mit Weltkoordinaten `[x, y, z]`, gemeint ist die Mitte einer Ebene in Bildgröße. Stationen liegen 2000 bis 2800 Einheiten auseinander in z und seitlich versetzt (300 bis 800), damit jede Fahrt auch eine Seitenbewegung hat. Zwei Szenen mit gleichem Ort, aber 200 bis 300 tiefer gestaffelt, ergeben einen Rückzug ohne Ortswechsel. Projektion mit Brennweite `F = 1000`: Steht die Kamera 1000 vor einer Station, erscheint die Ebene in Originalgröße.

**Kamera.** Keyframe-Liste `[zeit, x, y, z]`, je Station zwei Keyframes (Ankunft, Ende der Haltung). Zwischen ihnen driftet die Kamera nur 30 bis 100 Einheiten in z (Atmen), die Fahrt dazwischen dauert 0,8 bis 1,0 s. Interpolation als monotone kubische Hermite-Kurve je Achse (Tangenten als Mittel der Nachbarsteigungen, auf das Dreifache der kleineren begrenzt, bei Vorzeichenwechsel 0). Auf jeder Fahrt ein Rollen von 2 bis 4 Grad, Richtung abwechselnd, Verlauf `A * sin(PI * easeInOut(p))`.

```js
const proj = (p) => { const d = p.z - cam.z; if (d < 4) return null;
  const s = F / d, u = (p.x - cam.x) * s, v = (p.y - cam.y) * s;
  return { x: CX + u * cam.c - v * cam.sn, y: CY + u * cam.sn + v * cam.c, s }; };
/* Ebene an der Kamera: dieselbe Projektion als CSS-Matrix */
const planeM = (S) => { const d = S[2] - cam.z; if (d < 4) return null; const s = F / d;
  const U = (S[0] - CX - cam.x) * s, V = (S[1] - CY - cam.y) * s;
  return [s * cam.c, s * cam.sn, -s * cam.sn, s * cam.c, CX + U * cam.c - V * cam.sn, CY + U * cam.sn + V * cam.c]; };
/* Deckkraft der Ebene nach Abstand: erst ab 120 sichtbar, ab 2200 ausblenden */
const op = (d) => lin(d, 120, 420) * (1 - lin(d, 2200, 3400));
```

**Punktwelt.** Rund 300 Hintergrundpunkte, x und y gleichmäßig über die doppelte Bildbreite um den Pfad, z über die ganze Fahrstrecke verteilt (von etwas vor der ersten bis hinter die letzte Station). Radius 2 bis 5,5, rund 80 Prozent Tinte und 20 Prozent Akzent, Deckkraft 0,3, nach Abstand ein- und ausgeblendet (unter 80 unsichtbar, ab 2600 abnehmend). Jeder Punkt atmet mit `sin(t * 0.6 + phase) * 10`. Weil alle Punkte durch dieselbe Kamera laufen, entsteht auf jeder Fahrt Parallaxe von selbst. Zufall nur geseedet (z. B. mulberry32), nie `Math.random`.

**Motive an den Stationen.** Gruppen aus 40 bis 50 Punkten (Radius 7 bis 14) mit gestaffeltem Erscheinen (0,6 s, Versatz bis 0,6 s, `easeOut`). Ein Held (ein einzelner Punkt), der die Geschichte trägt: Er reist auf den Fahrten selbst von Station zu Station, die Kamera folgt ihm, auf der ersten Fahrt mit kurzer Nachzieh-Spur (vier Kopien, je 0,04 s zurück, abnehmend). Verbindungen als Linien, die von 0 auf volle Länge wachsen (0,6 s, gestaffelt 0,07 s). Puls als Ring, der sich ausdehnt und ausblendet (`frac(t * Tempo)`). Ein Kreis aus 12 bis 16 Punkten um das Hauptmotiv wird zum Netz (Linien zum Kern und zum Nachbarn).

**Text an der Kamera.** Textebenen hängen an ihrer Station und folgen der Kamera per `matrix(...)`, sie fliegen also mit der Welt ein und aus. Wort für Wort aus der Unschärfe, Akzentwort mit Markenfarbe (auf hellem Grund als Markerstrich unter dem Wort, damit der Kontrast reicht).

```js
const inW = (sel, at) => tl.fromTo(sel + " .w",
  { opacity: 0, y: 34, filter: "blur(14px)" },
  { opacity: 1, y: 0, filter: "blur(0px)", duration: 0.55, stagger: 0.08, ease: "power3.out" }, at);
const outW = (sel, at) => tl.to(sel + " .w",
  { opacity: 0, y: -26, filter: "blur(10px)", duration: 0.32, stagger: 0.03, ease: "power2.in" }, at);
```

**Farbwolken.** Wolken wandern über die ganze Länge langsam (`translate` proportional zu `t / Dauer`) und gegen die Kamera mit kleinem Faktor (0,035 bis 0,08 mal Kameraposition), das ergibt eine zweite, sehr langsame Parallaxe. Eine warme Wolke blendet am Wendepunkt ein (1,6 s, `sine.inOut`).

**Endkarte.** Die Kamera fliegt durch das letzte Motiv hindurch in die Endkarte (das Netz rauscht am Bild vorbei, Übergang über Bewegung). Danach langsamer Zoom von rund 90 Einheiten über 2,5 s. Während dieses Zooms die Endkarten-Ebene mit `will-change: transform` als eigene Grafikebene führen, sonst springt Text aufs Pixelraster. Reihenfolge: Titel Wort für Wort, Adress-Pille federt ein (`back.out(1.5)`), Adresse tippt sich (Zeichen einzeln sichtbar, 0,034 s Abstand), Wortmarke zuletzt.

**Antrieb.** Ein Proxy-Tween über die ganze Dauer ruft je Frame eine `render(t)`-Funktion auf, die Kamera, Canvas und Ebenen setzt. Die Text-Tweens liegen auf derselben pausierten Zeitleiste.

```js
const proxy = { t: 0 };
tl.to(proxy, { t: DUR, duration: DUR, ease: "none", onUpdate: () => render(proxy.t) }, 0);
```

**Timing.** Je Szene Einleitung (Fahrt kommt an, Text fliegt ein, 0,5 bis 0,8 s), Haltung (1,5 bis 2,5 s, Kamera driftet, Punkte atmen, Motiv entwickelt sich) und Übergang (Text geht 0,3 s vor der Fahrt, Fahrt 0,8 bis 1,0 s). Nichts steht länger als 1,5 s still. Auf jeder Fahrt muss etwas im Bild sein (Held, Spur, Punktwelt), sonst wirkt der Übergang leer. Text verlässt die Ebene, bevor die Fahrt ihn an den Bildrand schiebt.
