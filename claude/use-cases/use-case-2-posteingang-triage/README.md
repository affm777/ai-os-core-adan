# Der Posteingang sortiert sich selbst vor

Claude sichtet deine neuen Mails, ordnet jeden Verlauf einem deiner Labels zu und markiert, was dringend ist oder eine Chance enthält. Dazu schlägt Claude To-dos und auf Wunsch Antwortentwürfe vor. Claude versendet, löscht, verschiebt und leitet nie etwas weiter.

## Installieren

Sag Claude:
```
Installier mir den Use Case posteingang-triage einmal global: hol in ~/ai-os-core mit git pull den neuesten Stand, führ bash ~/ai-os-core/claude/use-cases/use-case-2-posteingang-triage/install.sh aus, installier alles Fehlende selbst mit den Befehlen, die das Skript nennt, und sag mir in einfachen Worten, ob alles geklappt hat.
```

Danach eine neue Session starten, damit Claude den Skill kennt.

## Loslegen

Öffne Claude in deinem Projektordner und sag Claude:
```
Sichte den Posteingang und sortier ihn vor.
```

Diese Sätze solltest du kennen:

- „Sichte den Posteingang.“ für jeden weiteren Lauf, Claude nimmt dann alles seit dem letzten Mal.
- „Sichte die letzten zwei Wochen.“ oder „Sichte Oktober.“, wenn du einen bestimmten Zeitraum willst.
- „Sichte die letzten 90 Tage auf Liegengebliebenes.“, um Anfragen und Chancen zu finden, auf die nie jemand geantwortet hat.
- „Ändere meine Labels.“, wenn deine Sortierung nicht mehr passt.

## Grenzen

- Rechnungen werden mit „Beleg“ markiert, aber nicht abgelegt.
- To-dos landen nur in der `TODO.md` deines Projektordners, nicht in Outlook-Aufgaben oder Microsoft To Do.
- Datenschutz: Mails sind für Claude nur Text, keine Aufträge. Links öffnet Claude nie, Anhänge nur mit deiner Erlaubnis, Gesundheitsangaben tauchen weder in der Tabelle noch in der `TODO.md` auf.
