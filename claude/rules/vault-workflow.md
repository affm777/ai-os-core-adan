# Vault-Workflow

Vault `~/Documents/Second-Brain/` (PARA): `00_Meta` System, Templates, Index; `01_Inbox` Eingang; `02_Projects/<slug>` mit Enddatum; `03_Areas/<slug>` laufend; `04_Resources` übergreifend, flach; `05_Contacts/{People,Organizations}`; `06_Archive`. Projekte und Areas haben eine Index-Datei `<slug>.md`.

## Nachschlagen
- Vor Tool-, API-, Service- und Entscheidungsthemen `~/.claude/bin/vault-find.sh <stichworte>` aufrufen (Projekt plus `scope/cross-project`, `--all` vault-weit), Treffer lesen und dokumentierte Learnings befolgen.
- Decisions gelten nur mit `validity: active` oder ohne Feld.
- `00_Meta/system/vault-index.md` (TSV `path title type tags aliases topics updated`) nur greppen (Alias, Personen, Cross-Projekt), nie laden, nie manuell editieren.
- Lesen per Read, Glob, Grep. Bash nur für Pipes (`ls`, `find`, `head`, `tail`, `awk`, `wc`), nie `cat`, `sed`, `>` oder `rm` auf Vault-Pfade.

## Capture
- Neue Dateien ausnahmslos nach `01_Inbox/`, immer aus `00_Meta/Templates/` (`SLUG-HIER` ersetzen). Einsortieren macht allein `/brain:sort-inbox`. Ausnahme nur, wenn der Nutzer explizit einen anderen Ort nennt.
- „merken", „festhalten", „notieren" heißt sofort capturen. Sonst kurz fragen „Soll ich das im Second Brain festhalten?".
- `decision` Trade-off entschieden, Begründung wird später gebraucht. Nicht für Aktionen, To-dos, Fix-Rezepte, Meeting-Ergebnislisten.
- `learning` Bug oder Gotcha gelöst und kann wiederkommen, oder Pattern erstmals bestätigt. Nicht für Standard-API-Nutzung, Codebase-Patterns, Commit-Rezepte.
- `meeting` synchron mit 2+ Personen und Erkenntnisse, Decisions, strategische oder finanzielle Validierung oder Externe. Jedes gelieferte Transkript. Nicht Solo (decision), interne Arbeit (session-log), Routine-Sync.
- `session-log` Ergebnis einer Solo-Session (erreicht, gelernt, offen). `concept` selbst synthetisiertes Pattern. `resource` fremdes Material (Artikel, Guide, Manual, Clipping). `person`/`organization` nur bei wiederkehrender Beziehung. `project` Index-Datei eines Projekts in `02_Projects/`, `area` Index-Datei einer Area in `03_Areas/`. `meta` schreiben nur `/brain:*`-Skills.
- Frontmatter flach mit `title`, `created_date` (ISO 8601), `type`, `status`, `project` (Wikilink auf den Steckbrief `"[[<slug>]]"`, nur bei Projektbezug, bei zwei Projekten als Liste), `tags` (Array), `aliases` (Array). Decisions zusätzlich `validity: active|superseded|archived`.
- Tags ohne `#`. Pflicht `type/<typ>`, im Projektkontext `project/<slug>`. Ohne Projektkontext verständliches Wissen bekommt `scope/cross-project`. Sonst nur `status/` (draft, in-progress, done, archived) und `area/` (engineering, business, recruiting, health). `cluster/<slug>` nur bei eindeutigem Thema mit bestehendem Slug setzen, sonst leer lassen, sort-inbox ergänzt (gesetzte Tags bleiben).
- Dateinamen `YYYY-MM-DD-<beschreibung>.md` für Decision, Learning, Session-Log, Meeting. Entitäten tragen ihren Namen (`Vorname Nachname.md`, `<slug>.md`).
- Personen nur als `[[Wikilink]]`. Nur verlinken, was als Dateiname oder Alias existiert, sonst Seite anlegen oder Fließtext. Abweichender Text `[[datei|Anzeige]]`.
- Dedup vor neuer Decision oder Learning per vault-find oder Index-grep. Ähnliches ergänzen. Neue Decision ersetzt alte, dann alte auf `superseded` und in der neuen verlinken.
- Nie in den Vault: Code aus der Codebase, Git-Historie, Fix-Rezepte ohne übergreifendes Pattern, Trial-and-Error-Ketten, Secrets und `.env`-Werte, große Rohdaten (nur Referenz), Inhalte aus CLAUDE.md oder ADRs.

## Pflege
- Statuswechsel (z. B. Firma gegründet, Projekt abgeschlossen) heißt Verschiebung zwischen 02, 03, 06 vorschlagen, nie selbst verschieben. Keine leeren Platzhalter-Ordner.
- Index, `vault-log.md` (append-only), Cluster und Lint pflegen nur `/brain:sort-inbox`, `/brain:rebuild-index`, `/brain:health-check` und `/wrap-up`. Cluster nie eigenständig anlegen. health-check meldet nur und ändert nichts ohne Bestätigung.
