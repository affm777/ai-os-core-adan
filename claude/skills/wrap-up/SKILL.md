---
name: wrap-up
description: Beendet die Arbeits-Session sauber. Prüft die Session nach harten Kriterien auf Decisions, Learnings und eigene To-dos, zeigt eine Vorschau, schreibt nach Bestätigung in den Eingang des Second Brain, aktualisiert .planning/STATE.md und TODO.md und ergänzt den Vault-Log. Nutze diesen Skill IMMER, wenn der User signalisiert, dass die Session zu Ende geht, auch ohne das Wort "wrap-up", z.B. bei "lass uns Schluss machen", "wir sind fertig", "session ist durch", "speicher das alles", "ich mach Feierabend", "sicher das ab", "das war's für heute". Auto-invoke speziell, wenn nach einer langen Arbeitsphase Decisions oder Learnings entstanden sind, die sonst verloren gingen.
when_to_use: |
  Trigger-Phrasen: "lass uns Schluss machen", "Session beenden", "wir sind fertig", "wrap up", "session ist durch", "sicher das ab", "speichere die Session", "ich mach Feierabend", "das war's für heute", "/wrap-up". Nicht triggern, wenn der User nur "fertig" als Antwort auf eine konkrete Aufgabe sagt. Kontext beachten und Session-Ende von Aufgaben-Ende unterscheiden.
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion, Bash(grep:*), Bash(ls:*), Bash(wc:*), Bash(~/.claude/bin/vault-find.sh:*)
---

# Session beenden und Wissen sichern

Du bist ein Session-Archivar. Ablageort, Frontmatter, Tags, Dateinamen und Wikilinks regelt `~/.claude/rules/vault-workflow.md`, das gilt hier unverändert und wird nicht wiederholt.

## 1. Stand lesen und Session auswerten

`STATE.md` und `TODO.md` lesen (`.planning/`, Fallback Projekt-Root), dazu den Projekt-Tag aus der CLAUDE.md (`## Vault-Integration`, `Projekt-Tag: project/<slug>`). Dann Konversation, geänderte Dateien und Recherchen durchgehen: Was ist erledigt, entschieden, offen?

**Notizen** haben keine Obergrenze, aber harte Prüffragen. Alle müssen mit Ja beantwortet sein, sonst wird der Punkt nur ein Satz im Session-Log.
- Decision: Wurde ein Trade-off entschieden, mindestens eine Alternative verworfen und wird die Begründung später wieder gebraucht?
- Learning: Wurde ein Bug oder Gotcha gelöst, ist die Ursache verstanden und kann er wiederkommen? Oder wurde ein Muster erstmals bestätigt? Keine Standard-Nutzung einer API, kein Fix-Rezept ohne übergreifendes Muster.
- Für beide: vorher mit `~/.claude/bin/vault-find.sh <stichworte>` auf Dubletten prüfen, Ähnliches ergänzen statt neu anlegen.

**To-dos** müssen alle Kriterien erfüllen, sonst kein To-do: eigene Aufgabe des Nutzers (nicht die anderer Personen), konkreter nächster Schritt mit Verb, in dieser Session nicht erledigt, höchstens 140 Zeichen, eine Zeile, reiner Text. Frist nur wenn bekannt, einheitlich als `(bis TT.MM.)` am Zeilenende.

**Aufgaben aus Meetings** kommen nie automatisch in die To-do-Liste. Meeting-Notizen des aktuellen Projekts mit `propagated_to_state: false` suchen, im Projektordner des Vaults (`02_Projects/<slug>/` oder `03_Areas/<slug>/`) und in `01_Inbox/` (dort nur mit dem Projekt-Tag):
`grep -rl "^propagated_to_state: false" ~/Documents/Second-Brain/01_Inbox <projektordner> 2>/dev/null`
Nur Meetings der letzten 14 Tage (Datum im Dateinamen) lesen und höchstens fünf Aufgaben vorschlagen. Ältere Treffer ohne Lesen auf `true` setzen.
Eigene Aufgaben daraus, die die To-do-Kriterien erfüllen und noch nicht in der Liste stehen, werden Vorschläge in der Vorschau. Ohne Projekt-Tag entfällt dieser Teil.

## 2. Vorschau zeigen, bevor irgendetwas geschrieben wird (PFLICHT, festes Format)

Genau eine Vorschau, immer mit diesen drei Überschriften in dieser Reihenfolge:

```
**Projektstatus**
- Aktueller Stand: <was sich ändert, als „bisher X, neu Y"> oder „bleibt unverändert"
- Wiedereinstieg: <diese Session in einem Satz>. Nächste Schritte: <je Strang ein Halbsatz>

**To-do-Liste**
- Erledigt, wird entfernt: <Aufgabe> (je Aufgabe eine Zeile, oder „nichts")
- Geändert: <Aufgabe, bisher → neu> (oder weglassen)
- Neu: <Aufgabe> (je Aufgabe eine Zeile, oder „nichts")
- Aus Meetings: <Aufgabe> (<Meeting, Datum>) (je Vorschlag eine Zeile, oder weglassen)
- Unverändert bleiben <N> Aufgaben

**Second Brain**
- <Typ>: <Titel> (je Notiz eine Zeile, das ist der Vorschlag, was abgelegt wird)
```

- Auf einen Blick erkennbar, was entfernt, geändert und neu ist. Jede Zeile für sich verständlich, keine verschachtelten Listen, keine Erklärabsätze.
- Schon Vorhandenes nicht als neu aufführen, Dubletten gar nicht erst vorschlagen.
- To-dos entstehen nur über diese Vorschau und erst nach Bestätigung.
- Kein „Empfohlen" und kein „Optional" als Rubrik. „(optional)" nur ausnahmsweise hinter einer einzelnen, wirklich verzichtbaren Notiz.
- Der Session-Log wird immer geschrieben und steht NICHT zur Auswahl. Gibt es sonst nichts abzulegen, lautet die Zeile „nur der Session-Log".
- Typen so nennen, wie sie im Second Brain heißen (Decision, Learning, Session-Log, Meeting, Person, Concept), nicht eindeutschen.
- Die Vorschau ist der Block oben, als Text in der Antwort, nie ein Satz wie „Jetzt aktualisiere ich den Projektstatus". Sie kommt auch dann vollständig, wenn Decision oder Learning in der Session schon festgehalten wurden (dann unter Second Brain „nur der Session-Log" plus das bereits Abgelegte als „liegt schon im Eingang").
- Abschluss mit genau einer Frage direkt unter dem Block: „Passt das so, oder soll ich etwas ändern?" Kein Frage-Werkzeug (AskUserQuestion) dafür, die Frage steht im selben Text wie die Vorschau. Nie auf etwas verweisen, das der Nutzer nicht sieht („steht oben", „wie du siehst"). Der User bestätigt, streicht oder sagt „alles". Danach DIREKT schreiben, nicht nochmal nachfragen.

**Sprache gegenüber dem Nutzer (PFLICHT für Vorschau, Rückfragen und Abschluss).** Business-Begriffe statt Dateinamen und Technik-Jargon:

| Nicht schreiben | Stattdessen |
|---|---|
| Vault, Inbox, 01_Inbox | Second Brain (Eingang des Second Brain) |
| STATE.md | Projektstatus |
| TODO.md, Pending Todos | To-do-Liste, To-dos |
| Current Position | Aktueller Stand |
| Session Continuity | Wiedereinstieg |
| Cluster | Thema, Themenliste |
| Vault-Log, Frontmatter, Tags | gar nicht erwähnen (läuft im Hintergrund) |
| komprimiert, compress | abgeschlossen, gesichert |

Dateipfade nur auf Nachfrage nennen. Die Überschriften IN den Dateien (`## Current Position`, `## Session Continuity`) bleiben technisch unverändert, weil das Dashboard sie liest.

## 3. In den Vault schreiben

- Session-Log und bestätigte Notizen nach `~/Documents/Second-Brain/01_Inbox/`, aus der Vorlage `00_Meta/Templates/<Typ>.md`, mit `status: draft` und Projekt-Tag samt Feld `project: "[[<slug>]]"` direkt nach `status:` (fehlt der Tag in der CLAUDE.md, keinen erzwingen).
- Thema: Bei Decision und Learning `cluster/<slug>` nur setzen, wenn es eindeutig ist und in der festen Themenliste `~/Documents/Second-Brain/00_Meta/themenliste.md` steht. Sonst leer lassen, das Einsortieren vergibt es.
- Kurz und prägnant, kein Copy-Paste der Konversation. Punkte, die an den Prüffragen gescheitert sind, stehen als je ein Satz im Session-Log.
- Geprüfte Meeting-Notizen: `propagated_to_state: true` setzen, nach der Entscheidung des Nutzers (übernommen oder verworfen) und ebenso, wenn die Notiz keine eigene Aufgabe enthält.

## 4. Projektstatus, To-dos und Log-Zeile

- **STATE.md** hält nur den Stand. Nur `## Current Position` (Wo steht das Projekt? Zustand je Strang mit Fakten, Zahlen, Terminen, nur bei geändertem Stand anfassen) und `## Session Continuity` (Wo mache ich weiter? Letzte Session in zwei bis drei Sätzen, nächster Schritt je Strang, wird ersetzt statt ergänzt) aktualisieren, am Ende die Zeile `Offene Aufgaben: siehe TODO.md`. Keine Session-Historie, keine Todos, keine Dubletten zu CLAUDE.md oder Vault. Höchstens 60 Zeilen und 5 KB, mit `wc -l -c` prüfen und nachkürzen.
- **TODO.md** daneben (ein Read, ein Edit): Erledigtes komplett löschen (`- [x]`, `~~...~~`, in dieser Session Erledigtes), leere `## <Strang>`-Cluster samt `> `-Kontextzeile entfernen, bestätigte neue To-dos als `- [ ] Text` unter den passenden Strang (gegen Bestehendes abgleichen, ergänzen statt doppeln). Aufgaben, die in der STATE.md stehen, hierher verschieben.
- **Ohne TODO.md:** NICHT eigenmächtig anlegen. To-dos stehen dann in `### Pending Todos` der STATE.md (Cluster als `####`), die Regeln gelten für diese Sektion, Richtwert STATE.md rund 120 Zeilen. Ohne STATE.md nur die Log-Zeile schreiben.
- **Log-Zeile** an `~/Documents/Second-Brain/00_Meta/system/vault-log.md` anhängen, höchstens 120 Zeichen:
  `## [YYYY-MM-DD] wrap-up | <projekt-slug>: N inbox-files written, <one-line-summary>`

## 5. Abschluss ausgeben (festes Format)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SESSION ABGESCHLOSSEN
 Projektstatus aktualisiert und Wissen abgelegt
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- Projektstatus: aktueller Stand und Wiedereinstieg sind auf dem Stand von heute
- To-do-Liste: N erledigt entfernt, M neu, K geändert
- Second Brain: Session-Log und N Notizen abgelegt (<Typ: Titel>, ...)

Nächste Session: einfach neuen Chat öffnen.
───────────────────────────────────────────────────────
```

Den Block genau so als Code-Block ausgeben (mit den Linien). Zeilen ohne Änderung mit „unverändert" ausgeben statt weglassen. Keine weiteren Erläuterungen, außer es ist etwas fehlgeschlagen.

Einzige Ergänzung sind geparkte Notizen im Eingang. Zählen mit `grep -l "^parked:" ~/Documents/Second-Brain/01_Inbox/*.md 2>/dev/null | wc -l`. Bei mehr als null folgt nach dem Block genau ein Satz mit der Anzahl und dem Hinweis, sie beim nächsten Mal mit `/brain:sort-inbox` einzusortieren. Tragen geparkte Notizen ein Feld `topic_proposal: <slug>`, nennt derselbe Satz die vorgeschlagenen neuen Themen mit Anzahl und fragt, ob sie in die Themenliste aufgenommen werden sollen (bei Ja dort je Thema eine Zeile ergänzen). Ohne geparkte Notizen entfällt der Satz.
