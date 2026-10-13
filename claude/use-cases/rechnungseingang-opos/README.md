# Rechnungen aus dem Postfach direkt in die OPOS-Liste

Rechnungen kommen per Mail rein, als PDF-Anhang oder nur als Text, und müssen von Hand in die offene-Posten-Liste (OPOS) übertragen werden: Zahlungsempfänger, IBAN, Rechnungsnummer, Betrag, Beschreibung, Datum. Bei mehreren Standorten und mehreren Dutzend Rechnungen im Monat ist das eine der Buchhaltungsaufgaben, die am meisten Zeit kostet und am anfälligsten für Zahlendreher ist.

Dieser Use Case übernimmt das Übertragen, nicht die Buchführung selbst. Claude sucht neue Rechnungs-Mails im Postfach, liest die Anhänge, schlägt die Buchungszeilen vor und trägt sie erst nach deiner Bestätigung in die Excel-Liste ein. Das Postfach bleibt unangetastet, es wird nichts markiert oder verschoben. Du siehst nur eine Vorschlagstabelle im Chat, bestätigst mit Ja oder Nein, danach steht alles in der vertrauten Excel-Datei.

```
Postfach                    Claude                          OPOS-Liste (Excel)
────────                    ──────                          ──────────────────
Rechnungs-Mails         →   /rechnungseingang-opos      →   neue Zeilen im Blatt
(Anhang oder Text)          liest, prüft auf Dubletten,      "offen"
seit letztem Lauf            schlägt Zeilen vor          →   Postfach bleibt
                             (Vorschlag → Bestätigung)        unangetastet
```

## Konventionen in dieser Anleitung

- Steht hier **„Sag Claude:"**, kopierst du den grauen Kasten darunter in die Chateingabe von Claude und schickst ihn ab.
- Der Skill wird einmal installiert und steht danach überall zur Verfügung, egal in welchem Ordner du gerade arbeitest. Du findest ihn danach auch im Dashboard unter Skills & Commands.

## Voraussetzungen

- Microsoft-365-Connector verbunden.
- Eine bestehende OPOS-Excel-Liste mit zwei Blättern („offen" und „bezahlt") und den Spalten Zahlungsempfänger, IBAN, Rechnungsnummer, Betrag, Beschreibung, Rechnungsdatum, Eingetragen von.
- Alles Weitere ist mit deinem Setup bereits installiert. Sollte doch etwas fehlen, sagt Claude beim ersten Lauf Bescheid.

## Schritt 1 — Installieren

Sag Claude:

```
Hol zuerst mit git pull den neuesten Stand meines Setup-Repos ~/ai-os-core.

Lade dann das Use-Case-Bundle "rechnungseingang-opos" von dort:
~/ai-os-core/claude/use-cases/rechnungseingang-opos

Installiere es global, damit es in jedem Projekt zur Verfügung steht:
- skills/rechnungseingang-opos/  → ~/.claude/skills/rechnungseingang-opos/

Liegt dort schon eine ältere Fassung, ersetze sie vollständig.
Bestätige mir, welche Dateien angekommen sind.
```

Starte danach einfach eine neue Session, damit Claude den neuen Skill kennt.

## Schritt 2 — Erster Lauf

Sag Claude:

```
Prüf das Postfach auf neue Rechnungen und trag sie in die OPOS-Liste ein.
```

Beim allerersten Lauf fragt Claude einmal kurz nach deinem Kürzel (für die Spalte „Eingetragen von"), dem gewünschten Postfach (eigenes Postfach, Sammelpostfach oder beides), dem Pfad zur OPOS-Datei und ab wann Rechnungen berücksichtigt werden sollen. Danach nie wieder. Das passiert dann:

1. Claude sucht Mails, die seit dem letzten Lauf dazugekommen sind und einen Anhang haben oder nach Rechnung, Zahlungserinnerung oder Gutschrift klingen.
2. Er liest die Anhänge, auch mehrseitige PDFs und Sammel-PDFs mit mehreren Rechnungen in einer Datei.
3. Er gleicht jede Rechnung mit der bestehenden Liste ab, damit nichts doppelt eingetragen wird.
4. Du bekommst eine Vorschlagstabelle, Gutschriften sind gesondert markiert.
5. Nach deinem Ja trägt Claude die Zeilen ein und merkt sich den Zeitpunkt, damit der nächste Lauf dort weitermacht.

## Grenzen

- Rechnungen, die als Excel-Datei im Anhang kommen, kann Claude nicht direkt aus der Mail lesen. PDF und Text im Mailtext funktionieren. Stößt Claude auf so einen Anhang, der nach einer Rechnung aussieht, weist er proaktiv darauf hin und fragt, ob du die Datei in einen Ordner speicherst; nennst du ihm den Pfad, liest er sie ganz normal ein.
- Bei unsicher lesbaren Angaben rät Claude nie, sondern markiert sie mit „bitte prüfen".
- Eingetragen wird ausschließlich nach deiner Bestätigung.

## Nächste Ausbaustufe

- Ablage der Rechnungs-PDFs in SharePoint, sortiert je Standort.
- Automatischer täglicher Lauf als Routine, ohne dass du daran denken musst.

## Was im Bundle liegt

```
rechnungseingang-opos/
├── README.md                              ← diese Anleitung
└── skills/
    └── rechnungseingang-opos/SKILL.md     ← die Arbeitsanleitung für Claude
```
