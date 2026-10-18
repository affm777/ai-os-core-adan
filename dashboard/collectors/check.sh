#!/usr/bin/env bash
# =============================================================================
# check.sh (Deterministischer System-Check-Sammler für /system-check)
# =============================================================================
# Read-only gegenüber dem restlichen System. Einzige Schreibziele:
#   $OUTPUT_DIR/system-check.json und $REPORT_DIR/YYYY-MM-DD-system-check.md
#
# Aufruf:
#   bash check.sh [light|full]   (Default: light)
#
# Härtungsregel: Ein Check, der selbst nicht ausführbar ist (Datei fehlt,
# Tool fehlt, Parse-Fehler), liefert FAIL mit Erklärung, niemals ein
# stilles Ueberspringen.
#
# Alle Pfade sind über CHECK_*-Umgebungsvariablen überschreibbar (für
# Tests). Ohne Overrides zeigt das Skript auf das echte System.
# =============================================================================

set -uo pipefail

# Interpreter-Aufloesung: setzt $PYBIN, bricht mit klarer Meldung ab,
# wenn kein lauffaehiges Python existiert (Windows-Store-Stub, siehe Datei).
# shellcheck source=python-bin.sh
. "$(dirname "${BASH_SOURCE[0]}")/python-bin.sh"

# Windows-Umgebungsvariablen wie APPDATA oder LOCALAPPDATA kommen im
# Windows-Format mit Backslashes. In Bash laesst sich damit kein Pfad bauen,
# Checks gegen "$LOCALAPPDATA/..." schlugen deshalb unter Windows immer fehl,
# auch wenn die gesuchte Software installiert war. Auf dem Mac existiert weder
# die Variable noch cygpath, dann gibt die Funktion einfach den Eingabewert
# zurueck und nichts aendert sich.
win_env_to_unix() {
  local p="${1:-}"
  [ -z "$p" ] && { printf '%s' ""; return 0; }
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -u "$p" 2>/dev/null || printf '%s' "$p"
  else
    printf '%s' "$p"
  fi
}

MODE="${1:-light}"
if [[ "$MODE" != "light" && "$MODE" != "full" ]]; then
  echo "Usage: check.sh [light|full]" >&2
  exit 2
fi

# --- Pfade (überschreibbar für Tests) ---
CLAUDE_DIR="${CHECK_CLAUDE_DIR:-$HOME/.claude}"
SETTINGS_PATH="${CHECK_SETTINGS_PATH:-$CLAUDE_DIR/settings.json}"
HOOKS_DIR="${CHECK_HOOKS_DIR:-$CLAUDE_DIR/hooks}"
MCP_AUTH_CACHE="${CHECK_MCP_AUTH_CACHE:-$CLAUDE_DIR/mcp-needs-auth-cache.json}"
PROJECT_REPOS_YAML="${CHECK_PROJECT_REPOS_YAML:-$CLAUDE_DIR/project-repos.yaml}"
VAULT_DIR="${CHECK_VAULT_DIR:-$HOME/Documents/Second-Brain}"
TRASH_STAGING_DIR="${CHECK_TRASH_STAGING_DIR:-$CLAUDE_DIR/trash-staging}"
SAFETY_LOG="${CHECK_SAFETY_LOG:-$HOOKS_DIR/safety.log}"
CLAUDE_ROOT_FOR_BACKUPS="${CHECK_CLAUDE_ROOT:-$CLAUDE_DIR}"
OUTPUT_DIR="${CHECK_OUTPUT_DIR:-$HOME/.claude/dashboard/data}"
REPORT_DIR="${CHECK_REPORT_DIR:-$HOME/.claude/dashboard/reports}"
TEMPLATE_PATH="${CHECK_TEMPLATE_PATH:-$HOME/.claude/templates/new-project/STATE.md.template}"

mkdir -p "$OUTPUT_DIR" "$REPORT_DIR"

ROWS_FILE="$(mktemp)"
trap 'rm -f "$ROWS_FILE"' EXIT

FS=$'\x1f'  # Feld-Trenner, Zeile = ein Check-Ergebnis

# emit id name status detail fix
emit() {
  local id="$1" name="$2" status="$3" detail="$4" fix="$5"
  detail="${detail//$'\n'/ }"
  fix="${fix//$'\n'/ }"
  printf '%s%s%s%s%s%s%s%s%s\n' "$id" "$FS" "$name" "$FS" "$status" "$FS" "$detail" "$FS" "$fix" >> "$ROWS_FILE"
}

now_epoch() { date +%s; }

# --- Hilfsfunktion: Datum YYYY-MM-DD zu Epoch (macOS + Linux) ---
date_to_epoch() {
  local d="$1"
  date -j -f "%Y-%m-%d" "$d" +%s 2>/dev/null || date -d "$d" +%s 2>/dev/null
}

file_mtime_epoch() {
  # GNU stat (Git Bash) zuerst versuchen: unter GNU-stat ist "-f" ein anderer
  # Schalter (Dateisystem-Status) als bei BSD-stat, der Aufruf endet mit
  # Exit 1, schreibt vorher aber einen mehrzeiligen Block nach stdout, den
  # "2>/dev/null" nicht abfängt (das fängt nur stderr). Ohne Abfangen in
  # einer Variable liefert die Funktion dann Text PLUS Zahl zurück, was bei
  # Aufrufern im arithmetischen Kontext abstürzt.
  local f="$1" m=""
  m=$(stat -c %Y "$f" 2>/dev/null) || m=$(stat -f %m "$f" 2>/dev/null) || m=""
  [[ "$m" =~ ^[0-9]+$ ]] && printf '%s' "$m"
  return 0
}

# --- Lesbarkeit einer Datei bzw. eines Verzeichnisses pruefen ---
# Unter macOS sind ~/Desktop und ~/Documents durch den Datenschutz geschuetzt:
# stat gelingt, das Lesen des Inhalts scheitert mit EPERM. Ohne diese Pruefung
# liefern grep/find/ls dann leere Treffer, die von einem echten inhaltlichen
# Befund ("kein Eintrag vorhanden") nicht zu unterscheiden sind. Trennt also
# "nicht lesbar" von "nichts gefunden".
path_readable() {
  local p="$1"
  if [[ -d "$p" ]]; then
    ls "$p" >/dev/null 2>&1
  else
    head -c1 "$p" >/dev/null 2>&1
  fi
}

# =============================================================================
# Check 1: settings.json parsebar
# =============================================================================
check_settings_json() {
  if [[ ! -f "$SETTINGS_PATH" ]]; then
    emit "1" "settings.json parsebar" "fail" \
      "Datei nicht gefunden: $SETTINGS_PATH" \
      "Datei aus jüngstem Backup wiederherstellen (z. B. ein settings.json.bak-* oder settings.json.backup-* im ~/.claude-Root) oder aus settings.json.template neu aufsetzen."
    return
  fi
  local err
  if err=$($PYBIN -m json.tool "$SETTINGS_PATH" 2>&1 >/dev/null); then
    emit "1" "settings.json parsebar" "ok" "$SETTINGS_PATH ist valides JSON." ""
  else
    emit "1" "settings.json parsebar" "fail" \
      "JSON-Parse-Fehler in $SETTINGS_PATH: $err" \
      "JSON-Fehler manuell beheben, danach gegen ein jüngeres Backup (settings.json.bak-* oder settings.json.backup-*) diffen."
  fi
  SETTINGS_OK=$([[ "$err" == "" ]] && echo 1 || echo 0)
}

# =============================================================================
# Hilfsfunktion für Check 2+3: Hook-Kommandos aus settings.json extrahieren
# Ausgabe je Zeile: "<runner>\t<pfad>"
# =============================================================================
extract_hook_commands() {
  $PYBIN - "$SETTINGS_PATH" <<'PYEOF'
import json, sys, re, os
path = sys.argv[1]
try:
    with open(path, encoding="utf-8") as f:
        d = json.load(f)
except Exception:
    sys.exit(0)
hooks = d.get("hooks", {})
seen = set()
home = os.path.expanduser("~")
for _event, entries in hooks.items():
    if not isinstance(entries, list):
        continue
    for entry in entries:
        for h in entry.get("hooks", []):
            cmd = h.get("command", "")
            if not cmd:
                continue
            expanded = cmd.replace("$HOME", home).replace('"', "")
            m = re.match(r"^(bash|python3|node|sh)\s+(\S+)", expanded)
            if m:
                runner, p = m.group(1), m.group(2)
            else:
                parts = expanded.split()
                runner, p = "direct", (parts[0] if parts else "")
            if p and p not in seen:
                seen.add(p)
                print(f"{runner}\t{p}")
PYEOF
}

# =============================================================================
# Check 2: Registrierte Hooks existieren + ausführbar
# Check 3: Hook-Syntax (bash -n / node --check)
# =============================================================================
check_hooks_exist_and_syntax() {
  if [[ "${SETTINGS_OK:-0}" != "1" ]]; then
    emit "2" "Registrierte Hooks existieren + ausführbar" "fail" \
      "settings.json ist nicht lesbar (siehe Check 1), Hook-Registry kann nicht geprüft werden." \
      "Erst Check 1 beheben (settings.json reparieren), Check 2 danach erneut laufen lassen."
    emit "3" "Hook-Syntax" "fail" \
      "settings.json ist nicht lesbar (siehe Check 1), Hook-Syntax kann nicht geprüft werden." \
      "Erst Check 1 beheben (settings.json reparieren), Check 3 danach erneut laufen lassen."
    return
  fi

  local pairs
  pairs=$(extract_hook_commands)

  if [[ -z "$pairs" ]]; then
    emit "2" "Registrierte Hooks existieren + ausführbar" "ok" "Keine Hook-Kommandos in settings.json registriert." ""
    emit "3" "Hook-Syntax" "ok" "Keine Hook-Skripte zu prüfen." ""
    return
  fi

  local missing=()
  local not_exec=()
  local syntax_errors=()
  local n=0

  while IFS=$'\t' read -r runner p; do
    [[ -z "$p" ]] && continue
    n=$((n + 1))

    if [[ ! -e "$p" ]]; then
      missing+=("$p")
      continue
    fi
    # Unter Windows (Git Bash) ist chmod auf NTFS ein No-Op, das -x-Bit ist
    # dort kein verlaesslicher Indikator, daher Test dort ueberspringen.
    if [[ "$runner" == "direct" && ! -x "$p" && "$(uname -s)" != MINGW* && "$(uname -s)" != MSYS* ]]; then
      not_exec+=("$p")
    fi

    case "$p" in
      *.sh)
        local err
        if ! err=$(bash -n "$p" 2>&1); then
          syntax_errors+=("$p: $err")
        fi
        ;;
      *.js)
        if command -v node >/dev/null 2>&1; then
          local err
          if ! err=$(node --check "$p" 2>&1); then
            syntax_errors+=("$p: $err")
          fi
        else
          syntax_errors+=("$p: node nicht verfügbar, Syntax-Check übersprungen (siehe Check 4)")
        fi
        ;;
    esac
  done <<< "$pairs"

  if (( ${#missing[@]} == 0 && ${#not_exec[@]} == 0 )); then
    emit "2" "Registrierte Hooks existieren + ausführbar" "ok" "Alle $n registrierten Hook-Dateien vorhanden (und, wo direkt aufgerufen, ausführbar)." ""
  else
    local detail="Fehlend: ${missing[*]:-keine}. Nicht ausführbar (Direktaufruf ohne Interpreter, fehlendes +x): ${not_exec[*]:-keine}."
    emit "2" "Registrierte Hooks existieren + ausführbar" "fail" "$detail" \
      "Fehlende Hook-Datei(en) wiederherstellen bzw. Pfad in settings.json korrigieren; bei fehlendem +x: chmod +x <datei>."
  fi

  if (( ${#syntax_errors[@]} == 0 )); then
    emit "3" "Hook-Syntax" "ok" "Alle geprüften .sh/.js-Hooks sind syntaktisch fehlerfrei." ""
  else
    local detail
    detail=$(printf '%s | ' "${syntax_errors[@]}")
    emit "3" "Hook-Syntax" "fail" "$detail" "Syntaxfehler im betroffenen Hook beheben (bash -n bzw. node --check lokal nachvollziehen)."
  fi
}

# =============================================================================
# Check 4: Node erreichbar (gleiche Auflösung wie hooks/noderun.sh)
# =============================================================================
check_node() {
  local resolved=""
  if command -v node >/dev/null 2>&1; then
    resolved="$(command -v node) ($(node --version 2>/dev/null))"
  else
    local nvm_node
    nvm_node=$(ls -d "$HOME/.nvm/versions/node"/*/bin/node 2>/dev/null | sort -V | tail -1)
    if [[ -n "$nvm_node" && -x "$nvm_node" ]]; then
      resolved="$nvm_node ($("$nvm_node" --version 2>/dev/null))"
    fi
    # Windows-Kandidaten: offizieller Installer-Pfad, sowie nvm-windows-Layout
    # (anderes Verzeichnisschema als nvm-Unix, daher eigener Kandidat).
    if [[ -z "$resolved" && -x "/c/Program Files/nodejs/node.exe" ]]; then
      resolved="/c/Program Files/nodejs/node.exe ($("/c/Program Files/nodejs/node.exe" --version 2>/dev/null))"
    fi
    if [[ -z "$resolved" ]]; then
      local nvmw_node
      nvmw_node=$(ls -d "$(win_env_to_unix "${APPDATA:-}")/nvm/v"*/node.exe 2>/dev/null | sort -V | tail -1)
      if [[ -n "$nvmw_node" && -x "$nvmw_node" ]]; then
        resolved="$nvmw_node ($("$nvmw_node" --version 2>/dev/null))"
      fi
    fi
  fi
  if [[ -n "$resolved" ]]; then
    emit "4" "Node erreichbar" "ok" "Aufgelöst wie noderun.sh (PATH zuerst, sonst neueste nvm-Version): $resolved" ""
  else
    emit "4" "Node erreichbar" "fail" \
      "Kein node über PATH oder ~/.nvm/versions/node auffindbar (gleiche Logik wie hooks/noderun.sh)." \
      "Node.js installieren, z. B. via 'nvm install --lts', oder PATH prüfen."
  fi
}

# =============================================================================
# Check 5: Scheduled Tasks gelaufen
# Marker 1: jüngster "(scheduled)"-Eintrag im vault-log
# Marker 2: mtime von .last-cleanup
# WARN > 26h, FAIL > 3 Tage (72h), je Marker
# =============================================================================
check_scheduled_tasks() {
  local worst="ok"
  local details=()
  local found=0

  local vault_log="$VAULT_DIR/00_Meta/system/vault-log.md"
  if [[ -f "$vault_log" ]] && ! path_readable "$vault_log"; then
    emit "5" "Scheduled Tasks gelaufen" "fail" \
      "Lesezugriff auf $vault_log verweigert, obwohl die Datei laut stat existiert. Der Sweep-Status ist damit nicht ermittelbar (nicht zu verwechseln mit \"kein Sweep gelaufen\")." \
      "Prozess mit Zugriff auf den Documents-Ordner neu starten oder Node bzw. Terminal in Systemeinstellungen > Datenschutz und Sicherheit > Festplattenvollzugriff freigeben."
    return
  fi
  if [[ -f "$vault_log" ]]; then
    local last_line
    last_line=$(grep -E '\(scheduled\)' "$vault_log" | tail -1)
    if [[ -n "$last_line" ]]; then
      local d
      d=$(echo "$last_line" | grep -oE '\[[0-9]{4}-[0-9]{2}-[0-9]{2}\]' | head -1 | tr -d '[]')
      local epoch
      epoch=$(date_to_epoch "$d")
      if [[ -n "$epoch" ]]; then
        found=1
        local age_h=$(( ( $(now_epoch) - epoch ) / 3600 ))
        details+=("Vault-Sweep (scheduled) vor ca. ${age_h}h (Tagesauflösung)")
        if (( age_h > 72 )); then
          worst="fail"
        elif (( age_h > 26 )) && [[ "$worst" != "fail" ]]; then
          worst="warn"
        fi
      fi
    fi
  fi

  local last_cleanup="$CLAUDE_DIR/.last-cleanup"
  if [[ -f "$last_cleanup" ]]; then
    local mtime_epoch
    mtime_epoch=$(file_mtime_epoch "$last_cleanup")
    if [[ -n "$mtime_epoch" ]]; then
      found=1
      local age_h=$(( ( $(now_epoch) - mtime_epoch ) / 3600 ))
      details+=("Cleanup-Marker (.last-cleanup) vor ${age_h}h")
      if (( age_h > 72 )); then
        worst="fail"
      elif (( age_h > 26 )) && [[ "$worst" != "fail" ]]; then
        worst="warn"
      fi
    fi
  fi

  # Zusätzlich: echter Erfolg/Fehler-Status je Routine aus automationen.json
  # (vom automationen.sh-Collector aus den Session-Transcripts abgeleitet).
  # Fehlt oder ist kaputt: still überspringen, die Marker-Logik oben bleibt
  # unberührt (wichtig für Erst-Setups ohne vorherigen Collector-Lauf).
  # check.sh läuft auch standalone ohne vorherigen refresh.sh-Durchlauf,
  # dann ist automationen.json ggf. vom letzten Refresh: tolerant by design.
  # Vor dem found==0-Guard geprüft, damit automationen.json allein schon als
  # gültige Marker-Quelle zählt (Erst-Setup ohne vault-log/.last-cleanup).
  local automationen_json="$OUTPUT_DIR/automationen.json"
  local auto_fix=""
  if [[ -f "$automationen_json" ]]; then
    local auto_rows
    auto_rows=$($PYBIN - "$automationen_json" <<'PYEOF'
import json, sys
path = sys.argv[1]
try:
    with open(path, encoding="utf-8") as f:
        d = json.load(f)
except Exception:
    sys.exit(0)
tasks = d.get("tasks", [])
if not isinstance(tasks, list):
    sys.exit(0)
for t in tasks:
    if not isinstance(t, dict):
        continue
    name = t.get("name", "")
    titel = t.get("titel", name)
    status = t.get("status", "")
    fehler_text = (t.get("fehler_text") or "")[:80]
    print("\t".join([str(name), str(titel), str(status), fehler_text]))
PYEOF
)
    if [[ -n "$auto_rows" ]]; then
      found=1
      while IFS=$'\t' read -r a_name a_titel a_status a_fehler; do
        [[ -z "$a_name" ]] && continue
        if [[ "$a_status" == "fehler" ]]; then
          worst="fail"
          details+=("Routine ${a_titel}: letzter Lauf mit Fehler (${a_fehler})")
          auto_fix="Routine in der Claude Desktop App prüfen und manuell anstoßen, Details auf der Automationen-Seite."
        elif [[ "$a_status" == "ueberfaellig" ]]; then
          [[ "$worst" != "fail" ]] && worst="warn"
          details+=("Routine ${a_titel}: kein Lauf innerhalb des erwarteten Rhythmus")
          [[ -z "$auto_fix" ]] && auto_fix="Routine in der Claude Desktop App prüfen und manuell anstoßen, Details auf der Automationen-Seite."
        fi
      done <<< "$auto_rows"
    fi
  fi

  if (( found == 0 )); then
    # Kein einziger Marker irgendeiner Quelle = Erst-Setup, in dem noch keine
    # Routine gelaufen ist (nicht "kaputt": sobald eine Routine einmal lief,
    # bleibt mindestens ein Marker dauerhaft bestehen). warn statt fail.
    emit "5" "Scheduled Tasks gelaufen" "warn" \
      "Noch keine Scheduled-Task-Marker vorhanden (weder '(scheduled)'-Eintrag im vault-log noch .last-cleanup noch automationen.json)." \
      "Normal direkt nach dem Setup, die nächtlichen Routinen laufen automatisch, sobald sie einmal fällig waren."
    return
  fi

  local detail_str
  detail_str=$(printf '%s; ' "${details[@]}")
  local fix="$auto_fix"
  if [[ -z "$fix" && "$worst" != "ok" ]]; then
    fix="Scheduled Task prüfen und ggf. manuell anstoßen (z. B. /brain:sort-inbox scheduled)."
  fi
  emit "5" "Scheduled Tasks gelaufen" "$worst" "$detail_str" "$fix"
}

# =============================================================================
# Check 6: Connector-Auth (mcp-needs-auth-cache.json)
# =============================================================================
check_connector_auth() {
  if [[ ! -f "$MCP_AUTH_CACHE" ]]; then
    emit "6" "Connector-Auth" "ok" "mcp-needs-auth-cache.json nicht vorhanden, keine bekannten Re-Auth-Anforderungen." ""
    return
  fi
  local out
  out=$($PYBIN - "$MCP_AUTH_CACHE" <<'PYEOF'
import json, sys
path = sys.argv[1]
try:
    with open(path, encoding="utf-8") as f:
        d = json.load(f)
except Exception:
    print("ERROR")
    sys.exit(0)
if not isinstance(d, dict):
    print("ERROR")
    sys.exit(0)
print(len(d))
for k in d:
    print(k)
PYEOF
)
  local first_line
  first_line=$(echo "$out" | head -1)
  if [[ "$first_line" == "ERROR" ]]; then
    emit "6" "Connector-Auth" "fail" "mcp-needs-auth-cache.json ist nicht parsebar (kein valides JSON-Objekt)." "Datei prüfen: $MCP_AUTH_CACHE"
    return
  fi
  if [[ -z "$first_line" || "$first_line" == "0" ]]; then
    emit "6" "Connector-Auth" "ok" "Keine Connectoren mit Re-Auth-Bedarf." ""
    return
  fi
  local names
  names=$(echo "$out" | tail -n +2 | paste -sd, -)
  emit "6" "Connector-Auth" "warn" "Re-Auth nötig für: $names" "Connector(en) im Claude-Client neu autorisieren (OAuth-Flow erneut durchlaufen): $names"
}

# =============================================================================
# Check 7: Vault-Maschinerie (letzter Sweep, Inbox-Count, vault-index-Frische)
# WARN Sweep > 48h oder Inbox > 40
# =============================================================================
check_vault_machinery() {
  local vault_log="$VAULT_DIR/00_Meta/system/vault-log.md"
  if [[ ! -f "$vault_log" ]]; then
    emit "7" "Second-Brain-Automatik" "fail" "vault-log.md nicht gefunden unter $vault_log" \
      "Vault-Pfad prüfen (CHECK_VAULT_DIR) oder einmalig /brain:rebuild-index laufen lassen."
    return
  fi

  local status="ok"
  local msgs=()

  # Lesbarkeit zuerst: ein nicht lesbares vault-log wuerde unten still als
  # "kein Sweep-Eintrag gefunden" durchgehen, ein nicht lesbares Inbox-Verzeichnis
  # als "0 Dateien". Beides waeren Falschaussagen ueber den Vault-Zustand.
  if ! path_readable "$vault_log"; then
    emit "7" "Second-Brain-Automatik" "fail" \
      "Lesezugriff auf $vault_log verweigert, obwohl die Datei laut stat existiert. Sweep-Alter und Inbox-Fuellstand sind nicht ermittelbar." \
      "Prozess mit Zugriff auf den Documents-Ordner neu starten oder Node bzw. Terminal in Systemeinstellungen > Datenschutz und Sicherheit > Festplattenvollzugriff freigeben."
    return
  fi

  local last_sweep_line
  last_sweep_line=$(grep -E '^## \[[0-9]{4}-[0-9]{2}-[0-9]{2}\] sweep' "$vault_log" | tail -1)
  if [[ -n "$last_sweep_line" ]]; then
    local d
    d=$(echo "$last_sweep_line" | grep -oE '\[[0-9]{4}-[0-9]{2}-[0-9]{2}\]' | head -1 | tr -d '[]')
    local epoch
    epoch=$(date_to_epoch "$d")
    if [[ -n "$epoch" ]]; then
      local age_h=$(( ( $(now_epoch) - epoch ) / 3600 ))
      msgs+=("zuletzt einsortiert vor ca. ${age_h}h")
      (( age_h > 48 )) && status="warn"
    fi
  else
    msgs+=("noch kein Einsortier-Lauf im Protokoll gefunden")
    status="warn"
  fi

  local inbox_dir="$VAULT_DIR/01_Inbox"
  local inbox_count=0
  if [[ -d "$inbox_dir" ]]; then
    if path_readable "$inbox_dir"; then
      inbox_count=$(find "$inbox_dir" -maxdepth 1 -type f ! -name ".*" | wc -l | tr -d ' ')
      msgs+=("Eingang des Second Brain: ${inbox_count} Notizen")
      (( inbox_count > 40 )) && status="warn"
    else
      # Nicht als "0 Dateien" melden: eine unlesbare Inbox saehe sonst wie eine
      # vorbildlich leere aus.
      msgs+=("Eingang des Second Brain nicht lesbar (Zugriff verweigert), Füllstand unbekannt")
      status="fail"
    fi
  else
    msgs+=("Eingang des Second Brain: ${inbox_count} Notizen")
  fi

  local idx="$VAULT_DIR/00_Meta/system/vault-index.md"
  if [[ -f "$idx" ]]; then
    # GNU-stat zuerst (wie oben bei mtime_of): unter GNU bedeutet "-f"
    # Dateisystem-Status und liefert ERFOLGREICH einen Rohdatensatz, der
    # dann ungefiltert in der Dashboard-Kachel landet (Cloud PC 05.08.).
    local idx_mtime_h idx_epoch
    idx_epoch=$(stat -c %Y "$idx" 2>/dev/null) || idx_epoch=$(stat -f %m "$idx" 2>/dev/null) || idx_epoch=""
    if [[ -n "$idx_epoch" ]]; then
      idx_mtime_h=$(date -d "@$idx_epoch" "+%Y-%m-%d %H:%M" 2>/dev/null || date -r "$idx_epoch" "+%Y-%m-%d %H:%M" 2>/dev/null)
      [[ -n "$idx_mtime_h" ]] && msgs+=("Suchindex zuletzt aktualisiert: $idx_mtime_h")
    fi
  fi

  local detail_str
  detail_str=$(printf '%s; ' "${msgs[@]}")
  local fix=""
  [[ "$status" == "warn" ]] && fix="Eingang des Second Brain mit /brain:sort-inbox einsortieren bzw. prüfen, warum der nächtliche Einsortier-Lauf ausbleibt."
  emit "7" "Second-Brain-Automatik" "$status" "$detail_str" "$fix"
}

# =============================================================================
# Check 8: Vault-Lint-Frische (jüngster lint-reports/*-lint.md)
# WARN > 7 Tage
# =============================================================================
check_vault_lint() {
  local lint_dir="$VAULT_DIR/00_Meta/system/lint-reports"
  # Verzeichnis/Report fehlt komplett = /brain:health-check lief noch nie.
  # Das ist die erkennbare Erst-Setup-Signatur (nicht "kaputt"), deshalb warn
  # statt fail, mit Onboarding-Hinweis statt Fehler-Ton.
  if [[ ! -d "$lint_dir" ]]; then
    emit "8" "Second-Brain-Health-Check (Frische)" "warn" "Noch kein Health-Check-Report des Second Brain vorhanden: $lint_dir" "Einmalig /brain:health-check ausführen, dann läuft die wöchentliche Frische-Prüfung."
    return
  fi
  # Unlesbares Verzeichnis wuerde unten als "noch kein Report vorhanden"
  # erscheinen, also als harmlose Erst-Setup-Signatur statt als Zugriffsfehler.
  if ! path_readable "$lint_dir"; then
    emit "8" "Second-Brain-Health-Check (Frische)" "fail" \
      "Lesezugriff auf $lint_dir verweigert, obwohl das Verzeichnis laut stat existiert. Ob Lint-Reports vorliegen, ist nicht feststellbar." \
      "Prozess mit Zugriff auf den Documents-Ordner neu starten oder Node bzw. Terminal in Systemeinstellungen > Datenschutz und Sicherheit > Festplattenvollzugriff freigeben."
    return
  fi
  local latest
  latest=$(ls -1 "$lint_dir" 2>/dev/null | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}-lint\.md$' | sort | tail -1)
  if [[ -z "$latest" ]]; then
    emit "8" "Second-Brain-Health-Check (Frische)" "warn" "Noch kein Lint-Report im erwarteten Format YYYY-MM-DD-lint.md in $lint_dir" "Einmalig /brain:health-check ausführen, dann läuft die wöchentliche Frische-Prüfung."
    return
  fi
  local d="${latest%-lint.md}"
  local epoch
  epoch=$(date_to_epoch "$d")
  if [[ -z "$epoch" ]]; then
    emit "8" "Second-Brain-Health-Check (Frische)" "fail" "Datum aus Dateinamen $latest nicht parsebar." "Dateinamen-Konvention YYYY-MM-DD-lint.md prüfen."
    return
  fi
  local age_d=$(( ( $(now_epoch) - epoch ) / 86400 ))
  local status="ok"
  (( age_d > 7 )) && status="warn"
  local fix=""
  [[ "$status" == "warn" ]] && fix="/brain:health-check ausführen, um einen frischen Report zu erzeugen."
  local findings
  # grep -c gibt bei 0 Treffern "0" UND Exit 1 aus; ein "|| echo 0" ergab sonst "0 0".
  findings=$(grep -ciE 'FAIL|WARN' "$lint_dir/$latest" 2>/dev/null)
  findings="${findings:-0}"
  emit "8" "Second-Brain-Health-Check (Frische)" "$status" "Jüngster Report: $latest, Alter: ${age_d} Tage, ca. ${findings} WARN/FAIL-Zeilen darin (informativ)." "$fix"
}

# =============================================================================
# Check 9: STATE.md je Projekt (project-repos.yaml)
# WARN fehlend oder nicht konform (Sektionen: Current Position, Pending Todos,
# Session Continuity). Liegt eine TODO.md neben der STATE.md (geteiltes Format),
# ist sie die Todo-Quelle und Pending Todos wird in der STATE.md nicht verlangt.
# Im geteilten Format zusaetzlich WARN, wenn die STATE.md das Budget (60 Zeilen,
# 5120 Bytes) ueberschreitet.
# Alter ist nur informativ, beeinflusst den Status nicht.
# =============================================================================
check_state_md_for_project() {
  local slug="$1" proj_path="$2"

  local state_file=""
  if [[ -f "$proj_path/.planning/STATE.md" ]]; then
    state_file="$proj_path/.planning/STATE.md"
  elif [[ -f "$proj_path/STATE.md" ]]; then
    state_file="$proj_path/STATE.md"
  fi

  if [[ -z "$state_file" ]]; then
    emit "9.$slug" "STATE.md: $slug" "warn" \
      "Keine STATE.md gefunden (weder .planning/STATE.md noch STATE.md im Root von $proj_path)." \
      "STATE.md gemäß Template anlegen: $TEMPLATE_PATH"
    return
  fi

  # Lesbarkeit VOR den greps pruefen. Kann grep die Datei nicht lesen, liefert es
  # Exit-Code 2; die drei "&& has_x=1"-Zuweisungen werden dann uebersprungen und
  # das Ergebnis ist ununterscheidbar von "alle drei Sektionen fehlen". Genau so
  # meldete der Check alle Projekte als "altes Format", wenn der Serverprozess
  # ohne Desktop-Lesezugriff (macOS Datenschutz) gestartet wurde: stat gelingt,
  # open scheitert. Der Name beginnt bewusst NICHT mit "STATE.md: ", damit
  # groupIssues() in public/aios-core.js diesen Befund nicht in den Sammel-Issue
  # "altes Format" einsortiert. Status fail gemaess Haertungsregel im Dateikopf:
  # ein Check, der selbst nicht ausfuehrbar ist, meldet fail statt still zu raten.
  if ! head -c1 "$state_file" >/dev/null 2>&1; then
    emit "9.$slug" "STATE.md nicht lesbar: $slug" "fail" \
      "Lesezugriff auf $state_file verweigert, obwohl die Datei laut stat existiert. Vermutlich fehlt dem laufenden Prozess der Zugriff auf den Desktop-Ordner (macOS Datenschutz). Inhaltliche Konformität ist nicht prüfbar, der Befund sagt nichts über das Format aus." \
      "Dashboard-Server aus einer Shell mit Festplattenzugriff neu starten (kill \$(cat ~/.claude/dashboard/.pid) und danach /aios-dashboard) oder Node bzw. Terminal in Systemeinstellungen > Datenschutz und Sicherheit > Festplattenvollzugriff freigeben."
    return
  fi

  # Geteiltes Format: TODO.md im selben Verzeichnis wie die STATE.md. Muss
  # deckungsgleich bleiben mit portfolio.sh (todo_path) und server.mjs (findTodoPath).
  local todo_file=""
  [[ -f "$(dirname "$state_file")/TODO.md" ]] && todo_file="$(dirname "$state_file")/TODO.md"
  if [[ -n "$todo_file" ]] && ! head -c1 "$todo_file" >/dev/null 2>&1; then
    emit "9.$slug" "STATE.md nicht lesbar: $slug" "fail" \
      "Lesezugriff auf $todo_file verweigert, obwohl die Datei laut stat existiert. Vermutlich fehlt dem laufenden Prozess der Zugriff auf den Desktop-Ordner (macOS Datenschutz). Inhaltliche Konformität ist nicht prüfbar, der Befund sagt nichts über das Format aus." \
      "Dashboard-Server aus einer Shell mit Festplattenzugriff neu starten (kill \$(cat ~/.claude/dashboard/.pid) und danach /aios-dashboard) oder Node bzw. Terminal in Systemeinstellungen > Datenschutz und Sicherheit > Festplattenvollzugriff freigeben."
    return
  fi

  local has_current_pos=0 has_pending=0 has_session_cont=0
  grep -qE '^## ?Current Position|^Current Position[[:space:]]*$' "$state_file" && has_current_pos=1
  # Ebene 2 und 3 gelten beide: "Pending Todos" darf als eigene Top-Level-Sektion
  # ("## Pending Todos") oder als Unterpunkt von "## Accumulated Context"
  # ("### Pending Todos") gefuehrt werden. Muss deckungsgleich bleiben mit
  # RE_PENDING in portfolio.sh und RE_PENDING_HEADING in server.mjs.
  grep -qE '^#{2,3}[[:space:]]*Pending Todos[[:space:]]*$' "$state_file" && has_pending=1
  # Mit TODO.md gilt die Todo-Sektion als erfuellt, die Liste liegt in der eigenen Datei.
  [[ -n "$todo_file" ]] && has_pending=1
  grep -qE '^## Session Continuity' "$state_file" && has_session_cont=1

  local age_d="n/a"
  local mtime_epoch
  mtime_epoch=$(file_mtime_epoch "$state_file")
  [[ -n "$mtime_epoch" ]] && age_d=$(( ( $(now_epoch) - mtime_epoch ) / 86400 ))

  if (( has_current_pos == 1 && has_pending == 1 && has_session_cont == 1 )); then
    if [[ -n "$todo_file" ]]; then
      # Budget nur im geteilten Format pruefen (TODO.md vorhanden): dort ist die
      # STATE.md ein kurzer Status (Aktueller Stand, Wiedereinstieg), hoechstens
      # 60 Zeilen und 5 KB. Altformat-Dateien tragen die Todos noch selbst und
      # werden nicht gegen das Budget gemessen. wc mit Umleitung statt Dateiname
      # liefert auf BSD und GNU (Git Bash) nur die Zahl, tr entfernt die
      # fuehrenden Leerzeichen von BSD-wc. Der Name beginnt bewusst NICHT mit
      # "STATE.md: ", sonst landet der Befund in groupIssues() (public/aios-core.js)
      # im Sammel-Hinweis "altes Format".
      local st_lines st_bytes
      st_lines=$(wc -l < "$state_file" 2>/dev/null | tr -d ' ')
      st_bytes=$(wc -c < "$state_file" 2>/dev/null | tr -d ' ')
      [[ "$st_lines" =~ ^[0-9]+$ ]] || st_lines=0
      [[ "$st_bytes" =~ ^[0-9]+$ ]] || st_bytes=0
      if (( st_lines > 60 || st_bytes > 5120 )); then
        emit "9.$slug" "Projektstatus über Budget: $slug" "warn" \
          "$state_file hat ${st_lines} Zeilen und ${st_bytes} Bytes (Budget: höchstens 60 Zeilen und 5120 Bytes). Template-konform, Todos in $todo_file." \
          "Im Projekt /wrap-up ausführen oder den Projektstatus kürzen: nur aktueller Stand und Wiedereinstieg, höchstens 60 Zeilen und 5 KB"
      else
        emit "9.$slug" "STATE.md: $slug" "ok" \
          "$state_file ist Template-konform (Current Position, Session Continuity vorhanden, Todos in $todo_file, ${st_lines} Zeilen, ${st_bytes} Bytes). Alter: ${age_d} Tage (informativ)." ""
      fi
    else
      emit "9.$slug" "STATE.md: $slug" "ok" \
        "$state_file ist Template-konform (Current Position, Pending Todos, Session Continuity vorhanden). Alter: ${age_d} Tage (informativ)." ""
    fi
  else
    local missing=""
    (( has_current_pos == 0 )) && missing+="Current Position, "
    (( has_pending == 0 )) && missing+="Pending Todos, "
    (( has_session_cont == 0 )) && missing+="Session Continuity, "
    missing="${missing%, }"
    emit "9.$slug" "STATE.md: $slug" "warn" \
      "$state_file ist nicht Template-konform. Fehlende Sektionen: $missing. Alter: ${age_d} Tage (informativ)." \
      "Migriere die STATE.md von $slug verlustfrei in die Template-Struktur ($TEMPLATE_PATH, offene Aufgaben in eine TODO.md daneben gemäß TODO.md.template): Backup anlegen, kompletten Inhalt erhalten, nur unter die Template-Überschriften umsortieren, danach Diff zeigen."
  fi
}

# =============================================================================
# Check 9b: Hygiene der TODO.md je Projekt (nur Warnungen, nie fail)
# - To-do-Zeilen ueber 140 Zeichen (eine Zeile je To-do, Details gehoeren in den Vault)
# - Ueberschriften, die mit "Aus " beginnen (Herkunft statt Thema, Cluster nach Strang)
# Liest dieselbe TODO.md wie Check 9 (neben der STATE.md). Ohne TODO.md oder ohne
# Befund wird nichts gemeldet, das Verhalten fuer saubere Projekte bleibt unveraendert.
# Zeichen statt Bytes: LC_ALL=C plus Entfernen der UTF-8-Folgebytes (tr), damit
# Umlaute einfach zaehlen. Reines tr/grep/awk, laeuft unter Bash 3.2 und Git Bash.
# =============================================================================
check_todo_hygiene_for_project() {
  local slug="$1" proj_path="$2"
  local todo_file=""
  if [[ -f "$proj_path/.planning/TODO.md" ]]; then
    todo_file="$proj_path/.planning/TODO.md"
  elif [[ -f "$proj_path/TODO.md" ]]; then
    todo_file="$proj_path/TODO.md"
  fi
  [[ -z "$todo_file" ]] && return
  head -c1 "$todo_file" >/dev/null 2>&1 || return

  local long_n=0 aus_n=0 aus_first=""
  long_n=$(LC_ALL=C tr -d '\r\200-\277' < "$todo_file" \
    | grep -E '^[[:space:]]*-[[:space:]]\[[ xX]\][[:space:]]' \
    | awk 'length($0) > 140 { n++ } END { print n + 0 }')
  aus_n=$(grep -cE '^#{2,6}[[:space:]]+Aus[[:space:]]' "$todo_file" || true)
  aus_first=$(grep -E '^#{2,6}[[:space:]]+Aus[[:space:]]' "$todo_file" | head -n 1 | tr -d '\r' | sed -E 's/^#+[[:space:]]+//' || true)

  if (( long_n > 0 )); then
    emit "9b.$slug.lang" "To-do-Liste: lange Zeilen: $slug" "warn" \
      "$todo_file enthält $long_n To-do-Zeile(n) mit mehr als 140 Zeichen. Eine Zeile je To-do, kurz und ohne verschachtelte Erklärung." \
      "Die langen To-dos auf höchstens 140 Zeichen kürzen, Details gehören in den Vault oder ans Projekt, nicht in die Zeile."
  fi
  if (( aus_n > 0 )); then
    emit "9b.$slug.herkunft" "To-do-Liste: Überschrift nach Herkunft: $slug" "warn" \
      "$todo_file hat $aus_n Überschrift(en), die mit \"Aus \" beginnen (erste: $aus_first). Das ist Herkunft statt Thema." \
      "Die Items unter ein Themen-Cluster (## <Strang>) einsortieren, die Herkunft (Meeting, Call) gehört ans Item."
  fi
}

check_all_projects_state_md() {
  # Datei fehlt komplett = noch kein Projekt angelegt (Erst-Setup-Signatur),
  # kein defekter Zustand. warn + Onboarding-Hinweis statt fail.
  if [[ ! -f "$PROJECT_REPOS_YAML" ]]; then
    emit "9" "STATE.md je Projekt" "warn" "Noch keine project-repos.yaml vorhanden: $PROJECT_REPOS_YAML" "Erstes Projekt über /new-project anlegen, das schreibt project-repos.yaml automatisch."
    return
  fi

  local any=0
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line//[[:space:]]/}" ]] && continue
    if [[ "$line" =~ ^([a-zA-Z0-9_-]+):[[:space:]]*(.+)[[:space:]]*$ ]]; then
      local slug="${BASH_REMATCH[1]}"
      local proj_path="${BASH_REMATCH[2]}"
      proj_path="${proj_path%\"}"
      proj_path="${proj_path#\"}"
      proj_path="${proj_path%%#*}"
      proj_path="$(echo "$proj_path" | sed -e 's/[[:space:]]*$//')"
      # Pfadformat vereinheitlichen: Backslash-Pfade (Windows-nativ eingetragen)
      # zu Forward-Slash umbauen. Bash kommt mit dem MSYS-Format (/c/Users/...)
      # bereits nativ klar, das bleibt unverändert.
      proj_path="${proj_path//\\//}"
      [[ -z "$proj_path" ]] && continue
      any=1
      check_state_md_for_project "$slug" "$proj_path"
      check_todo_hygiene_for_project "$slug" "$proj_path"
    fi
  done < "$PROJECT_REPOS_YAML"

  if (( any == 0 )); then
    emit "9" "STATE.md je Projekt" "warn" "project-repos.yaml enthält noch keine parsebaren Projekt-Zeilen." "Erstes Projekt über /new-project anlegen, das schreibt project-repos.yaml automatisch."
  fi
}

# =============================================================================
# Check 10 (full): Repo-Drift Live vs. Starter
# Optionaler Repo-Drift-Check, nur wenn check-repo-drift.sh daneben liegt.
# Wird weiter unten per source eingebunden, wenn die Datei vorhanden ist.
# Fehlt sie, entfaellt Check 10 ersatzlos.
# =============================================================================

# =============================================================================
# Check 11 (full): Haushalt
# trash-staging ältester Ordner > 30 Tage, safety.log > 5000 Zeilen,
# > 2 Backup-Dateien im ~/.claude-Root
# =============================================================================
check_haushalt() {
  if [[ -d "$TRASH_STAGING_DIR" ]]; then
    local oldest_epoch="" oldest_name=""
    while IFS= read -r -d '' d; do
      local m
      m=$(file_mtime_epoch "$d")
      [[ -z "$m" ]] && continue
      if [[ -z "$oldest_epoch" || "$m" -lt "$oldest_epoch" ]]; then
        oldest_epoch="$m"
        oldest_name="$(basename "$d")"
      fi
    done < <(find "$TRASH_STAGING_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

    if [[ -n "$oldest_epoch" ]]; then
      local age_d=$(( ( $(now_epoch) - oldest_epoch ) / 86400 ))
      local status="ok"
      (( age_d > 30 )) && status="warn"
      local fix=""
      [[ "$status" == "warn" ]] && fix="Alte trash-staging-Ordner sichten und löschen (ältester: $oldest_name, ${age_d} Tage alt)."
      emit "11-trash-staging" "Haushalt: trash-staging" "$status" "Ältester Ordner: $oldest_name, ${age_d} Tage alt." "$fix"
    else
      emit "11-trash-staging" "Haushalt: trash-staging" "ok" "trash-staging ist leer." ""
    fi
  else
    emit "11-trash-staging" "Haushalt: trash-staging" "ok" "Kein trash-staging-Verzeichnis vorhanden." ""
  fi

  if [[ -f "$SAFETY_LOG" ]]; then
    local lines
    lines=$(wc -l < "$SAFETY_LOG" | tr -d ' ')
    local status="ok"
    (( lines > 5000 )) && status="warn"
    local fix=""
    [[ "$status" == "warn" ]] && fix="safety.log rotieren bzw. kürzen: $SAFETY_LOG (${lines} Zeilen)."
    emit "11-safety-log" "Haushalt: safety.log" "$status" "${lines} Zeilen." "$fix"
  else
    emit "11-safety-log" "Haushalt: safety.log" "ok" "safety.log nicht vorhanden." ""
  fi

  local backup_count=0
  local backups=()
  while IFS= read -r -d '' f; do
    backup_count=$((backup_count + 1))
    backups+=("$(basename "$f")")
  done < <(find "$CLAUDE_ROOT_FOR_BACKUPS" -maxdepth 1 -type f \
    \( -iname "*.backup-*" -o -iname "*.bak-*" -o -iname "*-backup-*" -o -iname "*.bak" \) \
    ! -iname "*.template" -print0)
  local status="ok"
  (( backup_count > 2 )) && status="warn"
  local fix=""
  [[ "$status" == "warn" ]] && fix="Alte Backup-Dateien im ~/.claude-Root aufräumen: ${backups[*]}"
  emit "11-root-backups" "Haushalt: Backup-Dateien im Root" "$status" "${backup_count} Backup-Datei(en) gefunden: ${backups[*]:-keine}." "$fix"
}

# =============================================================================
# Check 12 (full): Dependencies (node, npm, Chromium/Playwright, ccusage)
# WARN je fehlend. ccusage fehlt = Statistik-Modul "nicht verfügbar", kein FAIL.
# =============================================================================
check_dependencies() {
  if command -v node >/dev/null 2>&1; then
    emit "12-node" "Dependency: node" "ok" "$(command -v node) ($(node --version 2>/dev/null))" ""
  else
    emit "12-node" "Dependency: node" "warn" "node nicht im PATH gefunden." "Node.js installieren, z. B. via 'nvm install --lts'."
  fi

  if command -v npm >/dev/null 2>&1; then
    emit "12-npm" "Dependency: npm" "ok" "$(command -v npm) ($(npm --version 2>/dev/null))" ""
  else
    emit "12-npm" "Dependency: npm" "warn" "npm nicht im PATH gefunden." "npm kommt i. d. R. mit der Node-Installation, diese prüfen."
  fi

  local pw_cache="$HOME/Library/Caches/ms-playwright"
  if compgen -G "$pw_cache/chromium*" > /dev/null 2>&1; then
    emit "12-chromium" "Dependency: Chromium (Playwright)" "ok" "Chromium-Build gefunden unter $pw_cache" ""
  # Windows-Pendant (LOCALAPPDATA ist in Git Bash gesetzt), nur geprüft wenn der Mac-Pfad nicht existiert.
  elif compgen -G "$(win_env_to_unix "${LOCALAPPDATA:-}")/ms-playwright/chromium*" > /dev/null 2>&1; then
    emit "12-chromium" "Dependency: Chromium (Playwright)" "ok" "Chromium-Build gefunden unter $(win_env_to_unix "${LOCALAPPDATA:-}")/ms-playwright" ""
  else
    emit "12-chromium" "Dependency: Chromium (Playwright)" "warn" "Kein Chromium-Build unter $pw_cache gefunden." "npx playwright install chromium ausführen."
  fi

  if command -v ccusage >/dev/null 2>&1; then
    emit "12-ccusage" "Dependency: ccusage" "ok" "$(command -v ccusage)" ""
  else
    emit "12-ccusage" "Dependency: ccusage" "warn" "ccusage nicht gefunden, Nutzungs-Statistik-Modul ist 'nicht verfügbar' (kein Fehlerzustand)." "Optional: ccusage installieren (npm i -g ccusage) für das Nutzungs-Statistik-Modul."
  fi
}

# =============================================================================
# Ablauf
# =============================================================================
SETTINGS_OK=0

check_settings_json
check_hooks_exist_and_syntax
check_node
check_scheduled_tasks
check_connector_auth
check_vault_machinery
check_vault_lint
check_all_projects_state_md

# Optionaler Check 10: nur vorhanden, wenn check-repo-drift.sh
# neben diesem Skript liegt.
COLLECTOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$COLLECTOR_DIR/check-repo-drift.sh" ]]; then
  # shellcheck source=/dev/null
  source "$COLLECTOR_DIR/check-repo-drift.sh"
fi

if [[ "$MODE" == "full" ]]; then
  if declare -f check_repo_drift >/dev/null; then
    check_repo_drift
  fi
  check_haushalt
  check_dependencies
fi

# =============================================================================
# JSON + Markdown-Report schreiben
# =============================================================================
# GENERATED_AT wird hier (statt wie sonst am Skriptanfang) unmittelbar vor dem
# schreibenden Python-Aufruf gebildet und als Argument durchgereicht (statt
# lokal in Python neu zu berechnen), damit verify_json_output unten den
# Absturz-Fall zuverlaessig von einer stehengebliebenen alten
# system-check.json unterscheiden kann (siehe python-bin.sh).
GENERATED_AT=$(date +"%Y-%m-%dT%H:%M:%S%z" | sed -E 's/([0-9]{2})([0-9]{2})$/\1:\2/')
$PYBIN - "$ROWS_FILE" "$MODE" "$OUTPUT_DIR" "$REPORT_DIR" "$GENERATED_AT" <<'PYEOF'
import sys, json, datetime, os

rows_file, mode, out_dir, report_dir, generated_at = sys.argv[1:6]
checks = []
with open(rows_file, encoding="utf-8") as f:
    for line in f:
        line = line.rstrip("\n")
        if not line:
            continue
        parts = line.split("\x1f")
        if len(parts) != 5:
            continue
        cid, name, status, detail, fix = parts
        checks.append({"id": cid, "name": name, "status": status, "detail": detail, "fix": fix})

summary = {"ok": 0, "warn": 0, "fail": 0}
for c in checks:
    s = c["status"]
    if s in summary:
        summary[s] += 1

now = generated_at
data = {
    "generated_at": now,
    "mode": mode,
    "checks": checks,
    "summary": summary,
}

os.makedirs(out_dir, exist_ok=True)
os.makedirs(report_dir, exist_ok=True)

json_path = os.path.join(out_dir, "system-check.json")
with open(json_path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write("\n")

today = datetime.date.today().isoformat()
report_path = os.path.join(report_dir, f"{today}-system-check.md")
lamp = {"ok": "OK", "warn": "WARN", "fail": "FAIL"}

lines = []
lines.append(f"# System-Check {today} ({mode})")
lines.append("")
lines.append(f"Erzeugt: {now}")
lines.append("")
lines.append(f"Zusammenfassung: {summary['ok']} OK, {summary['warn']} WARN, {summary['fail']} FAIL")
lines.append("")
lines.append("| Status | ID | Name | Detail |")
lines.append("|---|---|---|---|")
for c in checks:
    detail_cell = c["detail"].replace("|", "/")
    lines.append(f"| {lamp.get(c['status'], c['status'].upper())} | {c['id']} | {c['name']} | {detail_cell} |")
lines.append("")

problems = [c for c in checks if c["status"] != "ok"]
if problems:
    lines.append("## Fix-Sektion (WARN/FAIL)")
    lines.append("")
    for c in problems:
        lines.append(f"### {lamp.get(c['status'], c['status'].upper())}: {c['name']} ({c['id']})")
        lines.append("")
        lines.append(c["detail"])
        lines.append("")
        if c["fix"]:
            lines.append(f"Fix: `{c['fix']}`")
        lines.append("")
else:
    lines.append("Keine offenen Befunde.")
    lines.append("")

with open(report_path, "w", encoding="utf-8") as f:
    f.write("\n".join(lines))
    f.write("\n")

print(f"JSON: {json_path}")
print(f"Report: {report_path}")
print(f"Summary: ok={summary['ok']} warn={summary['warn']} fail={summary['fail']}")
PYEOF
rc=$?

# Haertung gegen den Fail-Open-Fall (siehe python-bin.sh): stuerzt dieser
# letzte Python-Aufruf ab (z.B. Schreibfehler, kaputte ROWS_FILE-Zeile),
# durfte check.sh bisher trotzdem mit "exit 0" enden, obwohl system-check.json
# nicht (oder nicht frisch) geschrieben wurde. Jetzt wird das sichtbar.
verify_json_output "$rc" "$OUTPUT_DIR/system-check.json" "check-collector" "$GENERATED_AT" || exit 1

exit 0
