# Der Posteingang sortiert sich selbst vor

Dieser Use Case sichtet alle Mails, die seit dem letzten Lauf angekommen sind (beim allerersten Mal die letzten 7 Tage), und ordnet jede in eine von sechs Kategorien ein: drei Dringlichkeitsstufen für Interessenten, Bestandskunde, Bewerbung, Sonstiges. Du bekommst eine Übersicht in sinnvoller Abarbeitungsreihenfolge. Erst wenn du bestätigst, setzt Claude die passenden Farb-Kategorien in Outlook und legt für die dringendsten Anfragen fertige Antwortentwürfe in den Entwürfe-Ordner. Versendet wird nie automatisch. Eine Mail gilt als bearbeitet, sobald sie eine Kategorie trägt, nicht sobald sie gelesen wurde.

```
Postfach                    Claude                          Postfach + Chat
────────                    ──────                          ───────────────
Mails seit letztem       →  /posteingang-triage         →   6 Farb-Kategorien gesetzt
Lauf (Start: 7 Tage)          sortiert, zeigt Übersicht        Antwortentwürfe für das
                              (Vorschlag → Bestätigung)        Dringendste im Entwürfe-Ordner
```

## Konventionen in dieser Anleitung

- Steht hier **„Sag Claude:"**, kopierst du den grauen Kasten darunter in die Chateingabe von Claude und schickst ihn ab.
- Der Skill wird einmal installiert und steht danach überall zur Verfügung, egal in welchem Ordner du gerade arbeitest. Du findest ihn danach auch im Dashboard unter Skills & Commands.

## Voraussetzungen

- Microsoft-365-Connector verbunden.
- Alles Weitere ist mit deinem Setup bereits installiert.

## Schritt 1 — Installieren

Sag Claude:

```
Hol zuerst mit git pull den neuesten Stand meines Setup-Repos ~/ai-os-core.

Lade dann das Use-Case-Bundle "posteingang-triage" von dort:
~/ai-os-core/claude/use-cases/posteingang-triage

Installiere es global, damit es in jedem Projekt zur Verfügung steht:
- skills/posteingang-triage/  → ~/.claude/skills/posteingang-triage/

Liegt dort schon eine ältere Fassung, ersetze sie vollständig.
Bestätige mir, welche Dateien angekommen sind.
```

Starte danach einfach eine neue Session, damit Claude den neuen Skill kennt.

## Schritt 2 — Erster Lauf

Sag Claude:

```
Sichte den Posteingang und sortier ihn vor.
```

Das passiert dann:

1. Claude liest jede neue Mail und ordnet sie nach ihrem Inhalt einer der sechs Kategorien zu.
2. Du bekommst eine Übersichtstabelle in Abarbeitungsreihenfolge, bei den dringendsten Mails mit einer kurzen Begründung.
3. Nach deinem Ja setzt Claude die Farb-Kategorien in Outlook (beim ersten Mal legt er sie an).
4. Für jede dringende Anfrage bekommst du einen Antwortentwurf in den Entwürfe-Ordner, ohne Preiszusagen oder Versprechen, und nichts wird automatisch versendet.

## Persönlicher Schreibstil

Damit Antwortentwürfe nach dir klingen und nicht nach Standard-KI, schaut sich Claude beim allerersten Entwurf einmalig rund 50 deiner zuletzt gesendeten Mails an und merkt sich deinen Stil: Anrede, Grußformel, Satzlänge, Tonfall. Das Ergebnis liegt als Datei `TONE.md` im Skill-Ordner, alle späteren Entwürfe orientieren sich daran. Finden sich zu wenige gesendete Mails, startet Claude mit einem neutralen, professionellen Ton und sagt dir das.

Dein gelernter Stil ändert sich nie von allein. Willst du ihn neu lernen lassen oder anpassen, sag Claude:

```
Aktualisiere die TONE.md in meinem posteingang-triage-Skill.
Frag mich vorher, was angepasst werden soll.
```

## Grenzen

- Claude beurteilt jede Mail nach ihrem Inhalt, nicht nach dem Absender.
- Antwortentwürfe werden nie automatisch versendet, sie liegen immer nur im Entwürfe-Ordner.

## Nächste Ausbaustufe

- Automatischer Lauf als Routine zwei- bis dreimal täglich, ohne dass du daran denken musst.
- Bekannte Absender (Bestandskunde ja/nein) als zusätzliches Signal bei der Einordnung.

## Was im Bundle liegt

```
posteingang-triage/
├── README.md                          ← diese Anleitung
└── skills/
    └── posteingang-triage/
        ├── SKILL.md                   ← die Arbeitsanleitung für Claude
        ├── .last-run                  ← entsteht beim ersten Lauf, merkt sich den Zeitpunkt
        └── TONE.md                    ← entsteht beim ersten Entwurf, dein gelernter Schreibstil
```
