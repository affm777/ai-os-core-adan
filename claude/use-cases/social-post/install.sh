#!/usr/bin/env bash
# =============================================================================
# install.sh: Use-Case-Bundle social-post installieren (macOS und Windows/Git Bash)
# =============================================================================
# Was das Skript tut:
#   1. kopiert skills/social-post/ nach ~/.claude/skills/social-post/
#      (ältere Fassung wird nach ~/.claude/backups/ verschoben, nie gelöscht)
#   2. prüft, ob playwright-cli und Python 3 da sind (beides bringt das Setup mit)
#
# Was das Skript nie tut: Ordner im Arbeitsordner anlegen (social/ entsteht
# erst beim ersten Lauf des Skills), Programme installieren, Shell-Config oder
# PATH ändern, etwas löschen.
#
# Aufruf:
#   bash install.sh [--dry-run]
# Kompatibel mit bash 3.2 (macOS) und Git Bash (Windows). Idempotent.
# =============================================================================

export MSYS_NO_PATHCONV=1
set -eu

BUNDLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$BUNDLE_DIR/skills/social-post"
DEST="$HOME/.claude/skills/social-post"
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

for pflicht in SKILL.md scripts/vorbereiten.sh scripts/render.sh \
               templates/statement.html templates/info.html templates/karussell.html templates/basis.css templates/basis.js \
               marken/adan-ev/marke.css marken/adan-ev/logos.conf marken/adan-ev/STYLE-GUIDE.md \
               marken/adan-impact/marke.css marken/adan-impact/logos.conf marken/adan-impact/STYLE-GUIDE.md \
               marken/adan-careers/marke.css marken/adan-careers/logos.conf marken/adan-careers/STYLE-GUIDE.md; do
  [ -f "$SRC/$pflicht" ] || { err "Bundle unvollständig: $SRC/$pflicht fehlt."; exit 1; }
done

[ "$DRY" -eq 1 ] && echo "Probelauf (--dry-run): es wird nichts verändert."
echo "social-post installieren"
echo ""

# -----------------------------------------------------------------------------
# 1. Skill kopieren
# -----------------------------------------------------------------------------
if [ -d "$DEST" ] && diff -rq "$SRC" "$DEST" >/dev/null 2>&1; then
  info "Skill ist bereits aktuell: $DEST"
elif [ "$DRY" -eq 1 ]; then
  if [ -d "$DEST" ]; then
    drylog "würde die ältere Fassung nach ~/.claude/backups/skills/social-post.bak.$TS/ verschieben"
  fi
  drylog "würde $SRC nach $DEST kopieren"
else
  if [ -d "$DEST" ]; then
    BK="$HOME/.claude/backups/skills/social-post.bak.$TS"
    mkdir -p "$BK"
    for item in "$DEST"/* "$DEST"/.[!.]*; do
      [ -e "$item" ] || continue
      mv "$item" "$BK/"
    done
    info "Ältere Fassung gesichert: $BK"
    for m in "$BK"/marken/*/marke.css; do
      [ -f "$m" ] || continue
      slug="$(basename "$(dirname "$m")")"
      if [ -f "$SRC/marken/$slug/marke.css" ] && ! diff -q "$m" "$SRC/marken/$slug/marke.css" >/dev/null 2>&1; then
        warn "marke.css von $slug wich vom Standard ab. Eigene Werte gehören nach brand/$slug/marke.css im Arbeitsordner (Sicherung liegt in $BK)."
      fi
    done
  fi
  mkdir -p "$DEST"
  cp -R "$SRC/." "$DEST/"
  chmod +x "$DEST"/scripts/*.sh 2>/dev/null || true
  info "Skill installiert: $DEST"
fi

# -----------------------------------------------------------------------------
# 2. Werkzeuge prüfen (nur Hinweise, nichts wird installiert)
# -----------------------------------------------------------------------------
echo ""
if command -v playwright-cli >/dev/null 2>&1; then
  info "playwright-cli gefunden (rendert die Bilder)"
else
  warn "playwright-cli fehlt. Das Setup installiert es, bitte Setup-Prüfung (Pre-flight) erneut laufen lassen."
fi

PYBIN=""
for kandidat in python3 python "py -3"; do
  if $kandidat -c "import sys" </dev/null >/dev/null 2>&1; then PYBIN="$kandidat"; break; fi
done
if [ -n "$PYBIN" ]; then
  info "Python 3 gefunden ($PYBIN, für den lokalen Vorschau-Server)"
else
  if [ "$OS" = win ]; then warn "Python 3 fehlt. Installieren mit: winget install Python.Python.3.12 (danach neues Terminal öffnen)"
  else warn "Python 3 fehlt. Installieren mit: brew install python"; fi
fi

echo ""
if [ "$DRY" -eq 1 ]; then
  echo "Probelauf beendet. Ohne --dry-run starten, um zu installieren."
else
  echo "Fertig. Starte eine neue Claude-Session, damit der Skill social-post geladen wird."
fi
