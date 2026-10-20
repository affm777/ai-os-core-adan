# Rechnungen aus dem Postfach sauber ablegen

Claude sucht die Rechnungsmails eines Zeitraums heraus und zeigt sie dir als Tabelle. Du speicherst die Anhänge in einen Eingangsordner, Claude benennt sie einheitlich, legt sie nach Jahr und Monat ab und führt die Übersicht.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

```
Postfach                      Claude                             Ergebnis
────────                      ──────                             ────────
Rechnungsmails            →   findet Belegmails über       →    Tabelle zum Bestätigen,
des Zeitraums                 Betreff und Absender              Mails mit Kategorie „Beleg"

belege/_eingang/          →   liest Betrag und Nummer,     →    belege/2026/10/2026-10-02_
(von dir gespeicherte PDFs)   benennt, legt ab, prüft          Lieferant_238,00-EUR_RE-0412.pdf
                              auf Dubletten, trägt ein          belege/UEBERSICHT.md
                                                                 Mail: „Beleg abgelegt"
                                                                 optional SharePoint
```

## Das brauchst du

- Dein Setup ist installiert.
- Der Microsoft-365-Connector ist in Claude verbunden (für Postfach und SharePoint).
- Python 3 und ein Werkzeug zum Lesen von PDF-Text. Das Installationsskript prüft beides.
- Einen Arbeitsordner außerhalb von iCloud, OneDrive oder Dropbox, zum Beispiel `~/Belege-lokal`.

## Schritt 1: Installieren

Sag Claude:
```
Hol zuerst mit git pull den neuesten Stand meines Setup-Repos ~/ai-os-core.

Führe dann das Installationsskript des Use-Case-Bundles "beleg-ablage" aus:
bash ~/ai-os-core/claude/use-cases/beleg-ablage/install.sh

Zeig mir danach in einfachen Worten, ob alles geklappt hat.
```

Starte danach eine neue Session, damit Claude den neuen Skill kennt.

## Schritt 2: Erster Lauf

Probier es zuerst ohne Postfach mit zwei erfundenen Rechnungen. Öffne Claude in einem beliebigen Ordner. Sag Claude:
```
Zeig mir die Beleg-Demo.
```

Claude legt dann den Ordner `belege-demo/` an und fragt dich:
- ob die vorgeschlagenen Dateinamen passen und abgelegt werden sollen
- ob der unbekannte Lieferant in die Lieferantenliste soll

## Schritt 3: So nutzt du es

**Rechnungen suchen.** Öffne Claude in deinem Arbeitsordner. Beim ersten Mal fragt Claude nach Postfach, Zeitraum, Ablageort und SharePoint, dann zeigt Claude die Belegmails als Tabelle.
```
Hol meine Rechnungen aus dem Postfach und leg sie ab.
```

**Anhänge speichern und ablegen.** Filtere in Outlook nach der Kategorie „Beleg" und zieh die PDF-Anhänge in den Ordner `belege/_eingang/`. Unter Windows ziehst du sie in ein Explorer-Fenster, Sonderfälle stehen in [details.md](details.md).
```
Alle Anhänge liegen jetzt in belege/_eingang/. Leg sie ab.
```

**Nach SharePoint hochladen.** Ist SharePoint eingerichtet, lädt Claude nach einer Rückfrage hoch.
```
Lad die Belege nach SharePoint.
```

## Das kommt dabei heraus

- `belege/JJJJ/MM/` mit einheitlich benannten PDFs, etwa `2026-10-02_Lieferant_238,00-EUR_RE-0412.pdf`
- `belege/UEBERSICHT.md` mit allen Belegen und der Summe je Monat, optional als `UEBERSICHT.xlsx`
- `belege/KONFIG.md` mit deinen Einstellungen und `belege/LIEFERANTEN.md` mit deinen Lieferanten
- in Outlook die Kategorien „Beleg" und „Beleg abgelegt", auf Wunsch eine Kopie in SharePoint

## Grenzen

- Claude bezahlt nichts, leitet nichts weiter und löscht nichts.
- Keine Buchung, keine Kontierung, keine steuerliche Beurteilung.
- Gescannte PDFs ohne Text liest Claude nicht aus. Dann fragt Claude Betrag, Datum und Nummer bei dir ab.
- Die Anhänge speicherst du selbst, weil der Connector Claude nur den Text gibt, nicht die Datei.
- **Datenschutz.** Claude liest nur Absender, Betreff und Anhangtext der Belegmails. Andere Mails werden nicht geöffnet.
- **Datenschutz.** Belege mit Bezug zu Pflegebedürftigen bleiben lokal. Namen und Versichertennummern stehen nie in Tabellen oder Übersicht.

## Mehr dazu

Warum du die Anhänge selbst speicherst, der genaue Ablauf, Datenschutz in Langform und alle Grenzen stehen in [details.md](details.md).
