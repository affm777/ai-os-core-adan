#!/usr/bin/env bash
# =============================================================================
# vorbereiten.sh: legt einen Build-Ordner für einen Social-Post an
# =============================================================================
# Aufruf:  bash vorbereiten.sh <marke> <vorlage> <build-ordner>
#   marke     adan-ev | adan-impact | adan-careers (oder eigener Slug mit brand/<slug>/)
#   vorlage   statement | info | karussell
# Kopiert Vorlage (als index.html), basis.css, basis.js, marke.css und die Logos
# in den Build-Ordner. Vorrang hat immer der Arbeitsordner: brand/<marke>/marke.css
# und brand/<marke>/logos.conf schlagen die Fassung im Skill.
# Ein vorhandenes inhalt.json bleibt unangetastet. Löscht nichts.
# Kompatibel mit bash 3.2 (macOS) und Git Bash (Windows).
# =============================================================================
set -eu

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MARKE="${1:-}"; VORLAGE="${2:-}"; BUILD="${3:-}"

fehler() { echo "FEHLER: $*" >&2; exit 1; }
[ -n "$MARKE" ] && [ -n "$VORLAGE" ] && [ -n "$BUILD" ] || fehler "Aufruf: bash vorbereiten.sh <marke> <vorlage> <build-ordner>"

case "$MARKE" in *[!a-z0-9-]*) fehler "Markenname nur aus Kleinbuchstaben, Ziffern und Bindestrich: $MARKE" ;; esac
case "$VORLAGE" in statement|info|karussell) ;; *) fehler "Unbekannte Vorlage: $VORLAGE (statement, info, karussell)" ;; esac

LOKAL="brand/$MARKE"
SKILL_MARKE="$SKILL_DIR/marken/$MARKE"

# marke.css: Arbeitsordner vor Skill
if [ -f "$LOKAL/marke.css" ]; then MARKE_CSS="$LOKAL/marke.css"
elif [ -f "$SKILL_MARKE/marke.css" ]; then MARKE_CSS="$SKILL_MARKE/marke.css"
else fehler "Keine Marke $MARKE gefunden (weder $LOKAL/marke.css noch im Skill)."; fi

# logos.conf: Arbeitsordner vor Skill, Pfade gelten relativ zum Ordner der logos.conf
if [ -f "$LOKAL/logos.conf" ]; then LOGO_CONF="$LOKAL/logos.conf"
elif [ -f "$SKILL_MARKE/logos.conf" ]; then LOGO_CONF="$SKILL_MARKE/logos.conf"
else LOGO_CONF=""; fi

mkdir -p "$BUILD"
if [ -f "$BUILD/.marke" ] && [ "$(cat "$BUILD/.marke")" != "$MARKE" ]; then
  fehler "Der Build-Ordner $BUILD gehört zur Marke $(cat "$BUILD/.marke"). Für eine andere Marke einen neuen Ordner nehmen."
fi
printf '%s\n' "$MARKE" > "$BUILD/.marke"

cp "$SKILL_DIR/templates/$VORLAGE.html" "$BUILD/index.html"
cp "$SKILL_DIR/templates/basis.css" "$BUILD/basis.css"
cp "$SKILL_DIR/templates/basis.js" "$BUILD/basis.js"
cp "$MARKE_CSS" "$BUILD/marke.css"
echo "Vorlage:   $VORLAGE"
echo "Marke:     $MARKE_CSS"

if [ -n "$LOGO_CONF" ]; then
  CONF_DIR="$(dirname "$LOGO_CONF")"
  while IFS='=' read -r rolle datei || [ -n "$rolle" ]; do
    datei="$(printf '%s' "${datei:-}" | tr -d '\r')"
    case "$rolle" in auf-flaeche|auf-hell|wasserzeichen) ;; *) continue ;; esac
    [ -n "$datei" ] || continue
    if [ -f "$CONF_DIR/$datei" ]; then
      # Feste Zielnamen, die die Vorlagen erwarten. Chromium erkennt auch ein JPG unter .png.
      cp "$CONF_DIR/$datei" "$BUILD/logo-$rolle.png"
      echo "Logo:      $rolle = $CONF_DIR/$datei"
    else
      echo "WARNUNG:   Logo-Datei fehlt: $CONF_DIR/$datei" >&2
    fi
  done < "$LOGO_CONF"
else
  echo "WARNUNG:   keine logos.conf gefunden, Post entsteht ohne Logo." >&2
fi

if [ -f "$LOKAL/STYLE-GUIDE.md" ]; then
  echo "HINWEIS:   $LOKAL/STYLE-GUIDE.md im Arbeitsordner gefunden. Dieser Guide hat Vorrang, Farben und Schrift in $BUILD/marke.css danach abgleichen."
fi
[ -f "$BUILD/inhalt.json" ] && echo "inhalt.json ist schon da und bleibt unverändert." || echo "Jetzt $BUILD/inhalt.json schreiben."
