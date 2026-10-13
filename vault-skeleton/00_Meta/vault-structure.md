---
title: "Dein Second Brain: Erste Struktur"
type: meta
status: done
tags:
  - type/meta
aliases:
  - Vault-Struktur
  - Vault Onboarding
---

# Dein Second Brain: Erste Struktur

Dies ist eine vorgeschlagene Starterstruktur. Sie ist bewusst schlank. Du kannst spaeter Ordner oder Tags hinzufuegen, wenn du Bedarf siehst.

## Sieben Ordner, sieben Bedeutungen

| Ordner | Was kommt rein? |
|--------|-----------------|
| `00_Meta` | System-Files, Templates, Dashboards. Pflegt meist Claude. |
| `01_Inbox` | Eingangsfach. ALLES Neue landet hier zuerst. `/brain:sort-inbox` sortiert spaeter ein. |
| `02_Projects` | Projekte mit Enddatum (Produktlaunch, Buchprojekt, Kampagne). |
| `03_Areas` | Laufende Verantwortungen ohne Enddatum (Finanzen, Health, Recruiting). |
| `04_Resources` | Projekt-uebergreifendes Wissen (Konzepte, Artikel, Buchnotizen, Learnings, Tools). Flach gehalten. |
| `05_Contacts` | Menschen und Firmen, getrennt in `People/` und `Organizations/`. |
| `06_Archive` | Was abgeschlossen oder nicht mehr relevant ist. |

## Elf Typen, elf Schubladen

Jede Notiz bekommt im Frontmatter ein `type:`-Feld. Damit weiss Claude und du, was die Notiz IST, unabhaengig vom Ordner.

| Type | Wofuer | Beispiel |
|------|--------|----------|
| `decision` | Du hast zwischen Optionen entschieden | "Wir nehmen Tool X statt Y" |
| `learning` | Du hast etwas aus dem Tun gelernt | "OAuth-Flow braucht expliziten Redirect" |
| `concept` | Pattern oder Framework, das du selbst synthetisiert hast | "Two-Stage-Enrichment-Pattern" |
| `resource` | Externes Material, das du behalten willst | Artikel, Brand Guide, Manual, Web-Clipping |
| `session-log` | Outcome einer Solo-Arbeitssession | "Heute X gebaut, Y offen" |
| `meeting` | Gespraech mit anderen | Fathom-Synthese, Jour-fixe-Notiz |
| `person` | Eine Person | "Max Mustermann" |
| `organization` | Eine Firma oder Org | "Musterfirma GmbH" |
| `project` | Index-Datei eines Projekts in `02_Projects/` | "mein-projekt.md" |
| `area` | Index-Datei einer Area in `03_Areas/` (analog zu `project`) | "finanzen.md" |
| `meta` | System-Files (Index, Log, Dashboards, Lint-Reports) | "vault-index.md" |

## Wenn du dir nicht sicher bist

- **Ordner unklar?** Lass es im `01_Inbox` liegen. `/brain:sort-inbox` kuemmert sich.
- **Type unklar?** Frag dich: Was habe ich getan? Entschieden, gelernt, gelesen, getroffen, synthetisiert?
- **Mehrere Types passen?** Nimm den, der die wichtigste Aktion benennt. Im Zweifel: `learning` wenn aus eigenem Tun, `resource` wenn von ausserhalb.

## Die wichtigsten Slash-Commands

| Command | Was passiert |
|---------|--------------|
| `/wrap-up` | Session beenden, Wissen sichern, Projektstatus (STATE.md) und To-do-Liste (TODO.md) aktualisieren |
| `/brain:sort-inbox` | `01_Inbox` aufraeumen, alles in den richtigen Ordner verschieben |
| `/brain:health-check` | Vault auf Probleme pruefen (Orphans, kaputte Wikilinks, Drift) |
| `/brain:rebuild-index` | Maschinen-Index neu bauen (nach groesseren Aenderungen) |
| `/brain:sync-meetings` | Fathom-Meetings als Notizen importieren |
| `/new-project` | Neues Projekt schlank aufsetzen |

Einen Wiedereinstiegs-Befehl gibt es nicht: neuen Chat öffnen und loslegen. Claude liest den kurzen Projektstatus und sucht Wissen aus diesem Vault bei Bedarf gezielt mit `~/.claude/bin/vault-find.sh <stichworte>`.

## Themen

`00_Meta/themenliste.md` ist die feste Liste der Themen. Jede Decision und jedes Learning trägt ein bis zwei davon als Tag `cluster/<slug>`, Pflicht beim Einsortieren durch `/brain:sort-inbox`. Passt kein Thema, bleibt die Notiz im Eingang, neue Themen kommen nur nach Bestätigung des Nutzers in die Liste. Die Datei wird nicht bei jedem Session-Start geladen.

## Faustregel

Wenn das Projekt geloescht wird, was willst du behalten? → Second Brain.
