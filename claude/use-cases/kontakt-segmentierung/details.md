# Von deinen LinkedIn-Kontakten zur persönlichen Ansprache (Details)

Ergänzung zur [README](README.md) in diesem Ordner. Hier steht alles, was über die Schritt-für-Schritt-Anleitung hinausgeht.

## Inhalt

- [Überblick](#überblick)
- [Gut zu wissen](#gut-zu-wissen)
- [Voraussetzungen](#voraussetzungen)
- [Zeitbedarf](#zeitbedarf)
- [LinkedIn-Export holen](#linkedin-export-holen)
- [Erst mit der Demo üben](#erst-mit-der-demo-üben)
- [Phase A: Kontakte segmentieren](#phase-a-kontakte-segmentieren)
- [Phase B: Den Anlass festhalten](#phase-b-den-anlass-festhalten)
- [Phase C: Firmenakten anlegen](#phase-c-firmenakten-anlegen)
- [Phase D: Firmen recherchieren](#phase-d-firmen-recherchieren)
- [Phase E: Aufbau der Nachrichten festlegen](#phase-e-aufbau-der-nachrichten-festlegen)
- [Phase F: Entwürfe schreiben](#phase-f-entwürfe-schreiben)
- [Später weitermachen](#später-weitermachen)
- [So sieht das Ergebnis aus](#so-sieht-das-ergebnis-aus)
- [Regeln an dich anpassen](#regeln-an-dich-anpassen)
- [Datenschutz](#datenschutz)
- [Grenzen](#grenzen)
- [Nächste Ausbaustufe](#nächste-ausbaustufe)
- [Was im Bundle liegt](#was-im-bundle-liegt)

## Überblick

Mit diesem Use Case wird aus deinem LinkedIn-Export Schritt für Schritt eine Outreach-Pipeline, für den ADAN Career Day oder jeden anderen Anlass, für den du Firmen gewinnen willst. Claude sortiert deine Kontakte nach Rollen, legt für jede interessante Firma eine Akte an, recherchiert die Firmen in öffentlichen Quellen und schreibt daraus persönliche Nachrichtenentwürfe. Du gibst an jeder wichtigen Stelle frei und schickst jede Nachricht selbst. Versendet wird von Claude nie etwas.

Jede Phase ist für sich nützlich. Du kannst nach Phase A aufhören und nur die Excel-Liste nutzen, oder später weitermachen. Claude erkennt beim nächsten Mal, wo du stehst.

## Gut zu wissen

- Der Skill wird einmal installiert und steht danach überall zur Verfügung, egal in welchem Ordner du gerade arbeitest. Du findest ihn danach auch im Dashboard unter Skills & Commands.

## Voraussetzungen

- Dein Setup ist installiert.
- Python 3 mit dem Paket openpyxl für die Excel-Datei. Das Installationsskript prüft beides und nennt dir den Befehl, falls etwas fehlt.
- Dein LinkedIn-Export `Connections.csv` (so bekommst du ihn, siehe LinkedIn-Export holen) oder eine eigene Liste mit Spalten wie Vorname, Nachname, Firma, Position. Auch Exporte aus Werkzeugen wie Phantombuster, Evaboot oder Wiza und Teilnehmer- oder Messelisten als CSV oder Excel gehen, Claude zeigt dir dann, welche Spalte wofür genommen wird. Zum Ausprobieren reicht der mitgelieferte Beispieldatensatz mit rund 40 erfundenen Kontakten.
- Nur falls du einzelne Kontakte per E-Mail ansprechen willst, der Microsoft-365-Connector in Claude (Outlook). Ohne ihn bekommst du die Mailtexte zum Kopieren.

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

## LinkedIn-Export holen

Auf LinkedIn oben auf dein Profilbild (Ich), dann Einstellungen und Datenschutz, Datenschutz, „Kopie Ihrer Daten abrufen" (je nach Version leicht anders benannt). Wähle die Option, bei der du einzelne Daten auswählst, hake nur „Verbindungen" an und fordere das Archiv an. LinkedIn schickt dir einen Link per Mail, wenn du nur die Verbindungen anforderst meist nach etwa zehn Minuten, spätestens nach 24 Stunden. In der ZIP-Datei liegt `Connections.csv`. Auf einer englischen Oberfläche heißt der Punkt „Get a copy of your data".

Hast du deine Kontakte aus einem anderen Werkzeug oder von einer Messe, etwa als Excel-Liste, nimm einfach diese Datei.

Leg die Datei nicht in iCloud, OneDrive oder einen geteilten Ordner. Der Ordner Downloads auf deinem Rechner ist in Ordnung.

## Erst mit der Demo üben

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

1. Claude liest die Datei und zeigt dir in einer kleinen Tabelle, welche Spalte deiner Datei als Name, Firma, Position usw. genommen wird. Passt etwas nicht, sagst du es („die Rolle steht in der Spalte Funktion"). Namen wie „Muster, Anna" und Titel wie Dr. erkennt Claude selbst. Danach nennt Claude den Umfang: wie viele Kontakte und Firmen, wie viele ohne Position, wie viele doppelt waren.
2. Claude fragt, ob es eine Liste bisheriger Partner, Aussteller oder Sponsoren gibt (CSV oder Excel, eine Zeile je Firma, Pflicht ist nur die Spalte mit dem Firmennamen). Wenn ja, legt Claude sie gegen den Export und sagt dir, welche Partner Kontakte im Export haben und welche nicht. Diese Firmen bekommen in allen Ergebnissen die Markierung „Bisheriger Partner" und einen eigenen Textbaustein, der an die frühere Teilnahme anknüpft. Segment und Priorität richten sich weiter nach der Rolle.
3. Claude zeigt dir einmal die Segmentregeln als kurze Tabelle und fragt, ob sie passen, ob du Du oder Sie schreibst und was du für den Anlass suchst.
4. Claude ordnet jeden Kontakt zu, bei großen Listen in Blöcken zu 100. Dabei sieht Claude nur Position und Firma, keine Namen.
5. Du siehst die Verteilung, die Top-20-Firmen, alle Kontakte mit Priorität A, die bisherigen Partner und die Textbausteine als Tabellen im Chat. Du kannst korrigieren, etwa „Nr. 12 ist Sonstiges" oder „Firma X ganz raus".
6. Erst nach deinem Okay entstehen die Excel-Datei, eine Zusammenfassung und eine Übersicht als HTML-Seite. Claude fragt, ob sie nur im Browser aufgehen oder zusätzlich als eigener Reiter im AIOS-Dashboard liegen soll (Titel frei wählbar, etwa „ADAN Karriere"). Der Reiter bleibt im Dashboard, bis du ihn entfernst, und wird bei einem neuen Lauf mit demselben Titel ersetzt. In der Übersicht sind die relevanten Kontakte (Priorität A) grün hinterlegt und bisherige Partner blau markiert.

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

Dann arbeiten Recherche-Agenten (eigene Claude-Helfer im Hintergrund, die nur im Netz suchen und Webseiten lesen können, aber keine deiner Dateien) jeweils 5 bis 10 Firmen ab, A-Firmen zuerst. Nach jedem Batch siehst du eine Tabelle mit den wichtigsten Funden und entscheidest, ob es weitergeht. Sagst du „Stopp, das reicht", merkt sich Claude das und schlägt beim nächsten Mal Phase E vor, statt dich wieder in die Recherche zu schicken. Jeder Fakt steht mit Quelle und Datum in der Akte.

## Phase E: Ansprache festlegen

Sag Claude:

```
Lass uns die Ansprache festlegen.
```

Claude fragt dich vier Dinge: ob du eine eigene Nachricht als Vorbild hast (dann übernimmt Claude deinen Ton), ob es eher locker oder eher sachlich klingen soll, welche Frage am Ende stehen soll (ein Gespräch anbieten, direkt nach Stand oder Panel fragen, nach der richtigen Person fragen) und ob Zahl und Fächer der Talente in jede Nachricht gehören. Danach schreibt Claude eine echte Beispielnachricht für den ersten A-Kontakt, prüft den Fakt daraus an der Quelle und zeigt dir beides. Du sagst „passt", „lockerer", „sachlicher" oder „andere Frage", bis der Ton stimmt. Erst dann ist die Ansprache festgelegt.

Was eine Nachricht aus diesem Skill ausmacht, in Kurzform (die lange Fassung steht in `vorlagen/ansprache.md`):

- Die erste Zeile handelt von der Person und ihrem Job, nicht von euch.
- Ein Fakt aus der Akte, aber mit Folgerung: was er für die Person oder den Career Day bedeutet.
- Ein konkreter Nutzen in Zahlen und Fächern, kein „Sichtbarkeit".
- Eine Frage auf Augenhöhe, kein „Darf ich Infos schicken?".
- Wie an einen Bekannten, ohne Floskeln, 350 bis 650 Zeichen.
- Herkunft beiläufig, Schluss ohne Entschuldigung.
- Nichts, was Claude nicht an der Quelle geprüft hat.

Danach legt Claude die Tabelle `kontakte/anlass/ansprache.md` an, eine Zeile je Kontakt mit Kanal, Kontext aus der Akte und Status. Der Kanal ist immer LinkedIn, denn eine LinkedIn-Verbindung ist keine Erlaubnis für Werbung per Mail. Hast du mit einer Person schon geschäftlich zu tun oder hat sie eingewilligt, sag es Claude, etwa „Nr. 5 kenne ich aus einem Projekt, lieber per Mail". Claude fragt einmal nach und stellt nur diesen Kontakt um. Die Mail nennt dann, woher die Daten stammen, mit Link zu euren Datenschutzhinweisen und trägt die Impressumszeile deines Vereins.

## Phase F: Entwürfe schreiben

Sag Claude:

```
Schreib die nächsten Entwürfe.
```

Claude nimmt die nächsten 10 Kontakte (A zuerst), zeigt dir die Auswahl und schreibt nach deinem Okay für jeden einen eigenen Text. Vorher liest Claude je Kontakt die Akte, wählt den Fakt, der zur Rolle passt, und ruft die Quelle auf, um ihn zu prüfen. Steht die Aussage dort nicht, nimmt Claude den nächsten Fakt oder lässt den Firmenteil weg und sagt dir das. Unter jedem Entwurf steht, welche Quelle geprüft wurde. Du gehst sie durch: „1 passt, 2 lockerer, 3 streichen". Sagst du bei mehreren dasselbe, ändert Claude die Einstellung und schreibt den ganzen Batch neu. Danach liegen die LinkedIn-Texte in der Akte und gesammelt in `kontakte/ausgabe/entwuerfe-<datum>.md` zum Kopieren. Nur für Kontakte, die du ausdrücklich auf E-Mail gestellt hast, legt Claude einen Entwurf in deinem Outlook an, mit Empfänger und Betreff, ungesendet.

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

Claude liest den Ordner `kontakte/` und sagt dir in drei Zeilen, was fertig ist und was noch offen liegt. Dann bietet Claude an, dort weiterzumachen, wo du zuletzt aufgehört hast.

## So sieht das Ergebnis aus

Im Projektordner liegt nach allen Phasen:

```
kontakte/
├── ausgabe/
│   ├── segmentierung-<datum>.xlsx     ← Blätter Kontakte, Firmen, Textbausteine
│   ├── segmentierung-<datum>.md       ← Zusammenfassung mit den Top-20-Firmen
│   ├── segmentierung-<datum>.html     ← Übersicht zum Anschauen im Browser
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

Der Entwurf für die Talent-Acquisition-Leitung dieser Firma, zum Kopieren in LinkedIn (437 Zeichen):

```
Guten Tag Sarah Demo,

wir sind hier auf LinkedIn vernetzt. Fiktiva Pharma baut Frankfurt aus und sucht mit dem Traineeprogramm Life Sciences genau unsere Zielgruppe.

Am [FEHLT: Termin] ist in Frankfurt der ADAN Career Day, die Karrieremesse für afrodeutsche und afrodiasporische Akademikerinnen und Akademiker.

Darf ich Ihnen die Ausstellerinfos schicken?

Falls nicht, melde ich mich nicht wieder.

Viele Grüße
[Dein Name], ADAN e.V.
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

`segmente.md` enthält Stichwörter und Prioritäten je Segment, `ausschluss.md` die Firmen, die Claude weglassen soll (etwa bestehende Partner). Änderungen legt Claude im Ordner `kontakte/` deines Projektordners ab. Sie gelten dann nur dort, so kann der Career Day andere Regeln haben als die Sponsorensuche in einem anderen Ordner. Sagst du „für alle Anlässe", ändert Claude die Standardfassung im Skill-Ordner `~/.claude/skills/kontakt-segmentierung/`. Installierst du das Bundle neu, bleiben deine Änderungen erhalten.

## Datenschutz

- **Nur der offizielle Export.** Claude arbeitet mit der Datei, die LinkedIn dir selbst gibt, oder mit deiner eigenen Liste. Kein automatisches Auslesen von LinkedIn-Seiten im Browser, das verbieten die Nutzungsbedingungen von LinkedIn.
- **Recherche nur zu Firmen und nur öffentlich.** Die Recherche-Agenten lesen Firmenwebseiten, Karriereseiten, Pressemitteilungen und Messeseiten. Sie rufen nie LinkedIn-Profile auf, recherchieren keine einzelnen Menschen und bekommen keine Namen oder Adressen aus deiner Liste. Jeder Fakt steht mit Quelle und Datum in der Akte.
- **Keine erratenen Adressen.** Der Export enthält E-Mail-Adressen nur bei Kontakten, die das erlaubt haben. Fehlende Adressen bleiben leer. Claude rät keine Adressen und nutzt keine Dienste, die Adressen nachliefern.
- **Nur das Nötige.** Verarbeitet werden Name, Titel, Firma, Position, Verbunden seit, Profil-Link, eine vorhandene E-Mail-Adresse und, falls deine Liste sie hat, Ort, Branche und deine eigenen Notizen. Telefonnummern übernimmt Claude nie. Für die Einordnung schaut Claude nur auf Position und Firma, nie auf Namen oder vermutete Herkunft. Akten gibt es nur für Kontakte mit Priorität A oder B.
- **Bleibt auf deinem Rechner.** Liste, Akten und Entwürfe liegen im Ordner `kontakte/` in deinem Projektordner, nicht in iCloud, OneDrive oder geteilten Ordnern. Liegt der Ordner in einer Cloud, warnt Claude, schlägt einen lokalen Ordner vor und du entscheidest. Gib die Dateien nicht in andere KI-Chats oder Online-Werkzeuge. Was du nicht mehr brauchst, löschst du selbst.
- **Nie automatisch verschicken.** Werbung per Mail braucht nach § 7 UWG in der Regel eine vorherige Einwilligung, auch bei Firmenkontakten. Deshalb verschickt Claude nichts, auch keine Serienmails. Deshalb schreibst du standardmäßig über LinkedIn, wo ihr bereits vernetzt seid. Einen Outlook-Entwurf gibt es nur für eine Adresse aus dem Export und nur, wenn du für diesen Kontakt bestätigst, dass ihr schon geschäftlich zu tun habt oder eine Einwilligung vorliegt. Jede Mail prüfst und sendest du selbst.
- **Herkunft nennen.** Jede erste Nachricht nennt die Herkunft des Kontakts und bietet an, dich nicht wieder zu melden (Art. 14 DSGVO). Eine Mail enthält zusätzlich den Link zu euren Datenschutzhinweisen und die Impressumszeile. Beides ist fester Teil des Nachrichtenaufbaus.
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
├── details.md                             ← Details und Beispiele zur Anleitung
├── install.sh                             ← Installation (Mac und Windows)
└── skills/
    └── kontakt-segmentierung/
        ├── SKILL.md                       ← die Arbeitsanleitung für Claude
        ├── segmente.md                    ← Segmentregeln, von dir anpassbar
        ├── ausschluss.md                  ← Firmen, die wegbleiben sollen
        ├── vorlagen/
        │   ├── anlass.md                  ← Aufbau von ANLASS.md
        │   ├── struktur.md                ← Aufbau von STRUKTUR.md (Ton, Frage, Beispiel je Anlass)
        │   ├── ansprache.md               ← sieben Prinzipien, nach denen jede Nachricht geschrieben wird
        │   ├── checkliste.md              ← 14 Prüfpunkte für jeden Entwurf
        │   ├── recherche-anlass.md        ← Auftrag an den Recherche-Agenten zum Anlass
        │   └── recherche-firmen.md        ← Auftrag an die Recherche-Agenten zu Firmen
        ├── beispiel/
        │   ├── Connections-beispiel.csv   ← rund 40 erfundene Kontakte für die Demo
        │   ├── Partner-beispiel.csv       ← erfundene Partnerliste für die Demo (Aussteller, Sponsoren)
        │   ├── firmenakte-beispiel.md     ← fertige Beispiel-Akte aus der Demo
        │   └── formate/                   ← erfundene Beispiele anderer Exporte (Phantombuster, Evaboot, Wiza, Event, Messe)
        └── scripts/
            ├── einlesen.py                ← liest CSV oder Excel, erkennt die Spalten
            ├── bestand.py                 ← legt eine Partnerliste gegen den Export
            ├── spalten.json               ← welche Spaltennamen wofür stehen, erweiterbar
            ├── schreiben.py               ← schreibt Excel-Datei, Zusammenfassung und HTML-Übersicht
            └── akten.py                   ← legt Firmenakten an, pflegt Status, zeigt den Stand
```
