# Nachrichtenstruktur

**Bestätigt:** nein

So baut Claude jede Nachricht auf. Die Teile mit „fest" sind für alle Kontakte gleich, die Teile mit „persönlich" schreibt Claude je Kontakt neu. Anlass-Teil, Aufruf und Signatur kommen nur aus ANLASS.md und aus dieser Datei, nie aus der Recherche.

| Nr | Teil | Art | Inhalt |
|---:|---|---|---|
| 1 | Anrede | persönlich | <„Guten Tag Frau/Herr [Nachname]" nur, wenn die Form aus der Position hervorgeht, sonst „Guten Tag [Vorname] [Nachname]"; bei Du „Hallo [Vorname]"> |
| 2 | Einstieg | fest | <Herkunft nennen, etwa „wir sind hier auf LinkedIn vernetzt, deshalb schreibe ich Ihnen direkt."> |
| 3 | Firmenteil | persönlich | ein bis zwei Sätze aus den Anknüpfungspunkten der Akte, mit Bezug auf die Rolle der Person, nur belegte Fakten |
| 4 | Anlass-Teil | fest | <zwei bis drei Sätze aus ANLASS.md: was, wann, wo, für wen> |
| 5 | Aufruf | fest je Segment | <etwa „Hätten Sie Interesse an einem kurzen Austausch, wie [Firma] dabei sein kann?" Bei HR-Leitung und Geschäftsführung zusätzlich die Frage nach der richtigen Ansprechperson> |
| 6 | Ausstiegssatz | fest | <etwa „Falls das gerade nicht passt, sagen Sie es mir gern, dann melde ich mich nicht wieder."> |
| 7 | Signatur | fest | <Name, Rolle, Organisation, Link> |

## Regeln für jede Nachricht

- LinkedIn-Nachricht 500 bis 900 Zeichen, E-Mail höchstens 1.200 Zeichen plus Betreff (höchstens 60 Zeichen, nennt den Anlass).
- Absätze mit Leerzeile, keine Emojis, keine Hashtags, keine Gedankenstriche.
- Der Firmenteil nennt nichts, was nicht in der Akte mit Quelle steht. Fehlt Recherche, entfällt Teil 3 und Claude sagt das beim Vorzeigen.
- Nichts über die Person selbst (Herkunft, Aussehen, Privates), nur Rolle und Firma.
- Fehlende Angaben aus ANLASS.md bleiben als `[FEHLT: <was>]` stehen.

## Beispiel (fest)

<Hier steht nach der Freigabe einmal der vollständige Text der festen Teile 2, 4, 5, 6 und 7, damit jede Nachricht gleich klingt.>
