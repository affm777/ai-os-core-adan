# Best Practices (aus zwei Videoprojekten, Oktober 2026)

Prüfliste vor jeder Preview. Jede Regel stammt aus echtem Feedback, der Grund steht dabei.

## Bild

- **Film statt Folie.** Keine Karten-Raster, kein Browserfenster als Hauptbild, keine Tacho- oder Dashboard-Optik. Grund: Die zweite Fassung des Coaching-Videos wirkte „wie eine Webseite“ und wurde verworfen.
- **Bildidee je Beat.** Jeder Satz bekommt ein Bild, das die Aussage ohne Ton erzählt (Woche zerfällt in sieben Tage, „liegen“ kippt um). Test: Video stumm ansehen, Geschichte muss verständlich bleiben.
- **Text steht mindestens 1,5 s ruhig.** Einflug, dann stehen lassen, dann auflösen. Grund: Kostenträger lesen langsamer als Social-Publikum.
- **Klare Hierarchie.** Pro Moment eine Hauptaussage, höchstens eine Nebenzeile. Nichts darf etwas anderes überdecken.
- **Durchgehendes Motiv als Best Practice.** Ein roter Faden (beim Coaching-Video ein goldener Lichtstrahl mit Funken an der Spitze) verbindet die Szenen und macht Übergänge sinnvoll. Kein Muss, aber ein starkes Mittel, wenn die Story eine Bewegung von A nach B erzählt.
- **Übergänge tragen Bedeutung.** Ein Übergang sagt etwas (Lücke schließt sich, Strahl führt ins Handy), sonst lieber ruhiger Schnitt.
- **Echte Assets statt Stock.** Eigene Screens, Produktbilder, Logo. Keine Stockfotos und keine generischen Figuren: Die 3D-Miniaturwelt mit Figuren fiel durch.
- **Personen und Porträts:** Bildausschnitt jedes Porträts prüfen, Gesicht ganz sichtbar mit Luft über dem Kopf. In kleinen Kreisen rutscht das Gesicht sonst nach unten.
- **Logo zentrieren per Messung**, nicht nach Augenmaß: Bounding Box messen (`getBBox()`), weil viewBox und optische Mitte oft auseinanderliegen.
- **Bewegung mit Bedeutung.** Ein Auf und Ab einer Linie wirkt wie ein Auf und Ab der Aussage. Ruhige, gleichmäßige Bewegung für Verlässlichkeit, Dynamik nur, wo sie gemeint ist.
- **Dezenz bei Siegeln und Fakten.** Ein Zertifikat als kleines ruhiges Siegel, kein Stempel-Slam mit Shake.
- **Screens auf echte Namen und Daten prüfen**, bevor sie ins Bild kommen. Nur synthetische Namen zeigen.
- **Ein Motiv nicht zweimal.** Ein Wirbel oder Tunnelflug, der am Anfang schon kam, wirkt beim zweiten Mal wie Wiederholung. Für jede Verwandlung eine neue Idee (Rahmen-Morph, Match Cut).
- **Konkret statt abstrakt.** Rollen als echte Titel (CEO, CFO, COO, Head of Strategy, Founder Associate) statt Sammelbegriffen wie „Schlüsselpersonen“. Abstrakte Wörter fielen im Feedback zweimal durch.
- **Keine Zeichen als Wortersatz.** „+“ zwischen zwei Begriffen wurde nicht verstanden, „und“ ausschreiben.
- **Labels frei stellen.** Namen an Knoten, über die Linien laufen, bekommen eine helle Pille als Hintergrund. Sonst schneidet eine Linie genau durch das Wort (Slack im Tool-Netz). Labels nie am Bildrand anschneiden lassen, in beiden Formaten prüfen.
- **Keine losen Deko-Zeichen.** Frei schwebende Code-Glyphen (`//`, `[]`, `}`) im Hintergrund werden als Fehler gelesen („da ist was reingerutscht“). Zeichen nur dort, wo sie zu einem Motiv gehören (in Kreisen, im Fluss), Hintergrundfelder nur aus Punkten.
- **Nur zeigen, was schon da ist.** Partikelwolken an Stellen, an denen die Karte noch fehlt, wirken leer und unverständlich. Verbindungen und Austausch erst starten, wenn beide Enden stehen.
- **Feste Zahlen nur mit Absicht.** „Zehn Themen“ legte eine Zahl fest, die nichts belegt. Lieber „unzählige“ oder eine Bildmenge ohne Zahl.
- **Fremde Marken als Text, nicht als Logo.** Grundlage nennen („Claude Code“ als kleine Zeile), aber kein großes Fremdlogo, das eine Partnerschaft nahelegt.
- **Endkarte vollständig:** Call to Action, Webadresse oder Kontakt, bei Terminen Wochentag, Datum, Ort und Uhrzeit. Alle Werte nur aus dem Rohtext des Nutzers, nichts ergänzen.
- **9:16 eigenständig denken.** Zwei Aussagen, die in 16:9 nebeneinander passen, stapeln sich hochkant auf vier Zeilen und überdecken das Bild. Dann nacheinander zeigen (erste ausblenden, zweite an derselben Stelle).

## Ton

- **Keine langen Sprechpausen.** Stille über rund 1,5 s zwischen Sätzen hört sich wie abgeschnittener Ton an, auch mit Musik. Bildszenen ohne Text kurz halten oder ihnen einen eigenen Satz geben.
- **Musik im Kontext wählen.** Varianten unter das fertige Bild legen, nicht einzeln vorspielen. Prüfen, ob die Musik bis unter die Endkarte trägt.
- **Effekte sparsam.** Nur an Momenten mit Bedeutung (Einschlag, Senden, Logo), nicht bei jedem Übergang. Grund: Rauschen und Zischen bei jedem Funkenflug wirkten zu laut und inflationär.
- **Musik mindestens 15 dB unter der Stimme**, Ducking auf die Sprechphasen.
- **Kein Limiter auf der Stimme.** `alimiter` nur mit `level=disabled`, sonst hebt er den Pegel an.
- **Master -14 LUFS / -1 dBTP**, Loudnorm in zwei Durchgängen.

## Sprache und Inhalt

- **Skript vor dem Bau einfrieren.** Jede Textänderung nach der Aufnahme kostet eine neue Aufnahme.
- **Schwierige Wörter in Lautschrift** für die generierte Stimme, Anzeige-Text bleibt korrekt.
- **Keine unbelegten Zahlen oder Versprechen** (keine Quoten, keine Garantien). Leitplanken stehen im Brief.
- **Sichtbare Texte** mit echten Umlauten, ohne Gedankenstriche.

## Technik

- Root-`data-duration` = Gesamtdauer aus `timing.js`, nie von Hand pflegen.
- Deterministisch: kein `Math.random` (geseedeter PRNG), keine Netzwerkzugriffe, GSAP lokal.
- `fromTo` statt CSS-Start-Transforms, Bewegung über transform, opacity, filter, clip-path.
- Nach jeder Änderung `check`, dann Snapshots ansehen, mindestens zwei eigene Runden vor der Vorlage.
- Preview mit 30 fps Draft, Endfassung 60 fps. 9:16 als eigene Komposition, nicht als Beschnitt.
- **Keine absoluten Sekunden.** Jede Zeitangabe relativ zu `T` (Cue plus Versatz). Feste Werte wie `49.2` müssen bei jeder Neuvertonung von Hand verschoben werden, im AIOS-Video waren es 44 Stellen.
- **HyperFrames-Version pinnen** und immer so aufrufen: `npx --yes hyperframes@<version> check|snapshot|render`. Ohne Version zieht `npx` die neueste.
- **Langsamer Zoom über DOM-Text ruckelt.** Chrome rastet Text bei kleinen Skalierungsschritten aufs Pixelraster, er steht mehrere Frames und springt dann. Ebene während der langsamen Fahrt als eigene Grafikebene rendern: `el.style.willChange = t > <zoomstart> ? "transform" : "auto"`, erst nach dem schnellen Heranflug einschalten (sonst unscharf). Ergebnis mit `scripts/bewegung_messen.py` prüfen.
- **Kein `//`-Kommentar in einzeiligem Code.** In einer einzeiligen Arrow-Function schneidet er den Rest der Zeile ab, das ganze Skript fällt aus. Kommentare in eine eigene Zeile oder als `/* */`.
