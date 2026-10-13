# Kosten

Single Source of Truth. Klartext. Jede Zahl führt auf eine Quelle (`exporte/<quelle>/analysiert/`, `belege/analysiert/`) oder eine benannte Annahme (`ANNAHMEN.md`) zurück. Der Skill `cost-tracker` schreibt diese Datei fort.

> Noch keine Iteration gelaufen. Sobald ein Export in `exporte/<quelle>/_neu/` oder ein Beleg in `belege/_neu/` liegt und der Skill läuft, füllen sich die Abschnitte.

## Stand

_Datum des Laufs, betrachtetes Fenster, gelesene Quellen mit Zeilenzahlen, übersprungene Zuflüsse als Zähler („X Haben-Buchungen über Y EUR übersprungen, Einnahmen sind nicht Thema dieses Tools"; je Quelle kumuliert über die Iterationen plus der Zähler des aktuellen Laufs), und Datenlücken je Monat und Quelle („Juni hat Bankdaten, Juli erst bis zum 15."). Wird vom Skill gefüllt._

## Kosten-Cockpit

_Gesamtkosten des letzten vollen Monats mit Veränderung zum Vormonat, die drei größten Kostenblöcke mit Anteil, Fix-Quote (wie viel als `fix` eingestuft war: Kategorie-Default oder Fixkosten-Match), Veränderung je Block, Kosten je Standort mit Anteil, offene Posten (Alert, wenn über 2 % der Gesamtkosten des letzten vollen Monats). Wird vom Skill gefüllt._

## Monats-Matrix (Kostenblock × Monat)

_Die letzten 3 vollen Monate plus laufender Monat bisher: je Kostenblock eine Zeile, dazu Summenzeile sowie getrennte Fix- und Variabel-Summen. Der laufende Monat ist unvollständig und wird als solcher markiert. Wird vom Skill gefüllt._

## Standort-Matrix

_Standort × Kostenblock für den letzten vollen Monat, darunter Standort × Monat als Zeitreihe. `uebergreifend` ist eine eigene Zeile, kein Rest. Wird vom Skill gefüllt._

## Erwartete Kosten (terminiert)

_Aus `ANNAHMEN.md` gespiegelt: was terminiert noch kommt. Zählt in KEINER Summe oben mit, das ist Zukunft, kein Ist. Wird vom Skill gefüllt._

## Beobachtungen und Empfehlungen

_Ausschließlich Befunde aus dem Beobachtungs-Katalog der SKILL.md, je Zeile: Regel-Slug, Zahlen-Aussage, belegende Buchungs-IDs, offene Frage an dich. Keine Beobachtung ohne Beleg, keine Ursachen-Behauptung. Als gewollt erklärte Beobachtungen wandern nach `ANNAHMEN.md` („Geklärte Beobachtungen") und tauchen hier nicht wieder auf. Wird vom Skill je Lauf neu erzeugt._

## Buchungsjournal

_Der Drill-down: jede echte Kostenbuchung als Zeile (id, datum, betrag, gegenpartei, zweck, kategorie, fix_var, standort, quelle, confidence, status, notiz). Erstattungen als negative Beträge. Nur Ist, keine erwarteten Posten. Zugleich die Dedup-Grundlage für den nächsten Lauf. Wird vom Skill gefüllt._

## Zu prüfen

_Journalzeilen mit `status: offen` (uncategorized, `standort: unklar`), Duplikat-Verdachte aus dem Wiederhol-Lauf, gescheiterte Summenproben von Kontoauszug-PDFs, überfällige Erwartete Kosten ohne Klärung. Wird vom Skill gefüllt._
