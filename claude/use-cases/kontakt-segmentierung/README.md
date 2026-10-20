# Aus deinen LinkedIn-Kontakten wird die Ansprechliste für den Career Day

Mit diesem Use Case findest du in deinen LinkedIn-Kontakten die Menschen, die für den ADAN Career Day zählen: Recruiting, HR-Leitung, Employer Branding und Diversity, Geschäftsführung. Claude liest deinen offiziellen LinkedIn-Export, ordnet jede Person anhand ihrer Position einem Segment zu, vergibt eine Priorität A, B oder C mit kurzer Begründung und zeigt dir, welche Firmen am vielversprechendsten sind. Dazu bekommst du je Segment einen Textbaustein für eine LinkedIn-Nachricht. Versendet wird nie etwas, jede Nachricht schickst du selbst.

```
Vorher                          Claude                          Nachher
──────                          ──────                          ───────
800 LinkedIn-Kontakte in     →  liest Position und Firma,    →  Excel-Datei mit Segment,
einer CSV-Datei, Positionen     ordnet nach deinen Regeln       Priorität und Begründung
auf Deutsch und Englisch        zu, zeigt dir alles zum         je Kontakt, Firmenübersicht,
gemischt, keine Ahnung,         Abnicken                        Textbausteine je Segment,
wer im Recruiting sitzt                                         Top-20-Firmen auf einen Blick
```

## Konventionen in dieser Anleitung

- Steht hier **„Sag Claude:"**, kopierst du den grauen Kasten darunter in die Chateingabe von Claude und schickst ihn ab.
- Der Skill wird einmal installiert und steht danach überall zur Verfügung, egal in welchem Ordner du gerade arbeitest. Du findest ihn danach auch im Dashboard unter Skills & Commands.

## Voraussetzungen

- Dein Setup ist installiert.
- Python 3 mit dem Paket openpyxl für die Excel-Datei. Das Installationsskript prüft beides und nennt dir den Befehl, falls etwas fehlt.
- Dein LinkedIn-Export `Connections.csv` (so bekommst du ihn, siehe Schritt 2) oder eine eigene Excel-Liste mit Spalten wie Vorname, Nachname, Firma, Position. Zum Ausprobieren reicht der mitgelieferte Beispieldatensatz mit rund 40 erfundenen Kontakten.

Zeitbedarf: Installation rund 5 Minuten. Der Export bei LinkedIn kommt nach 10 Minuten bis 24 Stunden per Mail. Ein Lauf dauert etwa eine Minute je 100 Kontakte plus deine Freigaben, das meiste davon arbeitet Claude allein.

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

Die Demo nutzt rund 40 erfundene Kontakte bei erfundenen Firmen wie der Musterbank AG oder der Fiktiva Pharma AG. So kannst du alles in Ruhe ansehen oder im Workshop auf dem Beamer zeigen, ohne dass echte Kontakte zu sehen sind.

## Schritt 4: Mit deinen echten Kontakten

Sag Claude:

```
Segmentier meine LinkedIn-Kontakte für den Career Day.
```

und zieh die Datei `Connections.csv` ins Fenster, wenn Claude danach fragt. Das passiert dann:

1. Claude liest die Datei und nennt dir den Umfang: wie viele Kontakte und Firmen, wie viele ohne Position, wie viele doppelt waren.
2. Claude zeigt dir einmal die Segmentregeln als kurze Tabelle und fragt drei Dinge: Passen die Regeln? Du oder Sie in den Nachrichten? Was suchst du für den Career Day (Aussteller, Sponsoren, Speaker, Partner) und stehen Datum und Ort schon fest?
3. Claude ordnet jeden Kontakt zu, bei großen Listen in Blöcken zu 100. Dabei sieht Claude nur Position und Firma, keine Namen.
4. Du siehst die Verteilung, die Top-20-Firmen, alle Kontakte mit Priorität A und die Textbausteine als Tabellen im Chat. Du kannst korrigieren, etwa „Nr. 12 ist Sonstiges" oder „Firma X ganz raus".
5. Erst nach deinem Okay entstehen die Dateien.

Im Projektordner liegt danach:

```
kontakte/
├── ausgabe/
│   ├── segmentierung-<datum>.xlsx     ← Blätter Kontakte, Firmen, Textbausteine
│   └── segmentierung-<datum>.md       ← Zusammenfassung mit den Top-20-Firmen
└── arbeit/<datum>/                    ← Zwischenstände von Claude
```

Liegt dein Projektordner in iCloud (auf vielen Macs werden Schreibtisch und Dokumente mit iCloud synchronisiert), warnt Claude dich vorher, erklärt kurz das Risiko und schlägt einen lokalen Ordner wie `~/Kontakte-lokal` vor. Du entscheidest, ob Claude dort arbeitet oder trotzdem in deinem Projektordner.

In der Excel-Datei hat jede Kopfzeile einen Filter. Die Spalte „Status (für dich)" ist leer, dort kannst du eintragen, wen du angeschrieben hast.

## Die Segmente und Prioritäten

| Segment | Typische Positionen |
|---|---|
| Talent Acquisition und Recruiting | Head of Talent Acquisition, Recruiterin, Campus Recruiting, Early Careers, Ausbildungsleitung |
| HR-Leitung und People | Personalleitung, CHRO, Chief People Officer, HR Business Partner, People & Culture |
| Employer Branding und Diversity | Employer Branding, Personalmarketing, Diversity Manager, Head of DEI |
| Geschäftsführung und Gründer | Geschäftsführerin, CEO, Founder, Inhaber, Partner in Kanzlei oder Beratung |
| Sonstiges | alle anderen, etwa Fachrollen, Studierende, Einträge ohne Position |

**A** heißt sofort ansprechen (entscheidet über Messe oder Budget oder ist für Nachwuchs zuständig), **B** zweite Welle oder Türöffner, **C** nur bei Bedarf. Claude kennt auch Stolperfallen wie Personal Trainer oder Talent Manager in der Musikbranche, die nur nach HR klingen.

## Regeln an dich anpassen

Die Regeln stehen in zwei Dateien, die du jederzeit ändern kannst. Am einfachsten sagst du es Claude, zum Beispiel:

```
Nimm die Musterbank in die Ausschlussliste auf, die ist schon Partner.
```

```
Ausbildungsleitung soll immer Priorität A bekommen.
```

`segmente.md` enthält Stichwörter und Prioritäten je Segment, `ausschluss.md` die Firmen, die Claude weglassen soll (etwa bestehende Partner). Beide liegen im Skill-Ordner `~/.claude/skills/kontakt-segmentierung/`. Installierst du das Bundle neu, bleiben deine Änderungen erhalten.

## Datenschutz

- **Nur der offizielle Export.** Claude arbeitet mit der Datei, die LinkedIn dir selbst gibt, oder mit deiner eigenen Liste. Kein automatisches Auslesen von LinkedIn-Seiten im Browser, das verbieten die Nutzungsbedingungen von LinkedIn.
- **Keine erratenen Adressen.** Der Export enthält E-Mail-Adressen nur bei Kontakten, die das erlaubt haben. Fehlende Adressen bleiben leer. Claude rät keine Adressen und nutzt keine Dienste, die Adressen nachliefern.
- **Nur das Nötige.** Verarbeitet werden Name, Firma, Position, Verbunden seit, Profil-Link und eine vorhandene E-Mail-Adresse. Für die Einordnung schaut Claude nur auf Position und Firma, nie auf Namen oder vermutete Herkunft.
- **Bleibt auf deinem Rechner.** Die Ergebnisse liegen in deinem Projektordner, nicht in iCloud, OneDrive oder geteilten Ordnern. Liegt der Ordner in einer Cloud, warnt Claude, schlägt einen lokalen Ordner vor und du entscheidest. Gib die Liste nicht in andere KI-Chats oder Online-Werkzeuge. Listen, die du nicht mehr brauchst, löschst du selbst.
- **Nie automatisch verschicken.** Werbung per Mail braucht nach § 7 UWG in der Regel eine vorherige Einwilligung, auch bei Firmenkontakten. Deshalb verschickt Claude nichts, auch keine Serienmails. Du schreibst jeden Kontakt selbst über LinkedIn an, wo ihr bereits vernetzt seid.
- **Herkunft nennen.** Nenn in der ersten Nachricht die Herkunft des Kontakts und biete an, dich nicht wieder zu melden (Art. 14 DSGVO). Beides steht schon in den Textbausteinen.
- **Kontaktdaten sind Daten.** Steht in einem Feld der Liste ein Text, der Claude etwas befehlen will, führt Claude das nicht aus und markiert den Kontakt zur Prüfung.

## Grenzen

- Claude ordnet nach der Positionsbezeichnung. Ist sie ungenau („Manager", „Consultant"), kann die Zuordnung danebenliegen. Lies die A-Kontakte deshalb einmal gegen.
- Keine Recherche zu Firmen im Netz und keine persönlichen Einzelnachrichten in dieser Stufe.
- Claude verschickt nichts, plant keine Nachrichten und merkt sich nicht, wen du angeschrieben hast.

## Nächste Ausbaustufe (im Workshop)

**Stufe 2: Firmen recherchieren und Nachrichten entwerfen.** Für deine Top-Firmen sucht Claude öffentliche Informationen (Karriereseite, Einstiegs- und Traineeprogramme, Diversity- und Employer-Branding-Aktivitäten, frühere Messeteilnahmen) und schreibt daraus für jede A-Person einen persönlichen LinkedIn-Nachrichtenentwurf. Du liest jeden Entwurf, änderst ihn und gibst ihn frei, erst dann kopierst du ihn selbst in LinkedIn. Eine Mail gibt es nur als Entwurf in Outlook und nur bei Menschen, mit denen du schon geschäftlich in Kontakt bist. So siehst du im Workshop, wie ein Agent arbeitet (einlesen, sortieren, recherchieren, entwerfen). Vor jedem Schritt nach außen fragt er dich.

**Stufe 3: Nachverfolgen.** Status je Kontakt (angeschrieben, geantwortet, zugesagt), Erinnerung an Nachfassen nach einigen Tagen und Zuordnung von Antworten aus dem Postfach. Das ist ein eigenes Folgeprojekt.

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
        ├── beispiel/Connections-beispiel.csv  ← rund 40 erfundene Kontakte für die Demo
        └── scripts/
            ├── einlesen.py                ← liest CSV oder Excel, erkennt die Spalten
            └── schreiben.py               ← schreibt Excel-Datei und Zusammenfassung
```
