# Audio-Kette: Stimme, Timing, Musik, Master

Nur lesen, wenn das Video eine Stimme oder Musik bekommt.

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

## Musik

- **ElevenLabs Music:** Prompt mit Stimmung, Tempo (rund 90 bis 110 BPM), Instrumenten, Länge = `dur`. Dynamik so beschreiben, dass Sprechphasen ruhig sind. Instrumental nur über die Parameter (`lyrics_type: instrumental`, `instrumental: true`) beim Anlegen des Knotens, der Prompt allein liefert Gesang. Rund 930 Credits je 60 s. Auf Wunsch drei Stile mit je einer Generierung, jede unter das fertige Bild gemischt vergleichen (nicht einzeln vorspielen).
- **Länge anpassen:** nur auf Takt- oder Halbphrasengrenzen schneiden, 15 bis 20 ms vor dem Onset, 20 bis 30 ms Überblendung. Fehlt Länge, einen ganzen Takt wiederholen.
- **Gelieferte Datei:** Lizenz klären lassen, Länge per Schnitt am Taktende anpassen.

## Effekte

Nur an Momenten mit Bedeutung (Einschlag, Logo, Abschluss), nicht bei jedem Übergang. Quelle wie bei der Musik: eigene Datei oder ElevenLabs.

## Mix und Master

- Musik mindestens 15 dB unter der Stimme, Ducking während `bX_vo` bis `bX_end`.
- Kein Limiter auf der Stimme.
- `bash scripts/master.sh <mix.wav> <video.mp4> <ziel.mp4>`: Loudnorm zwei Durchgänge auf -14 LUFS / -1 dBTP, Ton ans Video, Messung am Ende.
- Stems (stimme, musik, sfx) als WAV 48 kHz neben die Endfassung.

## Python-Umgebung

Der Installer legt sie im Skill-Ordner an: `~/.claude/skills/motion-graphic/.venv` mit numpy, soundfile, scipy. Aufruf macOS `.venv/bin/python`, Windows (Git Bash) `.venv/Scripts/python.exe`, immer mit `-I`. Fehlt sie, die Installationszeile aus der README nennen, nicht selbst installieren.
