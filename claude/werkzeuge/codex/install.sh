#!/usr/bin/env bash
# =============================================================================
# install.sh: Werkzeug codex einrichten (macOS und Windows/Git Bash)
# =============================================================================
# Was das Skript tut:
#   1. kopiert die Skills aus skills/ (codex, codex-ask, codex-image) nach
#      ~/.claude/skills/<name>/ (ältere Fassung wird nach ~/.claude/backups/
#      verschoben, nie gelöscht)
#   2. prüft, ob Node, npm und die Codex CLI vorhanden sind. Fehlt etwas,
#      nennt es den Installationsbefehl
#   3. prüft, ob Codex mit einem ChatGPT-Konto angemeldet ist
#
# Was das Skript nie tut: Codex oder andere Programme installieren (den
# npm-Befehl führt Claude laut README selbst aus), sich anmelden, Shell-Config
# oder PATH ändern, etwas löschen.
#
# Nebenwirkung auch mit --dry-run: die Statusabfrage `codex login status`
# legt bei vorhandenem Codex den Ordner ~/.codex/tmp an. Das ist harmlos.
#
# Aufruf:
#   bash install.sh [--dry-run]
# Kompatibel mit bash 3.2 (macOS) und Git Bash (Windows). Idempotent.
# =============================================================================

export MSYS_NO_PATHCONV=1
set -eu

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS="codex codex-ask codex-image"
NPM_CMD="npm install -g @openai/codex@latest"
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

for s in $SKILLS; do
  [ -f "$TOOL_DIR/skills/$s/SKILL.md" ] || { err "Werkzeug unvollständig: $TOOL_DIR/skills/$s/SKILL.md fehlt."; exit 1; }
done

[ "$DRY" -eq 1 ] && echo "Probelauf (--dry-run): es wird nichts verändert."
echo "Werkzeug codex einrichten"
echo ""

# -----------------------------------------------------------------------------
# 1. Skills kopieren
# -----------------------------------------------------------------------------
for s in $SKILLS; do
  SRC="$TOOL_DIR/skills/$s"
  DEST="$HOME/.claude/skills/$s"
  if [ -d "$DEST" ] && diff -rq "$SRC" "$DEST" >/dev/null 2>&1; then
    info "Skill $s ist bereits aktuell: $DEST"
  elif [ "$DRY" -eq 1 ]; then
    if [ -d "$DEST" ]; then
      drylog "würde die ältere Fassung nach ~/.claude/backups/skills/$s.bak.$TS/ verschieben"
    fi
    drylog "würde $SRC nach $DEST kopieren"
  else
    if [ -d "$DEST" ]; then
      BK="$HOME/.claude/backups/skills/$s.bak.$TS"
      mkdir -p "$BK"
      for item in "$DEST"/* "$DEST"/.[!.]*; do
        [ -e "$item" ] || continue
        mv "$item" "$BK/"
      done
      info "Ältere Fassung von $s gesichert: $BK"
    fi
    mkdir -p "$DEST"
    cp -R "$SRC/." "$DEST/"
    info "Skill $s installiert: $DEST"
  fi
done

# -----------------------------------------------------------------------------
# 2. Node, npm und Codex prüfen (nur Hinweis, installiert wird nichts)
# -----------------------------------------------------------------------------
echo ""
FEHLT=0
if command -v node >/dev/null 2>&1; then
  info "Node $(node -v 2>/dev/null | tr -d '\r')"
else
  warn "Node fehlt. Das Setup bringt Node mit, bitte den Bootstrap erneut laufen lassen."
  FEHLT=1
fi
if command -v npm >/dev/null 2>&1; then
  info "npm $(npm -v 2>/dev/null | tr -d '\r')"
else
  warn "npm fehlt. Das Setup bringt npm mit Node mit, bitte den Bootstrap erneut laufen lassen."
  FEHLT=1
fi

if command -v codex >/dev/null 2>&1; then
  info "Codex gefunden: $(codex --version 2>/dev/null | tr -d '\r' | head -1)"
  echo "       Auf die aktuellste Version bringen: $NPM_CMD"
  # Anmeldestatus nur lesen, nie selbst anmelden
  STATUS="$(codex login status 2>&1 | tr -d '\r' || true)"
  case "$STATUS" in
    *"Logged in"*) info "Codex ist angemeldet ($STATUS)" ;;
    *) warn "Codex ist noch nicht angemeldet. In einem eigenen Terminal ausführen: codex login (öffnet den Browser für das ChatGPT-Konto)" ;;
  esac
else
  warn "Codex ist noch nicht installiert. Installieren mit: $NPM_CMD"
  if [ "$OS" = win ]; then
    echo "       Danach Git Bash schließen und neu öffnen, damit der Befehl codex gefunden wird."
  fi
  FEHLT=1
fi

echo ""
if [ "$DRY" -eq 1 ]; then
  echo "Probelauf beendet. Ohne --dry-run starten, um die Skills zu kopieren."
elif [ "$FEHLT" -eq 1 ]; then
  echo "Skills sind kopiert, es fehlt aber noch etwas (siehe [!!] oben). Danach dieses Skript einfach noch einmal laufen lassen."
else
  echo "Fertig. Starte eine neue Claude-Session, damit die Skills codex, codex-ask und codex-image geladen werden."
fi
