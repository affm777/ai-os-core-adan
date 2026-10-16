# Muster: Dark Launch (Kinetic Type mit Zeichen-Zerfall und Prompt als Held)

Quelle: Referenzvideo (Social-Reel eines Motion-Designers, Launch-Spot für ein KI-Produkt), Bildschirmaufnahme vom 10.10.2026, rund 28 s, Hochformat-Aufnahme eines Monitors. Ausgewertet über Kontaktbögen mit 2 Bildern je Sekunde.
Passt für: kurze Software-Launches, KI- und Tool-Produkte, Social (Reels, LinkedIn), Teaser vor einem längeren Erklärvideo
Passt nicht für: ruhige Behörden- oder Kostenträger-Videos, lange Erklärungen

## Bühne und Farbe
Fast schwarzes Anthrazit, ein einzelnes warmes Orange-Glühen wandert langsam als weicher Lichtfleck durchs Bild. Nur zwei Farben (Weiß, Orange als Akzent), sehr viel Leerraum.

## Typografie
Saubere Grotesk, mittelgroß, eine Zeile mittig. Wörter erscheinen einzeln aus der Unschärfe, das Schlüsselwort in Orange. Kurze Sätze, oft nur drei bis fünf Wörter.

## Techniken
- Wort-für-Wort-Blur-Einflug (rund 0 bis 4 s): je Wort Blur, Deckkraft, leichter Versatz, Stagger knapp 0,1 s.
- Zeichen-Zerfall (rund 4 bis 6 s): der Satz zerfällt in fliegende Sonderzeichen ([ > * / { ^), die sich zum nächsten Satz ordnen. Umsetzung: Buchstaben als Spans, über die Zeit geseedet durch Zeichen ersetzen, Positionen per Tween streuen und auf Zielpositionen zurückführen.
- Produktname-Reveal (rund 6 bis 8 s): Name schreibt sich von links mit Unschärfe, dann scharf.
- Eingabefeld als Hauptfigur (rund 8 bis 12 s): Prompt-Feld zoomt heran, Text tippt, Feld wächst mit dem Text, verkleinert sich danach zur Zusammenfassung.
- Klick-Moment (rund 12 bis 14 s): Senden-Pfeil wächst zum großen Button, beim Druck pulsiert ein leuchtender Ring nach außen (Ripple mit Glow), der Pfeil steigt auf.
- Rack-Focus auf das Ergebnis (rund 14 bis 16 s): erzeugtes Produkt kommt aus starker Unschärfe scharf.
- Split mit Live-Produkt (rund 16 bis 19 s): großer Text links („it's playable in seconds“, Schlusswort in Orange), rechts läuft das Produkt weiter.
- 3D-Kartenwolke (rund 19 bis 22 s): viele Screens fliegen in die Tiefe gestaffelt herein, Text läuft hindurch.
- Staccato (rund 22 bis 25 s): drei kurze Verneinungen nacheinander, um das letzte Wort zeichnet sich ein Rahmen.
- Endkarte (rund 25 bis 28 s): kleines Eingabefeld mit Claim, Klick, Logo-Symbol entfaltet sich, Wortmarke schreibt sich daneben, Tagline erscheint klein darunter.

## Tempo und Schnitt
Neues Bild etwa alle 1,5 bis 2 s, kaum harte Schnitte, fast alles sind Verwandlungen. Kurze Bewegungen mit starkem Ease-out, dazwischen kurze Ruhe.

## Ton
In der Aufnahme nicht ausgewertet. Typisch für den Stil: treibender, minimaler Elektronik-Beat, Klick- und Whoosh-Akzente auf den Verwandlungen, keine Stimme.

## Übertragen
Übernehmbar: dunkle Bühne mit wanderndem Glühen, Zeichen-Zerfall als Übergang, Eingabefeld und Klick als Spannungsbogen, Rack-Focus auf das Ergebnis, Staccato-Schluss. Nicht übertragen: Marke, Logo, Claims und Produktinhalte der Quelle.

## Rezept

Aus der Karte und `references/motion-techniken.md` abgeleitet, Werte als Startpunkt, im Bau an Snapshots prüfen.

**Ebenen.** Fast schwarzer Grund. Ein weicher Lichtfleck in der Akzentfarbe (großer Kreis mit Radialverlauf), der über die ganze Länge langsam wandert. Darüber eine Textzeile mittig. Nur zwei Farben, Weiß und Akzent.

**Wort-Einflug.** Wörter einzeln als Spans, je Wort aus Unschärfe, Deckkraft und leichtem Versatz, Abstand knapp 0,1 s, Schlüsselwort in Akzent. Kurze Sätze mit drei bis fünf Wörtern.

```js
tl.fromTo(".zeile .w", { opacity: 0, y: 20, filter: "blur(12px)" },
  { opacity: 1, y: 0, filter: "blur(0px)", duration: 0.5, stagger: 0.09, ease: "expo.out" }, at);
```

**Zeichen-Zerfall als Übergang.** Buchstaben als Spans. Über die Zeit geseedet durch Sonderzeichen ersetzen (Zeichen je Frame aus `floor(t * Rate + i)` berechnen, nicht zufällig), Positionen per Tween streuen und auf die Plätze des nächsten Satzes zurückführen.

**Eingabefeld und Klick.** Feld zoomt heran, Text tippt sich (Zeichen einzeln sichtbar), Feld wächst mit dem Text. Senden-Knopf wächst, beim Druck federt er (`scale 1 auf 0,96 auf 1`) und ein leuchtender Ring läuft nach außen (Ring skaliert hoch, Deckkraft auf 0).

**Rack-Focus.** Ergebnis aus der Unschärfe scharf ziehen: `blur 20 auf 0` plus `scale 1,06 auf 1`.

**Staccato und Endkarte.** Drei kurze Aussagen nacheinander, um das letzte Wort zeichnet sich ein Rahmen. Endkarte mit Logo-Zeichen, Wortmarke schreibt sich daneben mit Unschärfe von links, Tagline klein darunter.

**Timing.** Neues Bild alle 1,5 bis 2 s, fast alles Verwandlung statt Schnitt, kurze Bewegungen mit starkem `ease-out`, dazwischen kurze Ruhe. Der Lichtfleck wandert immer weiter, damit kein Bild länger als 1,5 s still steht.
