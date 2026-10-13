# Vom Gespräch zur Anforderung

Du hast mit jemandem gesprochen, eine Mail bekommen oder etwas beobachtet. Am Ende steht eine sauber geschriebene Karte auf deinem Notion-Board, die die Entwicklung ohne eine einzige Rückfrage ziehen kann.

```
Rohmaterial              Claude                       Notion-Board
─────────────            ──────                       ────────────
Gespräch, Mail,      →   /requirement-create      →   Karte im Backlog
Notiz, Transkript                                     (Grooming stuft auf Ready)
                                                              │
Du testest, es hakt  →   /requirement-feedback    →   Kommentar an Karte
                                                      (Status zurück auf In Progress)
```

## Konventionen in dieser Anleitung

- **„Sag Claude:"** + Block — du tippst das in den **Chat** von Claude Code.
- Board-Wissen (IDs, Properties) lebt in **einer** Datei: `.claude/rules/notion-board.md`. Ändert sich das Board, änderst du diese Datei, nicht die Skills.

## Voraussetzungen

- Standard-Bootstrap (`bash mac/bootstrap.sh`, Windows: `bash windows/bootstrap.sh`) ist durchgelaufen.
- **Notion-Connector** verbunden (claude.ai → Einstellungen → Connectors → Notion). **Gmail-Connector** verbunden, falls du Anforderungen aus Mails ziehen willst.
- **Verbindungs-Check, jetzt und nicht erst beim ersten produktiven Lauf:** Sag Claude: „Zeig mir die Karten aus einer beliebigen meiner Notion-Datenbanken." Kommen Daten, ist alles gut. Ein Plan-Upgrade brauchst du dafür nicht: Die Abfrage läuft auf allen Plänen, auf Free und Plus lediglich mit einem Stundenlimit.

## Schritt 1 — Projekt anlegen

Das Bundle lebt in einem Projekt, nicht global. Falls du noch keins hast:

```
/new-project
```

Damit hast du CLAUDE.md und STATE.md. Den `.claude/`-Ordner legt Claude im nächsten Schritt beim Kopieren mit an, den musst du nicht vorbereiten.

## Schritt 2 — Bundle ins Projekt holen

Sag Claude (er kennt sein Working-Verzeichnis und legt die Dateien passend ab):

```
Lade das Use-Case-Bundle "requirements-board" aus meinem Setup-Repo:
~/ai-os-core/claude/use-cases/requirements-board

Platziere es in meinem aktuellen Projekt so:
- rules/notion-board.md            → .claude/rules/notion-board.md
- skills/requirement-create/       → .claude/skills/requirement-create/
- skills/requirement-feedback/     → .claude/skills/requirement-feedback/
- board-setup.md                   → ./board-setup.md (brauche ich gleich einmal)

Bestätige mir kurz, welche Dateien angekommen sind.
```

Danach `/exit` und `claude` neu starten, damit die zwei Skills geladen werden.

## Schritt 3 — Notion-Board anlegen

**Habt ihr schon ein Board für Anforderungen?** Dann bau **kein** zweites. Sag Claude stattdessen: „Pass `.claude/rules/notion-board.md` an unser bestehendes Board an: Schema auslesen, Property-Tabelle und Board-Adoptions-Block ausfüllen, IDs eintragen, mit einer Testkarte verifizieren." Fertig, weiter zu Schritt 4.

**Noch kein Board?** Sag Claude:

```
Setz mir das Anforderungs-Board nach ./board-setup.md auf. Arbeite die Datei
mit mir Schritt für Schritt ab und trag die IDs am Ende in
.claude/rules/notion-board.md ein.
```

Claude fragt dich nach euren **Epics** (die groben Themenfelder, meist eure Produkte oder Systeme), legt Datenbank und die vier Views an, verifiziert die Filter mit zwei Testkarten und trägt beide IDs ein.

> **Die eine Stolperstelle:** Notion hat zwei IDs. Die Skills brauchen die **Data-Source-ID** (`collection://...`), und die steht **nicht** in der URL. `board-setup.md` und die Regel-Datei erklären den Unterschied, du musst nichts auswendig wissen.

## Schritt 4 — Erste Anforderung anlegen

Nimm ein **echtes** Rohmaterial, kein Beispiel. Eine Mail, eine Gesprächsnotiz, irgendetwas Reales von dieser Woche. Sag Claude:

```
Mach aus folgendem Material eine Anforderung fürs Board:
<dein Text, oder: "der Gmail-Thread mit Betreff X">
```

Der Skill `requirement-create` läuft an: Typ bestimmen, Dedup-Check, Karte schreiben (mit Akzeptanzkriterien und O-Ton-Zitat), im **Backlog** ablegen.

Dann die Prüffrage: **Könnte die Entwicklung die Karte ziehen, ohne dich zu fragen?** Wenn nein, liegt es fast immer an den Akzeptanzkriterien. Nachschärfen, wieder laufen lassen.

## Schritt 5 — Feedback zurückspielen (optional)

Du hast eine Karte getestet, etwas hakt. Sag Claude:

```
Ich habe <Karte> getestet, folgendes Feedback: <deine Beobachtung>
```

`requirement-feedback` hängt einen strukturierten Kommentar an die Karte (✅ / ⚠️ / 🔴 pro Befund, mit erwartetem Verhalten) und zieht den Status zurück auf `In Progress`.

## Die zwei Dinge, auf die es ankommt

**Akzeptanzkriterien.** Ohne sie ist es keine Anforderung, sondern ein Wunsch. Die Entwicklung muss daran ablesen können, wann sie fertig ist. Sind sie aus dem Material nicht ableitbar, gehört die Karte ins Backlog, mit der offenen Frage im Text.

**Der O-Ton.** Der wörtliche Satz, nicht deine Zusammenfassung. Der Unterschied zwischen „Nutzer finden die Buchung unübersichtlich" und „Ich hab dreimal auf Buchen geklickt und dachte, es ist abgestürzt" ist der Unterschied zwischen einer Diskussion und einem Fix.

## Was im Bundle liegt

```
requirements-board/
├── README.md                          ← das hier
├── board-setup.md                     ← Board und Views anlegen. Einmalig.
├── rules/notion-board.md              ← Board-Aufbau, IDs, Werkzeuge. Die eine Stelle.
└── skills/
    ├── requirement-create/SKILL.md    ← Rohmaterial wird Karte
    └── requirement-feedback/SKILL.md  ← Feedback wird Kommentar plus Status zurück
```

Das Board ist auf ein bewährtes GitHub-Projektboard gespiegelt (Status-Namen `Backlog`, `Ready`, `In Progress`, `In Review`, `Ready for Deployment`, `Done`, `Rejected` und die Views Current Sprint, Backlog, By Epic, Blockers). Wer beide Welten kennt, findet sich sofort zurecht.

**Die Entwicklungs-Seite desselben Boards** liefert das Bundle `dev-board` (Skills `issue-implement` und `issue-done`): Karten ziehen, im Plan-Modus umsetzen, mit Prüf-Kommentar auf Review stellen. Beide Bundles teilen sich die Regel-Datei `notion-board.md`.
