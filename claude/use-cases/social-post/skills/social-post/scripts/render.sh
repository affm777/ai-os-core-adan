#!/usr/bin/env bash
# =============================================================================
# render.sh: rendert alle Seiten eines Build-Ordners als PNG
# =============================================================================
# Aufruf:  bash render.sh <build-ordner> <ziel-praefix> [--offline]
#   Beispiel: bash render.sh social/build/2026-10-20-adan-ev-ig-1x1 social/ausgabe/2026-10-20-adan-ev-ig-1x1
#   ergibt   social/ausgabe/2026-10-20-adan-ev-ig-1x1-01.png, -02.png, ...
#   --offline sperrt im Browser alle Adressen außer 127.0.0.1 (Test, ob der Post
#             ohne Internet mit Rubik rendert)
# Ablauf: lokaler HTTP-Server (python), playwright-cli öffnet die Seite, wartet
# auf Schrift und Einpassung, prüft Überlauf, macht je Seite (.sp-frame) einen
# Screenshot, schließt Browser und Server wieder.
# Kompatibel mit bash 3.2 (macOS) und Git Bash (Windows).
# =============================================================================
set -u

BUILD=""; ZIEL=""; OFFLINE=0
for arg in "$@"; do
  case "$arg" in
    --offline) OFFLINE=1 ;;
    *) if [ -z "$BUILD" ]; then BUILD="$arg"; elif [ -z "$ZIEL" ]; then ZIEL="$arg"; fi ;;
  esac
done
fehler() { echo "FEHLER: $*" >&2; exit 1; }
[ -n "$BUILD" ] && [ -n "$ZIEL" ] || fehler "Aufruf: bash render.sh <build-ordner> <ziel-praefix> [--offline]"
[ -f "$BUILD/index.html" ] || fehler "$BUILD/index.html fehlt, zuerst vorbereiten.sh ausführen."
[ -f "$BUILD/inhalt.json" ] || fehler "$BUILD/inhalt.json fehlt."
command -v playwright-cli >/dev/null 2>&1 || fehler "playwright-cli nicht gefunden. Das Setup bringt es mit, bitte Setup prüfen lassen."

# Python finden (unter Windows ist python3 oft nur ein Store-Platzhalter)
PYBIN=""
for kandidat in python3 python "py -3"; do
  if $kandidat -c "import sys" </dev/null >/dev/null 2>&1; then PYBIN="$kandidat"; break; fi
done
[ -n "$PYBIN" ] || fehler "Python 3 nicht gefunden (wird für den lokalen Vorschau-Server gebraucht)."

# inhalt.json muss gültiges JSON sein, sonst bleibt die Seite leer
$PYBIN -c "import json,sys; json.load(open(sys.argv[1], encoding='utf-8'))" "$BUILD/inhalt.json" \
  || fehler "$BUILD/inhalt.json ist kein gültiges JSON."

# Absolute Pfade, unter Windows in der Form C:/... für node
abspfad() { ( cd "$1" && pwd ); }
mkdir -p "$(dirname "$ZIEL")"
ZIEL_ABS="$(abspfad "$(dirname "$ZIEL")")/$(basename "$ZIEL")"
BUILD_ABS="$(abspfad "$BUILD")"
if command -v cygpath >/dev/null 2>&1; then ZIEL_ABS="$(cygpath -m "$ZIEL_ABS")"; BUILD_WIN="$(cygpath -w "$BUILD_ABS")"; else BUILD_WIN="$BUILD_ABS"; fi

# Freien Port suchen und Server starten
PORT=""
for p in 8765 8766 8767 8768 8769 8770; do
  if ! $PYBIN -c "import socket,sys; s=socket.socket(); s.settimeout(0.3); sys.exit(0 if s.connect_ex(('127.0.0.1',$p)) else 1)" 2>/dev/null; then
    continue
  fi
  PORT="$p"; break
done
[ -n "$PORT" ] || fehler "Kein freier Port zwischen 8765 und 8770."

$PYBIN -m http.server "$PORT" --bind 127.0.0.1 --directory "$BUILD_WIN" >/dev/null 2>&1 &
SERVER_PID=$!
SITZUNG="social-post"
aufraeumen() {
  playwright-cli -s="$SITZUNG" close >/dev/null 2>&1 || true
  kill "$SERVER_PID" >/dev/null 2>&1 || true
}
trap aufraeumen EXIT

bereit=0
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
  if $PYBIN -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:$PORT/index.html', timeout=1)" >/dev/null 2>&1; then bereit=1; break; fi
  sleep 0.5
done
[ "$bereit" -eq 1 ] || fehler "Der lokale Server startet nicht (Port $PORT)."

playwright-cli -s="$SITZUNG" open "http://127.0.0.1:$PORT/index.html" >/dev/null || fehler "playwright-cli konnte den Browser nicht öffnen. playwright-cli rendert mit Google Chrome. Fehlt Chrome, hilft: playwright-cli install-browser chrome (oder Chrome normal installieren)"
playwright-cli -s="$SITZUNG" resize 1400 2100 >/dev/null 2>&1 || true
if [ "$OFFLINE" -eq 1 ]; then
  playwright-cli -s="$SITZUNG" run-code "async page => { await page.context().route(u => !/^http:[/][/]127[.]0[.]0[.]1[:/]/.test(u.href), r => r.abort('internetdisconnected')); }" >/dev/null \
    || fehler "Netzsperre für --offline ließ sich nicht setzen."
  echo "Netz:      gesperrt (--offline), nur 127.0.0.1 erreichbar"
fi
playwright-cli -s="$SITZUNG" reload >/dev/null 2>&1 || true

ok=0
for i in $(seq 1 40); do
  r="$(playwright-cli -s="$SITZUNG" --raw eval "document.body.classList.contains('sp-bereit')" 2>/dev/null | tr -d '\r\n" ')"
  if [ "$r" = "true" ]; then ok=1; break; fi
  sleep 0.5
done
[ "$ok" -eq 1 ] || fehler "Die Seite wurde nicht fertig (Schrift oder inhalt.json). Im Browser prüfen: http://127.0.0.1:$PORT/index.html"

FEHLERTEXT="$(playwright-cli -s="$SITZUNG" --raw eval "document.body.getAttribute('data-fehler') || ''" 2>/dev/null | tr -d '\r"')"
[ -z "$FEHLERTEXT" ] || fehler "Vorlage meldet: $FEHLERTEXT"

# Zählt nur tatsächlich geladene Rubik-Schnitte. document.fonts.check() meldet auch
# dann "true", wenn gar keine Rubik-Datei eingebunden ist, taugt hier also nicht.
SCHRIFT="$(playwright-cli -s="$SITZUNG" --raw eval "Array.from(document.fonts).some(f => f.family.replace(/[\"']/g, '') === 'Rubik' && f.status === 'loaded') ? 'Rubik geladen' : 'Rubik NICHT geladen, Ersatzschrift system-ui'" 2>/dev/null | tr -d '\r"')"
echo "Schrift:   $SCHRIFT"

BERICHT="$(playwright-cli -s="$SITZUNG" --raw eval "Array.from(document.querySelectorAll('.sp-frame')).map((f,i)=>'Seite '+(i+1)+': '+(f.getAttribute('data-ueberlauf')==='ja'?'ÜBERLAUF, Text kürzen':'passt')+' (Schriftgröße '+Math.round(parseFloat(f.getAttribute('data-stufe')||'1')*100)+' Prozent)').join(' | ')" 2>/dev/null | tr -d '\r"')"
echo "Prüfung:   $BERICHT"

ANZAHL="$(playwright-cli -s="$SITZUNG" --raw eval "document.querySelectorAll('.sp-frame').length" 2>/dev/null | tr -d '\r\n" ')"
case "$ANZAHL" in ''|*[!0-9]*) fehler "Konnte die Seiten nicht zählen." ;; esac
[ "$ANZAHL" -ge 1 ] || fehler "Keine Seite (.sp-frame) gefunden."

n=1
while [ "$n" -le "$ANZAHL" ]; do
  NN="$(printf '%02d' "$n")"
  playwright-cli -s="$SITZUNG" screenshot "section.sp-frame:nth-of-type($n)" --filename="$ZIEL_ABS-$NN.png" >/dev/null \
    || fehler "Screenshot von Seite $n fehlgeschlagen."
  echo "Bild:      $ZIEL-$NN.png"
  n=$((n + 1))
done

# Überlauf zählen (Zahl statt Text, damit die Prüfung auch unter Windows-Konsolen sicher greift)
UEBERLAEUFE="$(playwright-cli -s="$SITZUNG" --raw eval "document.querySelectorAll('.sp-frame[data-ueberlauf]').length" 2>/dev/null | tr -d '\r\n" ')"
case "$UEBERLAEUFE" in ''|0) exit 0 ;; *) exit 3 ;; esac
