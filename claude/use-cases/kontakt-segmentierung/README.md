# Von deinen LinkedIn-Kontakten zur persönlichen Ansprache

Mit diesem Use Case wird aus deinem LinkedIn-Export Schritt für Schritt eine Outreach-Pipeline, für den ADAN Career Day oder jeden anderen Anlass, für den du Firmen gewinnen willst. Claude sortiert deine Kontakte nach Rollen, legt für jede interessante Firma eine Akte an, recherchiert die Firmen in öffentlichen Quellen und schreibt daraus persönliche Nachrichtenentwürfe. Du gibst an jeder wichtigen Stelle frei und schickst jede Nachricht selbst. Versendet wird von Claude nie etwas.

```
Vorher                              Claude                                  Nachher
──────                              ──────                                  ───────
A  800 Kontakte in einer CSV,    →  ordnet nach Rolle, Priorität A/B/C  →  Excel-Liste mit Segmenten,
   keiner weiß, wer im                                                     Top-20-Firmen, Textbausteine
   Recruiting sitzt
B  der Anlass steckt in          →  fragt nach, recherchiert auf Wunsch →  ANLASS.md mit Termin, Ziel,
   deinem Kopf                                                             Angebot, Absender
C  Firmen nur als Namen          →  legt je A- oder B-Firma eine Akte an →  eine Datei je Firma mit
   in einer Spalte                                                         Kontakten und Status
D  du weißt wenig über           →  Recherche-Agenten lesen Karriere-   →  Fakten mit Quelle und Datum,
   die Firmen                       seiten, Presse, Messeseiten            Anknüpfungspunkte je Firma
E  jede Nachricht klingt         →  schlägt einen festen Aufbau vor     →  STRUKTUR.md und eine Tabelle
   anders oder gleich                                                      mit Kontext je Kontakt
F  leeres Nachrichtenfeld        →  schreibt in Batches zu 10           →  persönliche LinkedIn-Texte zum
                                                                           Kopieren, Outlook-Entwürfe
```

Jede Phase ist für sich nützlich. Du kannst nach Phase A aufhören und nur die Excel-Liste nutzen, oder später weitermachen. Claude erkennt beim nächsten Mal, wo du stehst.

## Konventionen in dieser Anleitung

- Steht hier **„Sag Claude:"**, kopierst du den grauen Kasten darunter in die Chateingabe von Claude und schickst ihn ab.
- Der Skill wird einmal installiert und steht danach überall zur Verfügung, egal in welchem Ordner du gerade arbeitest. Du findest ihn danach auch im Dashboard unter Skills & Commands.

## Voraussetzungen

- Dein Setup ist installiert.
- Python 3 mit dem Paket openpyxl für die Excel-Datei. Das Installationsskript prüft beides und nennt dir den Befehl, falls etwas fehlt.
- Dein LinkedIn-Export `Connections.csv` (so bekommst du ihn, siehe Schritt 2) oder eine eigene Excel-Liste mit Spalten wie Vorname, Nachname, Firma, Position. Zum Ausprobieren reicht der mitgelieferte Beispieldatensatz mit rund 40 erfundenen Kontakten.
- Für Phase F mit E-Mail-Entwürfen der Microsoft-365-Connector in Claude (Outlook). Ohne ihn bekommst du die Mailtexte zum Kopieren.

## Zeitbedarf

| Phase | Deine Zeit | Claude arbeitet |
|---|---|---|
| Installation | 5 Minuten | |
| LinkedIn-Export anfordern | 2 Minuten, dann 10 Minuten bis 24 Stunden warten | |
| A Segmentierung | 10 Minuten Freigaben | etwa 1 Minute je 100 Kontakte |
| B Anlass | 5 bis 10 Minuten Fragen beantworten | 3 Minuten, wenn du Recherche zum Anlass willst |
| C Firmenakten | 2 Minuten | Sekunden |
| D Recherche | 2 Minuten je Batch zum Durchsehen | je Firma 1 (nur Lücken), 2 bis 3 (Standard) oder 4 bis 5 Minuten (tief), 10 Firmen je Batch |
| E Struktur | 10 bis 15 Minuten | 2 Minuten |
| F Entwürfe | 10 Minuten je Batch zum Durchgehen | 3 Minuten je Batch zu 10 Kontakten |

Für 20 A-Firmen mit 30 Kontakten rechnest du grob mit zwei Stunden, davon die Hälfte Lesen und Freigeben.

## Schritt 1: Installieren

Sag Claude:

```
Hol zuerst mit git pull den neuesten Stand meines Setup-Repos ~/ai-os-core.

Führe dann das Installationsskript des Use-Case-Bundles "kontakt-segmentierung" aus:
bash ~/ai-os-core/claude/use-cases/kontakt-segmentierung/install.sh

Fehlt dabei openpyxl, installier es mit dem Befehl, den das Skript nennt.
Zeig mir danach in einfachen Worten, ob alles geklappt hat.
```

Starte danach eine neue Session, damit Claude den neuen Skill kennt.

## Schritt 2: LinkedIn-Export holen

Auf LinkedIn oben auf dein Profilbild (Ich), dann Einstellungen und Datenschutz, Datenschutz, „Kopie Ihrer Daten abrufen" (je nach Version leicht anders benannt). Wähle die Option, bei der du einzelne Daten auswählst, hake nur „Verbindungen" an und fordere das Archiv an. LinkedIn schickt dir einen Link per Mail. In der ZIP-Datei liegt `Connections.csv`.

Leg die Datei nicht in iCloud, OneDrive oder einen geteilten Ordner. Der Ordner Downloads auf deinem Rechner ist in Ordnung.

## Schritt 3: Erst mit der Demo üben

Öffne Claude in deinem Projektordner (zum Beispiel ADAN-Impact). Sag Claude:

```
Segmentier meine LinkedIn-Kontakte für den Career Day. Nimm zum Üben die Demo.
```

Die Demo nutzt rund 40 erfundene Kontakte bei erfundenen Firmen wie der Musterbank AG oder der Fiktiva Pharma AG. So kannst du alles in Ruhe ansehen oder im Workshop auf dem Beamer zeigen, ohne dass echte Kontakte zu sehen sind. Danach kannst du mit der Demo auch die Phasen B bis F durchspielen. Bei der Recherche in Phase D findet Claude zu den erfundenen Firmen natürlich nichts, wähl dort zum Üben eine echte, große Firma über „Bestimmte Firmen".

## Phase A: Kontakte segmentieren

Sag Claude:

```
Segmentier meine LinkedIn-Kontakte für den Career Day.
```

und zieh die Datei `Connections.csv` ins Fenster, wenn Claude danach fragt. Das passiert dann:

1. Claude liest die Datei und nennt dir den Umfang: wie viele Kontakte und Firmen, wie viele ohne Position, wie viele doppelt waren.
2. Claude zeigt dir einmal die Segmentregeln als kurze Tabelle und fragt, ob sie passen, ob du Du oder Sie schreibst und was du für den Anlass suchst.
3. Claude ordnet jeden Kontakt zu, bei großen Listen in Blöcken zu 100. Dabei sieht Claude nur Position und Firma, keine Namen.
4. Du siehst die Verteilung, die Top-20-Firmen, alle Kontakte mit Priorität A und die Textbausteine als Tabellen im Chat. Du kannst korrigieren, etwa „Nr. 12 ist Sonstiges" oder „Firma X ganz raus".
5. Erst nach deinem Okay entstehen die Excel-Datei und eine Zusammenfassung.

In der Excel-Datei hat jede Kopfzeile einen Filter. Die Spalte „Status (für dich)" ist leer, dort kannst du eintragen, wen du angeschrieben hast. Liegt dein Projektordner in iCloud (auf vielen Macs werden Schreibtisch und Dokumente mit iCloud synchronisiert), warnt Claude dich vorher, erklärt kurz das Risiko und schlägt einen lokalen Ordner wie `~/Kontakte-lokal` vor. Du entscheidest.

### Die Segmente und Prioritäten

| Segment | Typische Positionen |
|---|---|
| Talent Acquisition und Recruiting | Head of Talent Acquisition, Recruiterin, Campus Recruiting, Early Careers, Ausbildungsleitung |
| HR-Leitung und People | Personalleitung, CHRO, Chief People Officer, HR Business Partner, People & Culture |
| Employer Branding und Diversity | Employer Branding, Personalmarketing, Diversity Manager, Head of DEI |
| Geschäftsführung und Gründer | Geschäftsführerin, CEO, Founder, Inhaber, Partner in Kanzlei oder Beratung |
| Sonstiges | alle anderen, etwa Fachrollen, Studierende, Einträge ohne Position |

**A** heißt sofort ansprechen (entscheidet über Messe oder Budget oder ist für Nachwuchs zuständig), **B** zweite Welle oder Türöffner, **C** nur bei Bedarf. Claude kennt auch Stolperfallen wie Personal Trainer oder Talent Manager in der Musikbranche, die nur nach HR klingen. Geht es um einen anderen Anlass, etwa Sponsoren für ein Fest, sag Claude, welche Rollen dann zählen.

## Phase B: Den Anlass festhalten

Sag Claude:

```
Mach daraus eine Outreach-Pipeline für den Career Day.
```

Claude fragt dich, wofür die Ansprache ist: Name des Anlasses, was du von den Firmen willst (Aussteller, Sponsoren, Speaker, Partner), was du ihnen bietest, Termin, Ort, Link, deinen Namen und deine Rolle für die Signatur, Du oder Sie. Was noch offen ist, bleibt als `[FEHLT: Termin]` stehen und taucht so auch in den Entwürfen auf. Auf Wunsch sucht ein Recherche-Agent öffentliche Informationen zum Anlass (frühere Ausgaben, Aussteller, Presse) und ergänzt sie mit Quellen. Du liest alles einmal und bestätigst.

Für einen anderen Anlass sagst du einfach „Outreach für das Sommerfest" oder „Outreach für unsere Sponsoren-Suche".

## Phase C: Firmenakten anlegen

Sag Claude:

```
Leg für die A- und B-Firmen Akten an.
```

Für jede Firma mit mindestens einem Kontakt der Priorität A oder B entsteht eine Datei `kontakte/firmen/<firma>.md` mit Stammdaten, deinen Kontakten dort, leeren Abschnitten für Recherche, Anknüpfungspunkte und Entwurf und einem Status (offen, recherchiert, Entwurf, angeschrieben, geantwortet). Machst du später eine neue Segmentierung, ergänzt Claude nur neue Kontakte. Was du in einer Akte selbst geschrieben hast, bleibt immer erhalten.

## Phase D: Firmen recherchieren

Sag Claude:

```
Recherchier die A-Firmen.
```

Claude fragt nach der Tiefe:

| Tiefe | Was Claude sucht |
|---|---|
| Nur Lücken schließen | Website, Branche, Größe, Standort |
| Standard | dazu Karriereseite, Einstiegs-, Trainee- und Ausbildungsprogramme, Diversity und Employer Branding, frühere Messeteilnahmen |
| Tief | dazu aktuelle Stellenanzeigen für den Einstieg, Presse der letzten 12 Monate, ob es die Rolle deiner Ansprechperson dort sichtbar gibt |

Dann arbeiten Recherche-Agenten (eigene Claude-Helfer im Hintergrund) jeweils 5 bis 10 Firmen ab, A-Firmen zuerst. Nach jedem Batch siehst du eine Tabelle mit den wichtigsten Funden und entscheidest, ob es weitergeht. Jeder Fakt steht mit Quelle und Datum in der Akte.

## Phase E: Aufbau der Nachrichten festlegen

Sag Claude:

```
Lass uns den Aufbau der Nachrichten festlegen.
```

Claude schlägt einen festen Aufbau vor und zeigt eine Beispielnachricht:

| Teil | Inhalt |
|---|---|
| Anrede | persönlich, mit dem Namen aus dem Export |
| Einstieg | woher ihr euch kennt („wir sind hier auf LinkedIn vernetzt") |
| Firmenteil | ein bis zwei Sätze aus der Akte, passend zur Rolle der Person |
| Anlass-Teil | immer gleich, aus ANLASS.md |
| Aufruf | etwa ein kurzer Austausch |
| Ausstiegssatz | „Falls das gerade nicht passt, melde ich mich nicht wieder." |
| Signatur | dein Name, deine Rolle, deine Organisation |

Danach legt Claude die Tabelle `kontakte/anlass/ansprache.md` an, eine Zeile je Kontakt mit Kanal (LinkedIn oder E-Mail), Kontext-Stichworten aus der Akte und Status. Du korrigierst, was nicht passt, etwa „Nr. 5 lieber über LinkedIn".

## Phase F: Entwürfe schreiben

Sag Claude:

```
Schreib die nächsten Entwürfe.
```

Claude nimmt die nächsten 10 Kontakte (A zuerst), zeigt dir die Auswahl und schreibt nach deinem Okay für jeden einen persönlichen Text. Du gehst sie durch: „1 passt, 2 kürzer, 3 streichen". Danach liegen die LinkedIn-Texte in der Akte und gesammelt in `kontakte/ausgabe/entwuerfe-<datum>.md` zum Kopieren. Für Kontakte mit E-Mail-Adresse im Export legt Claude einen Entwurf in deinem Outlook an, mit Empfänger und Betreff, ungesendet.

Hast du Nachrichten verschickt, sag es Claude:

```
Nr. 13 und 14 habe ich angeschrieben.
```

Dann stimmt der Status in Akte und Tabelle.

## Später weitermachen

Sag Claude:

```
Wo stehen wir beim Outreach?
```

Claude liest den Ordner `kontakte/` und sagt dir in drei Zeilen, was fertig ist. Dann bietet Claude an, dort weiterzumachen.

## So sieht das Ergebnis aus

Im Projektordner liegt nach allen Phasen:

```
kontakte/
├── ausgabe/
│   ├── segmentierung-<datum>.xlsx     ← Blätter Kontakte, Firmen, Textbausteine
│   ├── segmentierung-<datum>.md       ← Zusammenfassung mit den Top-20-Firmen
│   └── entwuerfe-<datum>.md           ← LinkedIn-Texte zum Kopieren
├── anlass/
│   ├── ANLASS.md                      ← wofür, wann, wo, was du bietest
│   ├── STRUKTUR.md                    ← Aufbau jeder Nachricht
│   └── ansprache.md                   ← eine Zeile je Kontakt mit Kanal, Kontext, Status
├── firmen/
│   └── <firma>.md                     ← eine Akte je Firma
└── arbeit/<datum>/                    ← Zwischenstände von Claude
```

Eine Akte aus dem Demo-Datensatz, nach Recherche und Entwurf (gekürzt, Firma, Fakten und Quellen sind erfunden):

```markdown
# Firmenakte Fiktiva Pharma AG

**Status:** Entwurf

**Firmenpriorität:** A

## Stammdaten

| Feld | Wert |
|---|---|
| Name | Fiktiva Pharma AG |
| Branche | Pharma und Biotechnologie |
| Größe | rund 2.400 Mitarbeitende (2025) |
| Website | https://www.example.org/fiktiva-pharma |
| Standort | Hauptsitz Beispielstadt, Forschungsstandort Frankfurt am Main |

## Kontakte aus dem Export

| Name | Position | Segment | Priorität | Profil-Link | E-Mail (aus Export) |
|---|---|---|---|---|---|
| Sarah Demo | Global Talent Acquisition Director | Talent Acquisition und Recruiting | A | https://www.example.org/in/fiktiv-14 |  |
| Sophie Muster | Referentin Personalmarketing und Hochschulmarketing | Talent Acquisition und Recruiting | A | https://www.example.org/in/fiktiv-12 |  |
| Kwame Fiktiv | Chief People Officer | HR-Leitung und People | A | https://www.example.org/in/fiktiv-11 |  |

## Recherche

Stand 20.10.2026, Tiefe Standard.

- Fiktiva Pharma bietet ein 18-monatiges Traineeprogramm Life Sciences mit Start jeweils im April und Oktober an ([Quelle](https://www.example.org/fiktiva-pharma/karriere/trainee), Stand ohne Datum)
- Auf der Karriereseite nennt Fiktiva Pharma den Ausbau des Forschungsstandorts Frankfurt mit rund 150 neuen Stellen bis 2027 ([Quelle](https://www.example.org/fiktiva-pharma/karriere/frankfurt), Stand Juni 2025)

## Anknüpfungspunkte

- Der Ausbau in Frankfurt mit rund 150 neuen Stellen passt zum Messeort Frankfurt am Main.
- Das Traineeprogramm Life Sciences richtet sich genau an die Zielgruppe des Career Day.
```

Der Entwurf für die Talent-Acquisition-Leitung dieser Firma, zum Kopieren in LinkedIn:

```
Guten Tag Sarah Demo,

wir sind hier auf LinkedIn vernetzt, deshalb schreibe ich Ihnen direkt.

Ich habe gesehen, dass Fiktiva Pharma den Forschungsstandort Frankfurt ausbaut und mit dem Traineeprogramm Life Sciences gezielt Absolventinnen und Absolventen anspricht. Genau diese Zielgruppe kommt zu unserer Messe.

Ich organisiere den ADAN Career Day, eine Karrieremesse für afrodeutsche und afrodiasporische Akademikerinnen und Akademiker in Frankfurt am Main, am [FEHLT: Termin]. Aussteller treffen dort qualifizierte Talente, die sie über klassische Kanäle schwer erreichen.

Hätten Sie Interesse an einem kurzen Austausch, wie Fiktiva Pharma dabei sein kann?

Falls das gerade nicht passt, sagen Sie es mir gern, dann melde ich mich nicht wieder.

Viele Grüße
[Dein Name]
Projektleitung ADAN Career Day, ADAN e.V.
```

Die vollständige Beispiel-Akte liegt im Bundle unter `skills/kontakt-segmentierung/beispiel/firmenakte-beispiel.md`.

## Regeln an dich anpassen

Die Segmentregeln stehen in zwei Dateien, die du jederzeit ändern kannst. Am einfachsten sagst du es Claude, zum Beispiel:

```
Nimm die Musterbank in die Ausschlussliste auf, die ist schon Partner.
```

```
Ausbildungsleitung soll immer Priorität A bekommen.
```

`segmente.md` enthält Stichwörter und Prioritäten je Segment, `ausschluss.md` die Firmen, die Claude weglassen soll (etwa bestehende Partner). Beide liegen im Skill-Ordner `~/.claude/skills/kontakt-segmentierung/`. Installierst du das Bundle neu, bleiben deine Änderungen erhalten.

## Datenschutz

- **Nur der offizielle Export.** Claude arbeitet mit der Datei, die LinkedIn dir selbst gibt, oder mit deiner eigenen Liste. Kein automatisches Auslesen von LinkedIn-Seiten im Browser, das verbieten die Nutzungsbedingungen von LinkedIn.
- **Recherche nur zu Firmen und nur öffentlich.** Die Recherche-Agenten lesen Firmenwebseiten, Karriereseiten, Pressemitteilungen und Messeseiten. Sie rufen nie LinkedIn-Profile auf, recherchieren keine einzelnen Menschen und bekommen keine Namen oder Adressen aus deiner Liste. Jeder Fakt steht mit Quelle und Datum in der Akte.
- **Keine erratenen Adressen.** Der Export enthält E-Mail-Adressen nur bei Kontakten, die das erlaubt haben. Fehlende Adressen bleiben leer. Claude rät keine Adressen und nutzt keine Dienste, die Adressen nachliefern.
- **Nur das Nötige.** Verarbeitet werden Name, Firma, Position, Verbunden seit, Profil-Link und eine vorhandene E-Mail-Adresse. Für die Einordnung schaut Claude nur auf Position und Firma, nie auf Namen oder vermutete Herkunft. Akten gibt es nur für Kontakte mit Priorität A oder B.
- **Bleibt auf deinem Rechner.** Liste, Akten und Entwürfe liegen im Ordner `kontakte/` in deinem Projektordner, nicht in iCloud, OneDrive oder geteilten Ordnern. Liegt der Ordner in einer Cloud, warnt Claude, schlägt einen lokalen Ordner vor und du entscheidest. Gib die Dateien nicht in andere KI-Chats oder Online-Werkzeuge. Was du nicht mehr brauchst, löschst du selbst.
- **Nie automatisch verschicken.** Werbung per Mail braucht nach § 7 UWG in der Regel eine vorherige Einwilligung, auch bei Firmenkontakten. Deshalb verschickt Claude nichts, auch keine Serienmails. Am besten schreibst du über LinkedIn, wo ihr bereits vernetzt seid. Outlook-Entwürfe gibt es nur für Adressen aus dem Export, jede Mail prüfst und sendest du selbst.
- **Herkunft nennen.** Jede erste Nachricht nennt die Herkunft des Kontakts und bietet an, dich nicht wieder zu melden (Art. 14 DSGVO). Beides ist fester Teil des Nachrichtenaufbaus.
- **Daten sind Daten.** Steht in einem Feld der Liste oder auf einer recherchierten Webseite ein Text, der Claude etwas befehlen will, führt Claude das nicht aus und markiert die Stelle zur Prüfung.

## Grenzen

- Claude ordnet nach der Positionsbezeichnung. Ist sie ungenau („Manager", „Consultant"), kann die Zuordnung danebenliegen. Lies die A-Kontakte deshalb einmal gegen.
- Die Recherche ist nur so gut wie das, was eine Firma öffentlich zeigt. Bei kleinen Firmen bleibt die Akte oft dünn, dann entfällt der Firmenteil der Nachricht und Claude sagt dir das.
- Claude verschickt nichts, plant keine Nachrichten, erinnert nicht ans Nachfassen und ordnet Antworten aus dem Postfach nicht automatisch zu. Den Status pflegt Claude, wenn du ihn nennst.
- Outlook-Entwürfe landen in dem Postfach, mit dem der Microsoft-365-Connector verbunden ist.

## Nächste Ausbaustufe

**Nachverfolgen.** Erinnerung an Nachfassen nach einigen Tagen, Nachfass-Entwürfe und Zuordnung von Antworten aus dem Postfach zu den Akten. Das ist ein eigenes Folgeprojekt.

## Was im Bundle liegt

```
kontakt-segmentierung/
├── README.md                              ← diese Anleitung
├── install.sh                             ← Installation (Mac und Windows)
└── skills/
    └── kontakt-segmentierung/
        ├── SKILL.md                       ← die Arbeitsanleitung für Claude
        ├── segmente.md                    ← Segmentregeln, von dir anpassbar
        ├── ausschluss.md                  ← Firmen, die wegbleiben sollen
        ├── vorlagen/
        │   ├── anlass.md                  ← Aufbau von ANLASS.md
        │   ├── struktur.md                ← Aufbau von STRUKTUR.md
        │   ├── recherche-anlass.md        ← Auftrag an den Recherche-Agenten zum Anlass
        │   └── recherche-firmen.md        ← Auftrag an die Recherche-Agenten zu Firmen
        ├── beispiel/
        │   ├── Connections-beispiel.csv   ← rund 40 erfundene Kontakte für die Demo
        │   └── firmenakte-beispiel.md     ← fertige Beispiel-Akte aus der Demo
        └── scripts/
            ├── einlesen.py                ← liest CSV oder Excel, erkennt die Spalten
            ├── schreiben.py               ← schreibt Excel-Datei und Zusammenfassung
            └── akten.py                   ← legt Firmenakten an, pflegt Status, zeigt den Stand
```
