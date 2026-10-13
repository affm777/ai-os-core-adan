# CLAUDE.md (Global)

## Session
- Start: `.planning/STATE.md` lesen (kurzer Status, Fallback `STATE.md` im Projekt-Root; existieren beide, ältere ignorieren und den Nutzer auf die Dublette hinweisen). `TODO.md` daneben nur bei Bedarf lesen. Einfach loslegen, kein Resume-Ritual.
- Der SessionStart-Hook zeigt nur eine kurze Vault-Karte (Bestand, Themen). Wissen aus dem Second Brain gezielt suchen mit `~/.claude/bin/vault-find.sh <stichworte>`, vor allem vor Tool-, API- und Entscheidungsthemen.
- Ende: Bei „Schluss", „Fertig", „Session beenden" `/wrap-up` ausführen. Nach großer Aufgabe ohne wrap-up anbieten, STATE.md zu aktualisieren.

## Second Brain
Vault `~/Documents/Second-Brain/`, Regeln in `rules/vault-workflow.md`. Faustregel: Was bleiben soll, wenn das Projekt gelöscht wird (Business-Übersicht, Meetings, Decisions, Learnings, Personen), gehört in den Vault. CLAUDE.md, STATE.md, TODO.md, Roadmap und Deliverables bleiben im Projekt. Gelöstes Problem oder neues Pattern als Learning festhalten.

## Schreibstil (PFLICHT)
- Umlaute (ä, ö, ü, ß) immer ausschreiben, überall (Chat, Dateien, Commits, Kommentare, Vault). Nur technische Strings (Dateinamen, URLs, Slugs, Variablen, JSON-Keys) ausgenommen, im Zweifel Umlaut. Fehlende Umlaute beim Editieren mitkorrigieren.
- Keine Gedankenstriche (Geviert- oder Halbgeviertstrich), stattdessen Komma, Punkt, Doppelpunkt, Klammern.
- Edit-in-place: nur explizit Verlangtes ändern. Nie Dokumente oder Sektionen neu schreiben, nie Bilder, Links, Sektionen oder Formatierung entfernen oder umbauen, die nicht Gegenstand waren. Im Zweifel kleiner Edit statt Rewrite.
- Doppelpunkte sparsam, höchstens einer pro Absatz, nie als Ankündigung („Wichtig: ..."). Gehäufte Doppelpunkte lesen sich als AI-Slop.
- Kein Komma vor „und", auch zwischen Hauptsätzen, außer bei echter Fehllesung. Gilt für Chat und alle Texte nach außen.
- Keine harten Zeilenumbrüche im Fließtext, ein Absatz ist eine Zeile, Absätze trennt eine Leerzeile (E-Mail-Body, Zwischenablage, WhatsApp, Slack, auch via Heredoc, Shell-Argument, JSON).
- Todos stehen in `TODO.md` neben der STATE.md, nie in der STATE.md (Projekte ohne TODO.md: Sektion „Pending Todos" der STATE.md). Ein Todo eine Zeile, reiner Text ohne Markdown, ohne verschachtelte Erklärung. Details gehören in den Vault.

## Security
Kategorische Regeln in `rules/security-basics.md`. Nie API-Keys in Code, Secrets in Git, Tokens in Logs (Secret-Scan vor Commit erzwingt `git-secret-scan.sh`).

## Browser
Jede Browser-Aufgabe über Playwright, nie über die Chrome-Erweiterung (`claude-in-chrome`), nicht danach fragen. UI, HTML und visuelle Deliverables öffnen, per Screenshot prüfen, iterativ fixen, Screenshots danach löschen. Braucht es eine angemeldete Sitzung (z. B. Microsoft 365, SharePoint), macht der Nutzer den Schritt selbst, danach nur lesend weiter. Keine Anmeldedaten eingeben.

## Arbeitsweise
- Hauptsession koordiniert, Sub-Agents arbeiten. Große MCP-Antworten per Sub-Agent holen, Unabhängiges parallel. Agent-Beschreibung (description) auf Deutsch als verständlicher Auftrag, etwa „Angebot gegen Vorlage prüfen", sie steht im Agenten-Band.
- CLAUDE.md kurz halten (global ~150, Projekt ~100 Zeilen), Details in Referenzdateien.

## Referenzdateien (`~/.claude/rules-archive/`, nur bei Bedarf lesen)
Bewusst außerhalb von `rules/`, damit sie nicht automatisch geladen werden. Pro Datei eine Zeile, WANN sie gelesen wird (Details: README im Ordner).
- `security-code-quality.md` bei Code-Erstellung (OWASP, Input Validation, Quality Gates)
- `fullstack-patterns.md` bei neuem Full-Stack- oder Web-Projekt
