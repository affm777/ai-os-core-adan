# Ein Text, alle Kanäle, mit Bild im ADAN-Look

Claude macht aus deiner Idee oder deinem Text die Fassungen für LinkedIn, Instagram, Newsletter, Mail und Website, auf Deutsch und Englisch, im Ton deiner Marke, und auf Wunsch die passenden Bilder im Look von ADAN e.V., ADAN Impact oder ADAN Careers. Claude postet nichts, plant keine Veröffentlichungen und lädt nichts hoch, veröffentlichen machst du selbst.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

## Installieren

Sag Claude:
```
Installier mir den Use Case content-publisher: hol mit git pull den neuesten Stand von ~/ai-os-core, führ bash ~/ai-os-core/claude/use-cases/content-publisher/install.sh aus, installier Fehlendes mit den Befehlen, die das Skript nennt, und sag mir in einfachen Worten, ob alles geklappt hat.
```

Danach eine neue Session starten, damit Claude den Skill kennt.

## Loslegen

Öffne Claude in deinem Projektordner und ersetze die Zeile in spitzen Klammern durch deinen Text. Sag Claude:
```
Mach aus diesem Text Posts für meine Kanäle:

<hier deinen Text oder deine Idee einfügen>
```

Auf Englisch:
```
Turn this text into posts for my channels:

<paste your text or idea here>
```

Claude fragt alles Weitere selbst. Danach reicht ein Satz:

```
Die LinkedIn-Fassung auf Deutsch ist mir zu förmlich.
Mach mir zum letzten Lauf noch das Instagram-Bild und eine Story.
Kopier mir die Instagram-Fassung auf Englisch.
Speicher das als Referenz.
```

Eine gespeicherte Referenz nutzt du, indem du an den ersten Satz „wie die <Name der Referenz>" anhängst. Alles landet im Ordner `content-und-social/` deines Projekts (Texte, Bilder als PNG, Stil je Marke, Referenzen).

## Grenzen

- Claude verwendet nur, was in deinem Text steht. Zahlen, Namen, Termine oder Links werden nie erfunden, Fehlendes steht als `[FEHLT: ...]` im Text und nie im Bild.
- Die Marken-Guides sind vorläufig, ADAN Careers ist ein Platzhalter. Prüf Farben und Logo vor dem Veröffentlichen.
- Kein Ersatz für Figma. Fotos, Illustrationen und freie Layouts machst du weiter dort, Videos macht motion-graphic.

Voraussetzungen, ein Beispiel mit Design-Auftrag, Formate und Vorlagen, Beispieltexte und eigene Marken-Dateien nachreichen, Referenzen, Windows-Sonderfälle und alle Grenzen stehen in [details.md](details.md).
