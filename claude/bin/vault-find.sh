#!/bin/bash
# vault-find.sh: gezielte Suche im Second-Brain-Index statt Titel-Listen im Kontext.
#
# Aufruf:  vault-find.sh [--type T] [--topic SLUG] [--all] [--limit N] <stichwort> [<stichwort>...]
#          vault-find.sh --topics [--all]      listet die Themenbloecke mit Anzahl (Decisions und Learnings)
#   Ein Stichwort darf Varianten enthalten: "rechnung|invoice|beleg" (zaehlt als ein Begriff).
#   --topic grenzt auf einen Themenblock ein (Topic im Index oder cluster/<slug>-Tag), Varianten per a|b.
#   Ohne --all: nur Eintraege des aktuellen Projekts (Projekt-Tag aus CLAUDE.md) plus scope/cross-project.
#
# Durchsucht Titel, Aliase, Tags und Topics im TSV-Index (00_Meta/system/vault-index.md)
# sowie die noch unsortierten Dateien in 01_Inbox/. Teilwort-Treffer zaehlen, Wortanfang zaehlt mehr.
# Treffen weniger als drei Eintraege alle Begriffe, wird zusaetzlich der Volltext durchsucht.
# Ausgabe: hoechstens N Zeilen "Datum | Typ | Titel | Pfad" (Default 20), nie rohe Index-Zeilen.

VAULT="${VAULT_DIR:-$HOME/Documents/Second-Brain}"
INDEX="$VAULT/00_Meta/system/vault-index.md"
INBOX="$VAULT/01_Inbox"

TYPE=""; TOPIC=""; ALL=0; LIMIT=20; LIST=0; TERMS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --type) TYPE="$2"; shift 2 ;;
    --topic) TOPIC="$2"; shift 2 ;;
    --topics) LIST=1; shift ;;
    --all) ALL=1; shift ;;
    --limit) LIMIT="$2"; shift 2 ;;
    -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) for w in $1; do TERMS+=("$w"); done; shift ;;
  esac
done
case "$LIMIT" in ''|*[!0-9]*) LIMIT=20 ;; esac
if [ ${#TERMS[@]} -eq 0 ] && [ "$LIST" -eq 0 ] && [ -z "$TOPIC" ]; then
  echo "Aufruf: vault-find.sh [--type T] [--topic SLUG] [--all] [--limit N] <stichwort>... | --topics" >&2; exit 2
fi
[ -f "$INDEX" ] || { echo "Index fehlt: $INDEX (erst /brain:rebuild-index)" >&2; exit 1; }

SLUG=""
PDIR="${CLAUDE_PROJECT_DIR:-$PWD}"
if [ -f "$PDIR/CLAUDE.md" ]; then
  SLUG=$(grep 'Projekt-Tag:' "$PDIR/CLAUDE.md" 2>/dev/null | sed -E 's|.*project/([a-zA-Z0-9_-]+).*|\1|' | head -1)
fi
[ -z "$SLUG" ] && ALL=1
SCOPE="project/$SLUG + cross-project"; [ "$ALL" -eq 1 ] && SCOPE="gesamter Vault"

# Themenbloecke mit Anzahl: Topics aus dem Index plus cluster/-Tags, je Eintrag einmal gezaehlt.
if [ "$LIST" -eq 1 ]; then
  awk -F'\t' -v all="$ALL" -v slug="$SLUG" '
    NF>=7 {
      m=split($4, g, " ")
      for (i=1;i<=m;i++) if (g[i] ~ /^project\//) P[substr(g[i],9)]=1
    }
    NF>=7 && ($3=="decision" || $3=="learning") {
      if (!all && !index($4,"project/" slug) && !index($4,"scope/cross-project")) next
      split("", seen)
      n=split($6, a, "|")
      for (i=1;i<=n;i++) if (a[i]!="" && a[i]!="-" && a[i]!=slug) seen[a[i]]=1
      m=split($4, g, " ")
      for (i=1;i<=m;i++) if (g[i] ~ /^cluster\//) seen[substr(g[i],9)]=1
      k=0; for (s in seen) {c[s]++; k++}
      if (k==0) none++
      tot++
    }
    END {
      for (s in c) if (!(s in P)) printf "%d\t%s\n", c[s], s
      printf "-1\t%d\t%d\n", tot, none
    }' "$INDEX" | sort -t$'\t' -k1,1nr -k2,2 | awk -F'\t' -v scope="$SCOPE" '
    $1=="-1" {tot=$2; none=$3; next}
    {n++; if (n<=40) line=line (n>1?", ":"") $2 " (" $1 ")"}
    END {
      print "Themenbloecke (" scope "): " line
      printf "(%d Themen, %d Decisions und Learnings, %d ohne Thema. Eingrenzen: vault-find.sh --topic <slug> <stichworte>)\n", n, tot, none
    }'
  exit 0
fi

# Inbox-Dateien als Index-artige Zeilen (path, title, type, tags, aliases, topics, updated)
inbox_rows() {
  local f
  for f in "$INBOX"/*.md; do
    [ -f "$f" ] || continue
    awk -v p="01_Inbox/$(basename "$f")" '
      NR==1 && $0!="---" {exit}
      /^---$/ {n++; if (n==2) exit; next}
      /^title:/ {t=$0; sub(/^title: *"?/,"",t); sub(/"? *$/,"",t)}
      /^type:/ {ty=$0; sub(/^type: */,"",ty)}
      /^tags:/ {intags=1; next}
      /^aliases:/ {intags=0; inal=1; next}
      /^[a-z_]+:/ {intags=0; inal=0}
      intags && /^ *- / {x=$0; sub(/^ *- */,"",x); tags=tags " " x}
      inal && /^ *- / {x=$0; sub(/^ *- *"?/,"",x); sub(/"? *$/,"",x); al=al "|" x}
      END {if (t!="") printf "%s\t%s\t%s\t%s\t%s\t-\t-\n", p, t, ty, tags, al}' "$f"
  done
}

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t vaultfind)
trap 'rm -rf "$TMP"' EXIT
{ cat "$INDEX"; inbox_rows; } > "$TMP/rows"
: > "$TMP/body"

TERMSTR="${TERMS[*]}"

# Ein Lauf ueber alle Zeilen. mode=rank: Trefferliste. mode=cand: Pfade im Suchbereich (fuer den Volltext).
rank() {
  awk -F'\t' -v terms="$TERMSTR" -v type="$TYPE" -v topic="$TOPIC" -v all="$ALL" -v slug="$SLUG" \
      -v bodyfile="$TMP/body" -v mode="$1" '
  function tscore(s, t,   p, off, rest, c, best) {
    best=0; off=0; rest=s
    while ((p=index(rest,t))>0) {
      c=(off+p==1) ? "" : substr(s, off+p-1, 1)
      if (c=="" || c !~ /[a-z0-9]/) return 3
      best=2; off+=p; rest=substr(s, off+1)
    }
    return best
  }
  function has_topic(tp, tags,   n, i, j) {
    n=split(tolower(tp), a, "|")
    for (j=1;j<=nw;j++) {
      for (i=1;i<=n;i++) if (a[i]==W[j]) return 1
      if (index(" " tolower(tags) " ", " cluster/" W[j] " ")) return 1
    }
    return 0
  }
  BEGIN {
    nt=split(terms, T, " "); nw=split(tolower(topic), W, "|")
    while ((getline l < bodyfile) > 0) B[l]=1
  }
  NF>=7 {
    if (type!="" && $3!=type) next
    if (!all && !index($4,"project/" slug) && !index($4,"scope/cross-project")) next
    if (topic!="" && !has_topic($6, $4)) next
    if (mode=="cand") { if ($3!="project" && $3!="area" && $3!="meta") print $1; next }
    title=tolower($2); rest=tolower($4 " " $5 " " $6)
    hit=0; score=0
    for (i=1;i<=nt;i++) {
      if (T[i]=="") continue
      na=split(tolower(T[i]), A, "|"); best=0
      for (j=1;j<=na;j++) {
        if (A[j]=="") continue
        s=tscore(title, A[j]); r=(s==0) ? tscore(rest, A[j]) : 0
        if (length(A[j])<=3) { if (s<3) s=(r==3) ? 1 : 0 }
        else if (s==0 && r>0) s=1
        if (s>best) best=s
      }
      if (best>0) {hit++; score+=best}
    }
    flag="-"
    if (hit<nt && ($1 in B)) {hit=nt; flag="V"}
    if (hit==0 && nt>0) next
    n=split($1, P, "/"); d=substr(P[n],1,10)
    if (d !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) d=($7 ~ /^[0-9]/ ? substr($7,1,10) : "0000-00-00")
    own=(slug!="" && index($4,"project/" slug)) ? 1 : 0
    t=$2; sub(/^(Decision|Learning): */,"",t)
    printf "%d\t%d\t%d\t%s\t%s\t%s\t%s\t%s\n", hit, score, own, d, $3, t, $1, flag
  }' "$TMP/rows"
}

NT=${#TERMS[@]}
RESULTS=$(rank rank | sort -t$'\t' -k1,1nr -k2,2nr -k3,3nr -k4,4r)
FULL=$(printf '%s\n' "$RESULTS" | awk -F'\t' -v nt="$NT" '$1==nt && $7!=""{n++} END{print n+0}')

# Volltext-Nachlauf: nur wenn zu wenige Eintraege alle Begriffe in Titel, Aliasen, Tags oder Topics tragen.
BODY=0
if [ "$NT" -gt 0 ] && [ "$FULL" -lt 3 ]; then
  rank cand > "$TMP/cur"
  for term in "${TERMS[@]}"; do
    [ -s "$TMP/cur" ] || break
    ARGS=()
    OLDIFS=$IFS; IFS='|'
    for alt in $term; do [ -n "$alt" ] && ARGS+=(-e "$alt"); done
    IFS=$OLDIFS
    [ ${#ARGS[@]} -eq 0 ] && continue
    (cd "$VAULT" && tr '\n' '\0' < "$TMP/cur" | xargs -0 grep -l -i -F "${ARGS[@]}" 2>/dev/null) > "$TMP/next"
    mv "$TMP/next" "$TMP/cur"
  done
  if [ -s "$TMP/cur" ]; then
    cp "$TMP/cur" "$TMP/body"; BODY=1
    RESULTS=$(rank rank | sort -t$'\t' -k1,1nr -k2,2nr -k3,3nr -k4,4r)
  fi
fi

TOTAL=$(printf '%s\n' "$RESULTS" | sed '/^$/d' | wc -l | tr -d ' ')


if [ "$TOTAL" -eq 0 ]; then
  echo "Keine Treffer. Andere Begriffe oder Varianten versuchen (a|b), ggf. --all. Themenbloecke: vault-find.sh --topics"
  exit 0
fi

SHOWN=0
while IFS=$'\t' read -r hit score own d ty title path flag; do
  [ -z "$path" ] && continue
  if [ "$ty" = "decision" ] && [ -f "$VAULT/$path" ]; then
    v=$(awk '/^---$/{n++; next} n==1 && /^validity:/{sub(/^validity: */,""); print; exit} n>=2{exit}' "$VAULT/$path")
    case "$v" in superseded*|archived*) continue ;; esac
  fi
  [ "$flag" = "V" ] && title="$title [Volltext]"
  printf '%s | %s | %s | %s\n' "$d" "$ty" "$title" "$path"
  SHOWN=$((SHOWN+1))
  [ "$SHOWN" -ge "$LIMIT" ] && break
done <<< "$RESULTS"

HINT=""
[ "$TOTAL" -gt 30 ] && [ -z "$TOPIC" ] && HINT=" Viele Treffer: mit --topic <slug> eingrenzen (Liste per --topics)."
echo "($SHOWN von $TOTAL Treffern, $SCOPE. Pfade relativ zu $VAULT)$HINT"
