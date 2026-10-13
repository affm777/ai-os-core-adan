---
name: new-project
description: Setzt ein neues Projekt, eine Area oder ein laufendes Thema schlank auf, mit CLAUDE.md, .planning/STATE.md, .planning/TODO.md, Vault-Notiz und project-repos.yaml-Eintrag in einem Rutsch. Nutze diesen Skill IMMER wenn der User ein neues Vorhaben startet, eine neue Area anlegt oder ein laufendes Thema strukturieren will, auch ohne das Wort "Projekt", z.B. bei "ich starte was Neues", "ich hab da was Neues vor", "leg das mal an", "lass uns das aufsetzen", "ich brauch eine Struktur dafuer", "wo soll ich das ablegen". Auto-invoke besonders wenn der User in einem Ordner arbeitet der noch keine CLAUDE.md hat und ueber laengere Arbeit am Thema spricht.
when_to_use: |
  Trigger-Phrasen: "neues Projekt aufsetzen", "neue Area", "neues Thema starten", "leg ein Projekt an", "ich starte was Neues", "ich brauch Struktur für X", "lass uns das aufsetzen", "Projekt-Skeleton bauen", "/new-project". Annahme: User ist im richtigen Projekt-Ordner (CWD = Projekt-Stamm).
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion, Bash(mkdir:*), Bash(grep:*), Bash(ls:*), Bash(date:*), Bash(pwd:*)
---

# Neues Projekt schlank aufsetzen

Minimum Viable Setup: **CLAUDE.md (Root), `.planning/STATE.md`, `.planning/TODO.md`, Vault-Notiz, project-repos.yaml-Eintrag**. Kein PROJECT.md, kein Roadmap, kein config.json. Funktioniert fuer Projekte mit Enddatum, Areas ohne Enddatum, Client-Arbeit und laufende Themen.

**Annahme:** Wer diesen Skill ausfuehrt, ist im richtigen Projekt-Ordner (CWD = Projekt-Stamm). Wer kein Projekt-Verzeichnis will, nutzt den Skill nicht und legt Notizen direkt im Vault an.

## Flow

```
Banner → Phase 0 (Existing-Files-Check) → Phase 0.5 (Kontext optional)
  → Phase 0.7 (Pfad-Wahl) → Phase 1 (pfadspezifische Luecken)
  → Phase 2 (Write) → Phase 3 (Report)
```

### Banner

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 NEUES PROJEKT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Ich setze die Grundstruktur für dein neues Projekt auf:
- Eine Anleitung für Claude: wie es bei diesem Projekt
  arbeiten soll
- Den Projektstatus: wo das Projekt steht und wo du beim
  nächsten Mal weitermachst
- Die To-do-Liste: was noch offen ist
- Eine Projekt-Notiz im Second Brain: das langfristige
  Gedächtnis dieses Projekts
- Einen Eintrag in der Projekt-Liste, damit Aufgaben aus
  Meetings in der To-do-Liste landen

Projekt-Ordner: [CWD]
```

### Phase 0: Existing-Files-Check

Pruefen ob `CLAUDE.md`, `.planning/STATE.md` oder `.planning/TODO.md` im CWD existieren. Wenn ja:

```
AskUserQuestion:
  header: "Schon angelegt"
  question: "In diesem Ordner gibt es bereits [Anleitung für Claude | Projektstatus | To-do-Liste]. Wie weiter?"
  options:
    - label: "Abbrechen"
      description: "Nichts ändern. Du kannst direkt weiterarbeiten."
    - label: "Neu überschreiben"
      description: "Bestehendes durch ein frisches Setup ersetzen. Ich frage vorher noch einmal mit Liste nach."
    - label: "Nur fehlende Teile"
      description: "Bestehendes bleibt, nur Fehlendes wird angelegt."
```

Bei "Neu überschreiben": vor Phase 2 noch einmal klartext confirmen mit Liste der betroffenen Dateien.

### Phase 0.5: Kontext-Slot (optional)

```
AskUserQuestion:
  header: "Kontext"
  question: "Willst du erst Kontext teilen (Unterlagen, Briefings, Notizen), oder direkt zu den Fragen?"
  options:
    - label: "Kontext zuerst teilen (Recommended)"
      description: "Texte, Briefings, Links reinkippen. Ich extrahiere Felder automatisch und frage nur nach Luecken."
    - label: "Direkt zu den Fragen"
      description: "6 gezielte Fragen, kein Freeform-Slot."
```

**Wenn "Kontext zuerst teilen":**

> "Wirf rein was du hast, Text, Briefing, Links, Notizen, Ausschnitte. Schreib 'weiter' oder 'fertig' wenn du durch bist."

Aus dem Input diese Felder extrahieren (wenn ableitbar):
- Name → Slug
- Kurzbeschreibung (1-2 Saetze)
- Typ (Venture / Client / Internal / Area)
- Sprache
- Typ-Detail (Angebot / Dienstleistung / Ziel / Thema)

In Phase 1 nur die fehlenden Felder erfragen.

### Phase 0.7: Pfad-Wahl

Genau eine AskUserQuestion VOR allen anderen Lücken-Fragen. Die Antwort steuert allein die Second-Brain-Ablage (`02_Projects` vs `03_Areas`) und wie viele Lücken-Fragen folgen.

```
AskUserQuestion:
  header: "Vorhaben"
  question: "Was legen wir an?"
  options:
    - label: "Projekt mit Ziel und Enddatum"
      description: "Venture, Client-Auftrag oder internes Projekt. Landet unter
                    02_Projects im Second Brain (Projekte mit Enddatum)."
    - label: "Laufende Area / laufendes Thema"
      description: "Recherche, Community, Ongoing Ops, kein Enddatum. Landet
                    unter 03_Areas (laufende Verantwortungen)."
```

Routing:
- "Projekt mit Ziel und Enddatum" → **PATH_A**
- "Laufende Area..."              → **PATH_B** (Typ ist hart `Area`)

Felder, die in Phase 0.5 bereits aus Kontext extrahiert wurden, NICHT erneut fragen.

### Phase 1: Pfadspezifische Lücken-Fragen

#### PATH_A: Projekt mit Enddatum

| # | Frage | Modus |
|---|---|---|
| 1 | "Wie heisst das Projekt?" | freeform |
| 2 | "Beschreib in 1-2 Saetzen worum es geht." | freeform |
| 3 | "Welcher Sub-Typ passt?" | AskUserQuestion, 3 Options |
| 4 | "Sprache?" | AskUserQuestion, 3 Options |

**Frage 3 Options:**
- **Venture**: Eigenes Produkt, Service, Firma aufbauen
- **Client**: Dienstleistung fuer externen Kunden
- **Internal**: Internes Projekt mit Enddatum (Steuern, Marketing, Ops)

**Frage 4 Options:** Deutsch / Englisch / Gemischt.

Kein Typ-spezifischer Follow-up.

`TYP_DETAIL_LINE` = leer (kein Detail-Satz)
`VAULT_FOLDER` = `02_Projects`

#### PATH_B: Laufendes Thema / Area

| # | Frage | Modus |
|---|---|---|
| 1 | "Wie heisst die Area?" | freeform |
| 2 | "Beschreib in 1-2 Saetzen worum es geht." | freeform |
| 3 | "Sprache?" | AskUserQuestion, 3 Options |
| 4 | "Welches Thema deckt das ab?" | freeform |

`Typ` = `Area` (hart, nicht abfragen)
`TYP_DETAIL_LINE` = `**Thema:** {{Antwort Frage 4}}`
`VAULT_FOLDER` = `03_Areas`, Frontmatter `type: area`, `status: ongoing`

### Phase 2: Write

1. **CLAUDE.md im Root** erstellen:
   - `Read ~/.claude/templates/new-project/CLAUDE.md.template`
   - Platzhalter ersetzen: `{{PROJEKTNAME}}`, `{{KURZBESCHREIBUNG}}`, `{{TYP_DETAIL_LINE}}`, `{{SLUG}}`, `{{VAULT_FOLDER}}`, `{{SPRACHE}}`
   - `Write CWD/CLAUDE.md`
   - `TYP_DETAIL_LINE` Beispiele: `**Auftraggeber:** Kunde (anonymisiert)` oder `**Thema:** AI-Coding-Community` (leer lassen wenn kein Detail)
   - `VAULT_FOLDER` = `02_Projects` (Venture/Client/Internal) oder `03_Areas` (Area)

2. **.planning/STATE.md** erstellen:
   - `mkdir -p CWD/.planning`
   - `Read ~/.claude/templates/new-project/STATE.md.template`
   - Platzhalter ersetzen: `{{PROJEKTNAME}}`, `{{KURZBESCHREIBUNG}}`, `{{TYP}}`, `{{HEUTE}}` (alle Vorkommen)
   - `Write CWD/.planning/STATE.md`
   - Keine Todo-Zeilen in die STATE.md schreiben, die gehören in die TODO.md (Schritt 2a).

2a. **.planning/TODO.md** erstellen (im selben Verzeichnis wie die STATE.md):
   - `Read ~/.claude/templates/new-project/TODO.md.template`
   - Platzhalter ersetzen: `{{PROJEKTNAME}}`
   - Erste Todos aus dem Kontext-Slot (falls genannt) als `- [ ]`-Zeilen (eine Zeile, höchstens 140 Zeichen, Frist als `(bis TT.MM.)` am Zeilenende) unter passende `## <Strang>`-Cluster, sonst Template-Default belassen
   - `Write CWD/.planning/TODO.md`

3. **Vault-Notiz** erstellen:
   - `mkdir -p ~/Documents/Second-Brain/{{VAULT_FOLDER}}/{{SLUG}}`
   - `Read ~/Documents/Second-Brain/00_Meta/Templates/Project.md`
   - Platzhalter ersetzen:
     - `{{title}}` → Projektname
     - `{{date:YYYY-MM-DD}}` → Heute
     - `SLUG-HIER` → Slug
     - `type: project` → `type: project` (Venture/Client/Internal) oder `type: area` (Area)
     - `type/project` → `type/project` oder `type/area` (Area, Tag passend zum `type`)
     - `status: in-progress` → `in-progress` oder `ongoing` (Area)
     - `area/business` → `area/business` (Business-Typ) oder `area/engineering` (Tech-Typ), Default `business`
     - `[2-3 Saetze]` → Kurzbeschreibung
     - `[[Person]], Rolle` → Team aus Kontext-Slot, sonst entfernen oder leer lassen
     - `[Wo steht das Projekt?]` → "Frisch aufgesetzt am {{HEUTE}}"
     - `~/Desktop/projects/PROJEKTORDNER` → CWD-Pfad oder "reines Vault-Projekt"
   - `Write ~/Documents/Second-Brain/{{VAULT_FOLDER}}/{{SLUG}}/{{SLUG}}.md`

3a. **Vault-Index nachziehen** (die Projekt-Notiz liegt nicht in `01_Inbox/`, `/brain:sort-inbox` sieht sie deshalb nie):
   - `grep -c "^{{VAULT_FOLDER}}/{{SLUG}}/{{SLUG}}.md" ~/Documents/Second-Brain/00_Meta/system/vault-index.md` als Dup-Check
   - Sonst per `Edit` eine Zeile am Ende des TSV-Blocks ergänzen (vor der schließenden ```-Zeile): `{{VAULT_FOLDER}}/{{SLUG}}/{{SLUG}}.md<TAB>{{PROJEKTNAME}}<TAB>project|area<TAB>type/project|type/area project/{{SLUG}} area/business<TAB>-<TAB>-<TAB>{{HEUTE}}` (Tags space-separiert, Typ und `type/`-Tag wie im Frontmatter)

4. **project-repos.yaml** (immer):
   - Prüfen ob `~/.claude/project-repos.yaml` existiert. Wenn nein: anlegen mit folgendem Header-Kommentar (wörtlich, mit echten Umlauten):
     ```
     # Source of Truth für das Mapping Projekt-Slug -> Repo-Pfad.
     # Einzige Pflegestelle: bei jedem neuen Projekt hier eine Zeile ergänzen.
     # Format: {{slug}}: {{pfad}}  (ein Eintrag pro Zeile, siehe unten)
     ```
   - Grep auf `^{{SLUG}}:` → Dup-Check. Wenn schon drin: skip, warnen.
   - Sonst: Append-Zeile `{{SLUG}}: {{CWD}}` ans Ende.
   - **Pfadformat (PFLICHT):** `{{CWD}}` wird immer als nativer Forward-Slash-Pfad geschrieben, nie als Backslash-Pfad, nie im MSYS-Format (`/c/Users/...`), nie mit `~`. Unter Windows/Git Bash: `cygpath -m "$PWD"` verwenden (ergibt z. B. `C:/Users/...`). Sonst (macOS/Linux): `$PWD` direkt.

### Phase 3: Confirmation Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PROJEKT AUFGESETZT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{{PROJEKTNAME}}
Tag: project/{{SLUG}}
Typ: {{TYP}}

| Was          | Wo                                  |
|--------------|-------------------------------------|
| Anleitung für Claude | [CWD]/CLAUDE.md                     |
| Projektstatus | [CWD]/.planning/STATE.md            |
| To-do-Liste | [CWD]/.planning/TODO.md             |
| Projekt-Notiz im Second Brain | ~/Documents/Second-Brain/{{VAULT_FOLDER}}/{{SLUG}}/{{SLUG}}.md |
| Meeting-Aufgaben landen hier | [eingetragen | schon vorhanden]   |

───────────────────────────────────────────────────────
```

## Regeln

- **Frage-Wording business-tauglich.** Erklaere die Wirkung fuer den User, nicht die technische Aktion. Verwende "Projekt-Ordner" statt "Code-Repo"/"CWD"/"Repository", "Projekt-Notiz im Second Brain" statt "Vault-Notiz", "Projektstatus" statt "STATE.md", "To-do-Liste" statt "TODO.md", "Eintrag in der Projekt-Liste" statt "yaml-Eintrag", "Anleitung für Claude" statt "CLAUDE.md im Root". Kein Jargon in User-facing Strings (Banner, Fragen, Optionen, Beschreibungen, Reports).
- **Slug-Ableitung:** lowercase, Umlaute ersetzen (ae/oe/ue/ss), Leerzeichen und Unterstriche zu Bindestrichen, Sonderzeichen raus.
- **Area-Tag im Vault-Frontmatter:** `area/business` Default, `area/engineering` nur wenn Typ-Detail klar technisch (Software, Dev-Tool, Infra, etc.).
- **Frontmatter-Tags OHNE `#`** im YAML-Block (nur Inline-Markdown nutzt `#`).
- **Freeform-Extraktion aus Phase 0.5:** so viele Felder wie moeglich ableiten, nicht erneut fragen. Bei Unsicherheit (z.B. Typ nicht klar ableitbar): lieber nachfragen als falsch setzen.
- **Ueberschreiben-Option in Phase 0:** erfordert explizite zweite Confirm-Zeile mit Datei-Liste.
- **Abbruch jederzeit:** User kann "skip", "spaeter" oder "weiter" sagen. Fehlende Felder werden `[TODO]`.
- **Neue Vault-Notiz** kommt über Schritt 3a direkt in `00_Meta/system/vault-index.md`. `/brain:sort-inbox` verarbeitet nur `01_Inbox/` und nimmt sie nicht auf. Kein manueller Reindex.

## Templates

- `~/.claude/templates/new-project/CLAUDE.md.template`
- `~/.claude/templates/new-project/STATE.md.template`
- `~/.claude/templates/new-project/TODO.md.template`
- `~/Documents/Second-Brain/00_Meta/Templates/Project.md` (existierend, wird wiederverwendet)
