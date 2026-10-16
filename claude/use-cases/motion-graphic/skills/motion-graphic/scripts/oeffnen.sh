#!/usr/bin/env bash
# Öffnet eine Datei (Video, Bild) mit dem Standardprogramm, macOS und Windows (Git Bash).
#   bash oeffnen.sh <datei>
set -eu
F=$1
[ -e "$F" ] || { echo "Datei nicht gefunden: $F" >&2; exit 1; }
case "$(uname -s 2>/dev/null || echo unbekannt)" in
  Darwin) open "$F" ;;
  MINGW*|MSYS*|CYGWIN*) start "" "$(cygpath -w "$F")" ;;
  *) xdg-open "$F" >/dev/null 2>&1 || echo "Bitte von Hand öffnen: $F" ;;
esac
