#!/usr/bin/env bash
# Prüft alle Werkzeuge für den motion-graphic-Skill und nennt für Fehlendes die eine Installationszeile.
#   bash werkzeug-check.sh [--alle] [--mit-ton]
#     --alle     auch vorhandene Werkzeuge melden (sonst nur Fehlendes)
#     --mit-ton  zusätzlich die Python-Umgebung für Stimme und Mastering prüfen
# Exit 0 = alles Nötige da, Exit 1 = etwas fehlt. Installiert nichts.
# Läuft unter macOS (bash 3.2) und Windows (Git Bash).
set -u
export MSYS_NO_PATHCONV=1

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HF_VERSION="$(tr -d ' \r\n' < "$SKILL_DIR/VERSION" 2>/dev/null || true)"
ALLE=0; TON=0
for a in "$@"; do
  case "$a" in
    --alle) ALLE=1 ;;
    --mit-ton) TON=1 ;;
  esac
done

case "$(uname -s 2>/dev/null || echo unbekannt)" in
  Darwin) OS=mac ;;
  MINGW*|MSYS*|CYGWIN*) OS=win ;;
  *) OS=anderes ;;
esac

FEHLT=0
ok()    { [ "$ALLE" -eq 1 ] && echo "[OK]   $*"; return 0; }
fehlt() { echo "[FEHLT] $1"; echo "        Installieren: $2"; FEHLT=1; }
zeile() { if [ "$OS" = win ]; then echo "$2"; else echo "$1"; fi; }

# Node (bringt npx mit)
if command -v node >/dev/null 2>&1; then
  ok "Node $(node -v 2>/dev/null | tr -d '\r')"
else
  fehlt "Node.js" "$(zeile 'brew install node' 'winget install OpenJS.NodeJS.LTS')"
fi

# ffmpeg und ffprobe
if command -v ffmpeg >/dev/null 2>&1 && command -v ffprobe >/dev/null 2>&1; then
  ok "ffmpeg $(ffmpeg -version 2>/dev/null | head -1 | awk '{print $3}')"
else
  fehlt "ffmpeg (Videoschnitt und Messung)" "$(zeile 'brew install ffmpeg' 'winget install --id Gyan.FFmpeg -e  (danach Git Bash und Claude in einem neuen Fenster öffnen, fehlt ffmpeg dann noch, $LOCALAPPDATA/Microsoft/WinGet/Links in den PATH)')"
fi

# HyperFrames in der gepinnten Version und der Render-Browser
if [ -z "$HF_VERSION" ]; then
  fehlt "VERSION-Datei im Skill-Ordner" "Bundle neu installieren (install.sh)"
elif command -v npx >/dev/null 2>&1; then
  hf() { HYPERFRAMES_NO_TELEMETRY=1 npx --yes "hyperframes@$HF_VERSION" "$@"; }
  got="$(hf --version 2>/dev/null | tr -d '\r' | tail -1)"
  if [ "$got" = "$HF_VERSION" ]; then
    ok "HyperFrames $got"
    if hf browser path >/dev/null 2>&1; then
      ok "Render-Browser (Chrome headless)"
    else
      fehlt "Render-Browser für HyperFrames" "npx --yes hyperframes@$HF_VERSION browser ensure"
    fi
  else
    fehlt "HyperFrames $HF_VERSION (Download über npx fehlgeschlagen, Internet prüfen)" "npx --yes hyperframes@$HF_VERSION --version"
  fi
fi

# HyperFrames-Skills, die der Skill lädt
for s in hyperframes hyperframes-animation hyperframes-core hyperframes-cli; do
  if [ -f "$HOME/.claude/skills/$s/SKILL.md" ]; then
    ok "Skill /$s"
  else
    fehlt "Skill /$s" "npx --yes hyperframes@${HF_VERSION:-latest} skills update  (danach neue Claude-Session)"
  fi
done

# Python-Umgebung nur für Stimme und Mastering
if [ "$TON" -eq 1 ]; then
  if [ "$OS" = win ]; then PY="$SKILL_DIR/.venv/Scripts/python.exe"; else PY="$SKILL_DIR/.venv/bin/python"; fi
  if [ -x "$PY" ] && "$PY" -I -c "import numpy, soundfile, scipy" >/dev/null 2>&1; then
    ok "Python-Umgebung für Ton"
  else
    fehlt "Python-Umgebung für Stimme und Mastering" "bash ~/ai-os-core/claude/use-cases/motion-graphic/install.sh  (legt die Python-Umgebung an)"
  fi
fi

[ "$FEHLT" -eq 0 ] && ok "Alles bereit."
exit "$FEHLT"
