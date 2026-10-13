#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh: AI Operating System Workshop: Setup
# =============================================================================
# Idempotent: safe to run multiple times.
# Second run after successful first run produces 0 changes.
#
# SAFETY GUARANTEES (was dieses Skript schreibt und NIEMALS anfasst):
#
# Was das Skript schreibt:
#   - ~/.claude/           (globale Claude Code Konfig: CLAUDE.md, rules/, commands/, hooks/)
#   - ~/Documents/Second-Brain/  (Obsidian Vault, nur ergaenzend, niemals ueberschreibend)
#
# Was das Skript NIEMALS anfasst:
#   - Andere Projekt-Ordner (~/projects/..., ~/dev/..., etc.)
#   - Projekt-spezifische CLAUDE.md-Files in deinen bestehenden Repos
#   - User-PATH, zsh-Config, Shell-Aliases (~/.zshrc, ~/.zprofile, etc.)
#   - Claude Code Binary selbst (nur Config-Files)
#   - Obsidian App (nur Vault-Struktur und Template-Files)
#   - ~/.claude.json (OAuth-Token-Datei, niemals anfassen!)
#
# Was Backups bekommt:
#   - Alle existierenden Files in ~/.claude/, die mit Repo-Files kollidieren
#     UND unterschiedlichen Inhalt haben -> nach ~/.claude/backups/ verschoben,
#     mit .bak.<timestamp>-Suffix und gespiegelter relativer Struktur
#     (z.B. ~/.claude/hooks/foo.sh -> ~/.claude/backups/hooks/foo.sh.bak.<ts>)
#   - Vault-Files niemals Backup, niemals Overwrite (copy_if_absent)
#
# Voraussetzung:
#   Claude Code muss bereits installiert sein (Pre-Call mit Affom).
#   bootstrap.sh installiert NUR die Config-Files, NICHT Claude Code selbst.
# =============================================================================

set -euo pipefail

# --- Error trap ---
trap 'echo "[ERROR] Script failed at line $LINENO. See output above. Re-run is safe (idempotent)." >&2' ERR

# --- Variables ---
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
CLAUDE_DIR="$HOME/.claude"
VAULT_DIR="$HOME/Documents/Second-Brain"
DRY_RUN=0

# --- Counters ---
COUNT_BACKED=0
COUNT_NEW=0
COUNT_INSTALL=0
COUNT_UNCHANGED=0
COUNT_SKIPPED=0
COUNT_DRY=0

# Sicherheitsrelevante Schluessel, die in einer bestehenden (nicht ueberschriebenen)
# settings.json fehlen, siehe check_security_keys(), ausgegeben am Ende von report()
SECURITY_GAPS=""

# Skills, die frühere Versionen dieses Repos ausgeliefert haben und die
# inzwischen entfallen sind (resume-session: seit dem STATE.md/TODO.md-Standard
# reicht ein neuer Chat, siehe README "Was sich für bestehende Installationen
# ändert"). Bei bestehenden Installationen werden sie ins Backup-Verzeichnis
# verschoben, nicht gelöscht, siehe retire_obsolete_skills().
RETIRED_SKILLS="resume-session"
RETIRED_DONE=""

# --- Color output ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[OK]${NC}   $*"; }
warn()  { echo -e "${YELLOW}[!!]${NC}   $*"; }
drylog(){ echo -e "${CYAN}[DRY]${NC}  $*"; }
error() { echo -e "${RED}[ERR]${NC}  $*" >&2; }

# =============================================================================
# Argument parsing
# =============================================================================
parse_args() {
  for arg in "$@"; do
    case "$arg" in
      --dry-run)
        DRY_RUN=1
        ;;
      --help|-h)
        echo "Usage: bash bootstrap.sh [--dry-run]"
        echo ""
        echo "  --dry-run   Show what would be done without making any changes"
        exit 0
        ;;
      *)
        warn "Unknown argument: $arg (ignored)"
        ;;
    esac
  done
}

# =============================================================================
# Prerequisites
# =============================================================================
prereq_check() {
  # macOS PATH: source Homebrew in non-interactive mode so 'claude' can be found
  [ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

  echo "Checking prerequisites..."

  # macOS version >= 13
  local os_ver
  os_ver=$(sw_vers -productVersion 2>/dev/null | cut -d. -f1 || echo "0")
  if [ "$os_ver" -lt 13 ]; then
    error "macOS 13+ required for Claude Code. You have $(sw_vers -productVersion)."
    exit 1
  fi
  info "macOS $(sw_vers -productVersion) — OK"

  # git installed
  if ! command -v git &>/dev/null; then
    error "git not found. Install Xcode Command Line Tools: xcode-select --install"
    error "After installation completes, re-run this script."
    exit 1
  fi
  info "git $(git --version | cut -d' ' -f3) — OK"

  # bash version check (3.2+ is macOS default, should always pass)
  local bash_major
  bash_major="${BASH_VERSINFO[0]:-0}"
  if [ "$bash_major" -lt 3 ]; then
    error "bash 3.2+ required. Found: $BASH_VERSION"
    exit 1
  fi
  info "bash $BASH_VERSION — OK"

  # Soft-Check for Claude Code Binary (warning only, not a fatal error)
  if ! command -v claude &>/dev/null; then
    warn "Claude Code Binary nicht gefunden."
    warn "bootstrap.sh installiert die Config-Files, aber Claude Code selbst"
    warn "muss separat ueber den Pre-Call mit Affom installiert werden:"
    warn "  curl -fsSL https://claude.ai/install.sh | bash"
    warn "Files sind nach diesem Bootstrap bereit — Claude Code kommt spaeter."
    echo ""
  else
    info "claude $(claude --version 2>/dev/null | head -1 | cut -d' ' -f3 || echo '(version unknown)') — OK"
  fi
}

# =============================================================================
# Helper: Backup-Zielpfad unter ~/.claude/backups/ berechnen (spiegelt die
# relative Struktur unter ~/.claude/, z.B. hooks/foo.sh -> backups/hooks/foo.sh)
# =============================================================================
# Backups liegen bewusst NICHT mehr neben dem Original (z.B. in ~/.claude/skills/),
# weil Claude Code jedes Unterverzeichnis von skills/ als eigenen Skill laedt,
# ein liegen gebliebenes "<skill>.bak.<ts>"-Verzeichnis erschien dann als
# zusaetzlicher, kaputter Skill. Fuer Einzeldateien ist das unkritisch, aber ein
# einheitlicher Backup-Ort ist einfacher zu finden und aufzuraeumen.
backup_target() {
  local dst="$1"
  local rel="${dst#$CLAUDE_DIR/}"
  echo "$CLAUDE_DIR/backups/${rel}.bak.${TS}"
}

# =============================================================================
# Helper: copy with timestamped backup (for ~/.claude/ files)
# =============================================================================
copy_with_backup() {
  local src="$1"
  local dst="$2"
  local bak_dst
  bak_dst="$(backup_target "$dst")"

  if [ "$DRY_RUN" -eq 1 ]; then
    if [ -f "$dst" ]; then
      if cmp -s "$src" "$dst"; then
        drylog "WUERDE UEBERSPRINGEN (identisch): $(basename "$src")"
      else
        drylog "WUERDE BACKUP + KOPIEREN: $dst -> $bak_dst"
      fi
    else
      drylog "WUERDE NEU ANLEGEN: $dst"
    fi
    COUNT_DRY=$((COUNT_DRY + 1))
    return
  fi

  mkdir -p "$(dirname "$dst")"
  if [ -f "$dst" ]; then
    if cmp -s "$src" "$dst"; then
      info "Unveraendert (uebersprungen): $(basename "$dst")"
      COUNT_UNCHANGED=$((COUNT_UNCHANGED + 1))
    else
      mkdir -p "$(dirname "$bak_dst")"
      mv "$dst" "$bak_dst"
      cp "$src" "$dst"
      warn "Backup angelegt: $bak_dst — neu: $(basename "$dst")"
      COUNT_BACKED=$((COUNT_BACKED + 1))
    fi
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    info "Neu angelegt: $dst"
    COUNT_NEW=$((COUNT_NEW + 1))
  fi
}

# =============================================================================
# Helper: copy a Skill directory with timestamped backup
# Skills are directories: <skill>/SKILL.md plus optional references/, examples/, scripts/
# Backup landet unter ~/.claude/backups/skills/ (siehe backup_target), NICHT
# neben dem Original in ~/.claude/skills/, sonst laedt Claude Code das
# liegen gebliebene Backup-Verzeichnis als eigenen (kaputten) Skill.
# =============================================================================
copy_skill_with_backup() {
  local src_dir="$1"   # source skill directory in repo
  local dst_dir="$2"   # target skill directory in ~/.claude/skills/
  local bak_dst
  bak_dst="$(backup_target "$dst_dir")"

  if [ "$DRY_RUN" -eq 1 ]; then
    if [ -d "$dst_dir" ]; then
      if diff -rq -x node_modules -x .DS_Store "$src_dir" "$dst_dir" &>/dev/null; then
        drylog "WUERDE UEBERSPRINGEN (identisch): skill $(basename "$src_dir")"
      else
        drylog "WUERDE BACKUP + KOPIEREN: $dst_dir -> $bak_dst"
      fi
    else
      drylog "WUERDE NEU ANLEGEN: skill $(basename "$src_dir")"
    fi
    COUNT_DRY=$((COUNT_DRY + 1))
    return
  fi

  mkdir -p "$(dirname "$dst_dir")"
  if [ -d "$dst_dir" ]; then
    if diff -rq -x node_modules -x .DS_Store "$src_dir" "$dst_dir" &>/dev/null; then
      info "Skill unveraendert (uebersprungen): $(basename "$src_dir")"
      COUNT_UNCHANGED=$((COUNT_UNCHANGED + 1))
    else
      mkdir -p "$(dirname "$bak_dst")"
      mv "$dst_dir" "$bak_dst"
      cp -R "$src_dir" "$dst_dir"
      warn "Skill-Backup angelegt: $bak_dst — neu: $(basename "$src_dir")"
      COUNT_BACKED=$((COUNT_BACKED + 1))
    fi
  else
    cp -R "$src_dir" "$dst_dir"
    info "Skill neu angelegt: $(basename "$dst_dir")"
    COUNT_NEW=$((COUNT_NEW + 1))
  fi
}

# =============================================================================
# Helper: copy a Mod directory (Claude-Code-Plugin mit Funktions-Hooks) nach
# ~/.claude/skills/<name>/. Claude Code laedt jeden Ordner dort, der eine
# .claude-plugin/plugin.json traegt, in jeder Session als Plugin, ohne
# settings.json-Eintrag, ohne Marketplace, auf Mac und Windows gleich.
# Der Plugin-Lader erzeugt im geladenen Ordner .claude-plugin/types/ und
# tsconfig.json; beides wird beim Vergleich ausgenommen und nie mitkopiert,
# sonst waere jeder Lauf "abweichend" und die Idempotenz verletzt. diff -x
# trifft Basisnamen auf jeder Ebene, der versionierte Vertrag types/index.d.ts
# faellt damit ebenfalls aus der Aenderungserkennung (reiner Typ-Vertrag fuer
# claude plugin validate, ohne Laufzeitwirkung, wird beim Kopieren mitgenommen).
# Backup wie bei Skills unter ~/.claude/backups/skills/.
# =============================================================================
copy_mod_with_backup() {
  local src_dir="$1"   # source mod directory in repo (claude/mods/<name>)
  local dst_dir="$2"   # target directory in ~/.claude/skills/<name>
  local bak_dst
  bak_dst="$(backup_target "$dst_dir")"

  if [ "$DRY_RUN" -eq 1 ]; then
    if [ -d "$dst_dir" ]; then
      if diff -rq -x node_modules -x .DS_Store -x types -x tsconfig.json "$src_dir" "$dst_dir" &>/dev/null; then
        drylog "WUERDE UEBERSPRINGEN (identisch): mod $(basename "$src_dir")"
      else
        drylog "WUERDE BACKUP + KOPIEREN: $dst_dir -> $bak_dst"
      fi
    else
      drylog "WUERDE NEU ANLEGEN: mod $(basename "$src_dir")"
    fi
    COUNT_DRY=$((COUNT_DRY + 1))
    return
  fi

  mkdir -p "$(dirname "$dst_dir")"
  if [ -d "$dst_dir" ]; then
    if diff -rq -x node_modules -x .DS_Store -x types -x tsconfig.json "$src_dir" "$dst_dir" &>/dev/null; then
      info "Mod unveraendert (uebersprungen): $(basename "$src_dir")"
      COUNT_UNCHANGED=$((COUNT_UNCHANGED + 1))
      return
    fi
    mkdir -p "$(dirname "$bak_dst")"
    mv "$dst_dir" "$bak_dst"
    cp -R "$src_dir" "$dst_dir"
    warn "Mod-Backup angelegt: $bak_dst — neu: $(basename "$src_dir")"
    COUNT_BACKED=$((COUNT_BACKED + 1))
  else
    cp -R "$src_dir" "$dst_dir"
    info "Mod neu angelegt: $(basename "$dst_dir")"
    COUNT_NEW=$((COUNT_NEW + 1))
  fi
  # Generierte Lader-Dateien aus einem Entwickler-Klon nicht mitschleppen
  rm -rf "$dst_dir/.claude-plugin/types" "$dst_dir/tsconfig.json" 2>/dev/null || true
}

# =============================================================================
# Helper: Alt-Backups aus ~/.claude/skills/*.bak.* einmalig nach
# ~/.claude/backups/skills/ verschieben (Selbstheilung fuer Alumni-Rechner,
# auf denen eine frühere Bootstrap-Version dort schon Backups abgelegt hat)
# =============================================================================
migrate_old_skill_backups() {
  local skills_dir="$CLAUDE_DIR/skills"
  [ -d "$skills_dir" ] || return 0

  local found=0
  for old_bak in "$skills_dir"/*.bak.*; do
    [ -e "$old_bak" ] || continue
    found=1
    local target="$CLAUDE_DIR/backups/skills/$(basename "$old_bak")"
    if [ "$DRY_RUN" -eq 1 ]; then
      drylog "WUERDE MIGRIEREN (Alt-Backup): $old_bak -> $target"
      COUNT_DRY=$((COUNT_DRY + 1))
    else
      mkdir -p "$CLAUDE_DIR/backups/skills"
      mv "$old_bak" "$target"
      warn "Alt-Backup migriert: $old_bak -> $target"
    fi
  done

  [ "$found" -eq 1 ] && echo ""
  return 0
}

# =============================================================================
# Helper: entfallene Skills (RETIRED_SKILLS) aus ~/.claude/skills/ nehmen.
# Verschieben statt loeschen: Ziel ist derselbe Backup-Ort wie bei
# copy_skill_with_backup (~/.claude/backups/skills/<name>.bak.<ts>), damit
# Claude Code das Verzeichnis nicht mehr als Skill laedt und nichts verloren geht.
# =============================================================================
retire_obsolete_skills() {
  local name dir bak
  for name in $RETIRED_SKILLS; do
    dir="$CLAUDE_DIR/skills/$name"
    [ -d "$dir" ] || continue
    bak="$(backup_target "$dir")"
    if [ "$DRY_RUN" -eq 1 ]; then
      drylog "WUERDE ENTFERNEN (entfallener Skill, ins Backup): $dir -> $bak"
      COUNT_DRY=$((COUNT_DRY + 1))
    else
      mkdir -p "$(dirname "$bak")"
      mv "$dir" "$bak"
      warn "Entfallener Skill entfernt: $name (gesichert unter $bak)"
      RETIRED_DONE="${RETIRED_DONE}${name} "
      COUNT_BACKED=$((COUNT_BACKED + 1))
    fi
  done
  return 0
}

# =============================================================================
# Helper: copy only if absent (for vault files, NEVER overwrite)
# =============================================================================
copy_if_absent() {
  local src="$1"
  local dst="$2"

  if [ "$DRY_RUN" -eq 1 ]; then
    if [ -f "$dst" ]; then
      drylog "WUERDE BEHALTEN (existiert): $dst"
    else
      drylog "WUERDE ANLEGEN (neu): $dst"
    fi
    COUNT_DRY=$((COUNT_DRY + 1))
    return
  fi

  mkdir -p "$(dirname "$dst")"
  if [ -f "$dst" ]; then
    info "Behalten (existiert): $(basename "$dst")"
    COUNT_SKIPPED=$((COUNT_SKIPPED + 1))
  else
    cp "$src" "$dst"
    info "Neu angelegt: $dst"
    COUNT_NEW=$((COUNT_NEW + 1))
  fi
}

# =============================================================================
# Helper: themenliste.md anlegen und dabei das Datum stempeln
# =============================================================================
# Gleiche Semantik wie copy_if_absent (bestehende Datei wird nie angefasst),
# ersetzt beim erstmaligen Anlegen zusaetzlich den Platzhalter im Frontmatter.
# Eine alte 00_Meta/clusters/vault-clusters.md aus frueheren Installationen
# bleibt unangetastet (kein Loeschen, kein Verschieben).
copy_themenliste_template() {
  local src="$REPO_DIR/vault-skeleton/00_Meta/themenliste.md.template"
  local dst="$VAULT_DIR/00_Meta/themenliste.md"

  if [ "$DRY_RUN" -eq 1 ]; then
    if [ -f "$dst" ]; then
      drylog "WUERDE BEHALTEN (existiert): $dst"
    else
      drylog "WUERDE ANLEGEN (neu, mit heutigem created_date): $dst"
    fi
    COUNT_DRY=$((COUNT_DRY + 1))
    return
  fi

  mkdir -p "$(dirname "$dst")"
  if [ -f "$dst" ]; then
    info "Behalten (existiert): $(basename "$dst")"
    COUNT_SKIPPED=$((COUNT_SKIPPED + 1))
  else
    sed "s/^created_date: YYYY-MM-DD$/created_date: $(date +%Y-%m-%d)/" "$src" > "$dst"
    info "Neu angelegt: $dst"
    COUNT_NEW=$((COUNT_NEW + 1))
  fi
}

# =============================================================================
# Helper: sicherheitsrelevante Matcher/Env-Schluessel in der LIVE settings.json
# pruefen (einfacher grep, kein JSON-Merge). Wird nur aufgerufen, wenn eine
# bestehende settings.json vom aktualisierten Template abweicht und deshalb
# NICHT ueberschrieben wurde, sonst bliebe die Hook-Abdeckung stillschweigend
# auf altem Stand, ohne dass jemand es bemerkt.
# =============================================================================
check_security_keys() {
  local key
  for key in "Write|Edit|MultiEdit|NotebookEdit" "Bash|PowerShell" "CLAUDE_CODE_USE_POWERSHELL_TOOL"; do
    if ! grep -qF "$key" "$CLAUDE_DIR/settings.json" 2>/dev/null; then
      SECURITY_GAPS="${SECURITY_GAPS}${key}"$'\n'
    fi
  done
}

# =============================================================================
# Install ~/.claude/ configuration files
# =============================================================================
install_claude_files() {
  echo ""
  echo "Installiere ~/.claude/ Konfiguration..."
  echo ""

  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$CLAUDE_DIR/rules"
    mkdir -p "$CLAUDE_DIR/commands"
    mkdir -p "$CLAUDE_DIR/skills"
    mkdir -p "$CLAUDE_DIR/hooks"
    mkdir -p "$CLAUDE_DIR/bin"
    mkdir -p "$CLAUDE_DIR/agents"
    mkdir -p "$CLAUDE_DIR/templates"
  fi

  # CLAUDE.md
  copy_with_backup "$REPO_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

  # Rules
  for rule_file in "$REPO_DIR/claude/rules/"*.md; do
    [ -f "$rule_file" ] || continue
    copy_with_backup "$rule_file" "$CLAUDE_DIR/rules/$(basename "$rule_file")"
  done

  # Rules-Archiv (on-demand Wissen, wird nicht auto-geladen)
  if [ -d "$REPO_DIR/claude/rules-archive" ]; then
    for rule_file in "$REPO_DIR/claude/rules-archive/"*.md; do
      [ -f "$rule_file" ] || continue
      copy_with_backup "$rule_file" "$CLAUDE_DIR/rules-archive/$(basename "$rule_file")"
    done
  fi

  # Agents (Subagent-Definitionen)
  if [ -d "$REPO_DIR/claude/agents" ]; then
    for agent_file in "$REPO_DIR/claude/agents/"*.md; do
      [ -f "$agent_file" ] || continue
      copy_with_backup "$agent_file" "$CLAUDE_DIR/agents/$(basename "$agent_file")"
    done
  fi

  # Commands (top-level + namespaced subdirs wie brain/)
  while IFS= read -r -d '' cmd_file; do
    rel_path="${cmd_file#$REPO_DIR/claude/commands/}"
    copy_with_backup "$cmd_file" "$CLAUDE_DIR/commands/$rel_path"
  done < <(find "$REPO_DIR/claude/commands" -type f -name "*.md" -print0)

  # Projekt-Templates (z.B. templates/new-project/, Pflicht-Dependency des /new-project Skills)
  if [ -d "$REPO_DIR/claude/templates" ]; then
    while IFS= read -r -d '' tmpl_file; do
      rel_path="${tmpl_file#$REPO_DIR/claude/templates/}"
      copy_with_backup "$tmpl_file" "$CLAUDE_DIR/templates/$rel_path"
    done < <(find "$REPO_DIR/claude/templates" -type f -print0)
  fi

  # Alt-Backups aus einer frueheren Bootstrap-Version einmalig aufraeumen,
  # bevor neue Skill-Backups entstehen (siehe migrate_old_skill_backups)
  migrate_old_skill_backups

  # Skills (directory-based, each skill is <name>/SKILL.md plus optional subdirs)
  for skill_dir in "$REPO_DIR/claude/skills/"*/; do
    [ -d "$skill_dir" ] || continue
    skill_dir="${skill_dir%/}"  # strip trailing slash
    copy_skill_with_backup "$skill_dir" "$CLAUDE_DIR/skills/$(basename "$skill_dir")"
  done

  # Entfallene Skills bei bestehenden Installationen ins Backup verschieben
  retire_obsolete_skills

  # Mods (Claude-Code-Plugins mit Funktions-Hooks, z.B. session-assistent):
  # nach ~/.claude/skills/<name>/, dort laedt Claude Code sie in jeder Session.
  # Wer den Mod-Ordner stattdessen ueber CLAUDE_CODE_PLUGIN_DIRS in der eigenen
  # settings.json eingehaengt hat (Entwickler-Setup), bekommt keine zweite
  # Kopie, sonst liefe jeder Hook des Mods doppelt.
  if [ -d "$REPO_DIR/claude/mods" ]; then
    for mod_dir in "$REPO_DIR/claude/mods/"*/; do
      [ -f "${mod_dir}.claude-plugin/plugin.json" ] || continue
      mod_dir="${mod_dir%/}"
      mod_name="$(basename "$mod_dir")"
      if grep -F "CLAUDE_CODE_PLUGIN_DIRS" "$CLAUDE_DIR/settings.json" 2>/dev/null | grep -qE "/$mod_name|/claude/mods\"|/claude/mods[:;]"; then
        info "Mod $mod_name wird ueber CLAUDE_CODE_PLUGIN_DIRS geladen, keine Kopie nach skills/"
        continue
      fi
      copy_mod_with_backup "$mod_dir" "$CLAUDE_DIR/skills/$mod_name"
    done
  fi

  # Skill-Deps: if a skill ships a package.json, install its node deps locally
  if [ "$DRY_RUN" -eq 0 ] && command -v npm &>/dev/null; then
    for skill_dir in "$CLAUDE_DIR/skills/"*/; do
      [ -f "${skill_dir}package.json" ] || continue
      if [ ! -d "${skill_dir}node_modules" ]; then
        info "Installiere node-deps fuer skill $(basename "${skill_dir%/}")..."
        (cd "$skill_dir" && npm install --silent --no-audit --no-fund 2>&1 | tail -3) || \
          warn "npm install fuer $(basename "${skill_dir%/}") fehlgeschlagen"
      fi
    done
  elif [ "$DRY_RUN" -eq 1 ]; then
    for skill_dir in "$REPO_DIR/claude/skills/"*/; do
      [ -f "${skill_dir}package.json" ] || continue
      drylog "WUERDE npm install in skill $(basename "${skill_dir%/}")"
    done
  fi

  # Hilfsskripte (bin/, z.B. vault-find.sh fuer die gezielte Suche im Second Brain)
  if [ -d "$REPO_DIR/claude/bin" ]; then
    for bin_file in "$REPO_DIR/claude/bin/"*; do
      [ -f "$bin_file" ] || continue
      copy_with_backup "$bin_file" "$CLAUDE_DIR/bin/$(basename "$bin_file")"
      if [ "$DRY_RUN" -eq 0 ]; then
        chmod +x "$CLAUDE_DIR/bin/$(basename "$bin_file")" 2>/dev/null || true
      else
        drylog "WUERDE chmod +x: $CLAUDE_DIR/bin/$(basename "$bin_file")"
      fi
    done
  fi

  # Hooks
  for hook_file in "$REPO_DIR/claude/hooks/"*; do
    [ -f "$hook_file" ] || continue
    copy_with_backup "$hook_file" "$CLAUDE_DIR/hooks/$(basename "$hook_file")"
    if [ "$DRY_RUN" -eq 0 ]; then
      chmod +x "$CLAUDE_DIR/hooks/$(basename "$hook_file")" 2>/dev/null || true
    else
      drylog "WUERDE chmod +x: $CLAUDE_DIR/hooks/$(basename "$hook_file")"
    fi
  done

  # Eigene Adressen fuer die Sende-Sperre (bash_safety_check.py): nur anlegen,
  # wenn die Datei fehlt, bestehende Eintraege des Nutzers nie ueberschreiben.
  if [ ! -f "$CLAUDE_DIR/hooks/own-addresses.txt" ]; then
    if [ "$DRY_RUN" -eq 0 ]; then
      cp "$REPO_DIR/claude/hooks/own-addresses.txt.template" "$CLAUDE_DIR/hooks/own-addresses.txt"
      info "hooks/own-addresses.txt aus Vorlage angelegt, eigene Adressen dort eintragen"
    else
      drylog "WUERDE anlegen: $CLAUDE_DIR/hooks/own-addresses.txt (aus Vorlage)"
    fi
  fi

  # settings.json.template, IMMER aktuell halten (mit copy_with_backup)
  copy_with_backup "$REPO_DIR/claude/settings.json.template" "$CLAUDE_DIR/settings.json.template"

  # settings.json, NIEMALS ueberschreiben wenn vorhanden
  if [ "$DRY_RUN" -eq 1 ]; then
    if [ -f "$CLAUDE_DIR/settings.json" ]; then
      drylog "WUERDE BEHALTEN (existiert): $CLAUDE_DIR/settings.json"
    else
      drylog "WUERDE ANLEGEN aus Template: $CLAUDE_DIR/settings.json"
    fi
  else
    if [ -f "$CLAUDE_DIR/settings.json" ]; then
      if cmp -s "$REPO_DIR/claude/settings.json.template" "$CLAUDE_DIR/settings.json"; then
        info "settings.json unveraendert (identisch mit generierter Vorlage)."
      else
        warn ""
        warn "settings.json existiert bereits — wurde NICHT ueberschrieben (deine Konfig bleibt)."
        warn "Wenn du die Workshop-Hooks aktivieren willst, vergleiche:"
        warn "  diff ~/.claude/settings.json ~/.claude/settings.json.template"
        warn "und uebernimm den hooks-Block manuell ODER backup deine settings.json"
        warn "und kopiere die Vorlage: cp ~/.claude/settings.json.template ~/.claude/settings.json"
        warn ""
        check_security_keys
      fi
    else
      cp "$REPO_DIR/claude/settings.json.template" "$CLAUDE_DIR/settings.json"
      info "Neu angelegt: $CLAUDE_DIR/settings.json (aus Template)"
      COUNT_NEW=$((COUNT_NEW + 1))
    fi
  fi
}

# =============================================================================
# Install Obsidian Vault Skeleton
# =============================================================================
install_vault_skeleton() {
  echo ""
  echo "Installiere Vault-Skeleton unter $VAULT_DIR..."
  echo ""

  # Vault-Detection: friendly message if vault already exists
  if [ -d "$VAULT_DIR" ] && [ "$(ls -A "$VAULT_DIR" 2>/dev/null | head -1)" ]; then
    if [ "$DRY_RUN" -eq 0 ]; then
      info "Vault gefunden unter $VAULT_DIR — PARA-Struktur wird ergaenzt,"
      info "bestehende Inhalte werden NICHT angefasst."
    else
      drylog "Vault gefunden unter $VAULT_DIR — PARA-Struktur wuerde ergaenzt (bestehende Inhalte NICHT angefasst)"
    fi
    echo ""
  fi

  # Create PARA directories (00_Meta restrukturiert 2026-04-29:
  #   themenliste.md = feste Themenliste, system/ = Maschinen-State)
  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$VAULT_DIR/00_Meta/Templates"
    mkdir -p "$VAULT_DIR/00_Meta/system/lint-reports"
    mkdir -p "$VAULT_DIR/00_Meta/system/backups"
    mkdir -p "$VAULT_DIR/01_Inbox"
    mkdir -p "$VAULT_DIR/02_Projects"
    mkdir -p "$VAULT_DIR/03_Areas"
    mkdir -p "$VAULT_DIR/04_Resources"
    mkdir -p "$VAULT_DIR/05_Contacts/People"
    mkdir -p "$VAULT_DIR/05_Contacts/Organizations"
    mkdir -p "$VAULT_DIR/06_Archive"
  else
    drylog "WUERDE mkdir -p: $VAULT_DIR/{00_Meta/{Templates,system/{lint-reports,backups}},01_Inbox,02_Projects,03_Areas,04_Resources,05_Contacts/{People,Organizations},06_Archive}"
  fi

  # Templates (copy_if_absent, niemals ueberschreiben)
  for tmpl_file in "$REPO_DIR/vault-skeleton/00_Meta/Templates/"*.md; do
    [ -f "$tmpl_file" ] || continue
    copy_if_absent "$tmpl_file" "$VAULT_DIR/00_Meta/Templates/$(basename "$tmpl_file")"
  done

  # Vault meta files (copy_if_absent), neue Pfade nach Restrukturierung
  copy_if_absent "$REPO_DIR/vault-skeleton/00_Meta/system/vault-index.md" \
                 "$VAULT_DIR/00_Meta/system/vault-index.md"
  copy_if_absent "$REPO_DIR/vault-skeleton/00_Meta/system/vault-log.md" \
                 "$VAULT_DIR/00_Meta/system/vault-log.md"
  # Ziel OHNE .template-Suffix: /brain:sort-inbox liest die feste Themenliste
  # unter genau diesem Namen (00_Meta/themenliste.md). Existiert nur noch die alte
  # 00_Meta/clusters/vault-clusters.md, wird die neue Datei zusaetzlich angelegt
  # und die alte nicht angefasst.
  # Nicht copy_if_absent: die Vorlage enthaelt "created_date: YYYY-MM-DD" als
  # Platzhalter. Woertlich kopiert bleibt er auf jedem frisch eingerichteten
  # Rechner stehen und laeuft spaeter im /brain:health-check als Formatfehler auf.
  copy_themenliste_template
  copy_if_absent "$REPO_DIR/vault-skeleton/00_Meta/vault-structure.md" \
                 "$VAULT_DIR/00_Meta/vault-structure.md"
}

# =============================================================================
# Report summary
# =============================================================================
report() {
  echo ""
  echo "=============================================="
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  [DRY-RUN] Zusammenfassung — $COUNT_DRY Aktionen simuliert"
    echo "  (Keine Aenderungen auf Disk gemacht)"
  else
    echo "  Bootstrap abgeschlossen!"
    echo ""
    echo "  Neue Files angelegt:   $COUNT_NEW"
    echo "  Install-Schritte:      $COUNT_INSTALL (npx/npm, laufen bei jedem Lauf)"
    echo "  Backups erstellt:      $COUNT_BACKED"
    echo "  Unveraendert skip:     $COUNT_UNCHANGED"
    echo "  Vault kept-existing:   $COUNT_SKIPPED"
    echo ""
    if [ -n "$RETIRED_DONE" ]; then
      echo "  Entfallene Skills entfernt: $RETIRED_DONE(Backup unter ~/.claude/backups/skills/)"
    fi
    if [ "$COUNT_BACKED" -gt 0 ]; then
      echo "  Backup-Files findest du via:"
      echo "  ls -R ~/.claude/backups/ 2>/dev/null"
    fi
  fi
  echo "=============================================="
  echo ""
  if [ "$DRY_RUN" -eq 0 ]; then
    echo "Naechste Schritte:"
    echo "  1. Claude Code starten: claude"
    echo "  2. Im Projekt einfach losschreiben: Claude liest den Projektstatus (.planning/STATE.md)"
    echo "     und sucht Wissen gezielt mit ~/.claude/bin/vault-find.sh. Kein Resume-Befehl noetig."
    echo "  3. MCP-Connectors: claude.ai/settings/connectors"
    echo "     Details: docs/connector-setup.md"
    echo ""
    echo "Hinweis: Bestehende STATE.md-Dateien werden nicht umgebaut. Neue Projekte"
    echo "(/new-project) bekommen STATE.md plus TODO.md, /wrap-up pflegt beide Formate."
    echo ""
  fi

  # Ganz am Ende, nach allem anderen: unuebersehbarer Hinweis, wenn die
  # bestehende settings.json sicherheitsrelevante Hook-Matcher/Env-Keys nicht
  # enthaelt (kein automatischer Merge, siehe check_security_keys weiter oben).
  if [ -n "$SECURITY_GAPS" ]; then
    echo ""
    echo "################################################################"
    echo "#  [!!] SICHERHEITSHINWEIS: settings.json auf altem Stand      #"
    echo "################################################################"
    echo ""
    echo "  Deine bestehende ~/.claude/settings.json wurde NICHT ueberschrieben"
    echo "  (wie immer), enthaelt aber folgende sicherheitsrelevante Schluessel"
    echo "  aus der aktuellen Vorlage nicht:"
    echo ""
    # sed statt read-Schleife: das fruehere "[ -n ] && echo"-Muster endete bei
    # der leeren Schlusszeile mit Status 1 und riss unter set -euo pipefail
    # das ganze Skript mitten im Hinweis ab.
    printf '%s\n' "$SECURITY_GAPS" | sed '/^[[:space:]]*$/d; s/^/    - /'
    echo ""
    echo "  Ohne diese Schluessel bleibt die Hook-Abdeckung (z.B. Secret-Scan"
    echo "  vor Commits) auf dem alten Stand."
    echo ""
    echo "  Ein-Zeilen-Check gegen die frisch aktualisierte Vorlage:"
    echo "    diff ~/.claude/settings.json ~/.claude/settings.json.template"
    echo "  Fehlende Zeilen daraus manuell in deine settings.json uebernehmen."
    echo ""
    echo "################################################################"
    echo ""
  fi
}

# =============================================================================
# Main
# =============================================================================
# Dashboard-Runtime nach ~/.claude/dashboard ausrollen. Der /aios-dashboard-Skill
# (in claude/skills/) startet den Server on-demand und erwartet die Runtime hier.
# Code-Dateien werden aktualisiert (mit Backup), Seed-/Laufzeitdaten (data/) nicht
# ueberschrieben. .token/.pid/data-Livedateien liegen nicht im Repo (gitignored).
install_dashboard() {
  echo ""
  echo "Installiere AIOS-Dashboard (lokales Cockpit, via /aios-dashboard)..."
  echo ""

  local src="$REPO_DIR/dashboard"
  if [ ! -d "$src" ]; then
    warn "dashboard/ im Repo nicht gefunden — uebersprungen."
    return 0
  fi

  while IFS= read -r -d '' f; do
    local rel="${f#$src/}"
    case "$rel" in
      data/*) copy_if_absent "$f" "$CLAUDE_DIR/dashboard/$rel" ;;  # Seed/Livedaten behalten
      *)      copy_with_backup "$f" "$CLAUDE_DIR/dashboard/$rel" ;;
    esac
  done < <(find "$src" -type f -print0)

  # Fundament-Manifest: welche Skills/Commands DIESES Repo als Kern ausliefert.
  # Einzige Quelle ist der Repo-Inhalt selbst, damit nirgends eine zweite Liste
  # gepflegt werden muss, die auseinanderlaeuft. Der Skills-Collector gruppiert
  # daran entlang (Fundament vs. Weitere).
  if [ "$DRY_RUN" -eq 1 ]; then
    drylog "WUERDE SCHREIBEN: $CLAUDE_DIR/dashboard/fundament.json (aus claude/skills + claude/commands + playwright-cli)"
  else
    python3 - "$REPO_DIR" "$CLAUDE_DIR/dashboard/fundament.json" <<'PY' || warn "fundament.json konnte nicht geschrieben werden"
import sys, os, json, glob
repo, out = sys.argv[1], sys.argv[2]
skills = sorted(os.path.basename(os.path.dirname(p))
                for p in glob.glob(os.path.join(repo, "claude/skills/*/SKILL.md")))
cmd_root = os.path.join(repo, "claude/commands")
cmds = sorted(os.path.relpath(p, cmd_root)[:-3].replace(os.sep, ":")
              for p in glob.glob(os.path.join(cmd_root, "**", "*.md"), recursive=True))
# playwright-cli wird separat per npm installiert, gehoert aber zum Kern.
os.makedirs(os.path.dirname(out), exist_ok=True)
with open(out, "w", encoding="utf-8") as f:
    json.dump({"fundament": skills + cmds + ["playwright-cli"]}, f, ensure_ascii=False, indent=2)
PY
  fi

  if [ "$DRY_RUN" -eq 0 ]; then
    chmod +x "$CLAUDE_DIR/dashboard/server.mjs" 2>/dev/null || true
    chmod +x "$CLAUDE_DIR/dashboard/check-prereqs.sh" 2>/dev/null || true
    for c in "$CLAUDE_DIR/dashboard/collectors/"*.sh; do
      [ -f "$c" ] && chmod +x "$c" 2>/dev/null || true
    done
  fi
}

# =============================================================================
# Install Playwright CLI (Microsoft's coding-agent CLI + bundled Skills)
# =============================================================================
install_playwright_cli() {
  echo ""
  echo "Installiere playwright-cli (Browser-Automation fuer Coding-Agents)..."
  echo ""

  if ! command -v npm &>/dev/null; then
    warn "npm (Node.js) nicht gefunden — playwright-cli wird uebersprungen."
    warn "Spaeter nachinstallieren: brew install node && npm i -g @playwright/cli@latest"
    return 0
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    drylog "WUERDE installieren: npm i -g @playwright/cli@latest"
    drylog "WUERDE installieren: npx --yes playwright install chromium"
    drylog "WUERDE installieren: Chromium passend zur Playwright-Version jedes Skills mit eigenem node_modules/playwright (z.B. designer)"
    drylog "WUERDE Microsoft Playwright-Skill nach $CLAUDE_DIR/skills/playwright-cli kopieren"
    COUNT_DRY=$((COUNT_DRY + 4))
    return 0
  fi

  # 1. Install @playwright/cli (brings playwright lib transitively)
  if npm i -g @playwright/cli@latest 2>&1; then
    info "@playwright/cli installiert"
    COUNT_INSTALL=$((COUNT_INSTALL + 1))
  else
    warn "@playwright/cli-Install gescheitert — manueller Retry: npm i -g @playwright/cli@latest"
    return 0
  fi

  # 2. Install Chromium browser binary (~150 MB)
  info "Hinweis: der folgende WARNING-Kasten von Playwright ist erwartbar bei globaler Installation (kein Projekt-package.json) und kein Fehler."
  if npx --yes playwright install chromium 2>&1; then
    info "Chromium-Browser installiert"
    COUNT_INSTALL=$((COUNT_INSTALL + 1))
  else
    warn "Chromium-Install gescheitert — manueller Retry: npx --yes playwright install chromium"
  fi

  # 2b. Chromium passend zur Playwright-Version der Skills nachziehen.
  # Schritt 2 laedt den Browser fuer das JEWEILS AKTUELLE playwright (npx --yes,
  # ausserhalb eines Projekts). Skills mit eigenem package-lock.json (designer,
  # render-pdf.mjs) sind auf eine feste Playwright-Version gepinnt und suchen
  # im ms-playwright-Cache genau deren Browser-Revision. Sobald "latest" am Pin
  # vorbeizieht, fehlt diese Revision ("Executable doesn't exist at
  # ...chromium_headless_shell-NNNN"). Deshalb zusaetzlich mit dem
  # skill-lokalen playwright installieren (--no-install: nie ein fremdes
  # Paket nachladen). Ist die Revision schon da, ist der Aufruf ein No-op.
  local pw_skill_dir pw_skill_name
  for pw_skill_dir in "$CLAUDE_DIR/skills/"*/; do
    [ -d "${pw_skill_dir}node_modules/playwright" ] || continue
    pw_skill_name="$(basename "${pw_skill_dir%/}")"
    if (cd "$pw_skill_dir" && { npx --no-install playwright install chromium --only-shell 2>&1 || npx --no-install playwright install chromium 2>&1; }); then
      info "Chromium fuer Skill $pw_skill_name installiert (passend zur gepinnten Playwright-Version)"
    else
      warn "Chromium-Install fuer Skill $pw_skill_name gescheitert — manueller Retry: (cd \"${pw_skill_dir%/}\" && npx playwright install chromium)"
    fi
  done

  # 3. Copy Microsoft's bundled Playwright Skill globally to ~/.claude/skills/
  # Note: `playwright-cli install --skills` installs project-local (./.claude/skills/).
  # We want global, so we copy from the npm package source instead.
  local npm_root pw_source
  npm_root="$(npm root -g 2>/dev/null || echo '')"
  pw_source="${npm_root}/@playwright/cli/skills/playwright-cli"

  if [ -d "$pw_source" ]; then
    copy_skill_with_backup "$pw_source" "$CLAUDE_DIR/skills/playwright-cli"
  else
    warn "Microsoft Playwright-Skill-Source nicht gefunden ($pw_source)"
    warn "Manueller Install: playwright-cli install --skills (im Projekt) oder Skill aus dem npm-Paket kopieren"
  fi
}

main() {
  parse_args "$@"

  echo ""
  echo "================================================"
  echo "  AI Operating System Workshop — Bootstrap"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo ""
    echo "  [DRY-RUN MODE — keine Aenderungen werden gemacht]"
    echo "  (Zeigt was passieren WUERDE — sicher fuer Walkthrough)"
  fi
  echo "================================================"
  echo ""
  echo "Tipp: Falls noch nicht gemacht — fuehre zuerst 'bash preflight.sh' aus,"
  echo "      um Voraussetzungen zu pruefen (read-only)."
  echo ""

  prereq_check
  install_claude_files
  install_vault_skeleton
  install_dashboard
  install_playwright_cli
  report
}

main "$@"
