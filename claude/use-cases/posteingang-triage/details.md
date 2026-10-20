# Der Posteingang sortiert sich selbst vor (Details)

Ergänzung zur [README](README.md) in diesem Ordner. Hier steht alles, was über die Schritt-für-Schritt-Anleitung hinausgeht.

## Inhalt

- [Überblick](#überblick)
- [Gut zu wissen](#gut-zu-wissen)
- [Voraussetzungen](#voraussetzungen)
- [Installation](#installation)
- [Erster Lauf, deine Labels festlegen](#erster-lauf-deine-labels-festlegen)
- [Jeder weitere Lauf](#jeder-weitere-lauf)
- [So sieht das Ergebnis aus](#so-sieht-das-ergebnis-aus)
- [Rückblick: was ist liegengeblieben](#rückblick-was-ist-liegengeblieben)
- [Ablage-Ansicht je Label](#ablage-ansicht-je-label)
- [Ein zweites Postfach sichten](#ein-zweites-postfach-sichten)
- [Persönlicher Schreibstil](#persönlicher-schreibstil)
- [Grenzen](#grenzen)
- [Nächste Ausbaustufe](#nächste-ausbaustufe)
- [Was im Bundle liegt](#was-im-bundle-liegt)

## Überblick

Dieser Use Case sichtet die Mails, die seit dem letzten Lauf angekommen sind (beim allerersten Mal die letzten 7 Tage) oder die in einem Zeitraum liegen, den du nennst. Claude liest zusammengehörige Mails als einen Verlauf und ordnet jeden Verlauf nach seinem Inhalt einem deiner Labels zu. Welche Labels das sind, legst du beim ersten Lauf gemeinsam mit Claude fest, egal ob du einen Verein, einen Pflegedienst, ein Vertriebsteam oder etwas ganz anderes führst. Jeder Verlauf bekommt eine Priorität (hoch, mittel, niedrig). Was eilt, wird zusätzlich als Dringend markiert, wo Geld oder eine Gelegenheit drinsteckt, als Chance. Gleichzeitig erkennt Claude die Aufgaben für dich in den Mails und schlägt sie als To-do-Liste vor. Erst wenn du bestätigst, setzt Claude die Farb-Kategorien in Outlook, schreibt die To-dos in deine `TODO.md` und legt für die von dir genannten Mails fertige Antwortentwürfe in den Entwürfe-Ordner. Versendet wird nie automatisch.

## Gut zu wissen

- Der Skill wird einmal installiert und steht danach überall zur Verfügung, egal in welchem Ordner du gerade arbeitest. Du findest ihn danach auch im Dashboard unter Skills & Commands.

## Voraussetzungen

- Der Microsoft-365-Connector ist in Claude verbunden (Einstellungen, Connectoren, Microsoft 365).
- Euer Microsoft-Konto hat Claude einmalig freigegeben. Das macht die Person, die euer Microsoft-Konto als Administrator verwaltet, Schritt für Schritt beschrieben in der Admin-Anleitung, die ihr mit dem Workshop bekommen habt (`admin-anleitung-claude-m365.pdf`). Ohne diese Freigabe sieht Claude dein Postfach nicht.
- Alles Weitere ist mit deinem Setup bereits installiert.

Zeitbedarf: Der erste Lauf dauert mit dem Festlegen deiner Labels rund 15 Minuten, jeder weitere Lauf etwa 3 bis 5 Minuten, das meiste davon arbeitet Claude allein.

## Installation

Liegt schon eine ältere Fassung vor, sichert das Skript sie unter `~/.claude/backups/` und holt deinen gelernten Schreibstil (`TONE.md`) und die Merkzettel, wann welches Postfach zuletzt gesichtet wurde (`.last-run*`), zurück. Starte danach eine neue Session, damit Claude den neuen Skill kennt.

## Erster Lauf, deine Labels festlegen

Öffne Claude in dem Ordner, in dem deine Einstellungen und deine To-do-Liste liegen sollen (zum Beispiel dein Projektordner). Sag Claude:

```
Sichte den Posteingang und sortier ihn vor.
```

Liegen in diesem Ordner noch keine Einstellungen, weiß Claude, dass der Skill hier neu ist. Dann fragt Claude dich zuerst, wie du deine Mails strukturieren willst. Du bekommst drei Startsets zur Auswahl und kannst auch ganz eigene Labels nehmen:

| Startset | Labels |
|---|---|
| Verein | Förderung, Partner, Teilnehmende, Veranstaltungen, Verwaltung, Team, Sonstiges |
| Pflegedienst | Patienten und Angehörige, Kostenträger und Kassen, Mitarbeiter und Bewerbungen, Lieferanten und Rechnungen, Behörden und Prüfungen, Sonstiges |
| Vertrieb und Projekte | Chance, Kunden, Partner, Verwaltung, Team, Sonstiges |
| Eigene Labels | du beschreibst, wie du denkst, Claude macht einen Vorschlag |

So ungefähr läuft das Gespräch:

```
Claude: Bevor ich dein Postfach sichte, legen wir gemeinsam fest, wie deine
        Mails sortiert werden sollen. Das passiert nur einmal. Welche
        Mailadresse ist dein Hauptpostfach und zu welcher Einheit gehört es?

Du:     projekte@beispielverein.org, das ist unser Verein.

Claude: Für einen Verein schlage ich dieses Startset vor:
        Förderung (lila): Stiftungen, Ausschreibungen, Anträge, Nachweise
        Partner (blau): Unternehmen, Schulen, Kommunen, Netzwerke
        Teilnehmende (grün): Mentees, Mentoren, Bewerbungen, Terminfragen
        Veranstaltungen (beere): Career Day, Messen, Infoabende, Aussteller
        Verwaltung (orange): Rechnungen, Verträge, Bank, Versicherung
        Team (türkis): Vorstand, Geschäftsstelle, Ehrenamtliche
        Sonstiges (grau): Newsletter, Werbung, Systemmails
        Was fehlt, was soll anders heißen, was kann weg?

Du:     Ich brauche noch ein Label Presse, in Pink.

Claude: Pink gibt es in Outlook nicht und Beere hat schon Veranstaltungen,
        ich nehme Braun. Presse sind dann Anfragen von Journalistinnen und
        Journalisten, Interviews und Pressemitteilungen. Passt das?

Du:     Passt.

Claude: Dazu schlage ich zwei Markierungen vor, die zusätzlich zum Label
        gesetzt werden. Dringend (rot) für alles mit hoher Priorität und
        Chance (gelb) für Sponsoring, Kooperationen und Anfragen, auf die
        noch keiner geantwortet hat. Beide behalten?

Du:     Ja.

Claude: Hohe Priorität bekommt eine Mail bei einer Frist in den nächsten
        sieben Tagen, wenn jemand auf Antwort wartet oder wenn Geld im Spiel
        ist. Soll noch etwas dazu?

Du:     Alles von Stiftungen ist mindestens mittel.

Claude: Notiert. Was darf in Antwortentwürfen nie zugesagt werden? Mein
        Vorschlag: Fördermittel, Plätze im Programm, Kooperationen.

Du:     Passt.

Claude: Gespeichert in posteingang/KONFIG.md. Soll ich jetzt die letzten
        sieben Tage sichten?
```

Alles, was ihr festgelegt habt, steht danach in der Datei `posteingang/KONFIG.md` in deinem Ordner: Postfach, Einheit, Labels mit Beschreibung und Farbe, Markierungen, Prioritätsregeln, Entwurfs-Regeln und das Datum der Einrichtung. In Outlook legt Claude die Kategorien erst an, wenn du den ersten Digest bestätigt hast.

Du kannst die Einstellungen jederzeit ändern. Sag Claude:

```
Ändere meine Labels.
```

Claude zeigt dir die aktuelle Liste und passt sie nach deinen Wünschen an. Ein umbenanntes oder gestrichenes Label bleibt als Kategorie in Outlook bestehen, Claude löscht dort nie etwas. Alte Kategorien räumst du in Outlook selbst auf (Kategorisieren, Alle Kategorien).

## Jeder weitere Lauf

| Du sagst | Claude sichtet |
|---|---|
| „Sichte den Posteingang." | alles seit dem letzten Lauf |
| „Sichte die letzten zwei Wochen." | genau diesen Zeitraum |
| „Sichte Oktober." | den ganzen Oktober |
| „Sichte das Info-Postfach." | ein weiteres Postfach aus deiner KONFIG.md |

Das passiert dann:

1. Claude liest die Mails als Verläufe. Antworten und Nachfragen zum selben Thema bilden eine Einheit, die letzte Mail im Verlauf zählt.
2. Jeder Verlauf bekommt ein Label, eine Priorität und, wenn zutreffend, eine Chance mit einem Halbsatz, warum. Rechnungen sind mit „Beleg" markiert.
3. Du bekommst eine Übersichtstabelle, hohe Priorität zuerst, darin nach deinen Labels geordnet, mit einer Spalte „To-do" für jeden Verlauf.
4. Claude fragt, ob alles passt und für welche Nummern du Antwortentwürfe willst. Du sagst etwa „passt, Entwürfe für 1 und 2" oder korrigierst („Nr. 4 ist kein To-do", „Nr. 6 ist hoch").
5. Nach deinem Ja setzt Claude die Farb-Kategorien in Outlook und schreibt die To-dos in die `TODO.md` in deinem Ordner. Was dort schon offen steht, wird nicht doppelt eingetragen.
6. Für die Nummern, die du genannt hast, legt Claude Antwortentwürfe in den Entwürfe-Ordner, nach den Regeln aus deiner KONFIG.md. Nichts wird automatisch versendet.

Eine Mail gilt als bearbeitet, sobald sie eines deiner Labels trägt, nicht sobald du sie gelesen hast. Kommt in einem schon sortierten Verlauf eine neue Mail an, schaut Claude ihn sich neu an.

## So sieht das Ergebnis aus

Ein erfundenes Beispiel aus Sicht eines Vereins mit dem Verein-Startset ohne Änderungen, Stand Freitag 16.10.2026, neun Verläufe. Claude zeigt dir im Chat:

**Hauptpostfach, Beispielverein e.V., seit 09.10.**

| Nr. | Absender | Betreff | Label | Priorität | Chance | To-do |
|---|---|---|---|---|---|---|
| 1 | Stiftung Bildungsbrücke | Erinnerung: Verwendungsnachweis 2025 (2) | Förderung | hoch | | Sachbericht und Belegliste für den Verwendungsnachweis nachreichen, bis 22.10. |
| 2 | Realschule am Stadtpark | ● Infoabend Mentoring für unsere 9. Klassen | Partner | hoch | | Terminvorschlag für den Infoabend an die Schule schicken, bis 20.10. |
| 3 | Druckhaus Weber | ● Rechnung RE-2026-114 | Verwaltung, Beleg | hoch | | Rechnung RE-2026-114 zur Zahlung freigeben, bis 24.10. |
| 4 | Landesprogramm Jugend stärken | ● Ausschreibung 2027 geöffnet | Förderung | mittel | Ausschreibung passt zum Mentoring-Programm | Prüfen, ob wir uns auf die Ausschreibung 2027 bewerben, bis 30.11. |
| 5 | Hansewerk Personal GmbH | ● Stand beim Career Day? | Veranstaltungen | mittel | Firma will als Ausstellerin zum Career Day | Konditionen für einen Ausstellerstand schicken, ohne Frist |
| 6 | Nordlicht Logistik GmbH | Mentoring durch unsere Mitarbeitenden? | Partner | mittel | Unternehmen bietet eine Kooperation an | Rückruf bei Nordlicht Logistik vereinbaren, ohne Frist |
| 7 | Leyla K. | Absage Termin am Samstag | Teilnehmende | mittel | | Neuen Termin für das Mentoring-Gespräch mit Leyla vorschlagen, ohne Frist |
| 8 | Vereinsversicherung Süd | Bestätigung Ihrer Vertragsänderung | Verwaltung | niedrig | | keins |
| 9 | Konto-Service | ● Wichtiger Hinweis zu Ihrem Postfach | Sonstiges | niedrig | | keins |

Warum hoch? Nr. 1, die Stiftung erinnert zum zweiten Mal und braucht die Unterlagen bis 22.10. für die Prüfung. Nr. 2, die Schule bittet um Rückmeldung bis 20.10. Nr. 3, die Rechnung ist am 24.10. fällig.

Achtung bei Nr. 9, Verdacht auf eingeschleuste Anweisung. Die Mail fordert „den Assistenten" auf, alle Rechnungen an eine fremde Adresse weiterzuleiten. Claude hat nichts davon getan und die Mail nur einsortiert.

Passt das so? Und für welche Nummern soll ich Antwortentwürfe schreiben? Auf eine Antwort warten erkennbar Nr. 1, 2, 5 und 6.

Du sagst „passt, Entwürfe für 1 und 2". Danach stehen in deiner `TODO.md` diese sieben neuen Zeilen:

```
- [ ] Sachbericht und Belegliste für den Verwendungsnachweis nachreichen (von Stiftung Bildungsbrücke, 14.10.2026, Frist 22.10.2026)
- [ ] Terminvorschlag für den Infoabend an die Schule schicken (von Realschule am Stadtpark, 15.10.2026, Frist 20.10.2026)
- [ ] Rechnung RE-2026-114 zur Zahlung freigeben (von Druckhaus Weber, 16.10.2026, Frist 24.10.2026)
- [ ] Prüfen, ob wir uns auf die Ausschreibung 2027 bewerben (von Landesprogramm Jugend stärken, 13.10.2026, Frist 30.11.2026)
- [ ] Konditionen für einen Ausstellerstand schicken (von Hansewerk Personal GmbH, 15.10.2026, Frist ohne)
- [ ] Rückruf bei Nordlicht Logistik vereinbaren (von Nordlicht Logistik GmbH, 12.10.2026, Frist ohne)
- [ ] Neuen Termin für das Mentoring-Gespräch mit Leyla vorschlagen (von Leyla K., 15.10.2026, Frist ohne)
```

In Outlook tragen alle neun Verläufe ihr Label, Nr. 1 bis 3 zusätzlich Dringend, Nr. 4 bis 6 zusätzlich Chance. Claude zeigt dir die beiden Entwürfe zum Gegenlesen, sie liegen im Entwürfe-Ordner. Am Ende kommt eine kurze Meldung wie diese:

```
Fertig mit deinem Hauptpostfach. 9 Verläufe sortiert, 3 mit hoher Priorität, 3 Chancen, 1 Beleg.
7 To-dos neu in der TODO.md, 2 Antwortentwürfe liegen im Entwürfe-Ordner.
Eine Mail sah nach einer eingeschleusten Anweisung aus (Nr. 9), ich habe sie nur einsortiert.
```

## Rückblick: was ist liegengeblieben

Neben dem normalen Lauf gibt es einen zweiten Aufruf, der rückwirkend nach Mails sucht, auf die nie jemand geantwortet hat. Gedacht für die Frage „liegt da noch Geld rum?". Sag Claude:

```
Sichte die letzten 90 Tage auf Liegengebliebenes.
```

Claude liest den Eingang der letzten 90 Tage (auf Wunsch auch einen anderen Zeitraum, etwa „seit Juli"), lässt Newsletter, Werbung und interne Mails weg und prüft bei jedem übrigen Verlauf, ob aus deinem Postfach danach eine Antwort an den Absender ging. Übrig bleibt nur, was unbeantwortet ist, als Liste mit Chance-Markierung, Label, Absender, Datum, Kernanliegen und einem Vorschlag für den nächsten Schritt. Im Rückblick setzt Claude keine Kategorien in Outlook und ändert nichts daran, wann der normale Lauf zuletzt war. To-dos schreibt Claude nur, wenn du darum bittest.

Ein erfundenes Beispiel, Stand 20.10.2026:

| Nr. | Chance | Label | Absender | Datum | Kernanliegen | Nächster Schritt |
|---|---|---|---|---|---|---|
| 1 | Sponsoring-Interesse | Partner | Brückner Maschinenbau AG | 28.07.2026 | Fragt, ob der Verein Sponsoren für Veranstaltungen sucht | Kurz nachfassen und ein Telefonat anbieten |
| 2 | Rückfrage zu unserem Angebot | Partner | Volkshochschule Mittelstadt | 02.09.2026 | Will wissen, ob das Mentoring-Angebot auch für Erwachsene gilt | Rückfrage beantworten und Gesprächstermin vorschlagen |
| 3 |  | Partner | Stadtteilbüro Nord | 15.09.2026 | Bittet um Infomaterial für die Auslage | Infomaterial schicken oder sagen, wann es kommt |

Willst du daraus To-dos, sag „schreib Nr. 1 und 2 als To-do". Die Zeilen landen im selben Format in deiner `TODO.md` wie beim normalen Lauf.

## Ablage-Ansicht je Label

Claude verschiebt nie eine Mail, alles bleibt im Posteingang. Willst du trotzdem je Label eine eigene Ansicht wie einen Ordner, legst du sie in Outlook einmal selbst an. Die Mails bleiben dabei, wo sie sind, die Ansicht zeigt nur alle Mails mit dieser Kategorie.

- **Outlook am Windows-Rechner (klassisch):** Im Menüband auf Ordner, dann Neuer Suchordner. Unter „E-Mail organisieren" den Eintrag „Kategorisierte E-Mail" wählen, unten auf Auswählen klicken, die Kategorie ankreuzen (etwa Förderung) und zweimal mit OK bestätigen. Der Suchordner erscheint links unter Suchordner.
- **Outlook im Browser und neues Outlook:** Zahnrad oben rechts, Allgemein, Kategorien. Beim gewünschten Label auf den Stern klicken (Zu Favoriten hinzufügen). Das Label erscheint links unter Favoriten und zeigt alle Mails mit dieser Kategorie.

Je nach Outlook-Version heißen die Menüpunkte leicht anders. Findest du sie nicht, frag Claude „wie lege ich in meinem Outlook eine Ansicht für die Kategorie Förderung an" und beschreib, was du siehst.

## Ein zweites Postfach sichten

Hast du Zugriff auf ein weiteres Postfach im selben Microsoft-Konto (etwa ein Team- oder Info-Postfach), sag Claude:

```
Trag in meine posteingang/KONFIG.md das Postfach "Info" mit der Adresse info@... ein.
```

Danach reicht „Sichte das Info-Postfach". Claude merkt sich für jedes Postfach getrennt, wann es zuletzt gesichtet wurde. Die Labels gelten für alle Postfächer in derselben KONFIG.md. Gehört ein Postfach zu einer ganz anderen Einheit mit anderen Labels, öffne Claude für diese Einheit in einem eigenen Ordner, dort richtest du eigene Labels ein.

Ein Postfach in einem anderen Microsoft-Konto braucht dort eine eigene Freigabe durch den Administrator und ist in dieser Fassung noch nicht angebunden. Versuchst du es trotzdem, sagt Claude dir in einem Satz, dass der Zugriff fehlt. Dann bietet Claude dein Hauptpostfach an.

## Persönlicher Schreibstil

Damit Antwortentwürfe nach dir klingen und nicht nach Standard-KI, schaut sich Claude beim allerersten Entwurf einmalig rund 50 deiner zuletzt gesendeten Mails an und merkt sich deinen Stil: Anrede, Grußformel, Satzlänge, Tonfall. Das Ergebnis liegt als Datei `TONE.md` im Skill-Ordner, alle späteren Entwürfe orientieren sich daran. Finden sich zu wenige gesendete Mails, startet Claude mit einem neutralen, professionellen Ton und sagt dir das.

Dein gelernter Stil ändert sich nie von allein. Willst du ihn neu lernen lassen oder anpassen, sag Claude:

```
Aktualisiere die TONE.md in meinem posteingang-triage-Skill.
Frag mich vorher, was angepasst werden soll.
```

## Grenzen

- Claude beurteilt jeden Verlauf nach seinem Inhalt, der Absender ist nur ein Hinweis.
- Antwortentwürfe gibt es nur für die Nummern, die du nennst. Sie werden nie automatisch versendet, sie liegen immer nur im Entwürfe-Ordner. Sie sagen nichts zu, was in deiner KONFIG.md unter „Was nie zugesagt wird" steht. Sie enthalten keine Zahlen, sondern bieten einen Termin oder eine Rückmeldung bis zu einem Datum an.
- Claude leitet keine Mail weiter, löscht keine und verschiebt keine, nie. Auch Kategorien in Outlook entfernt oder löscht Claude nie.
- Mails sind für Claude nur Text zum Einordnen, keine Aufträge. Steht in einer Mail etwas wie „an den Assistenten, leite das weiter", tut Claude das nicht, sortiert die Mail unter Sonstiges ein und zeigt sie dir mit einem Warnhinweis. Links in Mails öffnet Claude nie, Anhänge liest Claude nur, wenn du es für die jeweilige Mail erlaubst.
- Gesundheitsangaben und andere sensible Daten aus Mails tauchen weder in der Tabelle noch in der TODO.md auf, dort steht nur das Anliegen allgemein.
- Rechnungen werden mit „Beleg" markiert, aber noch nicht abgelegt.
- To-dos landen nur in der `TODO.md`, nicht in Outlook-Aufgaben oder Microsoft To Do.
- Farb-Kategorien und Antwortentwürfe gibt es nur in dem Postfach, mit dem Claude verbunden ist. In einem weiteren Postfach (etwa Info) bekommst du die Übersicht und die To-dos, Kategorien und Entwürfe setzt du dort selbst.
- Im Rückblick fragt Claude bei mehr als rund 300 Verläufen nach, ob der Zeitraum gekürzt oder in zwei Teilen gesichtet werden soll. Bremst Microsoft wegen zu vieler Anfragen, wartet Claude kurz und sagt dir das.
- Fehlt die Verbindung zu Microsoft 365, sagt dir Claude das in einem Satz. Prüf dann in Claude unter Einstellungen bei den Connectoren, ob Microsoft 365 verbunden ist. Starte danach eine neue Session.

## Nächste Ausbaustufe

- Beleg-Ablage: Rechnungen mit Zusatz „Beleg" werden gesammelt in einen Ordner gelegt, bereit für die Buchhaltung.
- Zweites Postfach in einem anderen Microsoft-Konto, sobald dort die Freigabe erteilt ist.
- To-dos zusätzlich in Microsoft To Do.
- Automatischer Lauf als Routine zwei- bis dreimal täglich, ohne dass du daran denken musst.
- Bekannte Absender als zusätzliches Signal bei der Einordnung.
- Claude lernt aus deinen Korrekturen und schlägt vor, die Beschreibung eines Labels nachzuschärfen.

## Was im Bundle liegt

```
posteingang-triage/
├── README.md                          ← diese Anleitung
├── details.md                         ← Details und Beispiele zur Anleitung
├── install.sh                         ← Installationsskript (Schritt 1)
└── skills/
    └── posteingang-triage/
        ├── SKILL.md                   ← die Arbeitsanleitung für Claude
        ├── einrichtung.md             ← das Gespräch beim ersten Lauf und beim Ändern der Labels
        ├── .last-run-<adresse>        ← entsteht je Postfach, merkt sich den letzten Lauf
        └── TONE.md                    ← entsteht beim ersten Entwurf, dein gelernter Schreibstil
```

In deinem Arbeitsordner entsteht beim ersten Lauf:

```
posteingang/
└── KONFIG.md                          ← deine Einstellungen: Postfach, Einheit, Labels, Regeln
TODO.md                                ← deine To-dos aus den Mails, eine Zeile je Aufgabe
```
