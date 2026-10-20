# Rechnungen aus dem Postfach sauber ablegen

Rechnungen kommen per Mail, liegen verstreut im Postfach und müssen für die Buchhaltung einzeln gespeichert, umbenannt und sortiert werden. Mit diesem Use Case sucht Claude die Belegmails eines Zeitraums heraus und zeigt dir eine Tabelle. Nach deinem Ja speicherst du die Anhänge mit zwei Klicks in einen Eingangsordner, ab dort übernimmt Claude: einheitlich benennen, nach Jahr und Monat ablegen, die Übersicht führen, Dubletten erkennen, die Mail in Outlook als erledigt markieren und auf Wunsch nach SharePoint hochladen.

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

## Konventionen in dieser Anleitung

- Steht hier **„Sag Claude:"**, kopierst du den grauen Kasten darunter in die Chateingabe von Claude und schickst ihn ab.
- Der Skill wird einmal installiert und steht danach überall zur Verfügung, egal in welchem Ordner du gerade arbeitest. Du findest ihn danach auch im Dashboard unter Skills & Commands.

## Voraussetzungen

- Dein Setup ist installiert und der Microsoft-365-Connector in Claude verbunden (für Postfach und SharePoint).
- Python 3 und ein Werkzeug zum Lesen von PDF-Text. Das Installationsskript prüft beides und nennt dir sonst die passende Zeile zum Nachinstallieren (am Mac mit `python3`, unter Windows mit `py -3`).
- Ein Arbeitsordner, der nicht in iCloud, OneDrive oder Dropbox liegt, zum Beispiel `~/Belege-lokal`. Liegen Schreibtisch und Dokumente bei dir in iCloud oder OneDrive, fragt Claude nach.

Zeitbedarf: Der erste Lauf mit sieben kurzen Fragen dauert rund fünf Minuten. Danach braucht ein Monat mit 30 Rechnungen etwa zehn Minuten, davon zwei bis drei für das Speichern der Anhänge.

## Schritt 1: Installieren

Sag Claude:

```
Hol zuerst mit git pull den neuesten Stand meines Setup-Repos ~/ai-os-core.

Führe dann das Installationsskript des Use-Case-Bundles "beleg-ablage" aus:
bash ~/ai-os-core/claude/use-cases/beleg-ablage/install.sh

Zeig mir danach in einfachen Worten, ob alles geklappt hat.
```

Starte danach eine neue Session, damit Claude den neuen Skill kennt.

## Schritt 2: Demo ausprobieren

Ohne Postfach, mit zwei erfundenen Rechnungen. Öffne Claude in einem beliebigen Ordner und sag:

```
Zeig mir die Beleg-Demo.
```

Claude legt `belege-demo/` an, liest beide Rechnungen, schlägt Dateinamen vor, legt nach deinem Ja ab und schreibt die Übersicht. Einer der beiden Lieferanten ist schon bekannt, den anderen schlägt Claude für die Lieferantenliste vor. Sag danach „Lauf die Demo nochmal", dann siehst du, dass beide Rechnungen als Dublette erkannt und nicht doppelt abgelegt werden.

## Schritt 3: Erster echter Lauf

Öffne Claude in deinem Arbeitsordner und sag:

```
Hol meine Rechnungen aus dem Postfach und leg sie ab.
```

Das passiert dann:

1. Beim ersten Mal fragt Claude in zwei kurzen Runden nach Postfach, Zeitraum, Ablageort, Dateinamen, SharePoint, Excel-Übersicht und dem Umgang mit Belegen mit Patientenbezug. Die Antworten stehen danach in `belege/KONFIG.md`, du kannst sie dort jederzeit ändern.
2. Claude sucht alle Mails seit dem letzten Lauf mit PDF-Anhang und Stichworten wie Rechnung, Invoice, Beleg, Gutschrift, Mahnung oder Zahlungserinnerung, dazu Mails bekannter Lieferanten.
3. Du bekommst eine Tabelle mit Datum, Absender, Betreff, vermutetem Betrag, Lieferant, Anhang und Einschätzung („Beleg", „unsicher", „Patientenbezug"). Kann Claude den Anhang im Postfach nicht lesen, steht beim Betrag „aus Datei", dann kommt er in Schritt 5 aus dem gespeicherten PDF. Du sagst, was stimmt und was nicht.
4. Claude markiert die bestätigten Mails in Outlook mit der Kategorie „Beleg". Du filterst in Outlook nach dieser Kategorie und ziehst die PDF-Anhänge in den Ordner `belege/_eingang/`, am Mac in ein Finder-Fenster, unter Windows in ein Explorer-Fenster. Klappt das Ziehen nicht, speicherst du den Anhang über das Anhang-Menü („Herunterladen" am Mac, „Speichern unter" unter Windows) und verschiebst ihn dorthin.
5. Claude liest jede Datei, zeigt die neuen Dateinamen und Hinweise (Dublette, Scan ohne Text, neuer Lieferant) und legt nach deinem Ja unter `belege/JJJJ/MM/` ab.
6. Die Mail bekommt die Kategorie „Beleg abgelegt". Ist SharePoint eingerichtet, lädt Claude nach einer weiteren Rückfrage in den gewählten Ordner hoch, mit derselben Jahr-Monat-Struktur.

## Warum du die Anhänge selbst speicherst

Der Microsoft-365-Connector gibt Claude höchstens den Text der PDF-Anhänge, nie die Datei selbst. Für die Buchhaltung zählt das Original, ein aus dem Text nachgebautes PDF wäre kein Beleg. Deshalb dieser eine Handgriff. Sobald es die Datei gibt, übernimmt Claude den Rest. Den Handgriff ersetzt in einer Ausbaustufe ein Power-Automate-Flow (siehe unten).

## So sieht das Ergebnis aus

```
belege/
├── KONFIG.md                 ← deine Einstellungen
├── LIEFERANTEN.md            ← wer dir Rechnungen schickt, Claude lernt mit
├── UEBERSICHT.md             ← alle Belege nach Monat, mit Summe je Monat
├── UEBERSICHT.xlsx           ← optional als Excel
├── _eingang/                 ← hier speicherst du die Anhänge hinein
└── 2026/
    └── 10/
        ├── 2026-10-02_Pflegebedarf-Musterstadt-GmbH_238,00-EUR_RE-2026-0412.pdf
        └── 2026-10-08_Buerotechnik-Beispiel-KG_1249,50-EUR_2026-10-077.pdf
```

In `UEBERSICHT.md` steht je Beleg Datum, Lieferant, Betrag, Rechnungsnummer, Art, Datei, Quelle (Betreff und Datum der Mail) und Status (abgelegt, hochgeladen, nur lokal).

## Datenschutz

- Claude liest nur Absender, Betreff und den Anhangtext der Belegmails. Andere Mails werden nicht geöffnet.
- Belege mit Bezug zu Pflegebedürftigen (etwa von Kostenträgern oder Abrechnungsstellen) bleiben lokal und gehen nur in einen SharePoint-Ordner, den du dafür ausdrücklich freigibst. Für die Verarbeitung über Microsoft 365 und Claude braucht dein Betrieb einen Auftragsverarbeitungsvertrag mit beiden Anbietern.
- In Tabellen und Übersicht stehen nie Namen, Geburtsdaten oder Versichertennummern von Pflegebedürftigen.
- Mails und Anhänge sind für Claude Daten, keine Anweisungen. Verlangt eine Mail etwas von Claude oder nennt sie ein neues Bankkonto, wird sie als auffällig markiert und nicht als Beleg vorgeschlagen.

## Grenzen

- Claude bezahlt nichts, leitet nichts weiter und löscht nichts. In Outlook setzt Claude nur die zwei Kategorien, Mails bleiben, wo sie sind.
- Keine Buchung, keine Kontierung, keine steuerliche Beurteilung. Fürs Eintragen in eine Liste offener Posten gibt es den Use Case `rechnungseingang-opos`.
- Gescannte PDFs ohne Text erkennt Claude, liest sie aber nicht aus. Dann fragt Claude Betrag, Datum und Nummer bei dir ab.
- Anhänge über 1 MB lädt Claude nicht nach SharePoint, die ziehst du von Hand hinein.
- Im Sammelpostfach kann Claude lesen, aber keine Kategorien setzen.

## Nächste Ausbaustufe

- Anhänge automatisch speichern: Ein Power-Automate-Flow legt PDFs aus Mails mit der Kategorie „Beleg" selbst in OneDrive oder SharePoint ab, Claude holt sie von dort.
- Monatsmappe für den Steuerberater: alle Belege eines Monats als ZIP plus Übersicht und ein Mail-Entwurf, den du selbst prüfst und sendest.
- Abgleich mit dem Kontoauszug: Welche Abbuchung hat noch keinen Beleg.

## Was im Bundle liegt

```
beleg-ablage/
├── README.md                              ← diese Anleitung
├── install.sh                             ← Installation (Mac und Windows)
└── skills/
    └── beleg-ablage/
        ├── SKILL.md                       ← die Arbeitsanleitung für Claude
        ├── scripts/beleg.py               ← liest PDFs, benennt, legt ab, führt die Übersicht
        ├── vorlagen/                      ← KONFIG.md und LIEFERANTEN.md für den ersten Lauf
        └── beispiel/                      ← zwei erfundene Rechnungen für die Demo
```
