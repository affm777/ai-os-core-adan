# /brain:sort-inbox: Eingang des Second Brain aufräumen und Wissen einsortieren

Du bist ein Wissens-Kurator. Raeume die Inbox auf und sortiere Inhalte in die richtige Stelle im Vault ein.

## Voraussetzung

`00_Meta/system/vault-index.md` muss existieren (TSV-Index aller Vault-Dateien). Falls nicht: STOP, dem User `/brain:rebuild-index` empfehlen. Details zum Index in `~/.claude/rules/vault-workflow.md` (Abschnitt "Nachschlagen") und in Schritt 6.5.

## Delegation-Protocol

**Threshold:**
- < 10 Inbox-Files → alles im Hauptkontext.
- >= 10 → 1 `general-purpose` Sub-Agent fuer Schritte 3-7.
- >= 50 → mehrere Sub-Agents, Split nach Projekt.

**Hauptkontext (nicht delegierbar):** Schritt 1/1.5 (Scan), 2 (User-Questions), 6.9 (Rename/Delete-Confirmation), 8.5 (User-Interaktion), 9/10 (Log + Report).

**Delegiert:** Schritte 3 (Frontmatter), 4 (Extraktion), 5 (Linking), 6 (Move), 6.5 (Index-Patches), 6.8 (Team-Links), 7 (Wikilink-Audit).

**Sub-Agent-Return-Kontrakt:**
```
## Moved
- src-path → dst-path

## TSV-Patches
<block>

## Team-Links
- <steckbrief-path>: Team & Stakeholder -> <link-zeile>

## Parked
- <datei>: <grund> (topic_proposal=<slug>, wenn gesetzt)

## Open Questions
- <datei>: <unresolved wikilink / ambiguitaet>

## Frontmatter-Fixes
- <datei>: <fix>

## Errors
- <datei>: <grund>
```

Main buendelt TSV-Patches + Team-Links (1-2 Edits statt N), stellt Open Questions, fuehrt Schritte 6.9/8.5 interaktiv aus.

**Sub-Agent-Input:** Inbox-Dateiliste, Vault-Index-Snapshot (aus grep), bekannte Projekt-Slugs (`02_Projects/*/` + `03_Areas/*/`), Taxonomie-Regeln, Pfad der Themenliste (`00_Meta/themenliste.md`).

## Execution-Mode

- **on-demand** (User tippt `/brain:sort-inbox` interaktiv): alle Schritte wie beschrieben, Rueckfragen erlaubt.
- **scheduled** (Desktop-App Scheduled Task, keine User-Praesenz): autonom, keine Rueckfragen. Es gilt: **eindeutige Faelle einsortieren, alles andere parken.**

**Erkennungsregel:** `scheduled`-Mode aktiv, wenn (a) das Skill-Argument das Wort `scheduled` enthaelt ODER (b) der Prompt-Kontext den Scheduled-Run-Header enthaelt (`<scheduled-task ...>` bzw. "This is an automated run of a scheduled task" / "The user is not present"). Sonst on-demand.

**Scheduled-Regeln (Abweichungen von den Schritten unten):**

1. **Eindeutig** (wird einsortiert) heisst ALLE Bedingungen erfuellt:
   - kein `dedup_warning: true` im Frontmatter
   - gueltiger `type` aus der Taxonomie UND Ziel laut Einsortier-Tabelle klar bestimmbar
   - Zielordner existiert bereits (NIEMALS neue Projekt-/Area-Ordner, Themen oder MOCs anlegen)
   - bei `type: decision|learning` stehen Projekt (oder `scope/cross-project`) und mindestens ein Thema aus der Themenliste fest (Abschnitt „Themenliste")
   - kein Merge noetig (kein aehnlicher Titel in Inbox oder Vault laut TSV-Grep)
   - kein Loeschen, kein Rename noetig
2. **Alles andere wird geparkt:** Datei bleibt in der Inbox und bekommt im Frontmatter die Zeile `parked: "<Grund in einem Satz>"` (Abschnitt „Themenliste", Parken).
3. **Write-Boundary:** Writes nur innerhalb `~/Documents/Second-Brain/`.
   - **Schritt 8.5 (CLAUDE.md-Check) wird ÜBERSPRUNGEN**, er ist inhärent interaktiv (Diff-Vorschlag `[y/n/edit]`, menschliche Urteilsfrage). 8.5-Kandidaten stehen im Bericht unter „Hinweise".
4. **Schritt-Deltas:** Schritt 2 (Löschfragen) → nie löschen, parken. Schritt 2.5 (dedup_warning) → parken. Schritt 6.9 → keine Renames/Deletes. Schritt 7c (fehlende Zielseite) → Datei parken statt fragen. Schritte 6.5 (Index-Patch), 6.8 (Team-Links) und 7a/b (Wikilink-Audit) laufen normal für alle einsortierten Dateien.
5. **Parken ohne Bericht:** Der Grund steht an der Notiz (`parked`, bei fehlendem Thema zusätzlich `topic_proposal`). Ein gesonderter Park-Bericht wird nicht geschrieben und nicht gelesen. Eine Notiz, die schon `parked` trägt, wird im scheduled-Mode übersprungen, außer ihr `topic_proposal` steht inzwischen in der Themenliste (Prüfbefehl im Abschnitt „Themenliste").
6. **Vault-Log-Eintrag** (Schritt 9) mit Zusatz `scheduled`: `## [YYYY-MM-DD] sweep (scheduled) | N einsortiert, M geparkt (<gruende kurz>)`.

## Schritte

### 1. Inbox scannen
- Lies alle Dateien in `~/Documents/Second-Brain/01_Inbox/`
- Zeige eine Übersicht: Dateiname, Typ, Erstelldatum
- Erwartetes Dateiformat: `YYYY-MM-DD-[beschreibung].md`

### 1.5. Vault-Index pruefen (NICHT laden!)
- `00_Meta/system/vault-index.md` muss existieren. Wenn nicht: STOP, `/brain:rebuild-index` empfehlen.
- **Lade den Index NIE komplett in den Kontext.** Stattdessen: gezielte `grep`-Queries pro Lookup-Bedarf in den naechsten Schritten.
- Query-Muster:
  - Alias-Lookup: `grep -i "alias-text" 00_Meta/system/vault-index.md`
  - Topic-Lookup: `grep "topic-name" 00_Meta/system/vault-index.md`
  - Person-Lookup: `grep "	person	" 00_Meta/system/vault-index.md | grep -i "name"`
  - Projekt-Lookup: `grep "	project	" 00_Meta/system/vault-index.md`

### 2. Triage (mit Duplikat-Erkennung)
Pro Inbox-Datei:
- **Wertvoll:** weiterverarbeiten (Schritt 3-6).
- **Veraltet/irrelevant:** User fragen (loeschen oder archivieren).
- **Duplikat-Check:**
  - Inbox untereinander: aehnliche Titel, Person in anderer Schreibweise, gleiches Thema in mehreren Sessions → mergen.
  - Inbox gegen Vault via TSV-grep: `grep "	person	" 00_Meta/system/vault-index.md | grep -i "name"`, `grep "topic-x" 00_Meta/system/vault-index.md`.

Bei Unsicherheit IMMER User fragen (Namen, Personen, Decision-Ueberlappung). Keine eigenmaechtigen Merges.

### 2.5. Dedup-Warning-Guard (Meetings aus `/brain:sync-meetings`)

Meetings, die `/brain:sync-meetings` als **unklar** klassifiziert hat (gleicher Titel, leichte Zeit-/Scope-Differenz), kommen mit `dedup_warning: true` im Frontmatter und einem `> [!warning] Mögliches Duplikat`-Callout im Body in die Inbox (ältere Dateien: `Moegliches Duplikat`, beide Schreibweisen behandeln). Das ist der Punkt, an dem der User semantisch entscheiden muss.

**Pro Inbox-Datei mit `dedup_warning: true`:**

1. Kandidat-Referenz aus dem Callout extrahieren (`[[<basename>]]`).
2. Kandidat-Datei und Inbox-Datei dem User nebeneinander zeigen (Titel, Attendees, Zusammenfassung, max 30 Zeilen je Datei).
3. User fragen:
   ```
   Mögliches Duplikat: <neue Notiz> ↔ <vorhandene Notiz>
   [1] Ist dasselbe Meeting → neue Notiz löschen, vorhandene bleibt
   [2] Verschiedene Meetings → Warnung entfernen und normal einsortieren
   [3] Teilweise Überlappung → beide behalten, du führst sie vor dem Einsortieren zusammen
   ```
4. Handlung pro Antwort:
   - `[1]`: Inbox-File loeschen, Wikilink-Propagation mit `[1]`-Regel aus Schritt 6.9 (Delete), aus Rest-Sweep ausschliessen.
   - `[2]`: Im Inbox-Frontmatter `dedup_warning: false` setzen + Callout aus Body entfernen. Weiter mit Schritt 3.
   - `[3]`: Inbox-File zurueckstellen, User merged manuell. Im Report als `Manual merge pending` listen.

**Wichtig:** Solange `dedup_warning: true` ist, NICHT einsortieren (Schritt 6 ueberspringen). Das Flag ist ein harter Block bis User-Entscheidung.

### 3. Frontmatter pruefen und anreichern
- Pflichtfelder: title, created_date, type, status, tags, aliases
- Tags aus Taxonomie korrekt? Keine neuen Top-Level-Tags?
- Gueltige Typen: `decision`, `learning`, `concept`, `resource`, `session-log`, `meeting`, `person`, `organization`, `project`, `area`, `meta`
- **Verlinkung pruefen:** Personen nur via `[[Wikilinks]]` referenzieren (keine human/-Tags)
- Status von `draft` auf `done` setzen wenn fertig

### 4. Informations-Extraktion
- Meeting Note enthaelt Decision? Eigene Decision-Datei extrahieren
- Notiz enthaelt Learning? In bestehende Learning-Datei integrieren oder neue anlegen
- Neue Dateien immer zuerst in `01_Inbox/` schreiben (Vorlage aus `00_Meta/Templates/`) und danach in Schritt 6 per `mv` einsortieren. Ein direkter Write einer neuen Decision/Learning/Meeting-Datei in einen Zielordner wird vom Hook `vault-write-guard.sh` geblockt.
- Extrahierte Dateien zurueckverlinken: `Extrahiert aus: [[Quell-Notiz]]`

### 5. Semantisches Linking (via TSV)
- VOR jeder Verlinkung: `grep` im TSV-Index nach verwandten Dateien (Topic-Spalte)
- Zu passenden Hubs (Concepts, Index-Files) in `04_Resources/` verlinken
- Neue MOCs nur anlegen wenn 5+ Dateien ein Thema teilen

### 6. Einsortieren
**Bedingung für `decision` und `learning`:** Die Notiz verlässt `01_Inbox/` nur, wenn Titel, Typ, Projekt (`project/<slug>` oder `scope/cross-project`) und mindestens ein Thema (`cluster/<slug>`) feststehen. Thema prüfen und setzen nach Abschnitt „Themenliste". Fehlt eines davon, wird die Notiz geparkt statt bewegt.

| Typ | Ziel |
|-----|------|
| Decision | `02_Projects/[slug]/` oder `03_Areas/[slug]/` |
| Learning | `04_Resources/` (bestehende Datei ergaenzen wenn Topic-Match) |
| Meeting Note | `02_Projects/[slug]/` (wenn Projekt aktiv) oder `03_Areas/[slug]/` |
| Session Log | `02_Projects/[slug]/` |
| Concept/Evergreen | `04_Resources/` |
| Person | `05_Contacts/People/` |
| Organization | `05_Contacts/Organizations/` |

**Projekt-Feld:** Hat eine Notiz Projektbezug (Ziel `02_Projects/<slug>/` oder `03_Areas/<slug>/`, oder Tag `project/<slug>`) und fehlt `project` im Frontmatter, wird es gesetzt: Zeile `project: "[[<slug>]]"` direkt nach `status:` (Slug des Ziels bzw. des Tags, bei zwei Projekten als YAML-Liste mit zwei Zeilen `  - "[[slug]]"`). Ein vorhandenes Feld bleibt unverändert. Notizen ohne Projekt (nur `scope/cross-project`) bekommen das Feld nicht. Der Steckbrief listet seine Notizen nicht auf, die Verbindung kommt allein aus diesem Feld.

Zum Bewegen `mv` nutzen, nicht Read+Write+Delete.

### 6.5. Vault-Index inkrementell patchen
Fuer jede in Schritt 6 bewegte/neu angelegte/geloeschte Datei: `00_Meta/system/vault-index.md` gezielt updaten.

- **Neue Datei:** TSV-Zeile in den Code-Block appendieren mit Spalten `path	title	type	tags	aliases	topics	updated` (wie `/brain:rebuild-index`: `tags` space-separiert, `aliases` und `topics` `|`-getrennt, leer als `-`). `topics` wird nicht frei vergeben, sondern aus den `cluster/`-Tags der Notiz abgelesen (Slugs ohne `cluster/`, `|`-getrennt, `-` wenn keine, etwa bei anderen Typen).
- **Verschobene Datei:** Bestehende Zeile finden (`grep`), `path`-Spalte updaten via `Edit`.
- **Geloeschte Datei:** Zeile aus dem TSV entfernen.
- **Entity-Page mit neuen Backlinks:** wenn die Entity neue Aliases bekommt, aliases-Spalte updaten.
- Im Frontmatter: `updated:` auf heute, `file_count:` neu zaehlen.

### 6.8. Team-Links (Personen und Organisationen)
Decisions, Learnings, Concepts, Session-Logs, Meetings und Resources werden nicht im Steckbrief gelistet, ihre Verbindung kommt aus dem Feld `project` (Schritt 6). Schritt 6.8 gilt nur für einsortierte Personen- und Organisationsnotizen: via TSV-Topic-Lookup (`grep "topic-x" 00_Meta/system/vault-index.md | grep "	project\|	area	"`) die zugehörigen Projekt- oder Area-Steckbriefe finden, den Steckbrief lesen und den Link im Abschnitt `## Team & Stakeholder` ergänzen, falls er fehlt.

- **Link-Format:** `- [[basename|title]]`, Rolle in Klammern nur wenn bekannt. Kein Gedankenstrich, die globale Schreibregel gilt auch hier.
- **Limit:** max **5 verschiedene Steckbriefe** pro Inbox-Datei (Token-Cap).
- Im Bericht erwähnen: "2 Steckbriefe um Team-Links ergänzt"

### 6.9. Rename/Delete-Propagation
Wenn der Sweep eine Datei umbenennt oder loescht, muessen vault-weite Referenzen mitgezogen werden, sonst entstehen broken Wikilinks.

**Rename** (Basename-Aenderung):
1. `grep -rl "\[\[alter-basename" ~/Documents/Second-Brain/ --include="*.md"` findet Referenzen
2. Pro Trefferdatei: `Edit` mit `replace_all: true` auf `[[alter-basename]]` → `[[neuer-basename]]` und `[[alter-basename|` → `[[neuer-basename|`
3. TSV-Index `path`-Spalte updaten
4. Im Bericht: "Renamed X → Y, Z Wikilinks updated in N files"

**Delete**:
1. `grep -rl "\[\[basename" ~/Documents/Second-Brain/ --include="*.md"` findet Referenzen
2. Pro Trefferdatei: User fragen „Link auf die gelöschte Notiz `basename` in `pfad/datei.md` entfernen oder als Fließtext stehen lassen?". Default-Vorschlag: auf Hub-Pages (`type: project|area`) entfernen, auf Content-Files (Sessions/Meetings) als Fließtext stehen lassen (Anzeige-Text behalten, `[[]]` entfernen).
3. TSV-Zeile entfernen
4. Im Bericht: "Deleted X, Z Wikilinks resolved in N files"

**Token-Budget:** grep ist billig, Edits nur auf Trefferdateien. Typisch 0-5 Edits pro Rename/Delete.

### 7. Wikilink-Audit (PFLICHT, nach Einsortieren)
Alle in dieser Session verarbeiteten Dateien systematisch pruefen:

a) **Wikilinks extrahieren:** `grep -oh "\[\[[^]]*\]\]"` pro Datei
b) **Gegen TSV-Index abgleichen:** Fuer jeden Link `grep` in `vault-index.md` auf `path` (Dateiname ohne .md), `title`, `aliases`-Spalte
   - Code-Block-Beispiele in Backticks ignorieren
   - Template-Platzhalter ignorieren
c) **Unresolved Links fixen:**
   - Tippfehler: korrekten Dateinamen/Alias ermitteln, Pipe-Syntax verwenden
   - Fehlende Zielseite: User fragen „Soll ich [Seite] anlegen oder den Link als Fließtext schreiben?"
   - NIEMALS einen Link stehen lassen der ins Nirgendwo fuehrt
d) **Stub-Cleanup:** Inbox auf leere .md Dateien pruefen und loeschen

### 8. Drift-Check
Wenn waehrend des Sweeps ein TSV-Eintrag aufgetaucht ist, dessen Datei auf Disk nicht existiert (oder umgekehrt): Drift-Warnung im Bericht ausgeben und `/brain:rebuild-index` empfehlen.

### 8.5. CLAUDE.md-Implikations-Check

Fuer jede im Sweep verarbeitete Datei mit `type: decision|learning` + `project/<slug>`-Tag: pruefen ob die Erkenntnis als dauerhafte Instruction in CLAUDE.md gehoert.

1. Projekt-Repo via `~/.claude/project-repos.yaml` (oder User-Frage bei erstem Auftreten).
2. `<repo>/CLAUDE.md` lesen. Falls Tag `scope/cross-project`: zusaetzlich `~/.claude/CLAUDE.md`.
3. Einstufen:
   - **JA-Signale:** "Immer X bei Y", "Niemals X", "Default X = Y", "Wenn X dann Y", wiederkehrendes Pattern.
   - **NEIN-Signale:** einmalige Entscheidung (Name, Farbe, Zahl), Kontext-Notiz, Ad-hoc-Beschluss.
4. Bei JA: `grep` Ziel-CLAUDE.md auf Keywords → wenn schon drin: skip. Sonst Diff-Vorschlag an User:
   ```
   Decision „<Titel>" könnte als feste Anweisung in die Anleitung für Claude (<projekt>/CLAUDE.md).
   + <konkrete Zeile>
   Übernehmen? [y/n/edit]
   ```
   Bei `y`/`edit`: Edit anwenden, Vault-Datei bleibt (Audit-Trail). Bei `n`: skip.
5. Max 3 Vorschlaege pro Sweep. Weitere im Report listen.

### 9. Vault-Log Eintrag
Append an `00_Meta/system/vault-log.md`:
```
## [YYYY-MM-DD] sweep | N files ingested ([projekt: X, projekt: Y, ...]), M merges, K extracted, L drift-warnings
```

### 10. Bericht
```
**Second Brain einsortiert.**
- Einsortiert: [Anzahl] Notizen ([Typ: Titel → Projekt/Bereich], je Notiz eine Zeile)
- Neu herausgezogen: [Anzahl] Decisions, [Anzahl] Learnings
- Ergänzt statt neu angelegt: [Liste] (oder „nichts")
- Projekten zugeordnet: [Liste], Team-Links ergänzt: [Liste]
- Gelöscht: [Anzahl] (veraltet oder doppelt)
- Links geprüft: [Anzahl], [Anzahl] repariert
- Bleibt im Eingang: [Anzahl] Notizen ([Grund], oder „Eingang leer")
- Themenvorschläge: [Slug (Anzahl Notizen)] (oder „keine")
- Hinweise: [Drift-Warnung mit Empfehlung /brain:rebuild-index, im scheduled-Mode übersprungene CLAUDE.md-Kandidaten] (oder weglassen)
```
Zeilen ohne Ergebnis mit „nichts" ausgeben statt weglassen. Index-Patches, Vault-Log und Wikilink-Details nur auf Nachfrage nennen. Interne Begriffe (Inbox, STATE.md, Vault-Log, Frontmatter) nicht in den Bericht.

## Regeln
- NIEMALS neue Top-Level-Tags erfinden (nur aus definierter Taxonomie)
- IMMER Grep auf den TSV-Index VOR Verlinkung (Search Before Link)
- Personen nur via `[[Wikilinks]]` referenzieren (keine human/-Tags)
- Flache YAML-Strukturen
- Hub-and-Spoke: Primaer zu MOCs verlinken, nicht kreuz und quer
- User fragen bevor Dateien geloescht werden
- Tags im Frontmatter IMMER OHNE `#` (das `#` ist NUR fuer Inline-Markdown)
- **Index-Patch nicht vergessen** in Schritt 6.5, sonst veraltet der Index
- **Vault-Log nicht vergessen** in Schritt 9

## Themenliste

Themen ordnen Decisions und Learnings projektübergreifend. Die feste Liste steht in `00_Meta/themenliste.md`, die Slugs stehen dort in Backticks in der ersten Tabellenspalte.

**Thema ist Pflicht**
- Eine Notiz vom Typ `decision` oder `learning` verlässt `01_Inbox/` nur, wenn Titel, Typ, Projekt (`project/<slug>` oder `scope/cross-project`) und mindestens ein Thema feststehen. Andere Typen brauchen kein Thema.
- Themen stehen als Tag `cluster/<slug>` an der Notiz, ein bis zwei je Notiz, ausschließlich aus der Themenliste.
- Projektnamen sind kein Thema (dafür gibt es `project/<slug>`), `common-gotchas` gibt es nicht mehr.
- Ein schon gesetzter `cluster/`-Tag wird genauso geprüft. Steht er in der Liste, bleibt er. Steht er nicht drin, zählt er nicht als Thema.
- Die Index-Spalte `topics` wird aus den `cluster/`-Tags abgelesen (Schritt 6.5), nie frei vergeben.

**Prüfung per Befehl**

Vor dem Setzen eines Themas prüfen, ob der Slug in der Liste steht:
```bash
grep -c "^| \`<slug>\` |" ~/Documents/Second-Brain/00_Meta/themenliste.md
```
Ergebnis `1` heißt setzen. Ergebnis `0` heißt, der Slug wird nicht gesetzt.

**Parken (der Eingang ist der Parkplatz)**
- Kann eine Notiz nicht einsortiert werden (kein passendes Thema, Widerspruch, Dublette, Projekt unklar), bleibt sie in `01_Inbox/` und bekommt im Frontmatter die Zeile `parked: "<Grund in einem Satz>"`.
- Passt kein Thema der Liste, kommt zusätzlich `topic_proposal: <slug>` dazu (ein Vorschlag für ein neues Thema, lowercase, mit Bindestrich). Trägt eine andere geparkte Notiz schon einen passenden Vorschlag (`grep -h "^topic_proposal:" ~/Documents/Second-Brain/01_Inbox/*.md`), denselben Slug verwenden.
- Ein neues Thema wird nie eigenständig angelegt. Der `/wrap-up` nennt die geparkten Notizen und die Vorschläge in einem Satz, der Nutzer entscheidet. Im interaktiven Lauf darf sort-inbox die Frage direkt stellen.
- Sagt er Ja, wird der Slug mit einer Zeile Definition als Tabellenzeile in die Themenliste aufgenommen. Beim nächsten Lauf werden die Notizen einsortiert, dabei werden `parked` und `topic_proposal` wieder entfernt.
- Einen gesonderten Park-Bericht gibt es nicht, der Grund steht an der Notiz.

**Zusammenlegen und Streichen**

Nur als Vorschlag über `/brain:health-check` (Themen mit unter fünf Einträgen sind Kandidaten), nie eigenständig.
