# Quellen-Manifest

Die eine Stelle, an der steht, aus welchem System welche Kostendaten kommen und in welchem Zustand die Anbindung ist. Der Skill liest diese Datei zuerst, dann arbeitet er die Quellen ab.

**So erweiterst du:** Neue Quelle = neue Zeile hier plus ein Ordner unter `exporte/<slug>/`. Kein Umbau am Skill. Was auf `aktiv` steht und Dateien in `_neu/` hat, wird verarbeitet. Was auf `geplant` steht, wird übersprungen und im Lauf als Lücke gemeldet, nicht als Fehler.

## Nur die Kostenseite

Dieses Verzeichnis trackt Kosten, keine Umsätze. Zuflüsse in den Quelldateien (Kundenzahlungen, Auszahlungen von Zahlungsdienstleistern) werden NICHT verbucht, nur gezählt und im Stand ausgewiesen. Die einzige Ausnahme sind Erstattungen: eine Gutschrift, die eine frühere eigene Ausgabe zurückgibt, ist negative Kosten im Ursprungsblock (Details in der SKILL.md).

## Kanäle

Eine Quelle kann auf zwei Wegen liefern:

- **datei**: du legst Exporte in `exporte/<slug>/_neu/`, der Skill liest sie und schiebt sie nach `analysiert/`.
- **beleg**: du wirfst lose Dateien jeder Form (PDF, Foto, CSV, Screenshot) nach `belege/_neu/`. Der Skill liest jede, ordnet sie einem Kostenblock aus `KOSTEN-KATEGORIEN.md` und einem Standort aus `STANDORTE.md` zu, baut daraus einen Posten und fragt nach, wenn eine Zuordnung unklar ist. Siehe Abschnitt „Belege-Intake".

Live-Connectoren (Stripe, PayPal) liefern die Einnahmenseite und sind hier deshalb nicht angebunden. Die Zahlungsanbieter-Gebühren als Kostenposten sind ein späterer Ausbau.

## Register: System-Quellen

| Slug | System | Kanal | Was | Standort-fähig | Status |
|---|---|---|---|---|---|
| `bank` | Bankkonto | datei | Kontoauszug (CSV-Umsatzexport, siehe Schema unten; CAMT.053 XML noch nicht). Kontoauszug als PDF läuft ebenfalls unter diesem Slug, siehe SKILL.md | über die Regel-Tabelle in `STANDORTE.md`; bei getrennten Konten pro Standort hier je Konto den Standort vermerken | **aktiv** |
| `excel` | Beliebige Excel-/Tabellen-Datei | datei | Generischer Import: der Skill erkennt die Spalten, legt dir das Mapping zur Bestätigung vor und schreibt das bestätigte Schema hierher (siehe „Bestätigte Excel-Schemas") | wenn eine Spalte den Standort trägt | **aktiv** |
| `sevdesk` | sevDesk | datei | **Itemized Listenexport** aus der Ausgaben-Ansicht (NICHT der DATEV/EXTF-Steuerberater-Export): je Beleg eine Zeile. Nur Eingangsrechnungen sind relevant, Ausgangsrechnungen werden gezählt und übersprungen. Schema unten | Kostenstellen nur im Tarif Buchhaltung Pro | geplant (Schema provisorisch, gegen ersten echten Export verifizieren) |
| `pliant` | Pliant | datei | Kreditkarten-Transaktionen (CSV), laufende Ausgaben | unbekannt, Spalten nicht dokumentiert | geplant |

## Schema Bank-CSV (Umsatzexport)

Die meisten deutschen Banken exportieren semikolon-getrennt mit diesen Spalten. Namen variieren leicht, die **Bedeutung** ist entscheidend:

| Spalte (typisch) | Bedeutung | Hinweis |
|---|---|---|
| `Buchungstag` | Datum | Oft `TT.MM.JJ`, zweistelliges Jahr. `15.04.26` ist 2026, nicht 1926. |
| `Verwendungszweck` | Beschreibung | Trägt den Erstattungs- und Transfer-Hinweis sowie oft das Standort-Signal. |
| `Beguenstigter/Zahlungspflichtiger` | Gegenpartei | Zusammen mit dem Zweck die Grundlage von Kategorie- und Standort-Zuordnung. |
| `Betrag` | Betrag | **Deutsches Format:** Komma ist Dezimaltrenner, Punkt ist Tausendertrenner. `1.234,56` sind tausendzweihundertvierunddreißig Euro. |
| `Soll/Haben` | Richtung | `S` = Abfluss, `H` = Zufluss. **Wenn diese Spalte existiert, ist der Betrag unsigniert** und die Richtung kommt ausschließlich von hier. Fehlt sie, trägt der Betrag das Vorzeichen. |
| `Waehrung` | Währung | Alles außer EUR: stoppen und nachfragen. |

**Weicht ein Export hiervon ab, gilt weiterhin: Schema nicht raten, sondern fragen.** Dieses Schema deckt den Normalfall ab, nicht jeden Dialekt.

## sevDesk-Schema (vorbereitet, provisorisch)

Erwartete Spalten des itemized Listenexports (gegen den ersten echten Export mit Daten verifizieren, vorher NICHT scharf schalten, Status bleibt `geplant`):

| sevDesk-Spalte (erwartet) | unser Feld | Hinweis |
|---|---|---|
| Belegnummer | Teil der `id` | Dedup-Hilfe |
| Zahldatum (bei bezahlt) | `datum` | der Cash-Zeitpunkt |
| Zahlstatus (bezahlt/offen) | | bezahlt und Eingangsrechnung → Journal; offen mit Fälligkeit → Vorschlag als **Erwartete Kosten** in `ANNAHMEN.md` |
| Lieferant/Kunde | `gegenpartei` | |
| Belegtyp (Ausgangs-/Eingangsrechnung) | Filter | Nur Eingangsrechnungen verbuchen. Ausgangsrechnungen sind Umsatz: zählen, ausweisen, überspringen |
| Betrag brutto | `betrag` | |
| Kategorie / Buchungskonto | Kategorisierungs-Hilfe | → Kostenblock-Mapping aus `KOSTEN-KATEGORIEN.md` |

**Doppelzählung vermeiden:** Eine Eingangsrechnung, die auch als Bank-Abbuchung im selben Zeitraum auftaucht, ist EINE Ausgabe. Bei aktiver Bank-Quelle plus sevDesk gilt: die Bank ist die führende Cash-Quelle, sevDesk liefert Anreicherung (Kategorie, Belegbezug). Verdachtsfälle in „Zu prüfen", nicht doppelt buchen.

## Bestätigte Excel-Schemas

Vom User bestätigte Spalten-Mappings für `exporte/excel/`. Der Skill trägt hier nach jeder Mapping-Bestätigung einen Block ein; strukturgleiche Folge-Importe laufen dann ohne Rückfrage.

_Noch keins bestätigt._

## Konto-Transfers (keine Kosten)

Geld zwischen **eigenen** Töpfen ist keine Ausgabe. Zwei Fälle:

1. **Haben-Seite:** Eine Bank-Gutschrift, deren Gegenpartei ein Zahlungsdienstleister ist (PayPal, Stripe, Mollie, Adyen und Vergleichbare) oder deren Zweck auf einen Übertrag hindeutet („Auszahlung", „Payout", „Übertrag"), ist ein Transfer, keine Einnahme. Wird übersprungen und gezählt.
2. **Soll-Seite (wichtig für die Kosten):** Eine Abbuchung an einen eigenen Topf, typisch die Sammelabrechnung einer Firmen-Kreditkarte (Pliant) oder ein Übertrag aufs Zweitkonto, ist KEINE Kostenbuchung. Sonst zählen die Einzeltransaktionen der Karte und die Sammelabbuchung der Bank doppelt, sobald beide Quellen aktiv sind. Eigene Konten und Karten-Abrechnungs-Gegenparteien hier vermerken:

| Eigener Topf | Signal (Gegenpartei/IBAN enthält) | seit |
|---|---|---|
| _(Beispiel) Zweitkonto Rücklagen_ | _DE89 3704…_ | _2026-07_ |

Im Zweifel nicht stillschweigend entscheiden: in die „Zu prüfen"-Queue und nachfragen.

## Belege-Intake (lose Kosten, `belege/`)

Für Kosten, die in keinem angebundenen System liegen: Belege ohne Kontobezug, Barzahlungen, und alles aus Zeiträumen, für die noch kein Export vorliegt. Diese Ausgaben liegen oft nur als PDF oder Foto vor. Dafür der Ordner `belege/`:

- Du wirfst Dateien **jeder Form** nach `belege/_neu/`, ohne vorher zu sortieren.
- Der Skill liest jede Datei, extrahiert Betrag, Datum, Empfänger/Zweck und ordnet sie einem **Kostenblock** aus `KOSTEN-KATEGORIEN.md` und einem **Standort** aus `STANDORTE.md` zu.
- Sind beide Zuordnungen eindeutig, wird der Posten gebaut und die Datei mit Datums- und Kategorie-Präfix nach `belege/analysiert/` verschoben.
- Ist eine Zuordnung **unklar**, rät der Skill nicht: er listet die Datei am Ende auf und fragt.

Die gültigen Kostenblöcke stehen in `KOSTEN-KATEGORIEN.md`, die Standorte in `STANDORTE.md`. Beide Taxonomien sind bewusst als eigene Dateien ausgelagert, damit sie sich ändern lassen, ohne den Skill anzufassen.

## Regel für den Skill

1. Nur System-Quellen mit Status `aktiv` verarbeiten.
2. Pro aktiver Datei-Quelle: alles in `_neu/` lesen, in die Auswertung einarbeiten, danach mit Datum-Präfix (`YYYY-MM-DD-`) nach `analysiert/` verschieben. Am Ende des Laufs prüfen, dass `_neu/` leer ist.
3. `belege/_neu/` immer verarbeiten: jede Datei zuordnen, Posten bauen, Datei nach `belege/analysiert/` verschieben. Unklare Zuordnungen nicht raten, sondern am Ende als Rückfrage sammeln.
4. `geplant`-Quellen überspringen und am Ende als Lücke nennen: „sevDesk noch nicht angebunden, dessen Kostenseite kommt diese Iteration aus Bank und Belegen."
5. Nie gegen geratene Spalten oder geratene Kategorien arbeiten. Unbekanntes Schema: bei `excel` das interaktive Mapping (SKILL.md), sonst stoppen und nach echtem Export/Schema fragen.
