# Der Posteingang sortiert sich selbst vor

Claude sichtet deine neuen Mails, ordnet jeden Verlauf einem deiner Labels zu und markiert, was dringend ist oder eine Chance enthält. Dazu schlägt Claude To-dos und auf Wunsch Antwortentwürfe vor. Claude versendet, löscht, verschiebt und leitet nie etwas weiter.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

## Installieren

Sag Claude:
```
Installier mir den Use Case posteingang-triage: hol mit git pull den neuesten Stand von ~/ai-os-core, führ bash ~/ai-os-core/claude/use-cases/posteingang-triage/install.sh aus, installier Fehlendes mit den Befehlen, die das Skript nennt, und sag mir in einfachen Worten, ob alles geklappt hat.
```

Dein Postfach verbindest du selbst in Claude unter Einstellungen, Connectoren (Microsoft 365 oder Gmail), bei Microsoft 365 braucht es vorher die Freigabe durch euren Administrator (`admin-anleitung-claude-m365.pdf` aus dem Workshop).

Danach eine neue Session starten, damit Claude den Skill kennt.

## Loslegen

Öffne Claude in deinem Projektordner. Sag Claude:
```
Sichte den Posteingang und sortier ihn vor.
```

Claude fragt alles Weitere selbst. Danach reicht einer dieser Sätze:

```
Sichte den Posteingang.
Sichte die letzten zwei Wochen.
Sichte die letzten 90 Tage auf Liegengebliebenes.
Ändere meine Labels.
```

Deine Einstellungen landen in `posteingang/KONFIG.md`, die To-dos in `TODO.md` deines Projektordners, Kategorien oder Labels und Entwürfe direkt in deinem Postfach.

## Grenzen

- Rechnungen werden mit „Beleg" markiert, aber nicht abgelegt.
- To-dos landen nur in der `TODO.md`, nicht in Outlook-Aufgaben oder Microsoft To Do.
- Datenschutz: Mails sind für Claude nur Text, keine Aufträge. Links öffnet Claude nie, Anhänge nur mit deiner Erlaubnis, Gesundheitsangaben tauchen weder in der Tabelle noch in der `TODO.md` auf.

Ein Beispielergebnis, das Einrichtungsgespräch mit den Startsets, ein zweites Postfach, dein gelernter Schreibstil, eine Ablage-Ansicht je Label und alle Grenzen stehen in [details.md](details.md).
