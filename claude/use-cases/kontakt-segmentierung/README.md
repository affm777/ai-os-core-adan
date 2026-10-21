# Von deinen LinkedIn-Kontakten zur persönlichen Ansprache

Claude sortiert deinen LinkedIn-Export nach Rollen, legt je Firma eine Akte an, recherchiert öffentliche Quellen und schreibt persönliche Nachrichtenentwürfe. Du gibst an jeder Stelle frei und schickst jede Nachricht selbst, Claude versendet nie etwas.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

## Installieren

Sag Claude:
```
Installier mir den Use Case kontakt-segmentierung: hol mit git pull den neuesten Stand von ~/ai-os-core, führ bash ~/ai-os-core/claude/use-cases/kontakt-segmentierung/install.sh aus, installier Fehlendes mit den Befehlen, die das Skript nennt, und sag mir in einfachen Worten, ob alles geklappt hat.
```

Danach eine neue Session starten, damit Claude den Skill kennt.

## Loslegen

Öffne Claude in deinem Projektordner. Sag Claude:
```
Segmentier meine LinkedIn-Kontakte für den Career Day. Nimm zum Üben die Demo.
```

Claude fragt alles Weitere selbst. Mit deinem echten Export (`Connections.csv`, Weg in [details.md](details.md)) lässt du „Nimm zum Üben die Demo" weg und ziehst die Datei ins Fenster, wenn Claude danach fragt. Danach Phase für Phase, jede für sich nützlich:

```
Mach daraus eine Outreach-Pipeline für den Career Day.
Leg für die A- und B-Firmen Akten an.
Recherchier die A-Firmen.
Lass uns die Ansprache festlegen.
Schreib die nächsten Entwürfe.
```

Alles landet im Ordner `kontakte/` deines Projekts (Excel mit Segmenten, Übersicht für den Browser, Akte je Firma, Entwürfe zum Kopieren).

## Grenzen

- Claude ordnet nach der Positionsbezeichnung, lies die A-Kontakte einmal gegen.
- Outlook-Entwürfe nur für Kontakte, die du ausdrücklich auf E-Mail stellst (Microsoft-365-Connector nötig).
- Datenschutz: nur der offizielle Export, Recherche nur zu Firmen in öffentlichen Quellen, nie zu einzelnen Menschen. Der Ordner `kontakte/` bleibt auf deinem Rechner, nicht in iCloud oder OneDrive.

Zeitbedarf, Segmentregeln, Partnerliste, Dashboard-Reiter, Beispiel-Akte und das Melden gesendeter Nachrichten stehen in [details.md](details.md).
