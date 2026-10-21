# Rechnungen aus dem Postfach sauber ablegen

Claude sucht die Rechnungsmails eines Zeitraums heraus und zeigt sie dir als Tabelle. Du speicherst die Anhänge in einen Eingangsordner, Claude benennt sie einheitlich, legt sie nach Jahr und Monat ab und führt die Übersicht. Claude bezahlt nichts, leitet nichts weiter und löscht nichts.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

## Installieren

Sag Claude:
```
Installier mir den Use Case beleg-ablage: hol mit git pull den neuesten Stand von ~/ai-os-core, führ bash ~/ai-os-core/claude/use-cases/beleg-ablage/install.sh aus, installier Fehlendes mit den Befehlen, die das Skript nennt, und sag mir in einfachen Worten, ob alles geklappt hat.
```

Den Microsoft-365-Connector (für Postfach und SharePoint) verbindest du selbst in Claude unter Einstellungen, Connectoren.

Danach eine neue Session starten, damit Claude den Skill kennt.

## Loslegen

Probier es zuerst ohne Postfach mit zwei erfundenen Rechnungen. Öffne Claude in einem beliebigen Ordner. Sag Claude:
```
Zeig mir die Beleg-Demo.
```

Claude fragt alles Weitere selbst. Für echte Rechnungen öffnest du Claude in einem Arbeitsordner außerhalb von iCloud, OneDrive oder Dropbox, zum Beispiel `~/Belege-lokal`:

```
Hol meine Rechnungen aus dem Postfach und leg sie ab.
Alle Anhänge liegen jetzt in belege/_eingang/. Leg sie ab.
Lad die Belege nach SharePoint.
```

Vor dem zweiten Satz filterst du in Outlook nach der Kategorie „Beleg" und ziehst die PDF-Anhänge selbst in `belege/_eingang/`. Alles landet im Ordner `belege/` (PDFs unter `JJJJ/MM/`, `UEBERSICHT.md`, deine Einstellungen und Lieferanten).

## Grenzen

- Keine Buchung, keine Kontierung, keine steuerliche Beurteilung.
- Gescannte PDFs ohne Text liest Claude nicht aus, dann fragt Claude Betrag, Datum und Nummer bei dir ab.
- Datenschutz: Claude liest nur Absender, Betreff und Anhangtext der Belegmails. Belege mit Bezug zu Pflegebedürftigen bleiben lokal, Namen und Versichertennummern stehen nie in Tabellen oder Übersicht.

Warum du die Anhänge selbst speicherst, der genaue Ablauf, Windows-Sonderfälle, ein Beispielergebnis, Datenschutz in Langform und alle Grenzen stehen in [details.md](details.md).
