# Standorte

Die zweite Zuordnungs-Dimension neben dem Kostenblock. Jeder Kostenposten gehört zu genau einem Standort, oder er ist `uebergreifend` (zentrale Kosten, die keinem einzelnen Standort gehören: Software-Lizenzen, Versicherung, Steuerberater). Erst diese Dimension macht die Frage beantwortbar: was kostet mich welcher Standort?

> Wie `KOSTEN-KATEGORIEN.md` ist das ein **Vorschlag**, kein Gesetz. Standorte und Regeln frei anpassen, der Skill arbeitet mit dem, was hier steht. Beim ersten Lauf füllt er das Register gemeinsam mit dir.

## Zuordnungs-Regeln (PFLICHT)

1. **Genau ein Standort pro Posten.** `uebergreifend` ist ein gültiger, bewusster Wert für zentrale Kosten, kein Verlegenheits-Default für „weiß nicht".
2. **Confidence-Schwelle 0.85**, dieselbe Mechanik wie bei den Kostenblöcken: reicht das Signal nicht, wird der Posten `standort: unklar` gesetzt und am Ende via Rückfrage geklärt. Nicht raten.
3. **Zuordnung über die Regel-Tabelle unten:** enthält Gegenpartei oder Verwendungszweck ein Signal-Stichwort, gilt der zugehörige Standort. Getrennte Bankkonten pro Standort sind das stärkste Signal: dann setzt die Quelldatei den Standort für alle ihre Zeilen (in `SOURCES.md` je Konto vermerken).
4. **Die Datei lernt, aber nur mit Bestätigung.** Klärt der User einen `unklar`-Posten, schlägt der Skill die passende neue Regel-Zeile vor (Stichwort, Standort). Er trägt sie NIE eigenmächtig ein.

## Register

| Standort | Slug | Status | Hinweis |
|---|---|---|---|
| Übergreifend / zentral | `uebergreifend` | fest | Zentrale Kosten ohne Standort-Bezug. Immer vorhanden. |
| _(Beispiel) Frankfurt_ | _`ffm`_ | _aktiv_ | _Erster Standort_ |
| _(Beispiel) Berlin_ | _`berlin`_ | _im Aufbau_ | _Eröffnung terminiert: Kosten laufen schon vor dem Start auf_ |

## Regel-Tabelle: Signal, dann Standort

| Signal (Gegenpartei oder Zweck enthält) | Standort | Quelle / seit |
|---|---|---|
| _(Beispiel) „Miete Musterstraße"_ | _`ffm`_ | _Mietvertrag, seit 2026-05_ |
| _(Beispiel) „Jobanzeige Berlin"_ | _`berlin`_ | _geklärt im Lauf vom 2026-07-21_ |

## Regeln für neue Standorte

- **`unklar` ist kein Endzustand.** Am Ende jedes Laufs als Rückfrage auflisten: „Posten X (Betrag, Datum, Gegenpartei) hat kein Standort-Signal, welchem Standort zuordnen, oder `uebergreifend`?"
- **Neue Standorte und neue Regel-Zeilen** nur nach Bestätigung. Der Skill legt nichts eigenmächtig an.
- Ein Standort, der noch nicht eröffnet ist, ist trotzdem ein Standort: Anlauf- und Umbaukosten gehören dorthin, nicht nach `uebergreifend`. So sieht man, was ein neuer Standort bis zur Eröffnung wirklich gekostet hat.
