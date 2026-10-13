# /brain:health-check: Second Brain prüfen, mit interaktivem Fix

Du fuehrst einen Health-Check des Vaults durch, schreibst einen Report, und bietest dann interaktiv an, die gefundenen Issues zu fixen. UX-Muster analog zu `/wrap-up`: erst zeigen was gefunden wurde, dann pro Kategorie auf Go warten, dann Aenderungen ausfuehren.

**Execution-Mode:** Enthaelt das Skill-Argument `scheduled` (oder der Prompt-Kontext den Scheduled-Run-Header `<scheduled-task ...>` / "This is an automated run of a scheduled task"), laeuft NUR die Report-Phase: Report nach `00_Meta/system/lint-reports/` schreiben, Vault-Log-Eintrag, dann ENDE. Keine Fix-Phase, keine Rueckfragen, keine Writes ausser Report + Vault-Log.

## Voraussetzung

`00_Meta/system/vault-index.md` muss existieren und aktuell sein. Falls Drift-Verdacht: zuerst `/brain:rebuild-index` empfehlen.

## Checks

Fuehre alle Checks via `grep` und gezielte Sub-Agent-Reads aus, NIE den ganzen Vault in den Kontext laden.

### 1. Orphans (Dateien ohne eingehende Links)

- Fuer jede Datei im Index (ausser MOCs und Meta-Dateien): pruefe ob es vault-weit irgendwo `[[dateiname]]` oder `[[alias]]` gibt
- `grep -r "\[\[<filename-without-md>" ~/Documents/Second-Brain/ -l` pro Kandidat (Sub-Agent-Job, Batches)
- Notizen mit Tag `project/<slug>` werden nicht über eingehende Links geprüft (Steckbriefe listen ihre Notizen nicht mehr auf). Prüfung für sie: Die Notiz trägt das Feld `project` mit Wikilink auf den Steckbrief. Fehlt es, ist sie ein Befund.
- Orphans listen, aber KEIN Auto-Delete

### 2. Broken Wikilinks

- `grep -roh "\[\[[^]]*\]\]" ~/Documents/Second-Brain/ --include="*.md"` extrahiert alle Wikilinks
- Fuer jeden Link: pruefe ob das Ziel als `path`, `title` oder in der `aliases`-Spalte des TSV-Index existiert
- Code-Block-Beispiele (in Backticks) und Template-Platzhalter ausschliessen
- Liste der toten Links + Quell-Datei

### 3. Stale Decisions

- `grep "	decision	" 00_Meta/system/vault-index.md` plus Frontmatter-Check auf `validity: active` und `updated` aelter als 90 Tage
- Liste der Stale-Kandidaten zur User-Review

### 4. Missing Cross-Refs

- Topics-Spalte im TSV gruppieren: Dateien mit gleichem Topic sammeln
- Pro Topic-Gruppe: pruefen ob die Dateien sich gegenseitig verlinken (`grep` auf Wikilinks)
- Fehlende Links als Vorschlaege ausgeben

### 5. Contradictions

- Decisions zum gleichen Topic finden (Topics-Spalte gruppieren)
- Sub-Agent: lies die Entscheidungs-Texte und pruefe auf Widersprueche
- Verdachtsfaelle listen, KEIN Auto-Fix

### 6. Index-Drift

- TSV-Eintraege gegen `find` auf Disk abgleichen
- Index-Eintrag ohne Datei → "Datei wurde ausserhalb /brain:sort-inbox geloescht"
- Datei ohne Index-Eintrag → "Datei wurde ausserhalb /brain:sort-inbox angelegt"
- Bei Drift: `/brain:rebuild-index` empfehlen

### 7. Projekt-Repos-Drift (YAML ↔ Vault)

Pruefe `~/.claude/project-repos.yaml` gegen die Vault-Projekt-Hubs. Drei Drift-Arten:

Projekt-Hubs liegen unter `02_Projects/<slug>/<slug>.md` (Projekte) ODER `03_Areas/<slug>/<slug>.md` (Areas). Beide Orte zählen, ein Hub in `03_Areas/` ist kein Drift.

- **YAML-Eintrag ohne Vault-Hub**: `<slug>` steht in YAML, aber weder `02_Projects/<slug>/<slug>.md` noch `03_Areas/<slug>/<slug>.md` existiert → Hub-Anlage-Vorschlag
- **Vault-Hub ohne YAML-Eintrag**: Datei `02_Projects/<slug>/<slug>.md` oder `03_Areas/<slug>/<slug>.md` existiert, aber `<slug>:` fehlt in YAML → YAML-Eintrag-Vorschlag (User muss Repo-Pfad liefern, oder explizit "kein Repo" sagen)
- **YAML-Pfad existiert nicht auf Disk**: `<slug>: <path>` zeigt auf nicht-existenten Ordner → Pfad-Korrektur oder Zeile entfernen

Wenn `project-repos.yaml` gar nicht existiert: Check ueberspringen, nicht als Fehler werten.

### 8. Themen (nur Meldung)

- Slugs aus `00_Meta/themenliste.md` lesen (in Backticks, erste Tabellenspalte).
- Je Slug die Decisions und Learnings im Index zählen (Spalte `type` ist `decision` oder `learning`, Slug steht in der Spalte `topics`), per `awk -F'\t'` auf dem TSV.
- Themen mit weniger als fünf Einträgen als Kandidaten zum Zusammenlegen melden, jeweils mit Anzahl.
- `cluster/`-Tags aus der Spalte `tags`, deren Slug nicht in der Themenliste steht, mit Datei melden.
- Nur melden. Zusammenlegen oder Streichen eines Themas und jede Änderung an Tags oder Themenliste erst nach Bestätigung des Nutzers.

### 9. Projekt-Lifecycle (nur Meldung)

Prüfe die Steckbriefe unter `02_Projects/<slug>/<slug>.md` und `03_Areas/<slug>/<slug>.md` (Frontmatter und Abschnitt zum aktuellen Stand, per Sub-Agent), ob sich die Natur des Vorhabens geändert hat:

- Projekt abgeschlossen (`status: done` oder `archived`): Verschiebung nach `06_Archive/` vorschlagen.
- Projekt ohne Enddatum, das dauerhaft weiterläuft: Verschiebung nach `03_Areas/` vorschlagen.
- Area mit neuem konkreten Ziel und Enddatum: Verschiebung nach `02_Projects/` vorschlagen.

Nur vorschlagen, nie selbst verschieben. Der Nutzer verschiebt selbst oder bestätigt jede Verschiebung ausdrücklich.

## Output

Schreibe Report nach `~/Documents/Second-Brain/00_Meta/system/lint-reports/YYYY-MM-DD-lint.md`:

```markdown
---
title: "Vault Lint Report YYYY-MM-DD"
type: meta
created_date: YYYY-MM-DD
---

# Vault Lint Report YYYY-MM-DD

## Summary
- Dateien gescannt: N
- Orphans: X
- Broken Wikilinks: Y
- Stale Decisions: Z
- Missing Cross-Refs: A
- Contradictions: B (Verdacht)
- Index-Drift: C
- Projekt-Repos-Drift: D
- Themen: E (unter fünf Einträgen), F (Tags außerhalb der Themenliste)
- Projekt-Lifecycle: G (Vorschläge)

## Orphans
- ...

## Broken Wikilinks
- `[[xyz]]` in `path/to/file.md` -> Ziel existiert nicht (Vorschlag: ...)

## Stale Decisions
- ...

## Missing Cross-Refs
- `file-a.md` und `file-b.md` teilen Topic `xxx`, verlinken aber nicht. Vorschlag: gegenseitig verlinken.

## Contradictions (Review noetig)
- ...

## Drift
- ...

## Themen
- `slug`: N Einträge (Kandidat zum Zusammenlegen)
- `cluster/xyz` in `path/to/file.md` steht nicht in der Themenliste

## Projekt-Lifecycle
- `<slug>`: Vorschlag Verschiebung nach `06_Archive/` (Grund: ...)

## Empfohlene naechste Schritte
- ...
```

## Interactive Fix Phase

Nach dem Report Summary zeigen und dann pro Kategorie mit Issues den User fragen. Reihenfolge: **Drift → Projekt-Repos-Drift → Broken Wikilinks → Missing Cross-Refs → Orphans → Stale Decisions → Contradictions**.

### Ablauf pro Kategorie

1. Summary-Zeile: `<Kategorie in Klartext>: N Befunde.` (z. B. „Tote Links: 12 Befunde.")
2. Frage: `Soll ich diese N Befunde angehen? [j/n/zeigen]`
   - **j** → iteriere durch alle Issues, fuehre Fix-Aktion aus (siehe unten). Bei Ambiguitaet pro Issue einzeln nachfragen.
   - **n** → Kategorie ueberspringen, im Report vermerken `skipped by user`
   - **zeigen** → kompakte Liste aller Issues ausgeben (max 20 sichtbar, Rest als "+N weitere"), dann erneut fragen

### Fix-Aktionen

**Drift**
- Hinweis: „Der Suchindex des Second Brain ist nicht mehr deckungsgleich mit den Dateien. Bitte `/brain:rebuild-index` laufen lassen, der baut ihn neu auf." (Gleiche Empfehlung wie in Check 6. `/brain:sort-inbox` patcht nur Dateien aus dem Eingang und behebt Drift nicht.)
- Nicht automatisch auslösen, der Neuaufbau läuft über einen eigenen Sub-Agent-Scan.

**Projekt-Repos-Drift**
- Pro Drift-Art:
  - **YAML ohne Vault-Hub**: Frage „Für `<slug>` gibt es keine Projekt-Notiz im Second Brain. Soll ich sie aus der Projekt-Vorlage anlegen? [j/n]". Bei `j`: Ort erfragen (Projekt mit Enddatum → `02_Projects/`, laufende Area → `03_Areas/`), Template mit Platzhaltern kopieren, der User füllt die Platzhalter später.
  - **Hub ohne YAML**: Frage „`<slug>` fehlt in der Projekt-Liste, Meeting-Aufgaben landen deshalb nirgends. Eintragen? Projekt-Ordner (absoluter Pfad) oder ‚nein' für ein reines Second-Brain-Projekt?". Bei Pfad-Angabe: Zeile appenden (Duplikat-Schutz). Bei 'nein': im Report als "Vault-only, kein YAML-Eintrag gewollt" markieren, nicht erneut vorschlagen.
  - **YAML-Pfad tot**: zeige Eintrag, frage „Der Projekt-Ordner für `<slug>` existiert nicht mehr. Pfad korrigieren (neuer Pfad) oder Eintrag entfernen [p/r]?", dann entsprechend editieren.
- Nichts stumm aendern, jede Schreib-Operation einzeln bestaetigen.

**Broken Wikilinks**
- Fuzzy-Match im TSV-Alias-Pool: `grep -i` auf Basename + `aliases`-Spalte
- Bei eindeutigem Match (genau 1 Treffer): `Edit` mit `replace_all: false` auf `[[alt]]` → `[[neu]]` oder Pipe-Syntax. User bestaetigt kurz ("OK?").
- Bei keinem Match: frage „Soll ich die Notiz `xyz` anlegen oder den Link als Fließtext schreiben?"
- Bei mehreren Matches: zeige Kandidaten, User waehlt.

**Missing Cross-Refs**
- Pro Topic-Cluster: ergaenze gegenseitige Wikilinks in den Files, in passende Sektion (`## Verwandt` oder bestehende Sektion).
- Projekt-Steckbriefe nicht um Links auf einzelne Notizen ergänzen, die Verbindung trägt das Feld `project` der Notiz.

**Orphans**
- Notiz mit Projekt-Tag ohne Feld `project`: Zeile `project: "[[<slug>]]"` direkt nach `status:` setzen (Slug aus dem Tag `project/<slug>`, bei zwei Projekt-Tags als YAML-Liste mit zwei Zeilen). Jede Änderung einzeln bestätigen.
- Notiz ohne Projekt-Tag und ohne eingehende Links: als "accepted orphan" im Report markieren, keine Aktion.

**Stale Decisions**
- Pro Decision kurzer Title + letztes Datum anzeigen.
- Frage: `Noch gültig [j] / ersetzt (superseded) [s] / archiviert [a] / zeigen [z]?`
  - **j** → `updated`-Feld im Frontmatter auf heute setzen (Refresh)
  - **s** → `validity: superseded` setzen. User fragen ob eine neuere Decision als Ersatz verlinkt werden soll.
  - **a** → `validity: archived` setzen
  - **z** → ganze Decision-Datei zeigen, dann erneut fragen

**Contradictions**
- Read-only, User-Review noetig. Nicht auto-fixen.
- Pro Verdachtsfall: betroffene Dateien listen, kurzer Hinweis auf den Widerspruch, User entscheidet manuell.

**Themen und Projekt-Lifecycle**
- Keine Fix-Aktion, beide Kategorien sind reine Meldungen. Befunde nach den übrigen Kategorien zeigen, der Nutzer entscheidet. Themenliste und Tags nicht ändern und nichts verschieben, solange der Nutzer es nicht für den einzelnen Fall bestätigt.

### Re-Check am Ende

Nach allen gefixten Kategorien: leichtgewichtiger Re-Check nur der betroffenen Kategorien (nicht kompletter Lint). Summary ausgeben:

```
**Second Brain geprüft.**
- Gefunden: N Befunde (Index-Abweichung x, Projekt-Liste d, tote Links y, fehlende Querverweise z, unverlinkte Notizen a, veraltete Decisions b, mögliche Widersprüche c)
- Behoben: M
- Übersprungen: K (auf deinen Wunsch)
- Offen: L
```
Den Report-Pfad nur auf Nachfrage nennen.

## Vault-Log Eintrag

Append an `00_Meta/system/vault-log.md`:
`## [YYYY-MM-DD] lint | N detected, M fixed, K skipped`

## Regeln

- **Detect ist immer automatisch, Fix braucht immer Go des Users** (j/n pro Kategorie).
- Nutze Sub-Agents fuer alle vault-weiten Reads in der Detect-Phase.
- Wenn ein Check mehr als ~50 Treffer liefert: Report zeigt die ersten 20, Rest als "+N weitere". In der Fix-Phase bearbeite ALLE Treffer wenn User j sagt (nicht nur die im Report gelisteten).
- Token-Budget: In der Fix-Phase nur Dateien mit Issues lesen, nie den ganzen Vault.
- NIEMALS stille Fixes: jede Schreib-Operation muss dem User angekuendigt werden.
