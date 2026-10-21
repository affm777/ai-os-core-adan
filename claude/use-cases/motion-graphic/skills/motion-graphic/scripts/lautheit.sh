#!/usr/bin/env bash
# Lautheitsverlauf alle 0,5 s plus True Peak, damit Drop und Ausklang wirklich hörbar sind.
#   bash lautheit.sh <audio-oder-video> [--drop <sekunde>]
# Zeigt je halbe Sekunde die Momentan-Lautheit (LUFS, 400 ms Fenster) als Balken.
# Prüft am Ende: True Peak höchstens -1 dBTP, mit --drop zusätzlich, dass es nach dem Drop
# mindestens 4 LU lauter ist als davor. Exit 0 = passt, Exit 2 = Hinweis ausgegeben.
# Läuft unter macOS (bash 3.2) und Windows (Git Bash), braucht nur ffmpeg und awk.
set -u
export MSYS_NO_PATHCONV=1
IN=${1:?Aufruf: bash lautheit.sh <datei> [--drop <sekunde>]}
DROP=""
[ "${2:-}" = "--drop" ] && DROP=${3:-}

ffmpeg -hide_banner -nostats -v verbose -i "$IN" -vn -af ebur128=peak=true:framelog=verbose -f null - 2>&1 | tr -d '\r' | awk -v drop="$DROP" '
  /Parsed_ebur128.*t: / {
    if (match($0, /t: *[0-9.]+/)) { x = substr($0, RSTART, RLENGTH); sub(/t: */, "", x); t = x + 0 }
    if (match($0, /M: *-?[0-9.]+/)) { x = substr($0, RSTART, RLENGTH); sub(/M: */, "", x); m = x + 0 }
    slot = int(t * 2 - 0.0001)
    if (slot < 0) slot = 0
    if (!(slot in seen)) { seen[slot] = 1; order[++n] = slot }
    lu[slot] = m
  }
  /Summary:/ { sum = 1 }
  sum && /I:/ && !gi { gi = $2 }
  sum && /Peak:/ { tp = $2 }
  END {
    if (n == 0) { print "Keine Tonspur gefunden."; exit 1 }
    print "Zeit   LUFS"
    vor = 0; nv = 0; nach = 0; nn = 0
    for (k = 1; k <= n; k++) {
      s = order[k]; v = lu[s] + 0; zeit = s / 2
      bar = ""; len = int((v + 50) / 1.5); if (len < 0) len = 0; if (len > 34) len = 34
      for (j = 0; j < len; j++) bar = bar "#"
      if (v < -70) printf "%5.1f   Stille\n", zeit; else printf "%5.1f  %6.1f  %s\n", zeit, v, bar
      if (drop != "" && v > -70) { if (zeit < drop) { vor += v; nv++ } else if (zeit < drop + 4) { nach += v; nn++ } }
    }
    printf "\nGesamt %s LUFS, True Peak %s dBTP\n", gi, tp
    rc = 0
    if (tp + 0 > -1.0) { print "Hinweis: True Peak über -1 dBTP, auf Handys droht Verzerrung (master.sh erneut laufen lassen)."; rc = 2 }
    if (drop != "" && nv > 0 && nn > 0) {
      d = nach / nn - vor / nv
      printf "Vor dem Drop im Mittel %.1f LUFS, danach %.1f LUFS, Unterschied %.1f LU\n", vor / nv, nach / nn, d
      if (d < 4) { print "Hinweis: Der Drop trifft nicht, das Intro ist zu laut (intro_db senken) oder die Musik nach dem Drop zu leise."; rc = 2 }
    }
    exit rc
  }'
