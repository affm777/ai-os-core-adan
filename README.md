# AI Operating System

Dieses Repository enthält das komplette AI Operating System: Claude Code mit vorbereiteten globalen Instructions, Skills (auto-invokable Workflows), Slash-Commands, Hooks, einem Obsidian Second Brain und dem lokalen Dashboard.

Nach dem Setup hast du ein vollständiges, persönliches AI-OS auf deinem Rechner.

---

## Setup für macOS

### Voraussetzungen (werden vom Preflight-Check automatisch geprüft)

Du brauchst:

- **macOS 14 (Sonoma) oder neuer**
- **zsh als aktive Shell** (macOS-Default seit Catalina)
- **git** (Xcode Command Line Tools)
- **Claude Code**: Anthropic Installer
- **Homebrew** + **Node.js**: für Statusline, Dashboard und Playwright
- **Obsidian**: Second Brain (kostenlos, [obsidian.md](https://obsidian.md))

> **Du musst das nicht selber durchgehen.** `bash mac/preflight.sh` checkt alles und gibt dir die exakten Install-Commands für alles was fehlt, in der richtigen Reihenfolge.

### Onboarding

#### Schritt 0: Terminal.app öffnen + zsh sicherstellen

Öffne **Terminal.app** (nicht Cursor-Terminal, das kommt später). Spotlight (`Cmd+Space`) → "Terminal".

Falls dein Prompt mit `(base)` startet oder du irgendwo `bash-3.2$` siehst, bist du auf bash. Auf zsh wechseln:

```bash
chsh -s /bin/zsh
```

**Terminal komplett zumachen + neu öffnen** (nicht nur Tab, komplett). Das ist wichtig, damit alle PATH-Anpassungen später in der richtigen Shell-Config landen.

#### Schritt 1: Repository klonen

```bash
git clone https://github.com/affm777/ai-os-core-adan.git ~/ai-os-core
cd ~/ai-os-core
```

> **WICHTIG:** Immer via `git clone` klonen, niemals ZIP-Download. macOS Gatekeeper kann ZIPs sonst blockieren (Quarantine-Attribut). Falls doch ZIP: `xattr -dr com.apple.quarantine ./ai-os-core`

#### Schritt 2: Preflight-Check, was fehlt noch?

```bash
bash mac/preflight.sh
```

Read-only Check. Ändert nichts. Output zeigt grüne Häkchen für alles was schon da ist und rote Kreuze + exakte Install-Commands für alles was fehlt.

**Typischer Workflow:** Falls etwas fehlt, die ausgegebenen Install-Commands von oben nach unten ausführen (z.B. erst Homebrew, dann Node, dann Claude Code). Nach jedem Install nochmal `bash mac/preflight.sh`, bis alle Checks grün sind.

**Häufige Reibungspunkte:**

- **Claude-Code-PATH:** Der Anthropic-Installer schreibt PATH-Hinweise nach `~/.bashrc`, auch wenn du zsh nutzt. Preflight gibt dir den korrekten Fix für deine Shell aus.
- **Homebrew auf Apple Silicon vs Intel:** Unterschiedliche `brew shellenv`-Pfade. Preflight kennt beide Varianten.

#### Schritt 3: Dry-Run (Bootstrap-Vorschau)

```bash
bash mac/bootstrap.sh --dry-run
```

Zeigt was passieren würde, ohne etwas zu schreiben. Output mit `[DRY-RUN MODE]`-Header.

#### Schritt 4: Bootstrap ausführen

```bash
bash mac/bootstrap.sh
```

Das Skript:
- Prüft Voraussetzungen
- Installiert `~/.claude/` Config-Files (CLAUDE.md, rules/, commands/, hooks/, skills/)
- Erstellt `~/Documents/Second-Brain/` PARA-Struktur + Templates
- Installiert das AIOS-Dashboard nach `~/.claude/dashboard` (Cockpit via `/aios-dashboard`)
- Installiert Playwright CLI (Browser-Automation)
- Gibt Summary mit Counts aus

Dauer: 30-60 Sekunden (länger wenn Playwright/Chromium über Netzwerk nachgeladen wird).

#### Schritt 5: Verifizieren

```bash
ls ~/.claude/CLAUDE.md
ls ~/.claude/rules/
ls ~/.claude/commands/
ls ~/.claude/hooks/
ls ~/.claude/bin/
ls ~/.claude/templates/new-project/
ls ~/Documents/Second-Brain/00_Meta/Templates/
claude --version
```

#### Schritt 6: Obsidian öffnen

1. Obsidian starten
2. "Open folder as vault" klicken
3. `~/Documents/Second-Brain/` auswählen
4. Vault ist jetzt mit PARA-Struktur und Templates bereit

#### Schritt 7: Claude Code starten + testen

```bash
cd ~
claude
```

In der Claude-REPL:
- `/help` → Slash-Commands sichtbar
- `/brain:health-check` → Vault-Sanity-Check
- `/aios-dashboard` → lokales Cockpit öffnen (startet den Server on-demand)

Falls du Cursor nutzen willst: erst jetzt Cursor öffnen, bei aktivem Cursor-Plugin **Cursor neu starten**, damit die frische `~/.claude/`-Config geladen wird.

#### Schritt 8: Nächste Schritte, in dieser Reihenfolge

Die Reihenfolge ist bewusst so gewählt: erst die Datenquellen, dann die Automatik, dann das erste Projekt. So arbeitet jeder Baustein von Anfang an mit echten Daten statt mit Leerzuständen.

1. **MCP-Connectors einrichten:** Gmail, Calendar, Drive, Fathom → [docs/connector-setup.md](docs/connector-setup.md). Zuerst, weil Briefing, Dashboard und Routinen auf diesen Datenquellen aufbauen.
2. **Routines anlegen:** damit dein Second Brain sich selbst pflegt → [docs/routines.md](docs/routines.md). Nach den Connectoren, denn die Routinen lesen deren Daten.
3. **Erstes Projekt anlegen:** einen Ordner für dein Vorhaben erstellen, dort `claude` starten und sagen: „Leg ein Projekt an." Der mitinstallierte Skill erzeugt CLAUDE.md, Projektstatus (`.planning/STATE.md`), To-do-Liste (`.planning/TODO.md`) und Vault-Notiz in einem Rutsch. Ab jetzt zeigt auch das Dashboard (`/aios-dashboard`) echte Projektdaten.

Danach bei Bedarf:

- **Google Workspace CLI:** Claude arbeitet direkt in Gmail, Kalender, Drive und Co. → [docs/google-workspace-cli.md](docs/google-workspace-cli.md)
- **Dashboard-Details:** wird von `bootstrap.sh` mitinstalliert, Aufruf einfach über `/aios-dashboard` in Claude Code → [dashboard/INSTALL.md](dashboard/INSTALL.md)
- **Workshop-Materialien:** Kommen vom Trainer im Pre-Call

---

## Setup für Windows 11

### Voraussetzungen

> **Voraussetzung:** Windows 11, Version 22H2 oder neuer (Build 22621+). Wird automatisch geprüft, siehe Schritt 1.

> **Konvention:** Alle Terminal-Befehle dieser Anleitung laufen in **Git Bash**, nicht in PowerShell oder cmd. Einzige Ausnahme: Schritt 1 (läuft in PowerShell, bevor Git Bash überhaupt installiert ist).

### Onboarding

#### Schritt 1: PowerShell öffnen + Oneliner ausführen

Startmenü öffnen (`Windows`-Taste), "PowerShell" eintippen, öffnen (normale PowerShell reicht, kein Administrator nötig). Dann:

```powershell
irm https://raw.githubusercontent.com/affm777/ai-os-core-adan/main/windows/setup.ps1 | iex
```

Das Skript prüft zuerst deine Windows-Version, installiert danach Git, Node.js, Python und Claude Code über `winget` und klont zuletzt das Setup-Repository nach `~/ai-os-core`. Ist das Repository öffentlich, läuft der Klon ohne Anmeldung durch; ist es privat, öffnet sich ein Browserfenster mit GitHub-Login.

Windows zeigt dabei möglicherweise SmartScreen-Warnungen ("Windows hat Ihren PC geschützt") oder Bestätigungs-Prompts der einzelnen Installer. Das ist normal bei neu installierter Software: "Weitere Informationen" → "Trotzdem ausführen" bzw. die jeweilige Installer-Bestätigung (Ja/Install) anklicken. Details und Screenshots: [docs/windows/setup.md](docs/windows/setup.md).

#### Schritt 2: Preflight-Check, was fehlt noch?

Dieses Fenster schließen. Startmenü öffnen, "Git Bash" eintippen, öffnen.

```bash
cd ~/ai-os-core && bash windows/preflight.sh
```

Read-only Check, ändert nichts. Fehlt etwas, bekommst du die exakten `winget`-Install-Commands ausgegeben, in der richtigen Reihenfolge. Nach jedem Install nochmal `bash windows/preflight.sh` ausführen, bis alle Checks grün sind (gleiches Prinzip wie bei Mac-Preflight oben).

#### Schritt 3: Dry-Run (Bootstrap-Vorschau)

```bash
bash windows/bootstrap.sh --dry-run
```

Zeigt was passieren würde, ohne etwas zu schreiben.

#### Schritt 4: Bootstrap ausführen

```bash
bash windows/bootstrap.sh
```

Installiert dieselben `~/.claude/`- und Vault-Inhalte wie auf dem Mac (siehe "Was macht bootstrap.sh?" weiter unten), zusätzlich mit einem Windows-Overlay für Hooks und einer generierten (statt kopierten) `settings.json` mit Windows-Pfaden.

#### Schritt 5: Verifizieren

In Git Bash:

```bash
ls ~/.claude/
claude --version
```

#### Schritt 6: Obsidian öffnen

1. Obsidian starten
2. "Open folder as vault" klicken
3. Zum Vault navigieren: **"Dieser PC" → "C:" → "Benutzer" → `<DEIN-NAME>` → "Documents" → "Second-Brain"**

> **WICHTIG:** Falls OneDrive eingerichtet ist, NICHT den OneDrive-Knoten "Dokumente" in der linken Seitenleiste wählen. Der Vault liegt im echten lokalen Ordner unter `C:\Users\<DEIN-NAME>\Documents\Second-Brain`, nicht im OneDrive-Spiegel. Immer über "Dieser PC" navigieren.

#### Schritt 7: Claude Code starten + testen

```bash
cd ~
claude
```

In der Claude-REPL wie beim Mac: `/help`, `/brain:health-check`, `/aios-dashboard`.

Danach gilt Schritt 8 aus dem macOS-Teil identisch auch für Windows: Connectors, dann Routines, dann das erste Projekt.

---

Mehr Details (Screenshots, SmartScreen, Defender-Hinweis, Windows-Terminal-Tipp): [docs/windows/setup.md](docs/windows/setup.md). Bekannte Probleme: [docs/windows/troubleshooting.md](docs/windows/troubleshooting.md).

---

## Was macht bootstrap.sh?

`bootstrap.sh` ist ein **idempotenter File-Installer**, es kopiert Config-Files an die richtigen Stellen.

**Konkret:**
- Kopiert `claude/CLAUDE.md` → `~/.claude/CLAUDE.md` (mit Backup falls vorhanden)
- Kopiert `claude/rules/*.md` → `~/.claude/rules/` (mit Backup)
- Kopiert `claude/commands/*.md` → `~/.claude/commands/` (mit Backup)
- Kopiert `claude/skills/*` → `~/.claude/skills/` (mit Backup, Verzeichnis-basiert)
- Kopiert `claude/mods/*` → `~/.claude/skills/<name>/` (Mods, also Plugins mit Funktions-Hooks, zum Beispiel `session-assistent`; Claude Code lädt sie von dort in jeder Session, ohne Eintrag in `settings.json`)
- Kopiert `claude/templates/*` → `~/.claude/templates/` (Projekt-Templates fuer `/new-project`)
- Kopiert `claude/hooks/*` → `~/.claude/hooks/` + setzt `chmod +x`
- Kopiert `claude/bin/*` → `~/.claude/bin/` + setzt `chmod +x` (z.B. `vault-find.sh`, die gezielte Suche im Second Brain)
- Verschiebt entfallene Skills einer früheren Version (aktuell `resume-session`) nach `~/.claude/backups/skills/` und nennt sie im Abschlussbericht
- Erstellt `~/Documents/Second-Brain/` Ordnerstruktur (PARA: 00_Meta, 01_Inbox, 02_Projects, 03_Areas, 04_Resources, 05_Contacts, 06_Archive)
- Legt Templates und vault-index/log an (nur wenn noch nicht vorhanden)
- Installiert das **AIOS-Dashboard** nach `~/.claude/dashboard` (Cockpit via `/aios-dashboard`, Laufzeitdaten bleiben lokal)
- Installiert **playwright-cli** via `npm i -g @playwright/cli` + Chromium-Browser + Microsofts gepflegte Playwright-Skills (Browser-Automation, HTML-Verifikation, Screenshots)

**Idempotent:** Zweiter Durchlauf nach erfolgreichem ersten → 0 Änderungen (alles bereits vorhanden).

### Was bringt playwright-cli?

Microsofts purpose-built CLI für Coding-Agents (token-effizient by design). Damit kannst du Claude beauftragen, Browser zu steuern, Screenshots/PDFs zu generieren, HTML-Slide-Decks zu verifizieren oder Webseiten zu analysieren, direkt aus dem Chat heraus. Die mitgelieferten Playwright-Skills landen in `~/.claude/skills/` und werden von Microsoft gepflegt (du musst nichts selbst bauen).

---

## Was macht es NICHT?

- Installiert **NICHT** Claude Code (das passiert im Pre-Call via `curl -fsSL https://claude.ai/install.sh | bash`)
- Setzt **NICHT** MCP-Connectors auf (Browser-OAuth via [claude.ai/settings/connectors](https://claude.ai/settings/connectors))
- Geht **NICHT** in andere Projekt-Ordner (z.B. `~/projects/...`), projekt-spezifische `CLAUDE.md`-Files in deinen anderen Repos bleiben unangetastet
- Ändert **NICHT** zsh-Config, PATH, Shell-Aliases
- **WARNUNG: Niemals `~/.claude.json` ins Repo committen**. Diese Datei enthält OAuth-Tokens und persönliche Auth-Daten. Sie liegt bewusst außerhalb von `~/.claude/` und wird von `.gitignore` abgedeckt.

---

## Was passiert mit meinen vorhandenen Files?

- **`~/.claude/CLAUDE.md` existiert:** wird mit Backup `.bak.<timestamp>` gesichert, dann mit Repo-Version überschrieben. Dein Custom-Inhalt steckt in der `.bak`-Datei und kann zurückgespielt werden.
- **`~/.claude/settings.json` existiert:** bleibt **vollständig unberührt**. Du erhältst nur einen Diff-Hinweis. Workshop-Hooks musst du manuell aus `settings.json.template` übernehmen.
- **Bestehender Obsidian-Vault** unter `~/Documents/Second-Brain/`: wird **nur ergänzt** mit PARA-Struktur. Bestehende Notizen, Dateien, Ordner bleiben unangetastet.
- **Custom Slash-Commands** unter `~/.claude/commands/` mit eigenen Namen (z.B. `my-cmd.md`): bleiben unberührt. Nur Files mit gleichen Namen wie Repo-Files werden mit Backup überschrieben.

Backup-Files findest du via:
```bash
ls ~/.claude/*.bak.* ~/.claude/**/*.bak.* 2>/dev/null
```

---

## Troubleshooting

Siehe [docs/troubleshooting.md](docs/troubleshooting.md) für:
- Quarantine-Attribut Probleme (ZIP statt git clone)
- `claude: command not found`
- Backup-Files wiederherstellen
- Vault unter anderem Pfad
- Hooks nicht aktiv
- `/remote-control` startet nicht (DISABLE_TELEMETRY)

---

## Repo-Struktur

```
ai-os-core/
├── mac/
│   ├── preflight.sh          # Read-only Voraussetzungs-Check macOS (Schritt 2)
│   └── bootstrap.sh          # Idempotenter Installer macOS (Schritt 4)
├── windows/
│   ├── setup.ps1             # PowerShell-Oneliner-Skript (Windows-Schritt 1)
│   ├── preflight.sh          # Read-only Voraussetzungs-Check Windows/Git Bash (Windows-Schritt 2)
│   ├── bootstrap.sh          # Idempotenter Installer Windows/Git Bash (Windows-Schritt 4)
│   └── claude/hooks/         # Overlay-Dateien (z.B. noderun.sh), legen sich nach claude/ über
├── README.md                 # Dieses Dokument
├── scripts/leak-scan.sh      # Leak-Scan vor dem Push (Mailadressen, Home-Pfade, Tokens, lokale Blockliste)
├── .gitignore                # Schützt .claude.json, .bak-Files, Logs, Dashboard-Runtime
├── claude/                   # Mappt zu ~/.claude/
│   ├── CLAUDE.md             # Globale Claude Code Instructions (nach ~/.claude/CLAUDE.md)
│   ├── settings.json.template # Stripped Settings (Template)
│   ├── rules/                # 2 Rule-Files (vault-workflow, security-basics), immer geladen
│   ├── rules-archive/        # On-Demand-Referenzen (security-code-quality, fullstack-patterns)
│   ├── bin/                  # Hilfsskripte nach ~/.claude/bin/ (vault-find.sh: Suche im Second Brain)
│   ├── agents/               # 2 Agenten (prompt-engineer, skill-designer; interne Worker)
│   ├── commands/brain/       # 4 Slash-Commands (Vault-Tooling, Doppelpunkt-Namespace /brain:*)
│   ├── mods/                 # Mods (Plugins mit Funktions-Hooks): session-assistent (Kontext-Band, To-do-Zahl, To-do-Bilanz, Knöpfe)
│   ├── skills/               # 9 Skills (skill-creator, wrap-up, new-project, designer, landing-page-builder, research-prompt, aios-dashboard, briefing, system-check), auto-invokable
│   ├── templates/            # Projekt-Templates (new-project: CLAUDE.md + STATE.md + TODO.md)
│   ├── use-cases/            # Fertige Use-Case-Bundles zum Ableiten in eigene Projekte (siehe unten)
│   ├── werkzeuge/            # Programme und Anbindungen für Claude (codex, google-workspace-cli, ffmpeg), Installation per „Sag Claude:" (siehe unten)
│   └── hooks/                # 8 Hook-Scripts (inkl. aios-statusline.js)
├── dashboard/                # Lokales Cockpit, wird via bootstrap nach ~/.claude/dashboard installiert
│   ├── INSTALL.md            # Betrieb + (manuelle) Installation
│   ├── check-prereqs.sh      # Read-only Voraussetzungs-Check fürs Dashboard
│   ├── server.mjs            # Node-Server (nur Built-ins), 127.0.0.1:4747
│   ├── public/               # Frontend (App-Shell + Views)
│   ├── collectors/           # Bash-Collectors (0 Tokens, schreiben data/*.json)
│   ├── actions.json          # Aktions-Katalog
│   └── data/                 # Collector-Ausgabe, bleibt bis zum ersten Lauf leer
│                             # (der /aios-dashboard-Skill liegt unter claude/skills/aios-dashboard/)
├── vault-skeleton/           # Mappt zu ~/Documents/Second-Brain/
│   ├── 00_Meta/
│   │   ├── Templates/        # 9 Obsidian-Templates
│   │   ├── vault-index.md    # Leer (Header only, /brain:sort-inbox befüllt)
│   │   ├── vault-log.md      # Append-only Chronik
│   │   └── themenliste.md.template  # feste Themenliste, Quelle der cluster/-Tags (kein Auto-Import)
│   ├── 01_Inbox/
│   ├── 02_Projects/
│   ├── 03_Areas/
│   ├── 04_Resources/         # Flach
│   ├── 05_Contacts/{People,Organizations}/
│   └── 06_Archive/
└── docs/
    ├── connector-setup.md        # MCP-Connector-Setup (Gmail/Calendar/Fathom)
    ├── routines.md               # Zeitgesteuerte Routines in der Desktop App
    ├── google-workspace-cli.md   # gws-CLI + Workspace-Skills
    ├── troubleshooting.md        # Bekannte Probleme + Lösungen (macOS)
    └── windows/
        ├── setup.md              # Windows-Setup, Langfassung
        └── troubleshooting.md    # Bekannte Windows-Probleme + Lösungen
```

### Use-Case-Bundles (`claude/use-cases/`)

Ein Use-Case-Bundle ist ein fertiges, in der Praxis erprobtes Paket aus README und einem oder mehreren Skills für eine konkrete wiederkehrende Aufgabe, gedacht zum Installieren statt zum Selberbauen. Für ADAN sind fünf Bundles vorbereitet:

- `content-publisher`: macht aus einer Idee oder einem Text in einem Lauf die Fassungen für LinkedIn, Instagram, Newsletter, Mail und Website (Deutsch und Englisch, im eigenen Ton je Marke) und auf Wunsch die passenden Social-Visuals (Instagram, Story, LinkedIn, Karussell) im Look von ADAN e.V., ADAN Impact oder ADAN Careers. Installation per `install.sh`.
- `motion-graphic`: baut aus einer Beschreibung ein kurzes animiertes Video für Social Media oder die Website (16:9 und 9:16). Installation per `install.sh`.
- `posteingang-triage`: sichtet neue Mails je Postfach und Einheit, ordnet sie als Verläufe den eigenen Labels zu (beim ersten Lauf im Gespräch festgelegt, Startsets für Verein, Pflegedienst sowie Vertrieb und Projekte), markiert Chancen und schlägt To-dos und Antwortentwürfe vor, dazu ein Rückblick auf Liegengebliebenes. Installation per `install.sh`.
- `kontakt-segmentierung`: Outreach-Pipeline vom LinkedIn-Kontaktexport bis zum Nachrichtenentwurf, für den Career Day oder jeden anderen Anlass. Sortiert Kontakte nach Rollen und Prioritäten (Excel-Datei), legt Firmenakten an, recherchiert die Firmen öffentlich und schreibt persönliche LinkedIn-Texte in Batches (Outlook-Entwurf nur je Kontakt nach Bestätigung), versendet nie selbst. Installation per `install.sh`.
- `beleg-ablage`: findet Rechnungen und Belege im Postfach, markiert die Mails, benennt die abgelegten PDFs einheitlich, sortiert sie nach Jahr und Monat, führt eine Übersicht und lädt sie auf Wunsch nach SharePoint hoch. Installation per `install.sh`.

Die Bundles kommen mit dem Download des Repos mit, werden vom Bootstrap aber **nicht automatisch installiert**. Installiert wird ein Bundle gezielt, wenn es gebraucht wird, bei `content-publisher`, `motion-graphic`, `kontakt-segmentierung`, `beleg-ablage` und `posteingang-triage` per `bash claude/use-cases/<bundle>/install.sh`. Am einfachsten sagst du Claude „installier mir den Use Case content-publisher".

Jedes Bundle-Verzeichnis enthält eine eigene `README.md` mit Voraussetzungen, Installations-Anleitung und (wo zutreffend) belegten Testergebnissen. Ein Bundle wird genutzt, indem sein `skills/`-Unterordner global nach `~/.claude/skills/` kopiert wird, damit es in jedem Projekt zur Verfügung steht, siehe die Anleitung in der jeweiligen Bundle-README.

### Werkzeuge (`claude/werkzeuge/`)

Ein Werkzeug ist ein Programm oder eine Anbindung, die Claude neue Fähigkeiten gibt oder die mehrere Use Cases brauchen. Installiert wird jedes Werkzeug gezielt über den Kasten „Sag Claude:" in seiner README, Claude holt dabei die aktuellste Version und prüft das Ergebnis (der Bootstrap installiert Werkzeuge nicht automatisch).

- `codex`: OpenAI Codex als zweiter Coding-Agent für Zweitmeinungen, Aufträge und Bilder, angemeldet über das ChatGPT-Konto.
- `google-workspace-cli`: Claude arbeitet direkt in Gmail, Kalender, Drive, Docs und Sheets.
- `ffmpeg`: verarbeitet Videos und Ton, Voraussetzung für den Use Case motion-graphic.

## Vor dem Push

Vor jedem Push `bash scripts/leak-scan.sh` laufen lassen, es prüft getrackte und ungetrackte Dateien auf Mailadressen, Home-Pfade und Token-Formate und bricht bei Treffern mit Exit 1 ab. Echte Namen von Teilnehmern und Kunden gehören in die lokale `.leak-blocklist` (gitignored, Vorlage `.leak-blocklist.example`), die das Skript zusätzlich prüft.

## Lizenz

Für Teilnehmer des AI Operating System Workshops. Nicht für Weiterverteilung ohne Erlaubnis.
