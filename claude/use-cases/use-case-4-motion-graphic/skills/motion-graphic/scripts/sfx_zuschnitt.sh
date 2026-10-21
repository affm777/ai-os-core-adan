#!/usr/bin/env bash
# Schneidet ein Geräusch (etwa von ElevenLabs) auf seinen Kern und wandelt es in WAV 48 kHz Stereo.
#   bash sfx_zuschnitt.sh <eingabe.mp3|wav> <ausgabe.wav> [schwelle-db]
# Entfernt Stille am Anfang und Ende (Standard -45 dB), damit der Klang genau auf seiner Timeline-Zeit sitzt.
# Gibt die Länge vorher und nachher aus. Läuft unter macOS (bash 3.2) und Windows (Git Bash), braucht nur ffmpeg.
set -eu
export MSYS_NO_PATHCONV=1
IN=${1:?Aufruf: bash sfx_zuschnitt.sh <eingabe> <ausgabe.wav> [schwelle-db]}
OUT=${2:?Ausgabedatei fehlt}
TH=${3:--45}
F="silenceremove=start_periods=1:start_threshold=${TH}dB:start_silence=0.005,areverse,silenceremove=start_periods=1:start_threshold=${TH}dB:start_silence=0.02,areverse"
ffmpeg -loglevel error -y -i "$IN" -af "$F" -ar 48000 -ac 2 -c:a pcm_s24le "$OUT"
vor=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$IN")
nach=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT")
echo "$(basename "$OUT"): ${vor%.*}.$(echo "${vor#*.}" | cut -c1-2) s auf ${nach%.*}.$(echo "${nach#*.}" | cut -c1-2) s"
