#!/usr/bin/env bash
# Master auf -14 LUFS / -1 dBTP (loudnorm, zwei Durchgänge) und Ton an das Video legen.
#   bash master.sh <mix-roh.wav> <video.mp4> <ziel.mp4>
# Schreibt <mix-roh>-master.wav neben die Eingabe und misst am Ende Lautheit und Spitzenpegel.
# Läuft unter macOS (bash 3.2) und Windows (Git Bash), braucht nur ffmpeg (kein Python).
set -eu
export MSYS_NO_PATHCONV=1
IN=$1; VID=$2; ZIEL=$3
OUT="${IN%.*}-master.wav"
J=$(ffmpeg -hide_banner -i "$IN" -af loudnorm=I=-14:TP=-1:LRA=11:print_format=json -f null - 2>&1 | tr -d '\r' | sed -n '/^{/,/^}/p')
wert() { printf '%s\n' "$J" | sed -n "s/.*\"$1\" *: *\"\{0,1\}\([-0-9.inf]*\)\"\{0,1\}.*/\1/p" | head -1; }
ii=$(wert input_i); itp=$(wert input_tp); ilra=$(wert input_lra); ith=$(wert input_thresh); off=$(wert target_offset)
if [ -z "$ii" ] || [ -z "$off" ]; then echo "Messung fehlgeschlagen, ist $IN eine Audiodatei mit Ton?" >&2; exit 1; fi
ffmpeg -loglevel error -y -i "$IN" -af "loudnorm=I=-14:TP=-1:LRA=11:measured_I=${ii}:measured_TP=${itp}:measured_LRA=${ilra}:measured_thresh=${ith}:offset=${off}:linear=true,aresample=48000" -c:a pcm_s24le "$OUT"
ffmpeg -loglevel error -y -i "$VID" -i "$OUT" -map 0:v -map 1:a -c:v copy -c:a aac -b:a 256k -shortest "$ZIEL"
ffmpeg -hide_banner -i "$OUT" -af ebur128=peak=true -f null - 2>&1 | grep -A16 Summary | grep -E " I:|Peak:"
