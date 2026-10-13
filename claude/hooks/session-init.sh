#!/bin/bash
# Session-Init Hook: Vault-Karte (kompakt)
# Liefert nur Orientierung: Projekt-Slug, Bestand je Typ, alle Themenbloecke mit Anzahl, Suchhinweis.
# Keine Titel-Listen mehr: Einzelnes wird bei Bedarf mit ~/.claude/bin/vault-find.sh gesucht.
# Ziel: rund 1,5 KB Ausgabe (die Themenliste ist fest und ueberschaubar).

VAULT="$HOME/Documents/Second-Brain"
INDEX="$VAULT/00_Meta/system/vault-index.md"

[ -f "$INDEX" ] || exit 0

# --- Projekt-Slug aus CLAUDE.md (Vault-Integration Abschnitt) ---
PROJECT_SLUG=""
if [ -n "$CLAUDE_PROJECT_DIR" ] && [ -f "$CLAUDE_PROJECT_DIR/CLAUDE.md" ]; then
  PROJECT_SLUG=$(grep 'Projekt-Tag:' "$CLAUDE_PROJECT_DIR/CLAUDE.md" 2>/dev/null | sed -E 's|.*project/([a-zA-Z0-9_-]+).*|\1|' | head -1)
fi

if [ -z "$PROJECT_SLUG" ]; then
  echo "=== VAULT-KARTE ==="
  echo "Kein Projekt-Tag. Vault-Suche: ~/.claude/bin/vault-find.sh --all <stichworte>"
  exit 0
fi

awk -F'\t' -v p="project/$PROJECT_SLUG" -v slug="$PROJECT_SLUG" '
  NF>=7 && index($4,p) {
    t[$3]++
  }
  END {
    printf "=== VAULT-KARTE project/%s ===\n", slug
    printf "Bestand: %d Decisions, %d Learnings, %d Meetings, %d Session-Logs\n", t["decision"], t["learning"], t["meeting"], t["session-log"]
  }' "$INDEX" 2>/dev/null

# Themenbloecke (Projekt plus projektuebergreifend) kommen aus vault-find, damit Karte und Suche dieselbe Quelle haben.
[ -x "$HOME/.claude/bin/vault-find.sh" ] && "$HOME/.claude/bin/vault-find.sh" --topics 2>/dev/null | head -1
echo "Suche: ~/.claude/bin/vault-find.sh [--topic <thema>] <stichworte> (vor Tool-, API- und Entscheidungsthemen, Varianten per a|b). Liefert bis zu 20 Titel, davon nur die passenden Eintraege lesen (auch mehrere)."

exit 0
