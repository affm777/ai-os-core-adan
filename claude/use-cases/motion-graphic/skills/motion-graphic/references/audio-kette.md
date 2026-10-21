# Audio-Kette: Stimme, Timing, Musik, Master

Nur lesen, wenn das Video eine Stimme, Musik oder Effekte bekommt.

## Stimme (ElevenLabs)

1. **Drei Proben:** drei Stimmen zur Zielgruppe passend auswählen (Sprache, Alter, Wärme). Alle sprechen dieselbe Probezeile von 5 bis 6 s, idealerweise mit einem schwierigen Wort aus dem Skript. Stimmen ausschließlich aus der Stimmliste des Connectors (`creative_list_voices`) oder vom User, nie aus dem Gedächtnis.
2. **Credits schätzen und nennen:** grob 1 Credit je Zeichen. Probe 3 x 80, Skript Zeichenzahl x 2 Takes plus eine Korrekturrunde. Beispiel AI-Coaching-Video: rund 4.200 Credits für 90 s inklusive Nachsprechen.
3. **Ein Take, ein Modell:** Das ganze Skript in einem Durchgang mit derselben Stimme und demselben Modell. Zwischen den Beats im Text Absätze lassen, damit klare Pausen entstehen.
4. **Lautschrift** für Abkürzungen und Eigennamen im TTS-Text (Anzeige-Text bleibt korrekt).
5. **Schnitt in Beats:** `scripts/split_take.py` findet die Pausen (ffmpeg silencedetect) und verteilt sie per dynamischer Programmierung auf die Beat-Grenzen. Ergebnis: `stimme.wav` mit festen Pausen zwischen den Beats und `timing.js` mit `bX` (Bildstart), `bX_vo`, `bX_end`, Wort-Cues `w_*`, `end` und `dur`. Schnittpunkte prüfen, bei Fehlern als `<take>.spans.json` festschreiben.
6. **Einzelne Sätze ersetzen** nur mit derselben Stimme und demselben Modell (`--ersatz b9,b10=datei.mp3`).
7. **Download:** Connector-Ergebnisse nur über `creative_get_flow_run_status` (alle `session_ids`) herunterladbar, Feld `content_url`, zwei Stunden gültig, sofort per curl laden und nicht speichern.
8. **Pausen:** Im Skript keine Lücke über rund 1,5 s zwischen Sätzen einplanen, sonst wirkt die Stimme abgeschnitten.

Ohne ElevenLabs-Anbindung gibt es keine generierte Stimme. Dann liefert der Nutzer eine eigene Aufnahme (ein Take, Absätze als Pausen, gleiche Kette ab Schritt 5) oder das Video bleibt ohne Stimme.

## Vor jeder ElevenLabs-Generierung (PFLICHT)

`~/.claude/bin/vault-find.sh elevenlabs` aufrufen, falls vorhanden, und die Treffer zu Musik und Geräuschen lesen. Grund: Im ADAN-Testlauf lief die Musik trotz „Instrumental“ im Prompt mit Gesang, obwohl das Learning dazu seit dem 21.09. im Vault stand.

## Geräusche (ElevenLabs, Standard)

1. Liste aus der Spalte Klang des Beat-Plans, je Aktion ein Geräusch (Tippen, Marker-Strich, Whoosh, Pop, Chime, Mausklick). Credits nennen: rund 17 je Geräusch.
2. Modell `eleven_text_to_sound_v2`, kurzer englischer Prompt mit Material und Länge (etwa „single soft mouse click, dry, 0.3 s“).
3. Herunterladen nur über `content_url` aus `creative_get_flow_run_status`, sofort per curl nach `renders/vN/ton/roh/`.
4. Jede Datei mit `bash "$S/scripts/sfx_zuschnitt.sh" <roh> renders/vN/ton/<name>.wav` auf ihren Kern schneiden, sonst sitzt der Klang zu spät (ElevenLabs liefert Stille davor).
5. In `timeline.js` je Aktion `{"t": <zeit>, "datei": "../renders/vN/ton/<name>.wav", "db": -6}` eintragen (Pfad relativ zur timeline.js), dann `klang.py` wie unten.

## Musik

- **ElevenLabs Music:** Modell `eleven_music_v2_5`. Prompt mit Stimmung, Tempo (rund 90 bis 120 BPM), Instrumenten, Länge = `dur`, bei Reels ein spürbarer Drop an der Stelle aus `drop`. Dynamik so beschreiben, dass Sprechphasen ruhig sind. **Instrumental hart setzen:** `lyrics_type: instrumental` und `instrumental: true` als Parameter beim Anlegen des Knotens, nie nur im Prompt. Vor dem Download im Ergebnis prüfen, dass `instrumental` wirklich `true` ist, sonst verwerfen und neu anlegen. In `timeline.js` als `"musik": {"art": "datei", "pfad": "<pfad>.wav", "db": -6}` (vorher mit `ffmpeg -i <mp3> -ar 48000 -ac 2 <wav>` umwandeln). Rund 900 Credits je Variante (Testlauf 21.10.: zwei Varianten plus sechs Geräusche rund 1.900 Credits). Auf Wunsch drei Stile mit je einer Generierung, jede unter das fertige Bild gemischt vergleichen (nicht einzeln vorspielen).
- **Länge anpassen:** nur auf Takt- oder Halbphrasengrenzen schneiden, 15 bis 20 ms vor dem Onset, 20 bis 30 ms Überblendung. Fehlt Länge, einen ganzen Takt wiederholen.
- **Gelieferte Datei:** Lizenz klären lassen, Länge per Schnitt am Taktende anpassen.

## Effekte

Nur an Momenten mit Bedeutung (Einschlag, Logo, Abschluss, eine Aktion im Bild), nicht bei jedem Übergang. Quelle ist ElevenLabs (Abschnitt Geräusche) oder eine eigene Datei.

## Klang auf der Timeline anlegen (`klang.py`)

`klang.py` legt die ElevenLabs-Geräusche und die Musik genau zu den Zeiten aus `timeline.js` an (Einträge mit `datei`). Nur ohne ElevenLabs-Anbindung und auf Wunsch des Nutzers synthetisiert es Effekte und Beat selbst (Einträge mit `typ`, Musik `art: beat`), das klingt einfacher. Grundlage ist `film-vN/timeline.js`, derselben Datei, aus der die Komposition ihre Zeiten liest. Dadurch sitzt jeder Klick genau auf dem Frame der Aktion, auch nach jeder Änderung.

1. In `timeline.js` die Felder `dauer`, `bpm`, `drop`, `musik` (`{"art": "beat", "grundton": 55, "intro_db": -12}` oder `null`) und `klang` pflegen. Typen: `klick`, `tipp`, `ding`, `pop`, `whoosh`, `glas`, `aufprall`, `riser` (endet bei `t`), `powerdown`, `schimmer`. Optional je Ereignis `db`, `ton` (Hz), `dauer`, `pan`.
2. `"$S/.venv/bin/python" -I "$S/scripts/klang.py" film-vN/timeline.js renders/vN/ton [--stimme stimme.wav]` schreibt `sfx.wav`, `musik.wav` und `mix-roh.wav`. Mit Stimme wird die Musik in Sprechphasen um 15 dB abgesenkt (Stimme 48 kHz).
3. Vorschau: `mix-roh.wav` als `<audio>` in die Komposition, Endfassung über `master.sh`.
4. Prüfen mit `bash "$S/scripts/lautheit.sh" <datei> --drop <s>`: Momentan-Lautheit alle 0,5 s als Balken, True Peak und der Abstand vor und nach dem Drop. Ziel leise vor dem Drop, mindestens 4 LU lauter danach, sanfter Ausklang, True Peak höchstens -1 dBTP. Getestet: Intro -28,5 LUFS, nach dem Drop -17,0 LUFS (11,5 LU), True Peak -1,4 dBTP nach `master.sh`.
5. Höhen über 16 kHz rollt `klang.py` ab, weil synthetische Kanten sonst zwischen den Samples überschießen (die Anleitung maß +2,7 dB True Peak ohne diese Maßnahme).

Pegel nachregeln mit Zahlen: Ein Effekt zu laut heißt `"db"` am Ereignis um 3 bis 6 senken, ein Drop ohne Wirkung heißt `intro_db` senken (etwa -12 auf -16).

## Mix und Master

- Musik mindestens 15 dB unter der Stimme, Ducking während `bX_vo` bis `bX_end`.
- Kein Limiter auf der Stimme.
- `bash scripts/master.sh <mix.wav> <video.mp4> <ziel.mp4>`: Loudnorm zwei Durchgänge auf -14 LUFS / -1 dBTP, Ton ans Video, Messung am Ende.
- Stems (stimme, musik, sfx) als WAV 48 kHz neben die Endfassung.

## Python-Umgebung

Der Installer legt sie im Skill-Ordner an: `~/.claude/skills/motion-graphic/.venv` mit numpy, soundfile, scipy. Aufruf macOS `.venv/bin/python`, Windows (Git Bash) `.venv/Scripts/python.exe`, immer mit `-I`. Fehlt sie, die Installationszeile aus der README nennen, nicht selbst installieren.
