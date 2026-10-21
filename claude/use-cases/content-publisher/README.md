# Ein Text, alle Kanäle, mit Bild im ADAN-Look

Claude macht aus deiner Idee oder deinem Text die Fassungen für LinkedIn, Instagram, Newsletter, Mail und Website, auf Deutsch und Englisch, im Ton deiner Marke, und auf Wunsch die passenden Bilder im Look von ADAN e.V., ADAN Impact oder ADAN Careers. Claude postet nichts, plant keine Veröffentlichungen und lädt nichts hoch, veröffentlichen machst du selbst.

## Installieren

Sag Claude:
```
Installier mir den Use Case content-publisher einmal global: hol in ~/ai-os-core mit git pull den neuesten Stand, führ bash ~/ai-os-core/claude/use-cases/content-publisher/install.sh aus, installier alles Fehlende selbst mit den Befehlen, die das Skript nennt, und sag mir in einfachen Worten, ob alles geklappt hat.
```

Danach eine neue Session starten, damit Claude den Skill kennt.

## Loslegen

**Hast du eigene Daten?** Leg deinen Text oder deine Idee bereit. Mit fünf bis zehn eigenen Texten deiner Marke (Posts, Newsletter, Website) trifft Claude den Ton deutlich besser. Offizielle Style-Guides und Logos legst du unter `content-und-social/brand/<marke>/` in deinem Projektordner ab, dann gelten sie vor den mitgelieferten Profilen. Öffne Claude in deinem Projektordner, ersetze die Zeile in spitzen Klammern durch deinen Text und sag Claude:
```
Mach aus diesem Text Posts für meine Kanäle:

<hier deinen Text oder deine Idee einfügen>
```

Sprichst du lieber Englisch, sag Claude:
```
Turn this text into posts for my channels:

<paste your text or idea here>
```

Diese Sätze solltest du kennen:

- „Hier sind Beispieltexte für die Marke ADAN Careers: <Ordner>“, damit Claude den Ton deiner Marke aus deinen Texten lernt.
- „Kopier mir die Instagram-Fassung auf Englisch.“, damit eine Fassung direkt in der Zwischenablage liegt.
- „Speicher das als Referenz.“, wenn ein Post Vorbild für künftige Posts sein soll (nach einer Freigabe fragt Claude das auch einmal selbst).
- „… wie die <Name der Referenz>“ hängst du an den ersten Satz, damit der neue Post Aufbau und Bild dieser Referenz übernimmt, ohne Rückfrage.

## Grenzen

- Claude verwendet nur, was in deinem Text steht. Zahlen, Namen, Termine oder Links werden nie erfunden, Fehlendes steht als `[FEHLT: ...]` im Text und nie im Bild.
- Die Marken-Profile sind vorläufig, ADAN Careers ist ein Platzhalter. Prüf Farben und Logo vor dem Veröffentlichen.
- Kein Ersatz für Figma. Fotos, Illustrationen und freie Layouts machst du weiter dort, Videos macht motion-graphic.
