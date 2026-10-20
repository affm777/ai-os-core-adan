#!/usr/bin/env bash
# =============================================================================
# install.sh: Use-Case-Bundle beleg-ablage installieren (macOS und Windows/Git Bash)
# =============================================================================
# Was das Skript tut:
#   1. kopiert skills/beleg-ablage/ nach ~/.claude/skills/beleg-ablage/
#      (ältere Fassung wird nach ~/.claude/backups/ verschoben, nie gelöscht)
#   2. prüft Python 3, ein Werkzeug zum Lesen von PDF-Text (pypdf oder
#      pdftotext) und optional openpyxl, nennt sonst den Befehl zum Nachinstallieren
#
# Was das Skript nie tut: Programme oder Pakete installieren, Ordner im
# Arbeitsordner anlegen (belege/ entsteht erst beim ersten Lauf), Shell-Config
# oder PATH ändern, etwas löschen. Deine Belege, KONFIG.md und LIEFERANTEN.md
# liegen im Arbeitsordner und werden nie angefasst.
#
# Aufruf:
#   bash install.sh [--dry-run]
# Kompatibel mit bash 3.2 (macOS) und Git Bash (Windows). Idempotent.
# =============================================================================

export MSYS_NO_PATHCONV=1
set -eu

BUNDLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$BUNDLE_DIR/skills/beleg-ablage"
DEST="$HOME/.claude/skills/beleg-ablage"
TS="$(date +%Y%m%d-%H%M%S)"
DRY=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY=1 ;;
    -h|--help)
      echo "Aufruf: bash install.sh [--dry-run]"
      echo "  --dry-run   nur prüfen und anzeigen, nichts verändern"
      exit 0 ;;
    *) echo "Unbekanntes Argument: $arg (ignoriert)" ;;
  esac
done

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'
info()  { printf "${GREEN}[OK]${NC}   %s\n" "$*"; }
warn()  { printf "${YELLOW}[!!]${NC}   %s\n" "$*"; }
drylog(){ printf "${CYAN}[DRY]${NC}  %s\n" "$*"; }
err()   { printf "${RED}[ERR]${NC}  %s\n" "$*" >&2; }

case "$(uname -s 2>/dev/null || echo unbekannt)" in
  Darwin) OS=mac ;;
  MINGW*|MSYS*|CYGWIN*) OS=win ;;
  *) OS=anderes; warn "Unbekanntes Betriebssystem, getestet sind macOS und Windows (Git Bash)." ;;
esac

for pflicht in SKILL.md scripts/beleg.py vorlagen/KONFIG.md vorlagen/LIEFERANTEN.md \
               beispiel/LIEFERANTEN.md beispiel/beispiel-rechnung-pflegebedarf.pdf \
               beispiel/beispiel-rechnung-buerotechnik.pdf; do
  [ -f "$SRC/$pflicht" ] || { err "Bundle unvollständig: $SRC/$pflicht fehlt."; exit 1; }
done

[ "$DRY" -eq 1 ] && echo "Probelauf (--dry-run): es wird nichts verändert."
echo "beleg-ablage installieren"
echo ""

# -----------------------------------------------------------------------------
# 1. Skill kopieren
# -----------------------------------------------------------------------------
if [ -d "$DEST" ] && diff -rq -x __pycache__ "$SRC" "$DEST" >/dev/null 2>&1; then
  info "Skill ist bereits aktuell: $DEST"
elif [ "$DRY" -eq 1 ]; then
  if [ -d "$DEST" ]; then
    drylog "würde die ältere Fassung nach ~/.claude/backups/skills/beleg-ablage.bak.$TS/ verschieben"
  fi
  drylog "würde $SRC nach $DEST kopieren"
else
  if [ -d "$DEST" ]; then
    BK="$HOME/.claude/backups/skills/beleg-ablage.bak.$TS"
    mkdir -p "$BK"
    for item in "$DEST"/* "$DEST"/.[!.]*; do
      [ -e "$item" ] || continue
      mv "$item" "$BK/"
    done
    info "Ältere Fassung gesichert: $BK"
  fi
  mkdir -p "$DEST"
  cp -R "$SRC/." "$DEST/"
  info "Skill installiert: $DEST"
fi

# -----------------------------------------------------------------------------
# 2. Python 3, PDF-Text und openpyxl prüfen (nur Hinweis, nichts wird installiert)
# -----------------------------------------------------------------------------
echo ""
PY=""
for kandidat in python3 py python; do
  if command -v "$kandidat" >/dev/null 2>&1; then
    if [ "$kandidat" = py ]; then
      "$kandidat" -3 -c "import sys" >/dev/null 2>&1 && { PY="py -3"; break; }
    else
      "$kandidat" -c "import sys; sys.exit(0 if sys.version_info[0] == 3 else 1)" >/dev/null 2>&1 && { PY="$kandidat"; break; }
    fi
  fi
done

if [ -z "$PY" ]; then
  warn "Python 3 nicht gefunden. Sag Claude: \"Installier mir bitte Python 3\" und führe danach dieses Skript erneut aus."
else
  info "Python gefunden: $($PY --version 2>&1)"
  if $PY -c "import pypdf" >/dev/null 2>&1; then
    info "pypdf ist installiert (liest den Text aus Rechnungs-PDFs)"
  elif command -v pdftotext >/dev/null 2>&1; then
    info "pdftotext gefunden (liest den Text aus Rechnungs-PDFs)"
  else
    warn "Kein Werkzeug zum Lesen von PDF-Text. Ohne es kann Claude Betrag und Rechnungsnummer nicht vorschlagen. Installieren mit:"
    echo "        $PY -m pip install --user pypdf"
  fi
  if $PY -c "import openpyxl" >/dev/null 2>&1; then
    info "openpyxl ist installiert (für die optionale Excel-Übersicht)"
  else
    warn "openpyxl fehlt, die Excel-Übersicht ist dann nicht verfügbar (die Markdown-Übersicht geht immer). Installieren mit:"
    echo "        $PY -m pip install --user openpyxl"
  fi
fi

echo ""
if [ "$DRY" -eq 1 ]; then
  echo "Probelauf beendet. Ohne --dry-run starten, um zu installieren."
else
  echo "Fertig. Starte eine neue Claude-Session, damit der Skill beleg-ablage geladen wird."
fi
