#!/usr/bin/env bash
# =============================================================================
# install.sh: Use-Case-Bundle content-adapter installieren (macOS und Windows/Git Bash)
# =============================================================================
# Was das Skript tut:
#   1. kopiert skills/content-adapter/ nach ~/.claude/skills/content-adapter/
#      (ältere Fassung wird nach ~/.claude/backups/ verschoben, nie gelöscht)
#   2. prüft, ob die Zwischenablage nutzbar ist (macOS pbcopy, Windows PowerShell
#      Set-Clipboard mit UTF-8, nicht clip)
#
# Was das Skript nie tut: Ordner im Arbeitsordner anlegen (content/ entsteht
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
SRC="$BUNDLE_DIR/skills/content-adapter"
DEST="$HOME/.claude/skills/content-adapter"
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

for pflicht in SKILL.md verbotsliste.md voice-vorlage.md scripts/pruefen.sh \
               kanaele/linkedin.md kanaele/instagram.md kanaele/newsletter.md kanaele/mail.md kanaele/website.md; do
  [ -f "$SRC/$pflicht" ] || { err "Bundle unvollständig: $SRC/$pflicht fehlt."; exit 1; }
done

[ "$DRY" -eq 1 ] && echo "Probelauf (--dry-run): es wird nichts verändert."
echo "content-adapter installieren"
echo ""

# -----------------------------------------------------------------------------
# 1. Skill kopieren
# -----------------------------------------------------------------------------
if [ -d "$DEST" ] && diff -rq "$SRC" "$DEST" >/dev/null 2>&1; then
  info "Skill ist bereits aktuell: $DEST"
elif [ "$DRY" -eq 1 ]; then
  if [ -d "$DEST" ]; then
    drylog "würde die ältere Fassung nach ~/.claude/backups/skills/content-adapter.bak.$TS/ verschieben"
  fi
  drylog "würde $SRC nach $DEST kopieren"
else
  if [ -d "$DEST" ]; then
    BK="$HOME/.claude/backups/skills/content-adapter.bak.$TS"
    mkdir -p "$BK"
    for item in "$DEST"/* "$DEST"/.[!.]*; do
      [ -e "$item" ] || continue
      mv "$item" "$BK/"
    done
    info "Ältere Fassung gesichert: $BK"
    if [ -f "$BK/verbotsliste.md" ] && ! diff -q "$BK/verbotsliste.md" "$SRC/verbotsliste.md" >/dev/null 2>&1; then
      warn "Die alte verbotsliste.md wich vom Standard ab. Eigene Ergänzungen bitte in content/voice.md unter „Eigene Verbote“ übernehmen (Sicherung liegt in $BK)."
    fi
  fi
  mkdir -p "$DEST"
  cp -R "$SRC/." "$DEST/"
  chmod +x "$DEST"/scripts/*.sh 2>/dev/null || true
  info "Skill installiert: $DEST"
fi

# -----------------------------------------------------------------------------
# 2. Zwischenablage prüfen (nur Hinweis, der Skill funktioniert auch ohne)
# -----------------------------------------------------------------------------
echo ""
if [ "$OS" = mac ]; then
  if command -v pbcopy >/dev/null 2>&1; then info "Zwischenablage nutzbar (pbcopy)"; else warn "pbcopy nicht gefunden, Texte dann aus den Dateien kopieren."; fi
elif [ "$OS" = win ]; then
  # Kopiert wird über PowerShell Set-Clipboard mit UTF-8, nicht über clip (clip verstümmelt Umlaute).
  if command -v powershell.exe >/dev/null 2>&1 \
     && powershell.exe -NoProfile -Command "if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }" >/dev/null 2>&1; then
    info "Zwischenablage nutzbar (PowerShell Set-Clipboard, Umlaute bleiben erhalten)"
    warn "Einfügen im Git-Bash-Fenster geht nicht mit Strg+V, dort Rechtsklick und Einfügen oder Umschalt+Einfg. In allen anderen Programmen geht Strg+V."
  else
    warn "PowerShell Set-Clipboard nicht gefunden, Texte dann aus den Dateien kopieren."
  fi
fi

echo ""
if [ "$DRY" -eq 1 ]; then
  echo "Probelauf beendet. Ohne --dry-run starten, um zu installieren."
else
  echo "Fertig. Starte eine neue Claude-Session, damit der Skill content-adapter geladen wird."
fi
