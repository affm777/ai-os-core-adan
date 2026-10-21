# Muster: Bright SaaS (Verlaufsflächen, Tipp-Zoom, Fortschritt als Geschichte)

Quelle: Referenzvideo (Spec-Ad eines Motion-Studios für einen KI-App-Builder), Bildschirmaufnahme vom 10.10.2026, rund 21 s Spot in 25 s Aufnahme, 16:9. Ausgewertet über Kontaktbögen mit 2 Bildern je Sekunde.
Passt für: Software- und KI-Tools mit einem klaren Ablauf „eingeben, erzeugen, fertig“, Launch und Social, 20 bis 40 s, helle freundliche Tonalität
Passt nicht für: ernste, ruhige Themen und lange Erklärungen

## Bühne und Farbe
Wechsel aus sehr hellen Flächen (Weiß, helles Blaugrau) und kräftigen Vollbild-Verläufen (Blau, Magenta, Orange, auch dunkles Violett). Eine große, gebogene 3D-Fläche schneidet als Welle ins Bild und trägt den Verlauf. Markenverlauf auch in Schrift, Cursor und Button. Endkarte auf dunklem Grün mit weichen Lichtstrahlen von oben.

## Typografie
Saubere Grotesk, mittig, eine Zeile je Bild. Schlüsselbegriff mit Farbverlauf in der Schrift („with intelligence“) und kleinem Funkeln am Wortende.

## Techniken
- Hintergrund-Verwandlung (0 bis 3 s): Verlauf morpht zwischen Farbstimmungen, die 3D-Welle schwingt durchs Bild, Text bleibt stehen. Umsetzung: zwei überblendete Verlaufsebenen plus SVG- oder Canvas-Fläche mit Perspektive.
- Prompt-Feld mit Mauszeiger (4 bis 6 s): leeres Feld wächst aus einem Verlaufsstrich, Platzhalter, Zeiger fährt hinein.
- Tipp-Zoom (6 bis 8 s): Kamera springt extrem nah an den getippten Text, Buchstaben bildschirmfüllend, Cursor als Verlaufsbalken. Danach Rückzoom auf das ganze Feld mit fertigem Satz. Umsetzung: Container-Scale mit `expo.inOut`, Tippen per Zeichen-Reveal.
- Riesiger Button-Klick (9 bis 10 s): Generate-Button füllt das Bild, Zeiger drückt, Button federt (Scale 1 auf 0,96 auf 1).
- Wort-Wand (10 bis 12 s): ein Begriff in vielen Zeilen und Schnitten als blasse Textur, eine Zeile mit Produktname in Markenfarben, Zeilen gleiten gegeneinander (Parallax).
- Code-Fluss (12 bis 14 s): Code scrollt weich, oben und unten in Verlauf ausgeblendet (Maske), nicht lesbar gedacht, nur Anmutung.
- Fortschritts-Checkliste (14 bis 17 s): Karte mit Schritten, Ladekreis wird zum grünen Haken, nächster Schritt rückt nach, am Ende verdichtet sich alles zur Pille „ready“. Starkes Mittel, um Automatisierung ohne Erklärung zu zeigen.
- 3D-UI-Paneele (17 bis 20 s): App-Screens als gekippte Karten in Perspektive vor Verlauf, langsame Rotation, Parallax.
- URL-Pille als Endkarte: Glas-Pille mit Logo und URL, Text tippt sich zu Ende.

## Tempo und Schnitt
Neues Bild etwa alle 1 bis 1,5 s, viele Zoom-Übergänge statt Schnitte, kurze, federnde Bewegungen.

## Ton
Nicht ausgewertet. Typisch: heller, rhythmischer Elektronik-Track, Tipp- und Klickgeräusche synchron.

## Übertragen
Übernehmbar: Tipp-Zoom, Riesen-Button, Wort-Wand, Fortschritts-Checkliste, 3D-Paneele, Verlaufsschrift, URL-Pille. Nicht übertragen: Marke, Logo, Claims und Inhalte der Quelle.

## Rezept

Aus der Karte und `references/motion-techniken.md` abgeleitet, Werte als Startpunkt, im Bau an Snapshots prüfen.

**Ebenen.** Zwei übereinanderliegende Verlaufsflächen, deren Deckkraft gegeneinander überblendet wird (Farbstimmung wechselt, Text bleibt stehen). Optional eine große gebogene Fläche (SVG-Pfad mit Verlauf), die als Welle durchs Bild schwingt. Wechsel zwischen sehr hellen Flächen und kräftigen Vollbild-Verläufen.

**Tipp-Zoom.** Ganze Bühne als Container. Der Container skaliert extrem nah an den getippten Text, Buchstaben werden bildschirmfüllend, Cursor als Verlaufsbalken. Danach Rückzoom auf das ganze Feld mit fertigem Satz.

```js
tl.to("#buehne", { scale: 6, x: zielX, y: zielY, duration: 0.9, ease: "expo.inOut" }, at);
tl.to("#tipp .c", { opacity: 1, duration: 0.01, stagger: 0.05 }, at + 0.3);
tl.to("#buehne", { scale: 1, x: 0, y: 0, duration: 0.9, ease: "expo.inOut" }, at + 2.0);
```

**Riesen-Knopf.** Knopf füllt das Bild, ein Zeiger fährt hinein, Druck federt (`scale 1 auf 0,96 auf 1`).

**Wort-Wand.** Ein Begriff in vielen Zeilen als blasse Textur, Zeilen gleiten gegeneinander (abwechselnde Richtung, verschiedene Tempi), eine Zeile in Markenfarben.

**Fortschritts-Checkliste.** Karte mit Schritten, je Schritt ein Ladekreis (`stroke-dashoffset` läuft ab), der zum Haken wird, nächster Schritt rückt nach, am Ende verdichtet sich alles zu einer Pille „fertig“.

**3D-Paneele und Endkarte.** Screens als gekippte Karten (`perspective`, `rotateY`) mit langsamer Rotation und Parallaxe. Endkarte als Glas-Pille mit Logo, Adresse tippt sich zu Ende. Schlüsselbegriff mit Verlauf in der Schrift (`background-clip: text`).

**Timing.** Neues Bild alle 1 bis 1,5 s, Zoom-Übergänge statt Schnitte, kurze federnde Bewegungen. Zwischen den Zooms läuft immer eine Verlaufs- oder Wellenbewegung weiter.
