#!/usr/bin/env bash
# =============================================================================
# pdf.sh: druckt alle Seiten eines Build-Ordners als eine PDF (LinkedIn-Karussell)
# =============================================================================
# Aufruf:  bash pdf.sh <build-ordner> <ziel.pdf>
#   Beispiel: bash pdf.sh content-und-social/ausgabe/<lauf>/bilder/_build/karussell-li-de \
#                         content-und-social/ausgabe/<lauf>/bilder/adan-ev-karussell-li-de.pdf
# Je Seite (.sp-frame) eine PDF-Seite in Reihenfolge, Seitengröße gleich der
# PNG-Größe (etwa 1080 x 1080 px), ohne Rand und ohne Skalierung. Ablauf wie
# render.sh: lokaler HTTP-Server (python), playwright-cli öffnet die Seite,
# wartet auf Schrift und Einpassung, druckt per Playwright page.pdf().
# Braucht nichts außer playwright-cli, Chrome und Python 3 (wie render.sh).
# Überschreibt keine vorhandene PDF. Kompatibel mit bash 3.2 und Git Bash.
# =============================================================================
set -u

BUILD="${1:-}"; ZIEL="${2:-}"
fehler() { echo "FEHLER: $*" >&2; exit 1; }
[ -n "$BUILD" ] && [ -n "$ZIEL" ] || fehler "Aufruf: bash pdf.sh <build-ordner> <ziel.pdf>"
case "$ZIEL" in *.pdf) ;; *) fehler "Ziel muss auf .pdf enden: $ZIEL" ;; esac
[ -f "$BUILD/index.html" ] || fehler "$BUILD/index.html fehlt, zuerst vorbereiten.sh ausführen."
[ -f "$BUILD/inhalt.json" ] || fehler "$BUILD/inhalt.json fehlt."
[ -e "$ZIEL" ] && fehler "$ZIEL gibt es schon. Anderen Namen wählen (etwa -v2), nichts wird überschrieben."
command -v playwright-cli >/dev/null 2>&1 || fehler "playwright-cli nicht gefunden. Das Setup bringt es mit, bitte Setup prüfen lassen."

# Python finden (unter Windows ist python3 oft nur ein Store-Platzhalter)
PYBIN=""
for kandidat in python3 python "py -3"; do
  if $kandidat -c "import sys" </dev/null >/dev/null 2>&1; then PYBIN="$kandidat"; break; fi
done
[ -n "$PYBIN" ] || fehler "Python 3 nicht gefunden (wird für den lokalen Vorschau-Server gebraucht)."
$PYBIN -c "import json,sys; json.load(open(sys.argv[1], encoding='utf-8'))" "$BUILD/inhalt.json" \
  || fehler "$BUILD/inhalt.json ist kein gültiges JSON."

# Absolute Pfade, unter Windows in der Form C:/... für node
abspfad() { ( cd "$1" && pwd ); }
mkdir -p "$(dirname "$ZIEL")"
ZIEL_ABS="$(abspfad "$(dirname "$ZIEL")")/$(basename "$ZIEL")"
BUILD_ABS="$(abspfad "$BUILD")"
if command -v cygpath >/dev/null 2>&1; then ZIEL_ABS="$(cygpath -m "$ZIEL_ABS")"; BUILD_WIN="$(cygpath -w "$BUILD_ABS")"; else BUILD_WIN="$BUILD_ABS"; fi
case "$ZIEL_ABS" in *\'*|*\\*) fehler "Zielpfad darf keine Apostrophe oder Backslashes enthalten: $ZIEL_ABS" ;; esac

# Freien Port suchen und Server starten
PORT=""
for p in 8775 8776 8777 8778 8779 8780; do
  if ! $PYBIN -c "import socket,sys; s=socket.socket(); s.settimeout(0.3); sys.exit(0 if s.connect_ex(('127.0.0.1',$p)) else 1)" 2>/dev/null; then
    continue
  fi
  PORT="$p"; break
done
[ -n "$PORT" ] || fehler "Kein freier Port zwischen 8775 und 8780."

$PYBIN -m http.server "$PORT" --bind 127.0.0.1 --directory "$BUILD_WIN" >/dev/null 2>&1 &
SERVER_PID=$!
SITZUNG="content-publisher-pdf"
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

# playwright-cli legt .playwright-cli/ im aktuellen Verzeichnis an, deshalb im Build-Ordner arbeiten.
cd "$BUILD_ABS" || fehler "Build-Ordner nicht erreichbar: $BUILD_ABS"
playwright-cli -s="$SITZUNG" open "http://127.0.0.1:$PORT/index.html" >/dev/null || fehler "playwright-cli konnte den Browser nicht öffnen. Fehlt Chrome, hilft: playwright-cli install-browser chrome"
playwright-cli -s="$SITZUNG" resize 1400 2100 >/dev/null 2>&1 || true

ok=0
for i in $(seq 1 40); do
  r="$(playwright-cli -s="$SITZUNG" --raw eval "document.body.classList.contains('sp-bereit')" 2>/dev/null | tr -d '\r\n" ')"
  if [ "$r" = "true" ]; then ok=1; break; fi
  sleep 0.5
done
[ "$ok" -eq 1 ] || fehler "Die Seite wurde nicht fertig (Schrift oder inhalt.json)."
FEHLERTEXT="$(playwright-cli -s="$SITZUNG" --raw eval "document.body.getAttribute('data-fehler') || ''" 2>/dev/null | tr -d '\r"')"
[ -z "$FEHLERTEXT" ] || fehler "Vorlage meldet: $FEHLERTEXT"

# Seitengröße aus dem ersten Frame (alle Seiten eines Builds haben dasselbe Format)
GROESSE="$(playwright-cli -s="$SITZUNG" --raw eval "(function(){var f=document.querySelector('.sp-frame');var r=f.getBoundingClientRect();return Math.round(r.width)+'x'+Math.round(r.height);})()" 2>/dev/null | tr -d '\r\n" ')"
B="${GROESSE%x*}"; H="${GROESSE#*x}"
case "$B$H" in ''|*[!0-9]*) fehler "Konnte die Seitengröße nicht lesen ($GROESSE)." ;; esac
ANZAHL="$(playwright-cli -s="$SITZUNG" --raw eval "document.querySelectorAll('.sp-frame').length" 2>/dev/null | tr -d '\r\n" ')"
case "$ANZAHL" in ''|*[!0-9]*) fehler "Konnte die Seiten nicht zählen." ;; esac

# Druck-Stylesheet: je Frame eine Seite, kein Rand, kein Abstand, keine Skalierung
CSS="@page { size: ${B}px ${H}px; margin: 0 } html, body { margin: 0 !important; padding: 0 !important; background: none !important } main { display: block !important; gap: 0 !important } .sp-frame { break-after: page; page-break-after: always; transform: none !important } .sp-frame:last-of-type { break-after: auto; page-break-after: auto }"
playwright-cli -s="$SITZUNG" run-code "async page => { await page.addStyleTag({ content: '$CSS' }); await page.emulateMedia({ media: 'print' }); await page.pdf({ path: '$ZIEL_ABS', width: '${B}px', height: '${H}px', printBackground: true, preferCSSPageSize: true, scale: 1, margin: { top: '0', right: '0', bottom: '0', left: '0' } }); }" >/dev/null \
  || fehler "PDF-Druck fehlgeschlagen. playwright-cli druckt PDFs nur mit Chromium oder Chrome."
[ -f "$ZIEL_ABS" ] || [ -f "$ZIEL" ] || fehler "PDF wurde nicht geschrieben: $ZIEL"
echo "PDF:       $ZIEL ($ANZAHL Seiten, je $B x $H px)"
exit 0
