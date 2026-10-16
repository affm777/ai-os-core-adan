#!/usr/bin/env bash
# =============================================================================
# install.sh: Use-Case-Bundle motion-graphic installieren (macOS und Windows/Git Bash)
# =============================================================================
# Was das Skript tut:
#   1. kopiert skills/motion-graphic/ nach ~/.claude/skills/motion-graphic/
#      (ältere Fassung wird nach ~/.claude/backups/ verschoben, nie gelöscht,
#      eine vorhandene Python-Umgebung .venv bleibt stehen)
#   2. prüft Node, ffmpeg, HyperFrames (gepinnte Version aus VERSION),
#      den Render-Browser und die HyperFrames-Skills
#   3. lädt HyperFrames in der gepinnten Version, den Render-Browser und
#      fehlende HyperFrames-Skills (nur über npx, nichts global per npm -g)
#   4. legt die Python-Umgebung für Stimme und Mastering im Skill-Ordner an
#      (numpy, soundfile, scipy), außer mit --ohne-ton
#
# Was das Skript nie tut: Node, ffmpeg oder Python installieren (nur Hinweis
# mit der Installationszeile), Shell-Config oder PATH ändern, etwas löschen.
#
# Aufruf:
#   bash install.sh [--dry-run] [--ohne-ton]
# Kompatibel mit bash 3.2 (macOS) und Git Bash (Windows). Idempotent.
# =============================================================================

export MSYS_NO_PATHCONV=1
set -eu

BUNDLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$BUNDLE_DIR/skills/motion-graphic"
DEST="$HOME/.claude/skills/motion-graphic"
TS="$(date +%Y%m%d-%H%M%S)"
DRY=0
TON=1

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY=1 ;;
    --ohne-ton) TON=0 ;;
    -h|--help)
      echo "Aufruf: bash install.sh [--dry-run] [--ohne-ton]"
      echo "  --dry-run   nur prüfen und anzeigen, nichts verändern"
      echo "  --ohne-ton  keine Python-Umgebung für Stimme und Mastering anlegen"
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
  Darwin) OS=mac
    # Homebrew im nicht-interaktiven Modus in den PATH holen (wie mac/bootstrap.sh)
    if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
    elif [ -x /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true; fi ;;
  MINGW*|MSYS*|CYGWIN*) OS=win ;;
  *) OS=anderes; warn "Unbekanntes Betriebssystem, getestet sind macOS und Windows (Git Bash)." ;;
esac

[ -f "$SRC/SKILL.md" ] || { err "Bundle unvollständig: $SRC/SKILL.md fehlt."; exit 1; }
HF_VERSION="$(tr -d ' \r\n' < "$SRC/VERSION")"
[ -n "$HF_VERSION" ] || { err "VERSION-Datei ist leer."; exit 1; }
hf() { HYPERFRAMES_NO_TELEMETRY=1 npx --yes "hyperframes@$HF_VERSION" "$@"; }

[ "$DRY" -eq 1 ] && echo "Probelauf (--dry-run): es wird nichts verändert."
echo "motion-graphic installieren, HyperFrames gepinnt auf $HF_VERSION"
echo ""

# -----------------------------------------------------------------------------
# 1. Skill kopieren
# -----------------------------------------------------------------------------
if [ -d "$DEST" ] && diff -rq -x .venv -x __pycache__ "$SRC" "$DEST" >/dev/null 2>&1; then
  info "Skill ist bereits aktuell: $DEST"
elif [ "$DRY" -eq 1 ]; then
  if [ -d "$DEST" ]; then
    drylog "würde die ältere Fassung nach ~/.claude/backups/skills/motion-graphic.bak.$TS/ verschieben (.venv bleibt)"
  fi
  drylog "würde $SRC nach $DEST kopieren"
else
  if [ -d "$DEST" ]; then
    BK="$HOME/.claude/backups/skills/motion-graphic.bak.$TS"
    mkdir -p "$BK"
    for item in "$DEST"/* "$DEST"/.[!.]*; do
      [ -e "$item" ] || continue
      case "$(basename "$item")" in .venv) continue ;; esac
      mv "$item" "$BK/"
    done
    info "Ältere Fassung gesichert: $BK"
  fi
  mkdir -p "$DEST"
  cp -R "$SRC/." "$DEST/"
  chmod +x "$DEST"/scripts/*.sh 2>/dev/null || true
  info "Skill installiert: $DEST"
fi

# -----------------------------------------------------------------------------
# 2. Abhängigkeiten prüfen (gleiche Prüfung, die der Skill vor jedem Lauf macht)
# -----------------------------------------------------------------------------
echo ""
echo "Abhängigkeiten:"
FEHLT_BASIS=0
if ! command -v node >/dev/null 2>&1; then
  FEHLT_BASIS=1
  if [ "$OS" = win ]; then err "Node.js fehlt. Installieren: winget install OpenJS.NodeJS.LTS"; else err "Node.js fehlt. Installieren: brew install node"; fi
fi
if ! command -v ffmpeg >/dev/null 2>&1 || ! command -v ffprobe >/dev/null 2>&1; then
  FEHLT_BASIS=1
  if [ "$OS" = win ]; then err "ffmpeg fehlt. Installieren: winget install Gyan.FFmpeg (danach Git Bash neu öffnen)"; else err "ffmpeg fehlt. Installieren: brew install ffmpeg"; fi
fi
if [ "$FEHLT_BASIS" -eq 1 ]; then
  err "Bitte das Fehlende installieren und install.sh danach erneut starten."
  exit 1
fi
info "Node $(node -v | tr -d '\r'), ffmpeg $(ffmpeg -version 2>/dev/null | head -1 | awk '{print $3}')"

# -----------------------------------------------------------------------------
# 3. HyperFrames, Render-Browser, HyperFrames-Skills
# -----------------------------------------------------------------------------
got="$(hf --version 2>/dev/null | tr -d '\r' | tail -1 || true)"
if [ "$got" = "$HF_VERSION" ]; then
  info "HyperFrames $got (über npx, gepinnt)"
else
  err "HyperFrames $HF_VERSION ließ sich nicht über npx laden. Internetverbindung prüfen und erneut starten."
  exit 1
fi

if hf browser path >/dev/null 2>&1; then
  info "Render-Browser vorhanden"
elif [ "$DRY" -eq 1 ]; then
  drylog "würde den Render-Browser laden: npx --yes hyperframes@$HF_VERSION browser ensure (einmalig rund 150 MB)"
else
  echo "Lade den Render-Browser (einmalig, rund 150 MB) ..."
  hf browser ensure && info "Render-Browser geladen" || { err "Render-Browser konnte nicht geladen werden."; exit 1; }
fi

SKILLS_FEHLEN=""
for s in hyperframes hyperframes-animation hyperframes-core hyperframes-cli; do
  [ -f "$HOME/.claude/skills/$s/SKILL.md" ] || SKILLS_FEHLEN="$SKILLS_FEHLEN $s"
done
if [ -z "$SKILLS_FEHLEN" ]; then
  info "HyperFrames-Skills vorhanden"
elif [ "$DRY" -eq 1 ]; then
  drylog "würde die HyperFrames-Skills installieren (fehlen:$SKILLS_FEHLEN): npx --yes hyperframes@$HF_VERSION skills update"
else
  echo "Installiere die HyperFrames-Skills (fehlen:$SKILLS_FEHLEN) ..."
  hf skills update && info "HyperFrames-Skills installiert" || warn "HyperFrames-Skills nicht installiert. Später: npx --yes hyperframes@$HF_VERSION skills update"
fi

# -----------------------------------------------------------------------------
# 4. Python-Umgebung für Stimme und Mastering (optional)
# -----------------------------------------------------------------------------
if [ "$TON" -eq 1 ]; then
  if [ "$OS" = win ]; then VPY="$DEST/.venv/Scripts/python.exe"; else VPY="$DEST/.venv/bin/python"; fi
  if [ -x "$VPY" ] && "$VPY" -I -c "import numpy, soundfile, scipy" >/dev/null 2>&1; then
    info "Python-Umgebung für Ton vorhanden"
  else
    PYBIN=""
    for cand in python3 python "py -3"; do
      # shellcheck disable=SC2086
      if $cand -c "import sys, venv; sys.exit(0 if sys.version_info >= (3, 9) else 1)" </dev/null >/dev/null 2>&1; then PYBIN="$cand"; break; fi
    done
    if [ -z "$PYBIN" ]; then
      if [ "$OS" = win ]; then warn "Python 3 fehlt (nur für Stimme und Mastering nötig). Installieren: winget install Python.Python.3.12"
      else warn "Python 3 fehlt (nur für Stimme und Mastering nötig). Installieren: brew install python"; fi
    elif [ "$DRY" -eq 1 ]; then
      drylog "würde mit '$PYBIN' die Python-Umgebung $DEST/.venv anlegen (numpy, soundfile, scipy, rund 100 MB)"
    else
      echo "Lege die Python-Umgebung für Stimme und Mastering an (rund 100 MB) ..."
      # shellcheck disable=SC2086
      $PYBIN -m venv "$DEST/.venv" \
        && "$VPY" -m pip install --quiet --disable-pip-version-check numpy soundfile scipy \
        && info "Python-Umgebung angelegt" \
        || warn "Python-Umgebung nicht vollständig. Videos ohne Stimme funktionieren trotzdem."
    fi
  fi
else
  info "Python-Umgebung übersprungen (--ohne-ton)"
fi

echo ""
if [ "$DRY" -eq 1 ]; then
  echo "Probelauf beendet. Ohne --dry-run starten, um zu installieren."
else
  echo "Fertig. Starte eine neue Claude-Session, damit der Skill motion-graphic geladen wird."
fi
