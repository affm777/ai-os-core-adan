# Notion-Board: Konvention und IDs

> Diese Datei hält alles, was die vier Board-Skills über euer Board wissen müssen, an genau einer Stelle: `requirement-create` und `requirement-feedback` auf der Anforderer-Seite, `issue-implement` und `issue-done` aus dem Bundle `dev-board` auf der Entwicklungs-Seite. Ändert sich das Board, ändert sich nur diese Datei, nicht die Skills.
>
> **Das Board hier ist auf ein bewährtes GitHub-Projektboard gespiegelt**, inklusive der Status-Namen. Wer beide Welten kennt, findet sich sofort zurecht.

## Vor dem ersten Lauf ausfüllen

Ohne diese Werte laufen die Skills ins Leere. Wenn das Board noch nicht existiert: erst `board-setup.md` im Bundle abarbeiten, das legt Board und Views an und liefert genau diese IDs.

```
DATENBANK_ID:   <noch nicht gesetzt>
DATASOURCE_ID:  <noch nicht gesetzt>   collection://...
DATENBANK_URL:  <noch nicht gesetzt>
WORKSPACE:      <dein Notion-Workspace>
```

### Achtung: Notion hat zwei IDs, und die Skills brauchen beide

Das ist die häufigste Fehlerquelle. Notion unterscheidet zwischen der **Datenbank** und ihrer **Data Source** (der eigentlichen Tabelle darunter). Sie haben verschiedene IDs.

| ID | Sieht aus wie | Wofür |
|---|---|---|
| **DATENBANK_ID** | 32 Zeichen, steht in der URL | Nur der Link zum Anschauen |
| **DATASOURCE_ID** | `collection://` plus UUID, steht **nicht** in der URL | Karten anlegen und Karten suchen |

**Die ID aus der URL ist die falsche für beide Skills.** Die Data-Source-ID bekommst du nur so:

```
notion-fetch mit der DATENBANK_ID aufrufen
→ in der Antwort steht <data-source url="collection://...">
→ das ist die DATASOURCE_ID
```

Oder einfach Claude fragen: „hol mir die Data-Source-ID meiner Datenbank <Name>".

## Aufbau des Boards

Ein Board, eine Karte pro Anforderung.

| Property | Typ | Werte | Wofür |
|---|---|---|---|
| **Name** | Titel | Freitext | Eine Zeile, die die Arbeit beschreibt. Kein Roman. |
| **Status** | Auswahl | `Backlog`, `Ready`, `In Progress`, `In Review`, `Ready for Deployment`, `Done`, `Rejected` | Wo die Karte steht. Siehe Lebenszyklus unten. |
| **Type** | Auswahl | `Bug`, `Feature`, `Task` | Bestimmt die Struktur des Karteninhalts. |
| **Priority** | Auswahl | `P0-blocker`, `P1-high`, `P2-normal`, `P3-nice-to-have` | Vorschlag, wird im Grooming bestätigt. |
| **Size** | Auswahl | `XS`, `S`, `M`, `L` | Schätzung. Darf leer bleiben. |
| **Sprint** | Auswahl | `Sprint 1`, `Sprint 2`, ... | Leer lassen, außer die Karte soll jetzt gezogen werden. |
| **Epic** | Auswahl | projekt-spezifisch | Grobes Themenfeld. Werte beim Setup festlegen. |
| **Area** | Auswahl | `frontend`, `backend`, `infra`, `docs` | Wo die Arbeit anfällt. Darf leer bleiben. |
| **Source** | Text | z.B. `Gespräch Gast 14.07.`, `Mail Interessent` | **Kein GitHub-Gegenstück, bewusst ergänzt.** Woher kam die Anforderung? Macht Feedback rückverfolgbar. |
| **Assignee** | Person | | Wer arbeitet daran. |

**Falls ihr schon ein Board habt: dieses hier nicht bauen.** Dann werden die Property-Namen oben an das bestehende Board angepasst. Ein zweites Board neben einem gewachsenen ist der schnellste Weg, dass beide sterben.

### Board-Adoption: bestehendes Board übernehmen

Beim Übernehmen liest Claude das Schema des bestehenden Boards (`notion-fetch`) und passt die Property-Tabelle oben auf die echten Namen und Werte an. Zusätzlich die drei Status eintragen, die die Skills aktiv setzen:

```
EINGANGS_STATUS:  <Status neuer Karten,                            Standard-Board: Backlog>
ZIEHBAR_STATUS:   <Status "durchdacht und ziehbar",                Standard-Board: Ready>
REWORK_STATUS:    <Status während Umsetzung und nach Feedback,     Standard-Board: In Progress>
REVIEW_STATUS:    <Status zur Abnahme,                             Standard-Board: In Review>
```

(`REVIEW_STATUS` nutzen die Entwicklungs-Skills aus dem Bundle `dev-board`, das auf demselben Board arbeitet.)

Die Skills verwenden ausschließlich die Werte aus dieser Datei, nicht ihre eingebauten Standard-Namen. Zwei Stolperfallen:

- **Notion legt unbekannte Select-Werte nicht automatisch an.** Ein Status, der hier steht, aber am Board fehlt, lässt den Skill-Lauf scheitern. Deshalb nach dem Anpassen einmal mit einer Testkarte verifizieren.
- **Fehlt dem Board eine Property** (z.B. `Source`): entweder am Board ergänzen (eine Property zu ergänzen ist harmlos, anders als ein zweites Board) oder die Zeile oben streichen, dann lassen die Skills sie weg.

## Status-Lebenszyklus

- **Backlog:** eingefangen, noch nicht durchdacht.
- **Ready:** so klar geschrieben, dass die Entwicklung sie ohne Rückfrage ziehen kann. Das ist das Ziel jeder neuen Karte.
- **In Progress:** die Entwicklung arbeitet daran.
- **In Review:** die Entwicklung ist fertig, du prüfst.
- **Ready for Deployment:** abgenommen, wartet auf das Ausrollen.
- **Done:** ausgerollt und erledigt.
- **Rejected:** bewusst verworfen. **Der einzige ehrliche Weg, eine Anforderung zu beerdigen**, ohne zu behaupten, sie sei fertig. Karten, die niemand baut, gehören hierhin und nicht auf ewig ins Backlog.

**Die Regel, die den Workflow trägt:** Kommt Feedback, während die Karte in `In Review` steht, geht sie zurück auf `In Progress`. Die Arbeit ist dann nicht fertig, egal was die Spalte behauptet. Genau das macht `requirement-feedback` automatisch.

## Views

| View | Layout | Was sie zeigt |
|---|---|---|
| **Current Sprint** | Board, gruppiert nach Status | Nur Karten des laufenden Sprints. Die Arbeitsansicht. |
| **Backlog** | Tabelle | Status `Backlog` und ohne Sprint. Alle Spalten, zum Groomen. |
| **By Epic** | Board, gruppiert nach Epic | Themen-Überblick. |
| **Blockers** | Tabelle | Alles `P0-blocker`, was nicht `Done` oder `Rejected` ist. |

### Der Sprint-Vorbehalt, bitte einmal lesen

GitHub hat einen Feldtyp *Iteration*, der von selbst weiß, welcher Sprint gerade läuft. Deshalb funktioniert dort ein Filter `sprint:@current` ohne Zutun.

**Notion hat diesen Feldtyp nicht.** Sprint ist hier ein Auswahl-Feld, und die Current-Sprint-View filtert auf einen **fest benannten** Sprint. Das heißt:

> **Bei jedem Sprintwechsel den Filter der Current-Sprint-View einmal umstellen.** Zwei Klicks in Notion. Wer es vergisst, schaut auf den alten Sprint, und die View lügt, ohne es zu sagen.

Das ist bewusst so gewählt: einfach zu verstehen, komplett per Connector baubar, und später erweiterbar. Wer es automatisch will, braucht eine zweite Datenbank „Sprints" mit Start- und Enddatum, eine Relation und einen Rollup. Mehr Mechanik, mehr Erklärung, gleicher Nutzen für kleine Teams.

## Werkzeuge

Der Notion-Connector muss verbunden sein (`claude.ai` → Einstellungen → Connectors → Notion).

| Zweck | Tool | Nimmt welche ID? |
|---|---|---|
| Datenbank finden | `notion-search`, dann `notion-fetch` | URL oder Name |
| Schema, Properties, Data-Source-ID lesen | `notion-fetch` | **DATENBANK_ID** |
| Karte anlegen | `notion-create-pages`, `parent` = `data_source_id` | **DATASOURCE_ID** |
| Karten suchen | `notion-query-data-sources` | **DATASOURCE_ID** |
| Karte lesen | `notion-fetch` | Seiten-ID |
| Property ändern (Status) | `notion-update-page` | Seiten-ID |
| Kommentar anhängen | `notion-create-comment` | Seiten-ID |

## Verbindungs-Check (vor dem ersten Lauf prüfen)

Die Datenbank-Abfrage über den Notion-Connector läuft auf **allen Plänen**, auch Free und Plus. Dort greift allerdings ein **Stundenlimit** auf die Zahl der Abfragen. Nur Abfragen über **mehrere** Data Sources hinweg verlangen Enterprise plus Notion AI, und beide Skills fragen immer nur **eine** Data Source ab. Ein Plan-Upgrade ist für diesen Use Case also nicht nötig. (Quelle: Tool-Beschreibung von `notion-query-data-sources`.)

**Das Stundenlimit betrifft beide Skills**, denn `notion-query-data-sources` steckt im Dedup-Check von `requirement-create` und in der Kartensuche von `requirement-feedback`. Wer auf Free oder Plus viele Karten hintereinander anlegt, kann es erreichen. Dann hilft warten, nicht upgraden.

**Einmal vorab testen**, nicht erst im Echtbetrieb. Test in einem Satz: „Zeig mir die Karten aus meinem Board <Name>." Kommen Daten, ist alles gut.

## Warum kein GitHub

Der Workflow stammt aus einem Entwickler-Projekt und lief dort auf GitHub Issues plus Projektboard. Für viele Teams passt Notion besser: Es ist ohnehin da, du bist dort ohnehin unterwegs, und Anforderungen sind kein Entwickler-Artefakt, sondern ein Produkt-Artefakt. Der Workflow ist identisch, nur der Behälter ist ein anderer.

**Was Notion im Vergleich nicht kann**, damit niemand danach sucht:

- **Iteration-Feld** mit automatischem „aktueller Sprint". Siehe Sprint-Vorbehalt oben.
- **Sub-Issues** mit Fortschrittsbalken. Notion bräuchte dafür eine Selbst-Relation (Parent/Children). Bewusst weggelassen, solange niemand danach fragt.
- **Verknüpfte Pull Requests.** Kein Gegenstück, ersatzlos gestrichen.
