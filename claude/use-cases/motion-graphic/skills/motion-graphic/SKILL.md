---
name: motion-graphic
description: Baut mit HyperFrames ein Motion-Graphics-Video für Social Media (Reel, TikTok, LinkedIn, Website) aus einer freien Beschreibung. Ein Pfad mit zwei Toren, Storyboard und Vorschau, der Nutzer sieht nur Fragen, Tabellen und die fertige MP4. Fragt Format, Länge, Stimme, Musik, Marke und Vorbilder ab, liefert eine Endfassung in 60 fps in 9:16 und auf Wunsch 16:9. Nutze diesen Skill IMMER, wenn ein Video, Clip, Reel, Motion Graphic oder Erklärvideo entstehen soll, auch ohne das Wort „Motion Graphic“.
when_to_use: |
  Trigger-Phrasen: "mach mir ein Video", "bau ein Reel", "Clip für Instagram", "TikTok-Video", "Video für LinkedIn", "Motion Graphic", "animiertes Video", "Erklärvideo", "kurzes Video über", "/motion-graphic". Auch zum Weitermachen an einem offenen Video ("mach mit dem Video weiter").
  NICHT für Standbilder, Flyer oder Slides (designer-Skill) und nicht für Webseiten (landing-page-builder).
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, Skill
---

# Motion Graphic

Ergebnis: ein fertiges Motion-Graphics-Video als MP4 (60 fps, 9:16 und auf Wunsch 16:9) im Arbeitsordner unter `videos/<slug>/final/`. Der Nutzer ist kein Techniker. Er redet frei, beantwortet wenige Fragen, bestätigt ein Storyboard, sieht eine Vorschau und bekommt die Endfassung.

Die Technik kommt aus den HyperFrames-Skills (`/hyperframes`, `/hyperframes-animation`), dieser Skill legt Ablauf und Qualität fest. Wo `/hyperframes` einen eigenen Ablauf vorschlägt (Intent-Interview, Studio-Vorschau, Workflow-Routing), gilt dieser Skill.

## Grundregeln

- **Der Nutzer sieht nie Technik.** Kein Code, keine Lint- oder Render-Ausgaben, keine Studio-Vorschau (`hyperframes preview`), keine Pfade zu Zwischendateien. Nur Fragen, Tabellen in Alltagssprache und die fertige MP4. Fehler in Alltagssprache erklären.
- **Nichts kostet Credits oder Renderzeit vor dem Go.** Generierte Stimme oder Musik erst nach Tor 1, gerendert wird erst nach Tor 1.
- **Rohinhalt des Nutzers ist Wahrheit.** Keine erfundenen Zahlen, Claims, Namen, Termine oder Webadressen. Fehlt etwas für die Endkarte, nachfragen oder weglassen.
- **Referenzen liefern Technik und Stimmung, nie Inhalt.** Keine fremden Logos, Screens, Claims oder Namen übernehmen.
- **Nichts löschen** (kein `rm`). Neue Fassungen sind Kopien, alte bleiben liegen.
- **Sichtbare Texte** auf Deutsch mit echten Umlauten, ohne Gedankenstriche.

## Pfade und Befehle

- Skill-Ordner `S=~/.claude/skills/motion-graphic`, HyperFrames-Version `V=$(cat "$S/VERSION")`.
- HyperFrames immer so aufrufen: `HYPERFRAMES_NO_TELEMETRY=1 npx --yes hyperframes@$V <befehl>`. Nie ohne Version, nie global installieren.
- Arbeitsordner ist das aktuelle Verzeichnis. Je Video ein Ordner `videos/<slug>/` mit `brief/`, `referenzen/`, `film-vN/` (bei beiden Formaten zusätzlich `film-vN-9x16/`), `renders/vN/`, `final/`, `_pruefung/` (Snapshots, nur für Claude).
- Plattform: macOS oder Windows mit Git Bash. Scripts immer mit `bash "$S/scripts/<name>.sh"` starten, Dateien mit `bash "$S/scripts/oeffnen.sh" <datei>` öffnen (macOS `open`, Windows `start`). Python für Stimme und Messung: macOS `"$S/.venv/bin/python" -I`, Windows `"$S/.venv/Scripts/python.exe" -I`.

## Ablauf

### 0. Werkzeug-Check (still)

`bash "$S/scripts/werkzeug-check.sh"` prüft Node, ffmpeg, HyperFrames in der gepinnten Version, den Render-Browser und die HyperFrames-Skills. Ausgabe leer und Exit 0: nichts sagen, weiter. Sonst nur das Fehlende in Alltagssprache nennen, mit der Installationszeile aus der Ausgabe, dann stoppen. Nicht selbst installieren. Die Python-Umgebung (`--mit-ton`) erst prüfen, wenn in Schritt 3 eine Stimme oder Musik gewählt wird.

### 1. Wiedereinstieg

`videos/*/brief/BRIEF.md` per Glob suchen und Zeile 3 lesen. Steht dort `Status: offen`, in einem Satz anbieten weiterzumachen („Dein Video ‚<Titel>‘ ist beim Schritt <Schritt> stehen geblieben. Sollen wir dort weitermachen?“). Bei Ja an diesem Schritt einsteigen, sonst neu beginnen. Mehrere offene: kurz als Liste zur Auswahl.

### 2. Freitext-Briefing

Keine Formularfragen zum Thema. Bitten:

> Erzähl mir, worum es geht. Was soll das Video zeigen und für wen? Hast du schon eine Idee für die Abfolge oder die Story? Du kannst das auch offen lassen.

Dann in genau drei Sätzen zusammenfassen, was verstanden wurde (Thema, Zielgruppe, Kernbotschaft). Danach fragen, ob das stimmt. Eine Story-Idee des Nutzers wird übernommen, nicht ersetzt. Ohne Story-Idee schlägt Claude im Storyboard einen Bogen vor (Problem, Wendepunkt, Lösung, Aufruf). Anschließend einen kurzen Slug festlegen (Kleinbuchstaben, Bindestriche), `videos/<slug>/brief/BRIEF.md` aus `references/brief-vorlage.md` anlegen und den Rohtext wörtlich übernehmen.

### 3. Rahmenfragen (AskUserQuestion, eine Runde, vier Fragen)

1. Kanal und Format: Instagram oder TikTok (9:16), LinkedIn oder Website (16:9), beides.
2. Länge: etwa 15, 30 oder 60 Sekunden.
3. Stimme: keine, eigene Audiodatei, generiert über ElevenLabs.
4. Musik: keine, eigene Datei, generiert über ElevenLabs.

Bei „generiert“ prüfen, ob eine ElevenLabs-Anbindung da ist (ToolSearch nach `elevenlabs` oder `creative_generate_speech`, sonst Umgebungsvariable `ELEVENLABS_API_KEY`). Fehlt sie, das sagen und „keine“ oder „eigene Datei“ anbieten. Bei Stimme oder Musik `werkzeug-check.sh --mit-ton` laufen lassen und `references/audio-kette.md` lesen. Mit Stimme gilt: Stimme zuerst, Bild folgt den Wortzeiten. Effekte nur, wo sie Bedeutung tragen. Antworten in den Brief.

### 4. Look und Design (eigene Runde)

**a) Marke.** Fragen:

> Gibt es einen Style-Guide oder Brand-Dateien (Logo, Farben, Schrift)? Du kannst mir Dateien oder einen Ordner nennen, ich kann im Projekt suchen, oder wir legen es jetzt kurz fest.

Beim ersten Lauf zuerst fragen, für welche Marke das Video ist (bei ADAN gibt es ADAN e.V. und ADAN Impact, keine Vorentscheidung, der Nutzer wählt je Video). Reihenfolge der Quellen: genannte Dateien, dann `brand/<marke>/STYLE-GUIDE.md`, dann jeder `STYLE-GUIDE.md` oder `brand/`-Ordner im Projekt (Glob), dann kurze Abfrage (Primärfarbe, Akzentfarbe, Schrift, Logo-Datei). Neu Festgelegtes als `brand/<marke>/STYLE-GUIDE.md` im Arbeitsordner speichern, damit es beim nächsten Video wieder da ist. Eine Kopie als `videos/<slug>/STYLE-GUIDE.md` hält fest, mit welchem Stand das Video gebaut wurde. Schriften nur, wenn sie lokal eingebunden werden dürfen (Dateien des Nutzers oder freie Schriften, keine Systemschriften wie SF Pro oder Segoe). Fehlt ein Logo, Wortmarke als Text setzen und das im Storyboard sagen.

**b) Vorbilder.** Fragen:

> Gibt es Videos, Bilder oder Links, deren Look oder Animation dir gefällt und die als Vorbild dienen sollen?

Geliefertes nach `videos/<slug>/referenzen/` kopieren (nie verschieben) und auswerten:
- Bilder per Read.
- Videos per Kontaktbogen `bash "$S/scripts/kontaktbogen.sh" <video> referenzen/<name>-bogen.jpg 2` und Read. Bei schnellen Stellen Detailbogen mit höherer Rate. Für Tempo und Schnitte `ffmpeg -i <video> -vf "select='gt(scene,0.25)',showinfo" -f null - 2>&1 | grep -o "pts_time:[0-9.]*"`.
- Links per Playwright-Screenshot (Regeln der globalen CLAUDE.md).

Je Referenz drei Sätze in den Brief (Look, Bewegung, was übernommen wird) und die Karte aus `muster/`, der sie am nächsten kommt.

**c) Stilkarte (Pflicht).** Jedes Video bekommt genau eine Karte aus `muster/`. Mit Vorbildern die Karte, die deren Bewegung am nächsten kommt. Ohne Vorbilder zwei Karten mit je einem Satz Begründung vorschlagen, der Nutzer wählt. Standard für Vereine, soziale Themen und Dienstleistungen ist `helle-konstellation-kamerafahrt.md`, für Software-Launches `dark-launch.md` oder `bright-saas.md`. Die Farben kommen immer aus der Marke, die Karte liefert Bewegung, Bühnenaufbau und Rhythmus.

### 5. Tor 1, Storyboard

Im Brief und im Chat als Tabelle mit den Spalten Szene, Text (was im Bild steht oder gesprochen wird), Bildidee, Bewegung, Sekunden. Darüber die Kernaussage in einem Satz und die gewählte Stilkarte. Die Spalte Bewegung nennt je Szene die Technik aus dem Rezept der Karte (etwa Kamerafahrt, Punktwelt, Wörter auf Wellen, Rahmen-Morph, Tipp-Zoom). Texte nur aus dem Rohtext ableiten, jede Szene mit eigener Bildidee, die ohne Ton verständlich ist. Vor dem Zeigen gegen `references/best-practices.md` (Abschnitte Bild und Sprache) prüfen. Fragen, ob es so passt oder was geändert werden soll. Erst nach dem Go weiter, Abnahme mit Datum in den Brief. Ohne eingetragene Stilkarte im Brief wird nicht gebaut.

Mit Stimme jetzt die Audio-Kette (`references/audio-kette.md`): Skript aus der Text-Spalte, Credits nennen, Probezeile mit drei Stimmen, Wahl, ein Take, Schnitt mit `split_take.py` in Beats, `timing.js`. Mit eigener Aufnahme dieselbe Kette ab dem Schnitt.

### 6. Bauen (ohne Nutzerbeteiligung)

1. `/hyperframes` und `/hyperframes-animation` laden (Skill-Tool). Daraus Kompositionsvertrag und Animationsregeln nutzen, Ablaufvorgaben gelten aus diesem Skill.
   Danach die gewählte Stilkarte lesen, vor allem ihren Abschnitt „Rezept“ (Ebenen, Kamera, Punkte, Text, Timing). Mindestens drei Techniken aus dem Rezept aus der Karte übernehmen und im Brief unter Technik nennen, je nach Karte etwa Kamerafahrt durch Stationen, Punktwelt mit Parallaxe, Wörter auf Wellen, Rahmen-Morph, Tipp-Zoom. Übernommen wird die Mechanik, nie Texte, Namen oder Bilder der Quelle.
2. Im Videoordner anlegen: `HYPERFRAMES_NO_TELEMETRY=1 HYPERFRAMES_SKIP_SKILLS=1 npx --yes hyperframes@$V init film-v1 --example blank --resolution <portrait|landscape> --non-interactive`. Bei beiden Formaten ein zweites Projekt `film-v1-9x16` als eigene Komposition (Layout hochkant neu denken, nicht beschneiden).
3. GSAP lokal: die Datei aus dem `<script src>` der Vorlage nach `film-v1/vendor/gsap.min.js` laden (`curl -sL <url> -o ...`) und den Verweis auf `vendor/gsap.min.js` ändern. Schriften als `.woff2` nach `assets/fonts/` (Dateien des Nutzers oder freie Schriften, z. B. `https://cdn.jsdelivr.net/npm/@fontsource/<name>/files/<name>-latin-<gewicht>-normal.woff2`), Logo nach `assets/`. Keine Netzwerkzugriffe zur Renderzeit.
4. Komposition schreiben mit den Techniken der Stilkarte und aus `references/motion-techniken.md`. Root-`data-duration` gleich Gesamtlänge. Keine Shader-Übergänge (flackern im Render), kein `Math.random` (geseedeter Zufall). Mit Stimme alle Zeiten relativ zu den Cues aus `timing.js`, nie feste Sekunden.
5. Nach jeder Änderung `npx --yes hyperframes@$V check film-v1` mit null Fehlern.
6. Snapshots je Szene: `npx --yes hyperframes@$V snapshot film-v1 -o _pruefung/v1-r<runde> --at <zeiten> --describe false` und die Bilder per Read ansehen. Prüfliste `references/best-practices.md`. Mindestens zwei eigene Verbesserungsrunden, bevor der Nutzer etwas sieht. Sie bewerten vor allem Bewegung und Rhythmus: Jede Szene hat eine Einleitung, eine Haltung und einen Übergang. Keine Szene steht länger als 1,5 s ganz still (Atmen, Drift, Kamera). Übergänge laufen über Bewegung (Kamerafahrt, Verwandlung, Match Cut), nicht über Schnitt oder Ausblenden und Einblenden. Dazu Lesbarkeit (Text steht mindestens 1,5 s lesbar), nichts am Rand angeschnitten, eine Hauptaussage je Moment. Für Rhythmus Snapshots dicht um die Übergänge legen (je 0,3 s davor, mittendrin, danach).

### 7. Tor 2, Vorschau

Render in 30 fps Draft: `npx --yes hyperframes@$V render film-vN -o renders/vN/<datum>_<slug>-vN[-9x16].mp4 -f 30 -q draft`. Mit Ton vorher die Tonspur als `<audio>` in die Komposition legen. Datei mit `oeffnen.sh` öffnen, keine Studio-Vorschau. Fragen, ob es passt oder was geändert werden soll.

Feedback wörtlich als nummerierte Liste in `brief/FEEDBACK-vN.md`, je Punkt die geplante Umsetzung. Nächste Fassung als Kopie (`cp -R film-vN film-vN+1`, ebenso `-9x16`), Änderungen dort, wieder Check, Snapshots, Render als `renders/vN+1/`. Ändert ein Punkt den gesprochenen Text, die neue Formulierung vorher abstimmen, erst dann Credits ausgeben. Bei Ruckeln oder Bildfehlern erst messen (`ffmpeg -ss <t> -i <video> -frames:v 1 _pruefung/<name>.png`, bei langsamen Zooms `bewegung_messen.py`), dann beheben. Schleife, bis der Nutzer „passt“ sagt. Fassungstabelle im Brief pflegen.

### 8. Endfassung

1. Render 60 fps je Format: `npx --yes hyperframes@$V render film-vN -o final/<YYYY-MM-DD>_<slug>-FINAL.mp4 -f 60 -q standard`, die Hochkant-Fassung als `..._<slug>-FINAL-9x16.mp4` aus ihrer eigenen Komposition. Gibt es nur 9:16, trägt die Datei trotzdem `-9x16`.
2. Mit Ton: Mix als WAV, dann `bash "$S/scripts/master.sh" <mix.wav> <video.mp4> <ziel.mp4>` (-14 LUFS, -1 dBTP). Ohne Ton entfällt das Mastering.
3. Kurzprüfung: `ffprobe` auf Dauer, Auflösung und fps, ein Kontaktbogen nach `_pruefung/` und ansehen.
4. Datei öffnen, Pfad nennen (nur `final/<datei>`), Brief auf `Status: fertig` setzen. Alte Endfassungen bleiben liegen, eine neue bekommt das neue Datum.

## Grenzen

- Keine Varianten durch parallele Agenten, kein Lernmodus für neue Stilkarten, keine Web-Fassungen mit Poster, kein Einbau auf Websites. Dafür gibt es den größeren Skill `erklaervideo`.
- Keine echten Personen, Namen oder Kundendaten im Bild, die nicht aus dem Rohtext stammen.
