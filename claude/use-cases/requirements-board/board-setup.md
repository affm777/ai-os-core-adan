# Board-Setup: einmalig, vor allem anderen

**Wofür:** Das Notion-Board anlegen, das die Skills `requirement-create` und `requirement-feedback` bespielen. **Ohne dieses Board läuft kein Skill.** Das hier ist Schritt null.

**Wie benutzen:** Diese Datei Claude geben und sagen: „Setz mir das Anforderungs-Board nach `board-setup.md` auf." Claude arbeitet sie ab und trägt am Ende die IDs in `.claude/rules/notion-board.md` ein.

**Dauer:** wenige Minuten. Einmalig.

---

## Schritt 0: Die Frage, die alles andere überflüssig machen kann

**Habt ihr schon ein Board für Anforderungen?**

Wenn ja: **hier aufhören.** Kein zweites Board bauen. Stattdessen die Property-Namen in `.claude/rules/notion-board.md` an das bestehende Board anpassen und die IDs von dort holen. Ein zweites Board neben einem gewachsenen ist der schnellste Weg, dass beide sterben.

Nur weiterlesen, wenn es wirklich noch keins gibt.

## Schritt 1: Verbindungs-Check, bevor irgendetwas gebaut wird

Beide Skills brauchen die Datenbank-Abfrage über den Notion-Connector. Sie läuft auf allen Plänen, auf Free und Plus mit einem Stundenlimit. Ein Upgrade ist nicht nötig, der Connector muss nur verbunden sein.

Test:

```
notion-query-data-sources mit einer beliebigen bestehenden Datenbank
```

Kommt ein Upgrade-Hinweis statt Daten, **hier stoppen und den Nutzer fragen**. Das Board zu bauen hat dann keinen Zweck, die Skills könnten nicht suchen. Das ist keine Kleinigkeit, die man nebenbei löst.

## Schritt 2: Epic-Werte klären

Die einzige Stelle, die pro Team anders aussieht. **Epics sind die groben Themenfelder**, meist die Produkte oder Systeme, an denen gearbeitet wird.

Frag den Nutzer: „Welche Systeme oder Produkte betreut ihr? Die werden die Epics."

**Nicht raten.** Wenn die Antwort fehlt, mit `Sonstiges` als einzigem Wert starten und später ergänzen. Ein falsches Epic-Set ist schlimmer als ein leeres, weil danach jede Karte in die falsche Schublade wandert.

## Schritt 3: Datenbank anlegen

`notion-create-database` mit genau diesem Schema. Die Epic-Werte aus Schritt 2 einsetzen.

**Vorher zwei Dinge klären, sonst sieht das Board niemand ausser dir:**

- **Wo soll es liegen?** Ohne `parent` legt Notion die Datenbank als **private Seite auf Workspace-Ebene** an. Ein Anforderungs-Board, das die Entwicklung nicht sieht, ist wertlos. Also fragen, in welchen Teamspace oder unter welche Seite es gehört, und diese als `parent` mitgeben. Im Zweifel den Teamspace nehmen, in dem das Team ohnehin arbeitet.
- **Wie soll es heissen?** Der `title` ist ein eigener Parameter und steht nicht im Schema unten. Fragen, statt einen Namen zu erfinden.

```sql
CREATE TABLE (
  "Name"     TITLE,
  "Status"   SELECT('Backlog':gray, 'Ready':blue, 'In Progress':yellow,
                    'In Review':orange, 'Ready for Deployment':purple,
                    'Done':green, 'Rejected':red),
  "Type"     SELECT('Bug':red, 'Feature':purple, 'Task':default),
  "Priority" SELECT('P0-blocker':red, 'P1-high':orange,
                    'P2-normal':yellow, 'P3-nice-to-have':gray),
  "Size"     SELECT('XS':gray, 'S':blue, 'M':yellow, 'L':orange),
  "Sprint"   SELECT('Sprint 1':blue, 'Sprint 2':blue, 'Sprint 3':blue, 'Sprint 4':blue),
  "Epic"     SELECT('<aus Schritt 2>':blue, 'Sonstiges':gray),
  "Area"     SELECT('frontend':blue, 'backend':purple, 'infra':gray, 'docs':default),
  "Source"   RICH_TEXT,
  "Assignee" PEOPLE
)
```

**Die Status-Namen sind bewusst englisch** und bewusst genau diese sieben. Sie spiegeln ein bewährtes GitHub-Projektboard. Nicht eindeutschen, nicht kürzen. `Rejected` wirkt verzichtbar, ist es aber nicht: Es ist der einzige Weg, eine Anforderung zu beerdigen, ohne zu behaupten, sie sei fertig.

**Aus der Antwort beide IDs mitnehmen:**
- die **Datenbank-ID** (steht in der zurückgegebenen URL)
- die **Data-Source-ID** aus dem `<data-source url="collection://...">`-Tag

Die zweite steht **nicht** in der URL und ist genau die, die die Skills brauchen. Siehe `.claude/rules/notion-board.md`.

## Schritt 4: Die vier Views anlegen

Alle mit `notion-create-view`, jeweils mit `database_id` **und** `data_source_id`.

**Current Sprint** (Typ `board`) — die Arbeitsansicht:
```
GROUP BY "Status"; FILTER "Sprint" = "Sprint 1"; SORT BY "Priority" ASC;
SHOW "Name", "Assignee", "Type", "Priority", "Size", "Epic"
```

**Backlog** (Typ `table`) — zum Groomen, alle Spalten:
```
FILTER "Status" = "Backlog" AND "Sprint" IS EMPTY; SORT BY "Priority" ASC;
SHOW "Name", "Type", "Priority", "Size", "Epic", "Area", "Source", "Assignee", "Sprint";
FREEZE COLUMNS 1
```

**By Epic** (Typ `board`) — Themen-Überblick:
```
GROUP BY "Epic"; FILTER "Status" != "In Progress";
SHOW "Name", "Status", "Type", "Priority", "Assignee"
```

**Blockers** (Typ `table`) — was gerade brennt:
```
FILTER "Priority" = "P0-blocker" AND "Status" != "Done" AND "Status" != "Rejected";
SORT BY "Status" ASC; SHOW "Name", "Status", "Type", "Epic", "Assignee", "Sprint"
```

> **Zum Current-Sprint-Filter:** `"Sprint" = "Sprint 1"` ist fest verdrahtet. Notion kennt kein „aktueller Sprint", anders als GitHub. **Bei jedem Sprintwechsel den Filter einmal umstellen.** Den Nutzer beim Aufsetzen ausdrücklich darauf hinweisen, sonst schaut er in vier Wochen auf einen alten Sprint und merkt es nicht.

## Schritt 5: Verifizieren, nicht hoffen

Die Schreib-Bestätigungen von Notion beweisen nichts über die Filter. **Zwei Testkarten anlegen**, die sich gezielt unterscheiden:

| Karte | Status | Sprint | Priority | Muss auftauchen in |
|---|---|---|---|---|
| A | `In Review` | `Sprint 1` | `P0-blocker` | Current Sprint, Blockers |
| B | `Backlog` | leer | `P2-normal` | Backlog |

Dann **jede View einzeln abfragen** (`notion-query-data-sources` im `view`-Modus mit der View-URL) und prüfen: Zeigt Current Sprint nur A? Zeigt Backlog nur B? Zeigt Blockers nur A?

Wenn eine View beide Karten zeigt, greift ihr Filter nicht. **Das jetzt klären, nicht später im Betrieb.**

Testkarten danach löschen, wenn das Board produktiv geht.

## Schritt 6: IDs eintragen

Beide IDs in `.claude/rules/notion-board.md` in den Block oben eintragen. **Erst danach funktionieren die Skills.**

Zum Abschluss dem Nutzer melden: Board-Link, die vier Views, und die zwei Dinge, die er wissen muss: der Sprint-Filter ist manuell, und `Rejected` ist da, um benutzt zu werden.
