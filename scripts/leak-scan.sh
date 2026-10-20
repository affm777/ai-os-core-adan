#!/usr/bin/env bash
# leak-scan.sh: Leak-Scan vor dem Push (macOS bash 3.2 und Git Bash unter Windows)
#
# Prüft alle getrackten und ungetrackten (nicht ignorierten) Dateien des Repos
# auf Mailadressen, Home-Pfade, Token-Formate und optional auf Begriffe aus der
# lokalen Blockliste .leak-blocklist (gitignored, eine Zeile ein Begriff).
#
# Exit-Codes: 0 = keine Treffer, 1 = Treffer gefunden, 2 = Aufruffehler

set -u

usage() {
  cat <<'USAGE'
Aufruf: bash scripts/leak-scan.sh [--help]

Durchsucht getrackte und ungetrackte Dateien (git ls-files plus
git ls-files --others --exclude-standard) nach
  1. Mailadressen (erlaubt sind nur example.org, example.com, beispiel.org, beispiel.de, beispielverein.org)
  2. Home-Pfaden (/Users/... und C:\Users\...)
  3. Token- und Key-Formaten (API-Keys, GitHub-, Slack-, AWS-, Google-Tokens,
     private Schlüssel, Zuweisungen wie token = "..." mit langem Wert)
  4. Begriffen aus der lokalen Blockliste .leak-blocklist im Repo-Stamm
     (eine Zeile ein Begriff, Groß- und Kleinschreibung egal, ganze Wörter,
     Zeilen mit # sind Kommentare). Vorlage: .leak-blocklist.example

Ausgabe: Treffer mit Datei und Zeile.
Exit 0 ohne Treffer, Exit 1 bei Treffern. Vor jedem Push laufen lassen.
USAGE
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  "") ;;
  *) echo "Unbekannte Option: $1" >&2; usage >&2; exit 2 ;;
esac

REPO_DIR="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "Kein Git-Repo gefunden. Bitte im Repo aufrufen." >&2
  exit 2
}
cd "$REPO_DIR" || exit 2

HITS=0
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t leakscan)"
trap 'rm -rf "$TMP_DIR"' EXIT
FILES="$TMP_DIR/files"
BLOCK="$TMP_DIR/block"

# Dateiliste: getrackt plus ungetrackt (ohne Ignoriertes). Das Skript selbst und
# die Blocklisten sind ausgenommen, weil sie die Muster absichtlich enthalten.
{ git ls-files -z; git ls-files -z --others --exclude-standard; } \
  | tr '\0' '\n' | sort -u \
  | grep -vxE 'scripts/leak-scan\.sh|\.leak-blocklist|\.leak-blocklist\.example' \
  | while IFS= read -r f; do [ -f "$f" ] && printf '%s\0' "$f"; done > "$FILES"

if [ ! -s "$FILES" ]; then
  echo "Keine Dateien zu prüfen."
  exit 0
fi

# grep über alle Dateien, Ausgabe Datei:Zeile:Inhalt, Binärdateien übersprungen.
# $1 = grep-Flags, $2 = Muster
run_grep() {
  xargs -0 grep -nIH $1 -- "$2" < "$FILES" 2>/dev/null || true
}

# Gibt Treffer gekürzt aus und zählt sie. $1 = Label, $2 = Treffer
report() {
  [ -n "$2" ] || return 0
  local n
  n="$(printf '%s\n' "$2" | grep -c '')"
  echo ""
  echo "[TREFFER] $1 ($n)"
  printf '%s\n' "$2" | awk '{
    if (length($0) > 140) print "  " substr($0, 1, 140) "..."; else print "  " $0
  }'
  HITS=$((HITS + n))
}

echo "Leak-Scan in $(basename "$REPO_DIR"), $(tr -cd '\0' < "$FILES" | wc -c | tr -d ' ') Dateien"

# 1. Mailadressen, nur Zeilen mit mindestens einer nicht erlaubten Adresse
# Bildnamen wie logo@2x.png sind keine Adressen und werden übergangen.
EMAIL_RE='[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}'
ALLOWED_RE='@([A-Za-z0-9-]+\.)*(example\.org|example\.com|beispiel\.org|beispiel\.de|beispielverein\.org)$'
NOMAIL_RE='\.(png|jpe?g|gif|svg|webp|avif|ico)$'
email_hits="$(run_grep "-E" "$EMAIL_RE" | while IFS= read -r line; do
  content="${line#*:}"; content="${content#*:}"
  if printf '%s\n' "$content" | grep -oE "$EMAIL_RE" | grep -viE "$NOMAIL_RE" \
    | grep -viqE "$ALLOWED_RE"; then
    printf '%s\n' "$line"
  fi
done)"
report "Mailadresse (nicht erlaubte Domain)" "$email_hits"

# 2. Home-Pfade macOS und Windows (/Users/name, C:\Users\name, C:/Users/name).
# Platzhalter wie /c/Users/..., C:\Users\<Name> oder /Users/DEIN-BENUTZERNAME
# gelten nicht als Treffer, nur ein konkreter Benutzername.
HOME_RE='(/|[A-Za-z]:(\\\\|\\|/))Users(\\\\|\\|/)[A-Za-z0-9_-][A-Za-z0-9._-]{2,}'
PLACEHOLDER_RE='Users.{1,2}(dein[-_]?(benutzer)?name|dein[-_]?konto|user(name)?|benutzer(name)?|name|max|max[-_ ]?mustermann|j(ü|ue)rgen[-_ ]?m(ü|ue)ller|public|default|shared)$'
home_hits="$(run_grep "-iE" 'Users(\\\\|\\|/)' | while IFS= read -r line; do
  content="${line#*:}"; content="${content#*:}"
  if printf '%s\n' "$content" | grep -oiE "$HOME_RE" | grep -viqE "$PLACEHOLDER_RE"; then
    printf '%s\n' "$line"
  fi
done)"
report "Home-Pfad mit Benutzername" "$home_hits"

# 3. Token- und Key-Formate
TOKEN_RE='sk-ant-[A-Za-z0-9_-]{20,}|sk-(proj-)?[A-Za-z0-9]{32,}|gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{40,}|xox[abpsr]-[A-Za-z0-9-]{10,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY-----'
report "Token- oder Key-Format" "$(run_grep "-E" "$TOKEN_RE")"
CRED_RE="(api[_-]?key|secret|password|passwort|token|bearer)[[:space:]]*[:=][[:space:]]*['\"][A-Za-z0-9_\-]{16,}"
report "Credential-Verdacht (Zuweisung mit langem Wert)" "$(run_grep "-iE" "$CRED_RE")"

# 4. Lokale Blockliste (optional)
if [ -f .leak-blocklist ]; then
  tr -d '\r' < .leak-blocklist | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' \
    | grep -v '^#' | grep -v '^$' > "$BLOCK"
  if [ -s "$BLOCK" ]; then
    block_hits="$(xargs -0 grep -nIHiwF -f "$BLOCK" < "$FILES" 2>/dev/null || true)"
    report "Begriff aus .leak-blocklist" "$block_hits"
  fi
else
  echo "Hinweis: keine .leak-blocklist gefunden, Namensprüfung übersprungen."
fi

echo ""
if [ "$HITS" -eq 0 ]; then
  echo "LEAK-SCAN OK: 0 Treffer."
  exit 0
fi
echo "LEAK-SCAN FEHLER: $HITS Treffer. Nicht pushen, erst bereinigen."
exit 1
