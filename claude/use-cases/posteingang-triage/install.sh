#!/usr/bin/env bash
# =============================================================================
# install.sh: Use-Case-Bundle posteingang-triage installieren (macOS und Windows/Git Bash)
# =============================================================================
# Was das Skript tut:
#   1. kopiert skills/posteingang-triage/ nach ~/.claude/skills/posteingang-triage/
#      (ältere Fassung wird nach ~/.claude/backups/ verschoben, nie gelöscht)
#   2. holt deine eigenen Dateien aus der Sicherung zurück: TONE.md (gelernter
#      Schreibstil), POSTFAECHER.md (ältere Fassung) und alle .last-run*-Dateien
#      (wann welches Postfach zuletzt gesichtet wurde)
#
# Was das Skript nie tut: Ordner im Arbeitsordner anlegen (posteingang/KONFIG.md
# und TODO.md entstehen erst beim ersten Lauf des Skills), Programme
# installieren, Shell-Config oder PATH ändern, etwas löschen.
#
# Aufruf:
#   bash install.sh [--dry-run]
# Kompatibel mit bash 3.2 (macOS) und Git Bash (Windows). Idempotent.
# =============================================================================

export MSYS_NO_PATHCONV=1
set -eu

BUNDLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$BUNDLE_DIR/skills/posteingang-triage"
DEST="$HOME/.claude/skills/posteingang-triage"
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
  Darwin|MINGW*|MSYS*|CYGWIN*) ;;
  *) warn "Unbekanntes Betriebssystem, getestet sind macOS und Windows (Git Bash)." ;;
esac

BUNDLE_FILES="SKILL.md einrichtung.md"
for pflicht in $BUNDLE_FILES; do
  [ -f "$SRC/$pflicht" ] || { err "Bundle unvollständig: $SRC/$pflicht fehlt."; exit 1; }
done

# Eigene Dateien im Skill-Ordner, die bei einem Update erhalten bleiben
eigene_dateien() {
  # $1 = Ordner; gibt die Dateinamen zeilenweise aus
  for f in "$1"/TONE.md "$1"/POSTFAECHER.md "$1"/.last-run*; do
    [ -f "$f" ] && basename "$f"
  done
  return 0
}

aktuell() {
  [ -d "$DEST" ] || return 1
  for f in $BUNDLE_FILES; do
    cmp -s "$SRC/$f" "$DEST/$f" || return 1
  done
  return 0
}

[ "$DRY" -eq 1 ] && echo "Probelauf (--dry-run): es wird nichts verändert."
echo "posteingang-triage installieren"
echo ""

# -----------------------------------------------------------------------------
# 1. Skill kopieren, eigene Dateien behalten
# -----------------------------------------------------------------------------
if aktuell; then
  info "Skill ist bereits aktuell: $DEST"
  EIGENE="$(eigene_dateien "$DEST")"
  if [ -n "$EIGENE" ]; then info "Deine eigenen Dateien bleiben unverändert: $(echo $EIGENE)"; fi
elif [ "$DRY" -eq 1 ]; then
  if [ -d "$DEST" ]; then
    drylog "würde die ältere Fassung nach ~/.claude/backups/skills/posteingang-triage.bak.$TS/ verschieben"
    for eigen in $(eigene_dateien "$DEST"); do
      drylog "würde deine $eigen behalten"
    done
  fi
  drylog "würde $SRC nach $DEST kopieren"
else
  BK=""
  if [ -d "$DEST" ]; then
    BK="$HOME/.claude/backups/skills/posteingang-triage.bak.$TS"
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
    for eigen in $(eigene_dateien "$BK"); do
      cp -p "$BK/$eigen" "$DEST/$eigen"
      info "Deine $eigen bleibt erhalten."
    done
  fi
  info "Skill installiert: $DEST"
fi

echo ""
if [ "$DRY" -eq 1 ]; then
  echo "Probelauf beendet. Ohne --dry-run starten, um zu installieren."
else
  echo "Fertig. Starte eine neue Claude-Session, damit der Skill posteingang-triage geladen wird."
  echo "Voraussetzung für den ersten Lauf: Microsoft 365 ist in Claude unter Einstellungen, Connectoren verbunden."
fi
