---
title: "Decision: {{title}}"
created_date: {{date:YYYY-MM-DD}}
updated: {{date:YYYY-MM-DD}}
type: decision
status: done
project: "[[SLUG-HIER]]"
validity: active
tags:
  - type/decision
  - project/SLUG-HIER
aliases: []
---

<!--
CAPTURE WENN: Ein Trade-off ist geloest, die Begruendung wird fuer spaetere
Entscheidungen wieder gebraucht (Folgewirkung, Kontext, Alternativen).
NICHT WENN: bloße Aktion, To-Do, Fix-Rezept, Meeting-Outcome-Listing.
STRUKTUR: Entscheidung (was) | Why (Begruendung, Incident/Deadline)
          | How to apply (wann Regel wieder greifen) | Alternatives
          | Konsequenzen.
CLUSTER-TAG: Ein bis zwei Themen als Tag cluster/<slug>, nur Slugs aus 00_Meta/themenliste.md.
Beim Anlegen freiwillig, nur setzen wenn eindeutig. Beim Einsortieren ist es Pflicht
(/brain:sort-inbox). Passt kein Thema, bleibt die Notiz im Eingang mit Themenvorschlag.
PROJEKT: Das Feld project verlinkt den Projekt-Steckbrief (bei zwei Projekten als
YAML-Liste mit zwei Zeilen). Bei Notizen ohne Projekt die Zeile weglassen.
-->

## Entscheidung

[Was wurde entschieden? 1 bis 2 Saetze, aktiv formuliert.]

## Why

[Begruendung: Incident, Deadline, Stakeholder-Ask, technische Notwendigkeit, Compliance?]

## How to apply

[Wann soll diese Regel in spaeteren Entscheidungen oder Situationen wieder greifen?]

## Alternatives Considered

[Kurze Liste: was verworfen, warum?]

## Konsequenzen

[Folgen, naechste Schritte, Verlinkungen zu anderen Decisions oder Tickets.]
