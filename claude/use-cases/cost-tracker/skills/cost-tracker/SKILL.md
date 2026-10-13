---
name: cost-tracker
description: Kostenüberblick, der nachvollziehbar bleibt. Liest Bank-CSV, Kontoauszug-PDFs, Belege und Excel-Exporte ein, ordnet jede Ausgabe einem Kostenblock UND einem Standort zu und zeigt, wohin das Geld geht, welche Blöcke wiegen, was davon fix ist und was welcher Standort kostet. Dazu ein fester Beobachtungs-Katalog (Ausreißer, Doppel-Abos, Preiserhöhungen), jede Beobachtung mit Beleg. Schreibt kosten.md als Text-Wahrheit fort, rendert auswertung.xlsx und dashboard.html als Ansichten, protokolliert jeden Lauf im CHANGELOG. Jede Zahl führt auf eine Quelle oder eine benannte Annahme zurück. Kann zwischendurch auch nur einen Posten erfassen oder vormerken (Quick-Capture), ohne vollen Lauf. Nutze diesen Skill, wenn im aktuellen Projekt ein kosten/-Ordner liegt und der User sagt "wohin geht mein Geld", "was kostet mich das im Monat", "kosten nach standort", "lies meinen Kontoauszug ein", "cost-tracker".
when_to_use: |
  Trigger-Phrasen voller Lauf: "wohin geht mein Geld", "was kostet mich das im Monat", "welche Kosten habe ich", "zeig mir meine Kostenblöcke", "kosten nach standort", "was kostet mich Standort X", "wo kann ich sparen", "lies meinen Kontoauszug ein", "lies die Quellen in kosten/ ein", "cost-tracker". Trigger-Phrasen Quick-Capture (kein voller Lauf): "50 Euro Parken heute" und ähnliche Ist-Belege per Zuruf, "merk dir: in X Wochen kommt eine Rechnung über Y", "vormerken: ...". Voraussetzung: im aktuellen Projekt existiert ein kosten/-Ordner (aus dem Bundle-vorlage/). Nicht triggern für allgemeine Steuer-/Buchhaltungsfragen ohne diesen Ordner, und nicht für Liquiditäts-/Runway-Fragen ("wie lange reicht das Geld"): das ist ein anderer Use Case, sag das dann ehrlich.
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion, Bash(ls:*), Bash(mkdir:*), Bash(mv:*), Bash(python3:*), Bash(python:*), Bash(py:*), Bash(pip3:*), Bash(git:*)
---

# Kosten-Tracking

Dieses Tool beantwortet eine Frage: **wohin geht mein Geld?** Je Kostenblock, je Standort, fix gegen variabel, Monat für Monat. Es braucht nichts als einen Kontoauszug und trifft keine einzige Annahme über die Zukunft. Jede Zahl darin ist eine Zahl, die tatsächlich geflossen ist.

**Bewusst NICHT in diesem Tool: Umsätze, Kontostand, Forecast, Liquidität.** Das ist ein anderer Use Case. Fragt der User danach ("wie lange reicht das Geld"), sag ehrlich, dass dieses Tool das nicht beantwortet, und biete die Kostensicht an.

Jeder Posten bekommt **zwei Zuordnungen**: einen Kostenblock aus `KOSTEN-KATEGORIEN.md` und einen Standort aus `STANDORTE.md` (inklusive `uebergreifend` für zentrale Kosten). Beides sind editierbare Dateien, kein Code.

Das Leitprinzip gilt absolut: **die Wahrheit ist Text (`kosten.md`), Excel und Dashboard sind nur Ansichten** und werden nie zurückgelesen. Jede Zahl führt auf eine Quelle oder eine benannte Annahme zurück. Du rechnest nie still, du rätst nie eine Zuordnung, du erfindest keine fehlende Zahl. Kannst du einen Posten nicht zuordnen, fragst du den User, statt zu raten.

## 0. Orientierung (immer zuerst)

1. Finde das Arbeitsverzeichnis: den Ordner `kosten/` im aktuellen Projekt (er entstand aus `vorlage/`). Alle Pfade unten sind relativ dazu.
2. Lies in dieser Reihenfolge, ohne sie zu duplizieren:
   - `ANNAHMEN.md`: Konfiguration (Währung), **Fixkosten-Tabelle**, **Erwartete Kosten**, Geklärte Beobachtungen, aktive Annahmen.
   - `SOURCES.md`: welche Quelle `aktiv` ist, die Schemas, die Transfer-Regeln.
   - `KOSTEN-KATEGORIEN.md`: die gültigen Kostenblöcke und Zuordnungs-Regeln.
   - `STANDORTE.md`: die gültigen Standorte und die Signal-Regel-Tabelle.
   - `kosten.md` + `CHANGELOG.md`: den bisherigen Stand (bei Folgeläufen der Ausgangspunkt fürs Diff).
3. Bestimme die Betriebsart (Schritt 1) und bei vollem Lauf die nächste Iterationsnummer aus dem `CHANGELOG.md`.

## 1. Betriebsart: Quick-Capture oder voller Lauf

### Quick-Capture (kein voller Lauf)

Zwei Fälle, beide enden nach der Bestätigung, ohne Excel, ohne Dashboard, ohne CHANGELOG-Eintrag (die Zeile selbst ist der Diff):

- **Ist-Beleg per Zuruf** ("50 Euro Parken heute, Frankfurt"): Datum, Betrag, Zweck extrahieren, Kostenblock und Standort zuordnen (bei Unklarheit kurz nachfragen), als GENAU EINE Journal-Zeile in `kosten.md` eintragen, `quelle: beleg`. Bestätige die Zeile im Klartext.
- **Künftiger Posten vormerken** ("in 3 Wochen kommt eine Rechnung über 300 Euro"): Datum (relatives Datum konkret auflösen), Betrag, Beschreibung, Kostenblock, Standort. Als GENAU EINE Zeile in `ANNAHMEN.md` unter `## Erwartete Kosten` eintragen, Status `offen`. Bestätige die Zeile im Klartext ("Vorgemerkt: 21.08., 300 Euro, Agentur-Rechnung, fremdleistungen, uebergreifend").

Ein wiederkehrender Posten ("ab sofort 89 Euro monatlich für Tool X") gehört stattdessen in die **Fixkosten-Tabelle**, gleiche Mechanik.

Alles andere ist ein **voller Lauf** (Schritte 2 bis 9).

### First-Run-Onboarding (nur wenn Config unvollständig)

Prüfe `ANNAHMEN.md` und `STANDORTE.md`. Sind sie noch im Beispiel-Zustand (typisch beim allerersten Lauf), stelle die offenen Fragen **einmal gebündelt** via `AskUserQuestion`:

- **Währung**: Standard `EUR`.
- **Standorte**: Welche gibt es (inklusive geplanter, die schon Kosten verursachen)? Woran erkennt man sie in Buchungen (Stichworte, getrennte Konten)? Das füllt Register und Regel-Tabelle in `STANDORTE.md`. Beispielzeilen ersetzen.
- **Fixkosten (Verträge)**: die laufenden, regelmäßigen Zahlungen (Gehälter, Miete, SaaS, Steuerberater, Versicherungen) mit Betrag, Rhythmus, Match-Stichwort, Kostenblock, Standort. Lieber grob vollständig als perfekt: der Skill schlägt später Ergänzungen vor, wenn er Wiederkehrendes in den Quellen sieht.
- **Schon bekannte terminierte Kosten**: erwartete Rechnungen, geplante Umbauten. Landen als Erwartete Kosten.

Es gibt KEINE Kontostand-Frage und KEINE Schätzfrage nach sonstigen Monatskosten: die Ist-Daten beantworten das selbst. Schreibe die Antworten in die Dateien und entferne beantwortete Punkte aus `## Offene Fragen`.

## 2. Datenmodell (pro Buchung)

Das Buchungsjournal in `kosten.md` enthält NUR echte Kostenbuchungen (Ist). Erwartete Kosten stehen in `ANNAHMEN.md` und im eigenen Abschnitt, nie im Journal.

- `id`: lesbarer Dedup-Schlüssel: `<quelle>-<datum ISO>-<betrag>-<gegenpartei normalisiert>` plus Zähl-Suffix `-1`, `-2`, ... Normalisierung der Gegenpartei: Kleinbuchstaben, ohne Sonderzeichen, erste 30 Zeichen. Beispiel: `bank-2026-06-03-49.00-telekom-1`.
- `datum`: der Tag, an dem das Geld tatsächlich fließt (Cash-Datum).
- `betrag`: positiv = Kosten, **negativ = Erstattung**.
- `gegenpartei`: der Begünstigte.
- `zweck`: Verwendungszweck. Bewusst NICHT Teil des Dedup-Schlüssels (variiert zwischen Exportformaten derselben Bank).
- `kategorie`: Kostenblock-Slug aus `KOSTEN-KATEGORIEN.md` oder `uncategorized`.
- `fix_var`: `fix` oder `var`. Kommt aus der Fix/Var-Spalte der Kategorie; bei „beides"-Kategorien entscheidet der Fixkosten-Tabellen-Match (Match-Stichwort in Gegenpartei/Zweck UND Betrag ±10 %). Kein Match = `var`.
- `standort`: Slug aus `STANDORTE.md` inklusive `uebergreifend`, oder `unklar` (landet in „Zu prüfen").
- `quelle`: `bank` / `beleg` / `excel` / `pliant` / `sevdesk`.
- `confidence`: bei automatischer Zuordnung, getrennt für Kategorie und Standort gedacht, Schwelle je 0.85.
- `status`: `ist` (verbucht) oder `offen` (wartet auf Rückfrage).
- `notiz`: optional (z.B. "Erstattung zu bank-2026-05-12-...", "Duplikat-Verdacht Lauf 3").

## 3. Ingestion pro Quelle

Arbeite nur Quellen mit Status `aktiv` aus `SOURCES.md` ab. **Fenster-Default: die letzten 3 vollen Monate plus der laufende Monat** (mehr nur auf expliziten Wunsch; ältere Daten bleiben im Journal stehen).

**Lauf ohne neue Dateien:** Sind alle `_neu/`-Ordner leer, ist das kein Fehler. Dann laufen trotzdem die Checks aus Schritt 5, der Beobachtungs-Katalog und die Renderings; der Stand weist aus: "keine neuen Daten in diesem Lauf". Der Übersprungen-Zähler im Stand wird je Quelle kumuliert fortgeführt (mit Iterations-Angabe), zusätzlich nennt der Stand den Zähler des aktuellen Laufs.

### Bank-CSV (`exporte/bank/_neu/`)

Das Normalfall-Schema steht in `SOURCES.md` (Semikolon, deutsches Zahlenformat, Soll/Haben-Spalte, zweistelliges Jahr, Nicht-EUR = stoppen). Weicht ein Export ab: Schema nicht raten, fragen.

**Soll-Buchungen (Abflüsse):** als Kostenbuchung erfassen und zuordnen (Schritt 4). **Ausnahme:** eine Abbuchung an einen eigenen Topf (Zweitkonto, Kreditkarten-Sammelabrechnung, siehe Transfer-Tabelle in `SOURCES.md`) ist KEINE Kostenbuchung, sonst zählt sie doppelt, sobald die Karten-Quelle aktiv ist. Überspringen und zählen.

**Haben-Buchungen (Zuflüsse), die Dreiweiche, in dieser Reihenfolge prüfen:**

1. **Erstattung:** Der Zweck trägt ein Erstattungs-Signal (`Erstattung`, `Storno`, `Gutschrift`, `Rückvergütung`) UND die Gegenpartei hat im Journal eine frühere Soll-Buchung. Dann als **negative Kosten** im Kostenblock und Standort der Ursprungsbuchung erfassen, mit `notiz`-Verweis auf deren `id`.
2. **Transfer:** Die Gegenpartei ist ein Zahlungsdienstleister (PayPal, Stripe, Mollie, Adyen und Vergleichbare) oder der Zweck deutet auf einen Übertrag aus einem eigenen Topf ("Auszahlung", "Payout", "Übertrag"). Überspringen, als Transfer zählen.
3. **Einnahme:** alles andere. Überspringen, als Einnahme zählen.

**Übersprungenes wird IMMER gezählt** und im Stand-Abschnitt ausgewiesen: "14 Haben-Buchungen über 23.400 EUR übersprungen (Einnahmen sind nicht Thema dieses Tools), davon 2 als Transfer erkannt." So sieht der User, dass nichts still verschwunden ist. Ist unklar, ob ein Zufluss Erstattung oder Einnahme ist: nachfragen, nie still entscheiden.

### Kontoauszug als PDF (läuft als Bank-Quelle)

Enthält eine Datei (typisch in `belege/_neu/`) nicht einen Beleg, sondern **viele Buchungen**, dann ist sie keine Beleg-Datei, sondern eine Bank-Quelle in anderem Gewand. Alle Zeilen einzeln erfassen und dieselben Bank-Regeln anwenden (Soll/Haben, Dreiweiche, Transfers). `quelle` ist `bank`, nicht `beleg`, damit der Dedup gegen einen späteren CSV-Export desselben Zeitraums greift.

**Vorher einmal verifizieren:** Aus einem PDF gelesene Tabellen sind fehleranfälliger als eine CSV (verrutschte Spalten, zusammengezogene Beträge, Zeilenumbrüche im Verwendungszweck). Deshalb nach dem Einlesen die **Summe der erfassten Zeilen gegen den im Auszug ausgewiesenen Saldo oder die Umsatzsumme** halten und das Ergebnis nennen. Weicht es ab: nicht weiterrechnen, sondern die Abweichung zeigen und in „Zu prüfen" vermerken. Wenn es die Bank hergibt, ist ein CSV-Export der verlässlichere Weg.

### Belege (`belege/_neu/`): immer verarbeiten

- Jede Datei lesen (PDF/Foto/CSV/Screenshot), Betrag/Datum/Empfänger/Zweck extrahieren, als Kostenbuchung erfassen, `quelle: beleg`.
- Kostenblock und Standort zuordnen (Schritt 4).
- Nach Verarbeitung mit `YYYY-MM-DD-<kategorie>-`-Präfix nach `belege/analysiert/` verschieben (`mv`).

### Excel generisch (`exporte/excel/_neu/`): interaktives Mapping statt Raten

Der Weg für „irgendeine Tabelle mit Kostendaten" (eigene Auswertungen, Tool-Exporte ohne vorbereitetes Schema):

1. Datei öffnen (`openpyxl` bzw. CSV-Parser), Blätter und Kopfzeilen sichten.
2. Spalten-Kandidaten erkennen: Datum, Betrag, Gegenpartei/Beschreibung, optional Kategorie und Standort.
3. Das erkannte Mapping dem User via `AskUserQuestion` VORLEGEN ("Ich lese Blatt 'Ausgaben', Spalte B als Datum, D als Betrag in Euro, C als Empfänger. Stimmt das?"). **Erst nach Bestätigung einlesen, nie vorher.**
4. Das bestätigte Mapping als Block unter „Bestätigte Excel-Schemas" in `SOURCES.md` festschreiben. Strukturgleiche Folge-Importe (gleiche Kopfzeilen) laufen dann ohne Rückfrage.
5. Zuflüsse in der Tabelle: gleiche Dreiweiche wie bei der Bank.

### Datei-Quellen mit vorbereitetem Schema (sevDesk/Pliant): nur wenn `aktiv`

- `exporte/<slug>/_neu/` lesen, Schema aus `SOURCES.md`. Unbekannter Spaltenaufbau: stoppen und nach echtem Export fragen.
- sevDesk: nur **Eingangsrechnungen** verbuchen. Ausgangsrechnungen sind Umsatz: zählen, ausweisen, überspringen. Offene Eingangsrechnungen mit Fälligkeit NICHT ins Journal, sondern als **Erwartete Kosten** in `ANNAHMEN.md` vorschlagen.
- `geplant`-Quellen überspringen und am Ende als Lücke melden (kein Fehler).
- Nach Verarbeitung mit `YYYY-MM-DD-`-Präfix nach `analysiert/` verschieben.

## 4. Zuordnung: Kostenblock und Standort

Für jede erfasste Kostenbuchung, gleiche Mechanik für beide Dimensionen:

1. **Kostenblock** aus Gegenpartei, Zweck und Betrag gegen `KOSTEN-KATEGORIEN.md`. Confidence < 0.85 = `uncategorized`, `status: offen`.
2. **Fix oder variabel:** Kategorie-Default; bei „beides"-Kategorien entscheidet der Fixkosten-Tabellen-Match (Match-Stichwort UND Betrag ±10 %). Kein Match = `var`.
3. **Standort** über die Regel-Tabelle in `STANDORTE.md` (Signal-Stichwort in Gegenpartei oder Zweck; bei getrennten Konten setzt die Quelldatei den Standort). Kein Signal und kein klarer `uebergreifend`-Fall mit Confidence >= 0.85: `standort: unklar`, `status: offen`.
4. **Erstattungen** erben Block und Standort ihrer Ursprungsbuchung, keine eigene Zuordnung.
5. **Rückfragen am Ende bündeln,** nicht pro Posten unterbrechen: eine `AskUserQuestion`-Runde für alle `uncategorized` und alle `unklar` (je Posten: Betrag, Datum, Gegenpartei, Vorschlag). Aus den Antworten: Buchung aktualisieren und, wo ein wiederverwendbares Signal erkennbar ist, die passende neue Regel-Zeile für `STANDORTE.md` (oder den neuen Block für `KOSTEN-KATEGORIEN.md`) VORSCHLAGEN. Nie eigenmächtig eintragen.
6. Bleibt ein Posten unbeantwortet, bleibt er `offen`. Er erscheint trotzdem im Journal und in den Matrizen (in der `uncategorized`-Zeile bzw. der `unklar`-Zeile der Standort-Matrix), damit die Monatssummen vollständig bleiben und nichts still untertrieben wird. Zusätzlich wird er im Cockpit über den Offene-Posten-Zähler ausgewiesen. In Beobachtungen des Katalogs fließt er nicht ein.

## 5. Wiederhol-Lauf (rollierend, typisch wöchentlich)

- **Dedup über die `id`-Anzahl:** Belege und Exporte akkumulieren über die Ordnerlogik (`_neu/` wird verarbeitet und nach `analysiert/` verschoben, nie zweimal gelesen). Überlappen sich Exporte trotzdem (Kontoauszug-PDF plus CSV desselben Monats), gilt: pro Dedup-Schlüssel die ANZAHL der Instanzen vergleichen. Neue Datei hat mehr Instanzen als das Journal: Differenz aufnehmen und als Duplikat-Verdacht in „Zu prüfen" ausweisen. Gleich viele oder weniger: nichts tun. Nie still entscheiden.
- **Gleicher Schlüssel mehrfach INNERHALB einer Datei** ist eine legitime Mehrfachbuchung (zweimal tanken am selben Tag): Suffix zählt hoch, beide bleiben.
- **Erwartete Kosten abgleichen (Lifecycle).** Für jeden Posten mit Status `offen` und Datum in der Vergangenheit:
  - Passt eine echte Journal-Buchung dazu (Betrag ähnlich, Zeitraum nah, Gegenpartei plausibel): Status auf `erledigt` setzen mit Verweis auf die Buchungs-`id`. **Nie beides zählen** (Erwartete Kosten zählen ohnehin in keiner Ist-Summe, aber der Status muss stimmen).
  - Passt nichts: via `AskUserQuestion` klären (kommt noch: Datum verschieben / kommt nicht mehr: streichen / ist schon gelaufen: erledigt abhaken). Nie still verfallen lassen.
- **Fixkosten-Vollständigkeits-Check:** je Zeile der Fixkosten-Tabelle prüfen, ob im letzten vollen Monat eine passende Buchung existiert (Match-Stichwort UND Betrag ±10 %). Fehlt eine: als Datenlücken-Hinweis in den Stand ("Miete hatte im Juni keine Buchung, fehlt ein Export?"). Nicht nachbuchen, nur melden.
- **Wiederkehrer-Vorschlag:** sieht der Skill in den Quellen einen wiederkehrenden Posten (Definition aus Schritt 7: gleiche Gegenpartei in mindestens 2 aufeinanderfolgenden vollen Monaten, jedes Vorkommen ±10 % zum vorherigen), der nicht in der Fixkosten-Tabelle steht, schlägt er die Aufnahme vor. Nie eigenmächtig eintragen.

## 6. kosten.md fortschreiben (die Wahrheit)

Schreibe `kosten.md` mit dieser Struktur; jede Kennzahl bekommt ihre Herkunft:

1. **Stand**: Datum des Laufs, Fenster, gelesene Quellen mit Zeilenzahlen, der Übersprungen-Zähler (Einnahmen/Transfers), Datenlücken je Monat und Quelle ("Juni hat Bankdaten, Juli erst bis zum 15.").
2. **Kosten-Cockpit**:
   - **Gesamtkosten des letzten vollen Monats** mit Veränderung zum Vormonat. **Achtung, häufiger Fehlgriff:** Das ist NICHT die letzte Zeile der Monats-Matrix. Die letzte Zeile ist der laufende, noch unvollständige Monat. Gemeint ist die Zeile davor. Wer die letzte nimmt, zeigt einen halben Monat als vollen und untertreibt.
   - **Die drei größten Kostenblöcke** des letzten vollen Monats, je mit Betrag und Anteil an den Gesamtkosten.
   - **Fix-Quote**: wie viel des Monats als `fix` eingestuft war (Kategorie-Default oder Fixkosten-Match), wie viel disponibel. Das ist die Zahl, an der ein Unternehmer etwas ändern kann. Nicht als "vertraglich gebunden" verkaufen: der Kategorie-Default ist eine Einstufung, kein nachgewiesener Vertrag. Blöcke mit Fix/Var `-` (privatentnahme, uncategorized) bleiben aus Zähler UND Nenner der Fix-Quote draußen und werden, falls vorhanden, als eigener Posten daneben genannt.
   - **Veränderung zum Vormonat je Block**, absolut und in Prozent.
   - **Kosten je Standort** mit Anteil an den Gesamtkosten.
   - **Offene Posten** (Anzahl + Summe der „Zu prüfen"-Queue). Alert, wenn > 2 % der Gesamtkosten des letzten vollen Monats. Gibt es noch keinen vollen Monat, entfällt der Alert und die offenen Posten werden nur gelistet.
3. **Monats-Matrix (Kostenblock × Monat)**: die letzten 3 vollen Monate + laufender Monat bisher (als unvollständig markiert). Je Block eine Zeile, Summenzeile, getrennte Fix- und Variabel-Summenzeilen. Erstattungen mindern die Summe ihres Blocks; ein dadurch negativer Blockmonat ist legitim und bekommt eine Fußnote (Erstattung größer als die Kosten des Monats), keine Fehlersuche.
4. **Standort-Matrix**: Standort × Kostenblock für den letzten vollen Monat, darunter Standort × Monat als Zeitreihe. `uebergreifend` ist eine eigene Zeile, kein Rest.
5. **Erwartete Kosten (terminiert)**: aus `ANNAHMEN.md` gespiegelt, mit dem Satz "zählt in keiner Summe oben mit".
6. **Beobachtungen und Empfehlungen**: der Katalog-Output aus Schritt 7. Wird je Lauf komplett neu erzeugt (er ist abgeleitet wie ein Rendering, steht aber im Text, damit er im Git-Diff sichtbar ist).
7. **Buchungsjournal**: jede Buchung eine Zeile mit allen Feldern aus Schritt 2.
8. **Zu prüfen**: `status: offen`-Zeilen (uncategorized, `standort: unklar`), Duplikat-Verdachte, gescheiterte PDF-Summenproben, überfällige Erwartete Kosten.

## 7. Beobachtungs-Katalog (geschlossene Liste)

Empfehlungen entstehen **ausschließlich** aus diesen sechs Regeln. Jede Beobachtung nennt ihren Regel-Slug, die Zahlen und die belegenden Buchungs-IDs, und endet in einer Frage an den User, nie in einer Ursachen-Behauptung. Beobachtungen, die in `ANNAHMEN.md` unter „Geklärte Beobachtungen" stehen, werden nicht erneut gemeldet. **Alle Regeln arbeiten nur auf vollen Monaten**; der laufende, unvollständige Monat löst keine Beobachtung aus. „Wiederkehrend" heißt überall: aufeinanderfolgende monatliche Vorkommen, jedes innerhalb von ±10 % des jeweils vorherigen. Zur Abgrenzung von Schritt 4.6: „ein offener Posten fließt in keine Beobachtung ein" heißt, er löst selbst keine Beobachtung aus und dient nicht als Beleg; Kennzahlen aus Schritt 6 (etwa die Fix-Quote) gehen unverändert in Beobachtungen ein, auch wenn ihre Monatssummen offene Posten enthalten.

1. `ausreisser`: Der letzte volle Monat eines Blocks weicht > 40 % UND > 250 EUR vom Mittel der (bis zu 3) vollen Monate davor ab; gibt es weniger als 2 Vergleichsmonate, entfällt die Regel. **Streuungs-Vorbehalt:** liegt die Standardabweichung der Vergleichsmonate über einem Viertel ihres Mittels, ist die Reihe unruhig und das Mittel keine belastbare Referenz; dann die Reihe zeigen statt den Ausreißer zu melden.
2. `doppel-abo`: Zwei verschiedene Gegenparteien, gleiche Kategorie, beide monatlich wiederkehrend (mindestens 2 aufeinanderfolgende volle Monate). Als Frage formulieren ("beide gebraucht?"), nie als Urteil.
3. `preiserhoehung`: Gleiche Gegenpartei, der letzte volle Monat liegt > 10 % über dem Mittel ihrer (bis zu 3) vollen Monate davor. Die Wiederkehr wird auf den Monaten DAVOR geprüft (mindestens 2), der letzte volle Monat wird dagegen gehalten; sonst würde die Preiserhöhung selbst die Wiederkehr disqualifizieren.
4. `wiederkehrer`: Wiederkehrender Posten ohne Fixkosten-Zeile (siehe Schritt 5), als Aufnahme-Vorschlag.
5. `fix-quote`: Fix-Quote über 70 % als Fakt benennen (hoher als `fix` eingestufter Anteil), ohne Bewertung und ohne das Wort "vertraglich" (siehe Schritt 6.2).
6. `standort-vergleich`: Gleicher Kostenblock an zwei Standorten mit Faktor >= 2 Unterschied, mit beiden Zahlenreihen. Nur vergleichen, wenn beide Standorte volle Daten im Monat haben (Datenlücken zuerst prüfen).

## 8. Ansichten rendern

Beide Ansichten werden bei jedem Lauf **komplett neu erzeugt** (nie manuell editieren, nie zurücklesen). Python/`openpyxl` für die Excel; fehlt `openpyxl`, sag es dem User (`pip3 install openpyxl`, Windows: `py -3 -m pip install openpyxl`; scheitert das an einer extern verwalteten Python-Umgebung, ist `pip3 install --user openpyxl` oder `python3 -m pip install --break-system-packages openpyxl` der Weg, vorher ankündigen).

### auswertung.xlsx

| Tab | Inhalt |
|---|---|
| `00_Cockpit` | die Cockpit-Kennzahlen, per Formel auf die anderen Tabs referenziert |
| `01_Monate` | die Monats-Matrix: Block × Monat, Summen- und Fix/Var-Zeilen als echte Excel-Formeln |
| `02_Standorte` | Standort × Block (letzter voller Monat) und Standort × Monat, Summen als Formeln |
| `03_Buchungen` | das vollständige Journal, eine Zeile pro Buchung, AutoFilter; `offen`-Zeilen farblich markiert |

- **Beträge sind echte Zahlen mit Zahlformat**, nie Text-Strings. Deutsches Anzeigeformat über das Excel-Zahlformat, nicht über formatierte Strings.
- Nur Journal-Werte sind statisch; jede abgeleitete Zelle (Summen, Anteile, Deltas) ist eine echte Excel-Formel.
- **Die xlsx wird nie zurückgelesen.** Wahrheit ist `kosten.md`. Wer in der Excel etwas ändert, ändert eine Ansicht, nicht die Daten.

### dashboard.html

Eine self-contained HTML-Datei im selben Ordner. **Komplett offline: Inline-CSS, Inline-JS, Diagramme als hand-gerolltes SVG. KEINE externen Ressourcen, kein CDN** (Finanzdaten bleiben lokal, die Datei muss ohne Netz im Browser aufgehen).

Inhalt:
- **Gesamtkosten-Kachel** groß: letzter voller Monat, Delta zum Vormonat, Stand-Datum.
- **Top-3-Kostenblöcke** mit Anteilen, **Fix-Quote** als eigene Kachel.
- **Block × Monat** als gestapelte Balken (die letzten 3 vollen Monate + laufender, laufender markiert).
- **Kosten je Standort** als Balken.
- **Beobachtungen** als Liste (Regel-Slug + Aussage), **Zu prüfen** als Hinweisblock, falls vorhanden.

**Zahlformat ist deutsch: `1.234,56 EUR`.** Im JS konsequent `toLocaleString('de-DE', ...)` verwenden, keine englischen Defaults.

**Verifikation:** Browser-Werkzeuge wie `playwright-cli` können `file://`-URLs oft nicht öffnen. Zum Prüfen im Ordner `python3 -m http.server` starten und über `http://localhost:8000/dashboard.html` rendern, danach den Server beenden. Unter Windows ist `python3` oft nur der Microsoft-Store-Stub: schlägt der Aufruf fehl, stattdessen `python` oder `py -3` verwenden.

## 9. Abschluss jedes Laufs

1. **CHANGELOG.md** fortschreiben (eine Sektion pro Lauf, Format aus der Datei): gelesene Quellen + Zeilen, was sich geändert hat, neue/geänderte Annahmen und Erwartete Kosten, offene Lücken.
2. Verarbeitete Exporte + Belege nach `analysiert/` verschieben (siehe Schritt 3) und prüfen, dass alle `_neu/`-Ordner leer sind (`SOURCES.md`, Regel für den Skill).
3. Dem User einen **kompakten Report** geben: Gesamtkosten des letzten vollen Monats mit Delta, die größten Blöcke, auffällige Beobachtungen, „Zu prüfen"-Rückfragen, welche `geplant`-Quellen noch fehlen. Keinen Excel-Dump im Chat.
4. Nicht ungefragt committen: das stößt der User bewusst nach Diff-Prüfung an (siehe README, "sichere diese Iteration als Version"). Wenn er das tut: Änderungen in Alltagssprache zusammenfassen, dann committen. Existiert im Projekt noch kein Git-Repo, einmalig anbieten, es einzurichten (`git init` + erster Commit), damit die Versionierung ab Iteration 1 greift.

## Später erweiterbar (bewusst NICHT in dieser Version)

Zahlungsanbieter-Gebühren live per Connector (nur die Gebühren-Seite), CAMT.053-XML, Budget-Ziele je Block, Kostenstellen-Sync mit der Buchhaltung. Die getrennte Text-Wahrheit macht das möglich, ohne den Bestand umzubauen. Liquiditätsplanung ist KEIN Ausbau dieses Tools, sondern ein eigener Use Case.

## Eiserne Regeln

- Rechne nie still: jede Zahl mit Herkunft (Quelldatei oder benannte Annahme).
- **Nur Ist.** Keine Prognose, keine Fortschreibung, keine geschätzte Zahl. Fehlt etwas, ist es eine offene Frage.
- Rate nie eine Kategorie: Confidence < 0.85 = `uncategorized` + Rückfrage.
- Rate nie einen Standort: kein Signal = `unklar` + Rückfrage. `uebergreifend` ist eine bewusste Zuordnung, kein Default.
- **Einnahmen werden nie verbucht, nur gezählt** und im Stand ausgewiesen. Ausnahme: Erstattungen als negative Kosten im Ursprungsblock.
- **Erwartete Kosten zählen in keiner Ist-Summe.** Lifecycle pflegen: Match = `erledigt`, überfällig = nachfragen, nie still verfallen lassen.
- Rate nie ein Datei-Schema: `excel` läuft über das interaktive Mapping, alles andere stoppt bei Unbekanntem.
- **Keine Empfehlung ohne Buchungs-IDs. Keine Aussage außerhalb des Beobachtungs-Katalogs.** Ursachen werden erfragt, nicht behauptet.
- Neue Kostenblöcke, Standorte, Regel-Zeilen und Fixkosten-Zeilen nur nach Bestätigung des Users.
