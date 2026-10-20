# Nachrichtenstruktur

**Bestätigt:** nein

So baut Claude jede Nachricht auf. Die Teile mit „fest" sind für alle Kontakte gleich, die Teile mit „persönlich" schreibt Claude je Kontakt neu. Anlass-Teil, Aufruf und Signatur kommen nur aus ANLASS.md und aus dieser Datei, nie aus der Recherche.

| Nr | Teil | Art | Inhalt |
|---:|---|---|---|
| 1 | Anrede | persönlich | <„Guten Tag Frau/Herr [Titel] [Nachname]" nur, wenn die Form aus der Position hervorgeht, sonst „Guten Tag [Titel] [Vorname] [Nachname]"; bei Du „Hallo [Vorname]"> |
| 2 | Einstieg | fest | <Herkunft in einem kurzen Satz, etwa „wir sind hier auf LinkedIn vernetzt."> |
| 3 | Firmenteil | persönlich | genau ein Satz aus den Anknüpfungspunkten der Akte, mit Bezug auf die Rolle der Person, nur belegte Fakten |
| 4 | Anlass-Teil | fest | <ein Satz aus ANLASS.md: was, wann, wo, für wen> |
| 5 | Aufruf | fest je Segment | <genau eine Ja-Nein-Frage, etwa „Darf ich Ihnen die Ausstellerinfos schicken?" Bei HR-Leitung und Geschäftsführung stattdessen „Sind Sie dafür die richtige Ansprechperson, oder an wen darf ich mich wenden?"> |
| 6 | Ausstiegssatz | fest | <etwa „Falls nicht, melde ich mich nicht wieder."> |
| 7 | Signatur | fest | <Name, Organisation. Bei E-Mail zusätzlich Rolle, Webseite und die Impressumszeile aus ANLASS.md> |
| 8 | Datenschutzsatz | fest, nur E-Mail | <„Ihre Kontaktdaten stammen aus unserer LinkedIn-Verbindung. Informationen und Widerspruch unter [Datenschutz-Link]."> |

## Regeln für jede Nachricht

- LinkedIn-Nachricht 250 bis 450 Zeichen, nie über 500. Kürzer ist besser, ab 500 Zeichen sinkt die Antwortquote deutlich.
- E-Mail 50 bis 125 Wörter ohne Signatur und Datenschutzsatz, Betreff 36 bis 50 Zeichen mit dem Anlass.
- E-Mail nur für Kontakte, bei denen in ansprache.md der Kanal E-Mail steht. Das setzt Claude erst, wenn du bestätigt hast, dass ihr schon geschäftlich zu tun habt oder eine Einwilligung vorliegt. Eine LinkedIn-Verbindung allein ist keine Einwilligung für Werbung per Mail (§ 7 UWG).
- Genau ein Nutzen und genau eine Frage. Keine Preise, keine Pakete, kein Anhang und kein Link zum Buchen in der ersten Nachricht.
- Absätze mit Leerzeile, keine Emojis, keine Hashtags, keine Gedankenstriche.
- Der Firmenteil nennt nichts, was nicht in der Akte mit Quelle steht. Fehlt Recherche, entfällt Teil 3 und Claude sagt das beim Vorzeigen.
- Nichts über die Person selbst (Herkunft, Aussehen, Privates), nur Rolle und Firma.
- Fehlende Angaben aus ANLASS.md bleiben als `[FEHLT: <was>]` stehen.
- Jeder Entwurf wird vor dem Vorzeigen gegen `vorlagen/checkliste.md` geprüft.

## Beispiel (fest)

<Hier steht nach der Freigabe einmal der vollständige Text der festen Teile 2, 4, 5, 6, 7 und 8, damit jede Nachricht gleich klingt.>
