#!/usr/bin/env bash
# =============================================================================
# pruefen.sh: Fassungen eines Laufs gegen Verbotsliste und Kanalregeln prüfen
# =============================================================================
# Aufruf:
#   bash pruefen.sh <laufordner> [--zusatz content/voice.md]
# Prüft jede <kanal>-<de|en>.txt im Laufordner (nicht _alt/).
#   VERSTOSS  muss behoben werden (Exit-Code 1, solange einer da ist)
#   HINWEIS   ansehen und nur beheben, wenn er zutrifft
#   INFO      Längen und offene [FEHLT]-Stellen
# Muster kommen aus dem Block ```muster in verbotsliste.md und optional aus
# demselben Block in voice.md (Abschnitt „Eigene Verbote“).
# Kompatibel mit bash 3.2 (macOS) und Git Bash (Windows). Ändert nichts.
# =============================================================================

export MSYS_NO_PATHCONV=1
set -u

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAUF=""
ZUSATZ=""
while [ $# -gt 0 ]; do
  case "$1" in
    --zusatz) ZUSATZ="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) LAUF="$1"; shift ;;
  esac
done
[ -n "$LAUF" ] && [ -d "$LAUF" ] || { echo "Laufordner fehlt oder existiert nicht: '$LAUF'" >&2; exit 2; }

# UTF-8-Locale für Zeichenzählung und Umlaute (macOS en_US.UTF-8, Git Bash C.UTF-8)
UTF=""
for l in en_US.UTF-8 C.UTF-8 de_DE.UTF-8; do
  if LC_ALL="$l" printf 'ä' 2>/dev/null | LC_ALL="$l" wc -m 2>/dev/null | grep -q '^ *1 *$'; then UTF="$l"; break; fi
done
[ -n "$UTF" ] || UTF=en_US.UTF-8
export LC_ALL="$UTF"

TMP="$(mktemp -d 2>/dev/null || mktemp -d -t pruefen)"
trap 'rm -rf "$TMP"' EXIT
PAT="$TMP/muster.txt"

muster_aus() { # $1 Datei: Zeilen zwischen ```muster und ``` ausgeben
  awk '/^```muster/{m=1;next} /^```/{if(m){m=0}} m && NF{print}' "$1" | tr -d '\r'
}
muster_aus "$SKILL_DIR/verbotsliste.md" > "$PAT"
if [ -n "$ZUSATZ" ]; then
  if [ -f "$ZUSATZ" ]; then muster_aus "$ZUSATZ" >> "$PAT"; else echo "HINWEIS Zusatzdatei nicht gefunden: $ZUSATZ"; fi
fi

VERSTOESSE=0
HINWEISE=0
FEHLT_GESAMT=0
v() { VERSTOESSE=$((VERSTOESSE+1)); echo "VERSTOSS $*"; }
h() { HINWEISE=$((HINWEISE+1)); echo "HINWEIS  $*"; }
i() { echo "INFO     $*"; }
zeichen() { printf '%s' "$1" | wc -m | tr -d ' '; }
woerter() { printf '%s' "$1" | wc -w | tr -d ' '; }

# Byte-Muster für Emoji am Zeilenanfang (F0 9F = die meisten Emoji, E2 98-9E/AD/AC = Symbole wie ✅ ✨ ➡ ⭐ ▪)
EMOJI_START="$(printf '^[[:space:]]*(\360\237|\342[\230-\236]|\342\255|\342\254|\342\226)')"
LABEL='^(Betreff|Subject|Vorschautext|Preview text|Überschrift|Headline|Teaser|Meta-Beschreibung|Meta description|Erster Kommentar|First comment):'

ANZ=0
for f in "$LAUF"/*.txt; do
  [ -f "$f" ] || continue
  ANZ=$((ANZ+1))
  n="$(basename "$f")"
  kanal="${n%%-*}"
  sprache="$(printf '%s' "$n" | sed -E -n 's/.*-(de|en)\.txt$/\1/p')"
  inhalt="$(tr -d '\r' < "$f")"

  # 1. Verbotsliste
  grep -n -i -E -f "$PAT" "$f" 2>/dev/null | while IFS= read -r z; do echo "VERSTOSS $n:$z (Verbotsliste)"; done
  c=$(grep -c -i -E -f "$PAT" "$f" 2>/dev/null); VERSTOESSE=$((VERSTOESSE+c))

  # 2. Gedankenstriche
  c=$(grep -n -e '–' -e '—' -e ' - ' "$f" | wc -l | tr -d ' ')
  if [ "$c" -gt 0 ]; then grep -n -e '–' -e '—' -e ' - ' "$f" | while IFS= read -r z; do echo "VERSTOSS $n:$z (Gedankenstrich)"; done; VERSTOESSE=$((VERSTOESSE+c)); fi

  # 3. Markdown-Schmuck
  MD='\*\*|__|^#{1,6} |^[[:space:]]*[*+-] '
  c=$(grep -c -E "$MD" "$f")
  if [ "$c" -gt 0 ]; then grep -n -E "$MD" "$f" | while IFS= read -r z; do echo "VERSTOSS $n:$z (Markdown)"; done; VERSTOESSE=$((VERSTOESSE+c)); fi

  # 4. Emoji als Aufzählung
  c=$(LC_ALL=C grep -c -E "$EMOJI_START" "$f")
  if [ "$c" -gt 0 ]; then LC_ALL=C grep -n -E "$EMOJI_START" "$f" | while IFS= read -r z; do echo "VERSTOSS $n:$z (Emoji am Zeilenanfang)"; done; VERSTOESSE=$((VERSTOESSE+c)); fi

  # 5. Hashtags: Anzahl und Position
  tags=$(printf '%s\n' "$inhalt" | grep -o -E '(^|[[:space:]])#[^[:space:]#]+' | wc -l | tr -d ' ')
  case "$kanal" in linkedin) max=3; min=0 ;; instagram) max=10; min=5 ;; *) max=0; min=0 ;; esac
  [ "$tags" -gt "$max" ] && v "$n Hashtags: $tags, erlaubt höchstens $max"
  [ "$tags" -lt "$min" ] && h "$n Hashtags: $tags, Kanalkarte empfiehlt mindestens $min"
  printf '%s\n' "$inhalt" | grep -n -E '(^|[[:space:]])#[^[:space:]#]+' | while IFS= read -r z; do
    rest="$(printf '%s' "${z#*:}" | sed -E 's/(^|[[:space:]])#[^[:space:]#]+//g' | tr -d '[:space:]')"
    [ -n "$rest" ] && echo "VERSTOSS $n:$z (Hashtag im Fließtext)"
  done
  c=$(printf '%s\n' "$inhalt" | grep -E '(^|[[:space:]])#[^[:space:]#]+' | sed -E 's/(^|[[:space:]])#[^[:space:]#]+//g' | grep -c '[^[:space:]]')
  VERSTOESSE=$((VERSTOESSE+c))

  # 6. Großschreibung zur Betonung (Platzhalter ausgenommen)
  caps="$(printf '%s\n' "$inhalt" | sed -E 's/\[[^]]*\]//g' | grep -o -E '(^|[^[:alpha:]])[[:upper:]]{4,}([^[:alpha:]]|$)' | tr -cd '[:alpha:]\n' | sort -u | tr '\n' ' ')"
  [ -n "$(printf '%s' "$caps" | tr -d ' ')" ] && h "$n Großgeschriebene Wörter: $caps(Abkürzung ok, Betonung nicht)"

  # 7. Frage als Einstieg (erste Zeile ohne Kennwort)
  erste="$(printf '%s\n' "$inhalt" | grep -v -E "$LABEL" | grep -v -E '^[[:space:]]*$' | head -1)"
  case "$erste" in *\?) v "$n Einstieg ist eine Frage: $erste" ;; esac

  # 8. Drei Adjektive in Reihe (Kandidaten)
  if [ "$sprache" = de ]; then ADJ='(^|[^[:alpha:]])[[:lower:]]+, [[:lower:]]+ und [[:lower:]]+'; else ADJ='(^|[^[:alpha:]])[[:lower:]]+, [[:lower:]]+,? and [[:lower:]]+'; fi
  treffer="$(printf '%s\n' "$inhalt" | grep -n -o -E "$ADJ")"
  if [ -n "$treffer" ]; then
    while IFS= read -r z; do h "$n:$z (drei Adjektive in Reihe?)"; done <<HIER
$treffer
HIER
  fi

  # 9. Längen je Kanal
  case "$kanal" in
    linkedin)
      post="$(printf '%s\n' "$inhalt" | awk '/^(Erster Kommentar|First comment):/{exit} {print}')"
      lz=$(zeichen "$post"); z1=$(zeichen "$(printf '%s\n' "$post" | head -1)")
      i "$n Post $lz Zeichen (Ziel 900 bis 1.300), erste Zeile $z1 Zeichen"
      { [ "$lz" -lt 900 ] || [ "$lz" -gt 1300 ]; } && h "$n Länge $lz Zeichen außerhalb 900 bis 1.300"
      [ "$z1" -gt 200 ] && h "$n Erste Zeile über 200 Zeichen, die Vorschau schneidet ab" ;;
    instagram)
      cap="$(printf '%s\n' "$inhalt" | grep -v -E '^[[:space:]]*#' | grep -v '\[FEHLT')"
      wz=$(woerter "$cap"); vor="$(printf '%s' "$inhalt" | head -c 400 | tr '\n' ' ' | cut -c1-125)"
      i "$n Caption $wz Wörter (Ziel 150 bis 300). Vor „mehr“: $vor"
      { [ "$wz" -lt 150 ] || [ "$wz" -gt 300 ]; } && h "$n Caption $wz Wörter außerhalb 150 bis 300" ;;
    newsletter)
      b="$(printf '%s\n' "$inhalt" | sed -n -E 's/^(Betreff|Subject):[[:space:]]*//p' | head -1)"
      [ -z "$b" ] && v "$n Betreff fehlt"
      [ -n "$b" ] && { lb=$(zeichen "$b"); i "$n Betreff $lb Zeichen: $b"; [ "$lb" -ge 50 ] && v "$n Betreff $lb Zeichen, Ziel unter 50"; }
      printf '%s\n' "$inhalt" | grep -q -E '^(Vorschautext|Preview text):' || v "$n Vorschautext fehlt"
      case "$b" in *\?) v "$n Betreff ist eine Frage" ;; esac ;;
    mail)
      b="$(printf '%s\n' "$inhalt" | sed -n -E 's/^(Betreff|Subject):[[:space:]]*//p' | head -1)"
      [ -z "$b" ] && v "$n Betreff fehlt"
      [ -n "$b" ] && { lb=$(zeichen "$b"); i "$n Betreff $lb Zeichen"; [ "$lb" -ge 60 ] && h "$n Betreff $lb Zeichen, Ziel unter 60"; }
      body="$(printf '%s\n' "$inhalt" | grep -v -E "$LABEL")"; i "$n Text $(woerter "$body") Wörter (Ziel 60 bis 150)"
      printf '%s\n' "$inhalt" | grep -q -E '\[(SIGNATUR|SIGNATURE)\]' || h "$n Signatur-Platzhalter fehlt" ;;
    website)
      m="$(printf '%s\n' "$inhalt" | sed -n -E 's/^(Meta-Beschreibung|Meta description):[[:space:]]*//p' | head -1)"
      [ -z "$m" ] && v "$n Meta-Beschreibung fehlt"
      [ -n "$m" ] && { lm=$(zeichen "$m"); i "$n Meta-Beschreibung $lm Zeichen"; [ "$lm" -gt 150 ] && v "$n Meta-Beschreibung $lm Zeichen, höchstens 150"; }
      u="$(printf '%s\n' "$inhalt" | sed -n -E 's/^(Überschrift|Headline):[[:space:]]*//p' | head -1)"
      [ -n "$u" ] && [ "$(zeichen "$u")" -gt 70 ] && h "$n Überschrift über 70 Zeichen"
      t="$(printf '%s\n' "$inhalt" | sed -n -E 's/^(Teaser):[[:space:]]*//p' | head -1)"
      [ -z "$t" ] && v "$n Teaser fehlt" ;;
  esac

  # 10. Offene Stellen
  fz=$(grep -o '\[FEHLT[^]]*\]' "$f" | wc -l | tr -d ' ')
  FEHLT_GESAMT=$((FEHLT_GESAMT+fz))
  [ "$fz" -gt 0 ] && grep -o '\[FEHLT[^]]*\]' "$f" | sort -u | while IFS= read -r z; do i "$n offen: $z"; done
done

[ "$ANZ" -eq 0 ] && { echo "Keine Fassungen (*.txt) in $LAUF gefunden." >&2; exit 2; }
echo ""
echo "Geprüft: $ANZ Fassungen. Verstöße: $VERSTOESSE. Hinweise: $HINWEISE. Offene [FEHLT]-Stellen: $FEHLT_GESAMT."
[ "$VERSTOESSE" -eq 0 ] || exit 1
exit 0
