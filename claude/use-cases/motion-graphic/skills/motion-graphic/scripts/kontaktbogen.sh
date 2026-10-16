#!/usr/bin/env bash
# Kontaktbogen aus einem Video: ein Bild je Intervall, als Raster.
#   bash kontaktbogen.sh <video> <ziel.jpg> [bilder-pro-sekunde=1] [spalten=6]
# Für Referenzvideos mit Details: höhere Rate wählen und ggf. vorher mit crop ausschneiden.
# Läuft unter macOS (bash 3.2) und Windows (Git Bash), Pfade mit Leerzeichen erlaubt.
set -eu
export MSYS_NO_PATHCONV=1
VID=$1; ZIEL=$2; FPS=${3:-1}; COLS=${4:-6}
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VID" | tr -d '\r')
N=$(awk -v d="$DUR" -v f="$FPS" 'BEGIN{n=d*f; c=int(n); if (c<n) c++; if (c<1) c=1; print c}')
ROWS=$(awk -v n="$N" -v c="$COLS" 'BEGIN{r=int(n/c); if (r*c<n) r++; print r}')
# Zeitstempel nur, wenn ffmpeg mit drawtext (freetype) gebaut ist; sonst Raster ohne Beschriftung
if ffmpeg -hide_banner -filters 2>/dev/null | grep -q " drawtext "; then
  TXT="drawtext=text='%{pts\:hms}':x=8:y=8:fontsize=20:fontcolor=white:box=1:boxcolor=black@0.5,"
else
  TXT=""; echo "Hinweis: ffmpeg ohne drawtext, Bild n entspricht Sekunde (n-1)/$FPS"
fi
ffmpeg -loglevel error -y -i "$VID" -vf "fps=$FPS,scale=480:-1,${TXT}tile=${COLS}x${ROWS}" -frames:v 1 "$ZIEL"
echo "$ZIEL ($N Bilder, ${COLS}x${ROWS})"
