# Kostenüberblick, der nachvollziehbar bleibt

Deine Kosten liegen auf dem Bankkonto, auf Firmenkarten, in losen Belegen und irgendwelchen Excel-Listen. Die Frage „wohin geht eigentlich unser Geld, und was kostet uns welcher Standort?" beantwortet keines dieser Systeme, und wer es von Hand zusammenzieht, hat am Ende eine Zahl, die niemand mehr nachvollziehen kann.

Diese Version macht bewusst nur die eine, wichtigste Sache: **die Kostenseite, vollständig und belegbar.** Jede Ausgabe wird einem **Kostenblock** (was für Kosten?) und einem **Standort** (wo entstanden?) zugeordnet. Daraus entstehen die Antworten, die man steuern kann: die größten Blöcke, die Fix-Quote, die Veränderung zum Vormonat, der Standort-Vergleich, plus ein fester Katalog von Beobachtungen (Ausreißer, Doppel-Abos, Preiserhöhungen), jede mit Beleg. Keine Umsätze, kein Forecast, keine Liquidität: das ist ein anderer Use Case und lässt sich später getrennt aufbauen.

Und das Prinzip dahinter: **Die Wahrheit ist Text, Excel und Dashboard sind nur Ansichten.** Jede Zahl führt auf eine benannte Annahme oder eine Quelldatei zurück, jede Änderung ist ein Git-Diff. Das ist mehr Nachvollziehbarkeit als Excel, wo die Annahme unsichtbar in der Formel steckt.

```
exporte/<quelle>/_neu/     Claude                  Ausgabe
──────────────────────     ──────                  ───────
CSV, XLSX, PDF         →   /cost-tracker      →    kosten.md        (die Wahrheit)
Belege, Fotos              liest, ordnet zu,       auswertung.xlsx  (Ansicht: Excel)
                           dokumentiert            dashboard.html   (Ansicht: Browser)
                                │                  CHANGELOG.md     (der Nachweis)
                                ▼
                           verschiebt Verarbeitetes nach _neu/ → analysiert/
```

## Konventionen in dieser Anleitung

- **„Sag Claude:"** + Block — du tippst das in den **Chat** von Claude Code.
- Der Ordner `vorlage/` ist das leere Gerüst. Es zieht in dein Projekt ein und heißt dort `kosten/`.

## Voraussetzungen

- Standard-Bootstrap (`bash mac/bootstrap.sh`, Windows: `bash windows/bootstrap.sh`) ist durchgelaufen.
- Python mit `openpyxl` (für den Excel-Render): `pip3 install openpyxl` (Windows: `py -3 -m pip install openpyxl`), falls nicht vorhanden. Claude sagt dir, wenn es fehlt.
  **Wenn das mit `externally-managed-environment` abbricht** (aktuelles macOS mit Homebrew-Python, häufig): Das ist kein Fehler bei dir, Python schützt nur seine Systeminstallation. Sag Claude einfach „installier openpyxl in einer venv" — er legt eine ab und nutzt sie. Alternativ `pip3 install --break-system-packages openpyxl`, das ist hier unbedenklich, weil `openpyxl` ein reines Zusatzpaket ist.
- Ein Kosten-Export zum Starten: der CSV-Umsatzexport deines Bankkontos ist der beste Einstieg (jede Bank bietet ihn im Online-Banking an). Es geht aber auch mit einem Kontoauszug-PDF, losen Belegen oder einer Excel-Liste. Connectoren braucht diese Version keine.

## Schritt 1 — Projekt anlegen

```
/new-project
```

Damit hast du CLAUDE.md, STATE.md und einen `.claude/`-Ordner.

## Schritt 2 — Bundle ins Projekt holen

Sag Claude (er kennt sein Working-Verzeichnis und legt die Dateien passend ab):

```
Lade das Use-Case-Bundle "cost-tracker" aus meinem Setup-Repo:
~/ai-os-core/claude/use-cases/cost-tracker

Platziere es in meinem aktuellen Projekt so:
- vorlage/              → ./kosten/   (mit allen Unterordnern)
- skills/cost-tracker/  → .claude/skills/cost-tracker/

Bestätige mir, welche Dateien und Ordner angekommen sind.
```

Danach `/exit` und `claude` neu starten, damit der Skill geladen wird.

## Schritt 3 — Leitplanken in deine Projekt-CLAUDE.md

Die Rechenregeln kennt der Skill selbst. Was er nicht abdeckt, sind die paar Punkte, die auch dann gelten sollen, wenn du ohne ihn im Ordner arbeitest (etwa `kosten.md` von Hand aufmachst). Die gehören in die CLAUDE.md deines Projekts, die aus Schritt 1 schon existiert. Sag Claude:

```
Ergänze die CLAUDE.md dieses Projekts um einen Abschnitt "Kosten-Tracking"
mit diesen Punkten. Bestehende Inhalte nicht umschreiben, nur anhängen:

- kosten/kosten.md ist die Single Source of Truth. auswertung.xlsx und
  dashboard.html sind nur Ansichten, werden bei jedem Lauf neu erzeugt und
  nie zurückgelesen. Wer dort etwas ändert, verliert es beim nächsten Lauf.
- Jede Zahl im Ordner kosten/ führt auf eine Quelldatei oder eine benannte
  Annahme zurück. Nie still rechnen, nie eine fehlende Zahl schätzen.
- Der Ordner kosten/ gehört in Git. Jede Iteration wird committet, damit die
  Historie steht.
- Sprache Deutsch, echte Umlaute.
- Keine Lohndaten und keine Klarnamen in kosten/, nur aggregierte
  Finanzdaten.
```

## Schritt 4 — Erste Iteration bauen

Leg deinen Bank-Export nach `kosten/exporte/bank/_neu/` (oder Belege nach `kosten/belege/_neu/`). Dann sag Claude:

```
Lies die Quellen in kosten/ ein und zeig mir, wohin unser Geld geht.
```

Der Skill `cost-tracker` läuft an:
1. liest `SOURCES.md`, `ANNAHMEN.md`, `KOSTEN-KATEGORIEN.md` und `STANDORTE.md`,
2. fragt dich beim allerersten Lauf einmal gebündelt nach deinen **Standorten** (und woran man sie in Buchungen erkennt), deinen **Fixkosten-Verträgen** und schon bekannten terminierten Kosten. Kein Kontostand, keine Schätzfragen: alles Weitere kommt aus den echten Daten,
3. liest alles in `_neu/` der aktiven Quellen und `belege/_neu/`, ordnet jede Ausgabe einem Kostenblock und einem Standort zu und fragt gebündelt nach, wo es sich nicht sicher ist (statt zu raten),
4. schreibt `kosten.md` fort: Kosten-Cockpit, Monats-Matrix je Kostenblock, Standort-Matrix, Beobachtungen mit Beleg, Buchungsjournal,
5. rendert `auswertung.xlsx` (vier Tabs: `00_Cockpit`, `01_Monate`, `02_Standorte`, `03_Buchungen` als Drill-down) und `dashboard.html` (offline-Browser-Ansicht),
6. schreibt den Diff ins `CHANGELOG.md` und verschiebt verarbeitete Dateien nach `analysiert/`.

## Schritt 5 — Prüfen und Version sichern

Eine Frage an dich selbst: **Führt jede Zahl auf eine Quelle oder eine Annahme zurück?** Wenn ja, sag Claude:

```
Zeig mir kurz, was sich an den Kosten seit dem letzten Stand
geändert hat, und sichere dann diese Iteration als Version.
```

Claude fasst die Änderungen zusammen und sichert den Stand (per Git-Commit). Falls das Projekt noch keine Versionierung hat, richtet Claude sie beim ersten Mal automatisch ein. Du musst dafür kein Git können.

**Warum dieser Schritt Gold wert ist:** Die Versionierung ist die Zeitmaschine deiner Kosten. Jeder gesicherte Stand bleibt für immer abrufbar. Du kannst nächste Woche fragen „was hat sich seit letztem Montag geändert?" und bekommst die genaue Antwort, Zahl für Zahl (wie der Änderungsmodus in Word, nur für den ganzen Ordner). Und weil jeder Stand gesichert ist, dürfen Excel und Dashboard bei jedem Lauf gefahrlos neu erzeugt werden: verloren geht nichts.

## Der wöchentliche Lauf (rollierend)

Du kannst den Skill so oft laufen lassen, wie du willst, typisch einmal die Woche. Er ist auf Wiederholung gebaut:

- **Neue Exporte einfach reinwerfen.** Alles in `_neu/` wird verarbeitet und wandert nach `analysiert/`, nichts wird zweimal gelesen. Überlappen sich Exporte doch einmal, erkennt der Skill Duplikat-Verdachte und fragt, statt still doppelt zu zählen.
- **Erwartete Kosten räumen sich selbst auf.** Ist ein vorgemerkter Posten inzwischen wirklich geflossen, hakt der Skill ihn ab. Ist er überfällig, fragt er nach: verschieben, streichen oder erledigt.
- **Die Fixkosten-Tabelle arbeitet mit.** Fehlt zu einem Vertrag im Monat die passende Buchung, meldet der Skill die Datenlücke. Sieht er etwas Wiederkehrendes, das in der Tabelle fehlt, schlägt er es vor.
- **Beobachtungen wiederholen sich nicht.** Was du einmal als gewollt erklärt hast (das Doppel-Abo ist Absicht), merkt sich `ANNAHMEN.md`, und der Skill meldet es nicht wieder.

So beantwortet jeder Lauf dieselbe Frage neu: **Wohin geht unser Geld, und was hat sich verändert?**

## Zwischendurch: erfassen und vormerken (ohne Lauf)

Du musst nicht auf den Wochenlauf warten. Zwei Handgriffe gehen jederzeit:

```
50 Euro Parken heute, Standort Frankfurt.
```

Claude trägt die Ausgabe als eine Journal-Zeile ein und bestätigt sie. Und für Künftiges:

```
Merk dir für die Kosten: in 3 Wochen kommt eine Rechnung
über 300 Euro von der Agentur.
```

Das landet als Erwartete Kosten in `ANNAHMEN.md` (zählt in keiner Ist-Summe mit, steht aber sichtbar im Blick). Ein neuer Dauerposten („ab sofort 89 Euro monatlich für Tool X") landet in der Fixkosten-Tabelle.

## Weitere Quellen anbinden

Der Skill ist quellen-agnostisch, und Formate sind kein Hindernis:

- **Excel-Listen jeder Art:** einfach nach `exporte/excel/_neu/` legen. Der Skill erkennt die Spalten, legt dir das Mapping zur Bestätigung vor und merkt sich das bestätigte Schema für Folge-Importe.
- **Kontoauszug als PDF:** nach `belege/_neu/`, der Skill erkennt selbst, dass es viele Buchungen sind, und prüft die Summe gegen den ausgewiesenen Saldo.
- **sevDesk, Pliant und andere Systeme:** echten Export besorgen, Datei nach `exporte/<quelle>/_neu/`, in `SOURCES.md` die Zeile von `geplant` auf `aktiv` setzen. Unbekannte Spalten werden erfragt, nie geraten.

Mehr braucht es nicht. Der Skill nimmt, was da ist, und meldet transparent, welche Quellen noch leer sind. So wächst das Bild Quelle um Quelle, ohne Umbau.

## Was im Bundle liegt

```
cost-tracker/
├── README.md                          ← das hier
├── vorlage/                           ← das Gerüst, zieht als kosten/ ins Projekt
│   ├── SOURCES.md                     ← Quellen-Manifest: Kanäle, Schemas, Transfer-Regeln
│   ├── KOSTEN-KATEGORIEN.md           ← gültige Kostenblöcke (Vorschlag, frei anpassbar)
│   ├── STANDORTE.md                   ← Standorte + Zuordnungs-Regeln (zweite Dimension)
│   ├── ANNAHMEN.md                    ← Konfiguration, Fixkosten (Verträge), Erwartete Kosten
│   ├── kosten.md                      ← die Single Source of Truth
│   ├── CHANGELOG.md                   ← der Änderungs-Nachweis
│   ├── exporte/<quelle>/_neu|analysiert/   ← System-Exporte (bank, excel, sevdesk, pliant)
│   └── belege/_neu|analysiert/        ← lose Kostenbelege jeder Form, KI kategorisiert
└── skills/cost-tracker/SKILL.md       ← liest Quellen, ordnet zu, baut Excel + Dashboard
```
