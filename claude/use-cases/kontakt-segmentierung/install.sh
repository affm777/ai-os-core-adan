#!/usr/bin/env bash
# =============================================================================
# install.sh: Use-Case-Bundle kontakt-segmentierung installieren (macOS und Windows/Git Bash)
# =============================================================================
# Was das Skript tut:
#   1. kopiert skills/kontakt-segmentierung/ nach ~/.claude/skills/kontakt-segmentierung/
#      (ältere Fassung wird nach ~/.claude/backups/ verschoben, nie gelöscht;
#      selbst angepasste segmente.md und ausschluss.md bleiben erhalten)
#   2. prüft Python 3 und das Paket openpyxl, nennt sonst den Befehl zum
#      Nachinstallieren
#
# Was das Skript nie tut: Programme oder Pakete installieren, Ordner im
# Arbeitsordner anlegen (kontakte/ entsteht erst beim ersten Lauf), Shell-Config
# oder PATH ändern, etwas löschen.
#
# Aufruf:
#   bash install.sh [--dry-run]
# Kompatibel mit bash 3.2 (macOS) und Git Bash (Windows). Idempotent.
# =============================================================================

export MSYS_NO_PATHCONV=1
set -eu

BUNDLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$BUNDLE_DIR/skills/kontakt-segmentierung"
DEST="$HOME/.claude/skills/kontakt-segmentierung"
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

for pflicht in SKILL.md segmente.md ausschluss.md scripts/einlesen.py scripts/bestand.py scripts/schreiben.py \
               scripts/akten.py scripts/spalten.json vorlagen/anlass.md vorlagen/struktur.md \
               vorlagen/checkliste.md vorlagen/ansprache.md vorlagen/recherche-anlass.md vorlagen/recherche-firmen.md \
               beispiel/Connections-beispiel.csv beispiel/Partner-beispiel.csv beispiel/firmenakte-beispiel.md; do
  [ -f "$SRC/$pflicht" ] || { err "Bundle unvollständig: $SRC/$pflicht fehlt."; exit 1; }
done

[ "$DRY" -eq 1 ] && echo "Probelauf (--dry-run): es wird nichts verändert."
echo "kontakt-segmentierung installieren"
echo ""

# -----------------------------------------------------------------------------
# 1. Skill kopieren, eigene Regeln behalten
# -----------------------------------------------------------------------------
if [ -d "$DEST" ] && diff -rq -x __pycache__ "$SRC" "$DEST" >/dev/null 2>&1; then
  info "Skill ist bereits aktuell: $DEST"
elif [ "$DRY" -eq 1 ]; then
  if [ -d "$DEST" ]; then
    drylog "würde die ältere Fassung nach ~/.claude/backups/skills/kontakt-segmentierung.bak.$TS/ verschieben"
    for eigen in segmente.md ausschluss.md; do
      if [ -f "$DEST/$eigen" ] && ! diff -q "$DEST/$eigen" "$SRC/$eigen" >/dev/null 2>&1; then
        drylog "würde deine angepasste $eigen behalten"
      fi
    done
  fi
  drylog "würde $SRC nach $DEST kopieren"
else
  BK=""
  if [ -d "$DEST" ]; then
    BK="$HOME/.claude/backups/skills/kontakt-segmentierung.bak.$TS"
    mkdir -p "$BK"
    for item in "$DEST"/* "$DEST"/.[!.]*; do
      [ -e "$item" ] || continue
      mv "$item" "$BK/"
    done
    info "Ältere Fassung gesichert: $BK"
  fi
  mkdir -p "$DEST"
  cp -R "$SRC/." "$DEST/"
  if [ -n "$BK" ]; then
    for eigen in segmente.md ausschluss.md; do
      if [ -f "$BK/$eigen" ] && ! diff -q "$BK/$eigen" "$SRC/$eigen" >/dev/null 2>&1; then
        cp "$BK/$eigen" "$DEST/$eigen"
        info "Deine angepasste $eigen bleibt erhalten (Standardfassung liegt im Bundle)."
      fi
    done
  fi
  info "Skill installiert: $DEST"

  # Agent-Typ "recherche" (nur WebSearch und WebFetch) fuer Phase B und D.
  # Liegt im Setup-Repo unter claude/agents/, aeltere Setups haben ihn nicht.
  AGENT_SRC="$BUNDLE_DIR/../../agents/recherche.md"
  AGENT_DEST="$HOME/.claude/agents/recherche.md"
  if [ -f "$AGENT_SRC" ]; then
    mkdir -p "$HOME/.claude/agents"
    if [ -f "$AGENT_DEST" ] && ! diff -q "$AGENT_SRC" "$AGENT_DEST" >/dev/null 2>&1; then
      mkdir -p "$HOME/.claude/backups/agents"
      cp "$AGENT_DEST" "$HOME/.claude/backups/agents/recherche.md.bak.$TS"
    fi
    cp "$AGENT_SRC" "$AGENT_DEST"
    info "Recherche-Helfer installiert: $AGENT_DEST"
  else
    warn "Recherche-Helfer (claude/agents/recherche.md) nicht im Setup-Repo gefunden, Claude nimmt den allgemeinen Helfer."
  fi
fi

# -----------------------------------------------------------------------------
# 2. Python 3 und openpyxl prüfen (nur Hinweis, nichts wird installiert)
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
  if $PY -c "import openpyxl" >/dev/null 2>&1; then
    info "openpyxl ist installiert (für die Excel-Datei)"
  else
    warn "Das Paket openpyxl fehlt, ohne es entsteht keine Excel-Datei. Installieren mit:"
    echo "        $PY -m pip install openpyxl"
  fi
fi

echo ""
if [ "$DRY" -eq 1 ]; then
  echo "Probelauf beendet. Ohne --dry-run starten, um zu installieren."
else
  echo "Fertig. Starte eine neue Claude-Session, damit der Skill kontakt-segmentierung geladen wird."
fi
