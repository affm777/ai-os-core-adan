# Rechnungen aus dem Postfach sauber ablegen

Claude sucht die Rechnungsmails eines Zeitraums heraus und zeigt sie dir als Tabelle. Die PDF-Anhänge ziehst du selbst in einen Eingangsordner, Claude sagt dir genau wie. Dann benennt Claude sie einheitlich, legt sie nach Jahr und Monat ab und führt die Übersicht. Claude bezahlt nichts, leitet nichts weiter und löscht nichts.

## Installieren

Sag Claude:
```
Installier mir den Use Case beleg-ablage einmal global: hol in ~/ai-os-core mit git pull den neuesten Stand, führ bash ~/ai-os-core/claude/use-cases/beleg-ablage/install.sh aus, installier alles Fehlende selbst mit den Befehlen, die das Skript nennt, und sag mir in einfachen Worten, ob alles geklappt hat.
```

Den Microsoft-365-Connector (für Postfach und SharePoint) verbindest du selbst in Claude unter Einstellungen, Connectoren.

Danach eine neue Session starten, damit Claude den Skill kennt.

## Loslegen

**Hast du eigene Daten?** Dafür reichen Rechnungsmails in deinem Outlook-Postfach. Öffne Claude in einem Arbeitsordner auf deinem Rechner, nicht in iCloud, OneDrive oder Dropbox (zum Beispiel `~/Belege-lokal`), und sag Claude:
```
Hol meine Rechnungen aus dem Postfach und leg sie ab.
```

**Zum Ausprobieren ohne eigene Daten** nimmt Claude zwei erfundene Rechnungen, ohne Postfach. Öffne Claude in einem beliebigen Ordner und sag Claude:
```
Zeig mir die Beleg-Demo.
```

## Grenzen

- Keine Buchung, keine Kontierung, keine steuerliche Beurteilung.
- Datenschutz: Claude öffnet nur die Mails, die nach Rechnung aussehen, und liest dort Absender, Betreff und Anhangtext. Andere Mails sortiert Claude nur nach Betreff und Absender aus.
- Datenschutz in der Pflege: Belege mit Bezug zu Pflegebedürftigen bleiben lokal, Namen und Versichertennummern stehen nie in Tabellen oder Übersicht. Für solche Daten braucht euer Betrieb einen Auftragsverarbeitungsvertrag mit Microsoft und mit Anthropic.
