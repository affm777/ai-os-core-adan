# Von deinen LinkedIn-Kontakten zur persönlichen Ansprache

Claude macht aus deinem LinkedIn-Export eine Outreach-Pipeline, etwa für den ADAN Career Day. Du gibst an jeder wichtigen Stelle frei und schickst jede Nachricht selbst, Claude versendet nie etwas.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

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

## Das brauchst du

- Dein Setup ist installiert.
- Python 3 mit dem Paket openpyxl. Das Installationsskript prüft beides.
- Deinen LinkedIn-Export `Connections.csv` oder eine eigene Liste als CSV oder Excel. Wie du den Export bekommst, steht in [details.md](details.md).
- Zum Üben reicht der mitgelieferte Demo-Datensatz mit rund 40 erfundenen Kontakten.
- Nur für E-Mail-Entwürfe den Microsoft-365-Connector in Claude (Outlook).

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

## Schritt 2: Erster Lauf

Öffne Claude in deinem Projektordner und übe mit der Demo. Sag Claude:
```
Segmentier meine LinkedIn-Kontakte für den Career Day. Nimm zum Üben die Demo.
```

Claude fragt dich dann:
- welche Spalte deiner Datei als Name, Firma und Position gilt
- ob die Segmentregeln passen und ob du Du oder Sie schreibst
- was du für den Anlass suchst
- ob die Zuordnung stimmt, bevor die Excel-Datei entsteht

## Schritt 3: So nutzt du es

**A Kontakte segmentieren.** Zieh deine `Connections.csv` ins Fenster, wenn Claude danach fragt. Jede Phase ist für sich nützlich.
```
Segmentier meine LinkedIn-Kontakte für den Career Day.
```

**B Anlass festhalten.** Claude fragt nach Termin, Ziel, Angebot und Absender.
```
Mach daraus eine Outreach-Pipeline für den Career Day.
```

**C Firmenakten anlegen.** Für jede Firma mit A- oder B-Kontakt entsteht eine Akte.
```
Leg für die A- und B-Firmen Akten an.
```

**D Firmen recherchieren.** Claude fragt nach der Tiefe und zeigt dir nach jedem Batch die Funde.
```
Recherchier die A-Firmen.
```

**E Aufbau festlegen.** Claude schlägt einen festen Aufbau für jede Nachricht vor.
```
Lass uns den Aufbau der Nachrichten festlegen.
```

**F Entwürfe schreiben.** Claude schreibt für die nächsten 10 Kontakte persönliche LinkedIn-Texte.
```
Schreib die nächsten Entwürfe.
```

## Das kommt dabei heraus

- `kontakte/ausgabe/segmentierung-<datum>.xlsx` mit Kontakten, Firmen und Textbausteinen
- `kontakte/ausgabe/entwuerfe-<datum>.md` mit den LinkedIn-Texten zum Kopieren
- `kontakte/anlass/ANLASS.md`, `STRUKTUR.md` und `ansprache.md` mit Anlass, Aufbau und Status je Kontakt
- `kontakte/firmen/<firma>.md` als Akte je Firma

## Grenzen

- Claude ordnet nach der Positionsbezeichnung. Lies die A-Kontakte deshalb einmal gegen.
- Claude verschickt nichts, plant keine Nachrichten und erinnert nicht ans Nachfassen.
- Outlook-Entwürfe gibt es nur für Kontakte, die du ausdrücklich auf E-Mail stellst.
- **Datenschutz.** Claude nutzt nur den offiziellen Export und recherchiert nur Firmen in öffentlichen Quellen, nie einzelne Menschen.
- **Datenschutz.** Alles bleibt im Ordner `kontakte/` auf deinem Rechner, nicht in iCloud, OneDrive oder geteilten Ordnern.

## Mehr dazu

Wie du gesendete Nachrichten meldest und später weitermachst, dazu Zeitbedarf, Segmentregeln, Beispiel-Akte und Datenschutz in Langform, steht in [details.md](details.md).
