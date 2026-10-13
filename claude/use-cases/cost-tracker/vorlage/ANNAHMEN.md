# Annahmen

Jede Geschäfts-Annahme, die in die Kosten-Auswertung einfließt, steht hier: eine pro Zeile, im Klartext, mit Quelle. Keine Annahme versteckt sich in einer Formel. Ändert sich eine Annahme, ändert sich diese Zeile, und der Diff zeigt es.

## Konfiguration

Dieses Verzeichnis ist ein **reines Kosten-Tracking**: nur Ist-Kosten, keine Umsätze, kein Kontostand, keine Prognose. Entsprechend schlank ist die Konfiguration:

- `waehrung: EUR`: die Hauptwährung. Beträge in anderer Währung werden nicht still umgerechnet, sondern gemeldet.

## Fixkosten (Verträge, wiederkehrend)

Was regelmäßig und vertraglich gebunden rausgeht. Diese Tabelle hat drei Jobs:

1. **Fix oder variabel:** Bei Kostenblöcken, die beides sein können (etwa `buero-hardware`), entscheidet ein Treffer in dieser Tabelle, ob eine Buchung als `fix` zählt. Match-Regel: das `Match-Stichwort` kommt in Gegenpartei oder Verwendungszweck vor UND der Betrag liegt innerhalb von ±10 % des Tabellenwerts.
2. **Vollständigkeits-Check:** Hat eine Zeile in einem vollen Monat keine passende Buchung in den Quellen, meldet der Skill das („Miete hatte im Juni keine Buchung, fehlt ein Export?"). So fallen Datenlücken auf.
3. **Ziel des Wiederkehrer-Vorschlags:** Sieht der Skill in den Quellen einen wiederkehrenden Posten, der hier fehlt, schlägt er die Aufnahme vor. Nie eigenmächtig eintragen.

Einmal grob vollständig anlegen (macht der Skill beim ersten Lauf mit dir), danach nur pflegen, wenn sich ein Vertrag ändert.

| Posten | Betrag | Rhythmus | Match-Stichwort | Kostenblock | Standort | Quelle / seit |
|---|--:|---|---|---|---|---|
| _(Beispiel) Gehälter inkl. Nebenkosten_ | _3.500,00_ | _monatlich_ | _Lohn_ | _personal_ | _`uebergreifend`_ | _Lohnabrechnung, seit 2026-05_ |
| _(Beispiel) Miete Standort 1_ | _2.400,00_ | _monatlich_ | _Miete Musterstraße_ | _raumkosten_ | _`ffm`_ | _Mietvertrag_ |

## Erwartete Kosten (einmalig, terminiert)

Was terminiert noch kommt, nur Richtung raus: erwartete Rechnungen, angekündigte Einmalabbuchungen, geplante Umbauten. Auch offene Eingangsrechnungen mit Fälligkeit aus einer Datei-Quelle landen hier (schlägt der Skill vor). **Zwischendurch vormerken geht ohne vollen Lauf:** sag Claude einfach „merk dir: in 3 Wochen kommt eine Rechnung über 300 Euro", er trägt die Zeile hier ein.

**Wichtig:** Erwartete Kosten sind Zukunft und zählen in KEINER Ist-Summe, keiner Matrix und keiner Kennzahl mit. Sie stehen in `kosten.md` in einem eigenen Abschnitt, klar getrennt vom Ist.

Lifecycle: Status `offen`, bis der Posten passiert ist. Taucht die passende echte Buchung in den Quellen auf, setzt der Skill den Status auf `erledigt` (mit Buchungs-id), damit nichts doppelt zählt. Überfällige offene Posten fragt der Skill aktiv nach (verschieben, streichen oder als erledigt abhaken).

| Datum | Betrag | Beschreibung | Kostenblock | Standort | Status |
|---|--:|---|---|---|---|
| _(Beispiel) 2026-08-21_ | _300,00_ | _Agentur-Rechnung Redesign_ | _fremdleistungen_ | _`uebergreifend`_ | _offen_ |
| _(Beispiel) 2026-09-15_ | _12.000,00_ | _Umbau neuer Standort, Rechnung Trockenbau_ | _raumkosten_ | _`berlin`_ | _offen_ |

## Geklärte Beobachtungen

Beobachtungen aus dem Empfehlungs-Katalog (`kosten.md`, Abschnitt „Beobachtungen und Empfehlungen"), die der User als gewollt erklärt hat. Der Skill meldet sie nicht erneut. Eine pro Zeile, mit Datum und Begründung.

- _(Beispiel) Doppel-Abo Zoom + Teams ist gewollt (Kunden-Anforderung), geklärt 2026-07-21._

## Aktiv

- (Beispiel) Erstattungen werden als negative Kosten im Ursprungsblock geführt, nicht als Einnahme (Quelle: Skill-Default, seit 2026-07-21)
- (Beispiel) Reinigungskosten laufen als `raumkosten`, nicht als `fremdleistungen` (Quelle: geklärt im Lauf vom 2026-07-21)

## Offene Fragen (noch keine Annahme, aber gebraucht)

- Welche Standorte gibt es, und woran erkennt man sie in den Buchungen? (`STANDORTE.md`)
- Welche laufenden Verträge gehören in die Fixkosten-Tabelle?
- Gibt es schon bekannte terminierte Kosten (Rechnungen, Umbauten)?
