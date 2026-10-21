#!/usr/bin/env bash
# =============================================================================
# install.sh: Use-Case-Bundle content-publisher installieren (macOS und Windows/Git Bash)
# =============================================================================
# Was das Skript tut:
#   1. kopiert skills/content-publisher/ nach ~/.claude/skills/content-publisher/
#      (ältere Fassung wird nach ~/.claude/backups/ verschoben, nie gelöscht)
#   2. prüft, ob playwright-cli, Google Chrome (rendert die Bilder) und Python 3
#      da sind und ob die Schrift Rubik lokal im Bundle liegt
#   3. prüft, ob die Zwischenablage nutzbar ist (macOS pbcopy, Windows PowerShell
#      Set-Clipboard mit UTF-8, nicht clip)
#
# Was das Skript nie tut: Ordner im Projektordner anlegen (content-und-social/ entsteht
# erst beim ersten Lauf des Skills), Programme installieren,
# Shell-Config oder PATH ändern, etwas löschen. Die älteren Skills
# content-adapter und social-post bleiben unberührt.
#
# Aufruf:
#   bash install.sh [--dry-run]
# Kompatibel mit bash 3.2 (macOS) und Git Bash (Windows). Idempotent.
# =============================================================================

export MSYS_NO_PATHCONV=1
set -eu

BUNDLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$BUNDLE_DIR/skills/content-publisher"
DEST="$HOME/.claude/skills/content-publisher"
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

for pflicht in SKILL.md visuals.md referenzen.md korpus.md verbotsliste.md voice-vorlage.md \
               kanaele/linkedin.md kanaele/instagram.md kanaele/newsletter.md kanaele/mail.md kanaele/website.md \
               scripts/pruefen.sh scripts/vorbereiten.sh scripts/render.sh scripts/pdf.sh \
               templates/statement.html templates/info.html templates/karussell.html templates/basis.css templates/basis.js \
               marken/adan-ev/marke.css marken/adan-ev/logos.conf marken/adan-ev/STYLE-GUIDE.md \
               marken/adan-impact/marke.css marken/adan-impact/logos.conf marken/adan-impact/STYLE-GUIDE.md \
               marken/adan-careers/marke.css marken/adan-careers/logos.conf marken/adan-careers/STYLE-GUIDE.md; do
  [ -f "$SRC/$pflicht" ] || { err "Bundle unvollständig: $SRC/$pflicht fehlt."; exit 1; }
done
SCHRIFT_FEHLT=""
for w in 300 400 500 600 700; do
  [ -f "$SRC/templates/fonts/rubik-latin-$w-normal.woff2" ] || SCHRIFT_FEHLT="$SCHRIFT_FEHLT $w"
done

[ "$DRY" -eq 1 ] && echo "Probelauf (--dry-run): es wird nichts verändert."
echo "content-publisher installieren"
echo ""

# -----------------------------------------------------------------------------
# 1. Skill kopieren
# -----------------------------------------------------------------------------
if [ -d "$DEST" ] && diff -rq "$SRC" "$DEST" >/dev/null 2>&1; then
  info "Skill ist bereits aktuell: $DEST"
elif [ "$DRY" -eq 1 ]; then
  if [ -d "$DEST" ]; then
    drylog "würde die ältere Fassung nach ~/.claude/backups/skills/content-publisher.bak.$TS/ verschieben"
  fi
  drylog "würde $SRC nach $DEST kopieren"
else
  if [ -d "$DEST" ]; then
    BK="$HOME/.claude/backups/skills/content-publisher.bak.$TS"
    mkdir -p "$BK"
    for item in "$DEST"/* "$DEST"/.[!.]*; do
      [ -e "$item" ] || continue
      mv "$item" "$BK/"
    done
    info "Ältere Fassung gesichert: $BK"
    if [ -f "$BK/verbotsliste.md" ] && ! diff -q "$BK/verbotsliste.md" "$SRC/verbotsliste.md" >/dev/null 2>&1; then
      warn "Die alte verbotsliste.md wich vom Standard ab. Eigene Ergänzungen bitte in content-und-social/stil/<marke>/voice.md unter „Eigene Verbote“ übernehmen (Sicherung liegt in $BK)."
    fi
    for m in "$BK"/marken/*/marke.css; do
      [ -f "$m" ] || continue
      slug="$(basename "$(dirname "$m")")"
      if [ -f "$SRC/marken/$slug/marke.css" ] && ! diff -q "$m" "$SRC/marken/$slug/marke.css" >/dev/null 2>&1; then
        warn "marke.css von $slug wich vom Standard ab. Eigene Werte gehören nach content-und-social/brand/$slug/marke.css im Projektordner (Sicherung liegt in $BK)."
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

# playwright-cli öffnet ohne --browser das installierte Google Chrome. Fehlt es,
# scheitert sonst erst der erste Render mit einer schwer lesbaren Meldung.
CHROME=""
if [ "$OS" = mac ]; then
  for c in "/Applications/Google Chrome.app" "$HOME/Applications/Google Chrome.app"; do
    [ -d "$c" ] && { CHROME="$c"; break; }
  done
elif [ "$OS" = win ]; then
  for c in "${PROGRAMFILES:-C:/Program Files}/Google/Chrome/Application/chrome.exe" \
           "${LOCALAPPDATA:-}/Google/Chrome/Application/chrome.exe" \
           "C:/Program Files (x86)/Google/Chrome/Application/chrome.exe"; do
    [ -f "$c" ] && { CHROME="$c"; break; }
  done
else
  for c in google-chrome google-chrome-stable; do
    command -v "$c" >/dev/null 2>&1 && { CHROME="$c"; break; }
  done
fi
if [ -n "$CHROME" ]; then
  info "Google Chrome gefunden (playwright-cli rendert damit die Bilder)"
else
  warn "Google Chrome fehlt. Ohne Chrome kann playwright-cli keine Bilder rendern."
  if [ "$OS" = win ]; then warn "Nachladen mit: playwright-cli install-browser chrome (oder: winget install Google.Chrome)"
  elif [ "$OS" = mac ]; then warn "Nachladen mit: playwright-cli install-browser chrome (oder: brew install --cask google-chrome)"
  else warn "Nachladen mit: playwright-cli install-browser chrome"; fi
  if [ "$OS" = win ]; then PWCACHE="${LOCALAPPDATA:-}/ms-playwright"; else PWCACHE="$HOME/Library/Caches/ms-playwright"; fi
  if ls -d "$PWCACHE"/chromium-* >/dev/null 2>&1; then
    warn "Im Playwright-Cache liegt zwar Chromium ($PWCACHE), playwright-cli nutzt ohne --browser aber Chrome."
  fi
fi

if [ -z "$SCHRIFT_FEHLT" ]; then
  info "Schrift Rubik liegt lokal im Bundle (Bilder entstehen auch ohne Internet)"
else
  warn "Rubik-Schnitte fehlen im Bundle (Gewicht$SCHRIFT_FEHLT). Die Bilder laden die Schrift dann von Google Fonts und brauchen Internet."
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

# -----------------------------------------------------------------------------
# 3. Zwischenablage prüfen (nur Hinweis, der Skill funktioniert auch ohne)
# -----------------------------------------------------------------------------
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
  echo "Fertig. Starte eine neue Claude-Session, damit der Skill content-publisher geladen wird."
fi
