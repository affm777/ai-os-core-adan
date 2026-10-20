# Ein Text, alle Kanäle, in deinem Ton

Claude formt deine Idee oder deinen Text um für LinkedIn, Instagram, Newsletter, Mail und Website, auf Deutsch und Englisch. Damit alles nach dir klingt, merkt sich Claude deinen Ton in einem Stil-Korpus, der mit jedem Text genauer wird.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

```
Du                           Claude                          Ergebnis
──                           ──────                          ────────
gibst einen Text oder     →  fragt Kanäle, Sprachen,      →  je Kanal und Sprache
eine Idee                    Aufruf und Termine ab,          ein fertiger Text zum
                             formt um nach Kanalregeln       Kopieren, alles gesammelt
                             und deinem Stil, prüft          im Ordner content/ausgabe/
                             gegen die Verbotsliste
```

## Das brauchst du

- Dein Setup ist installiert. Mehr brauchst du nicht.
- Optional 5 bis 10 eigene Texte (Posts, Newsletter, Website-Texte). Du kannst sie jederzeit nachreichen.

## Schritt 1: Installieren

Sag Claude:
```
Hol zuerst mit git pull den neuesten Stand meines Setup-Repos ~/ai-os-core.

Führe dann das Installationsskript des Use-Case-Bundles "content-adapter" aus:
bash ~/ai-os-core/claude/use-cases/content-adapter/install.sh

Zeig mir danach in einfachen Worten, ob alles geklappt hat.
```

Starte danach eine neue Session, damit Claude den neuen Skill kennt.

## Schritt 2: Erster Lauf

Öffne Claude in dem Ordner, in dem deine Texte entstehen sollen. Ersetze die Zeile in spitzen Klammern durch deinen Text. Sag Claude:
```
Mach aus diesem Text Fassungen für meine Kanäle:

<hier deinen Text oder deine Idee einfügen>
```

Claude fragt dich dann:
- beim ersten Mal sechs kurze Fragen zu deinem Ton (Du oder Sie, Humor, Emojis, Hashtags)
- für welche Marke der Text ist, wenn du mehrere angelegt hast
- welche Kanäle und Sprachen du willst und welcher Aufruf oder Link dazugehört
- ob es Bild, Termin oder Deadline gibt

## Schritt 3: So nutzt du es

**Beispieltexte nachreichen.** Mit fünf bis zehn eigenen Texten trifft Claude deinen Ton deutlich besser.
```
Hier sind Beispieltexte für meine Voice: content/beispiele/
```

**Nachbessern.** Claude ändert nur die genannte Fassung, die alte bleibt im Unterordner `_alt/` liegen.
```
Die LinkedIn-Fassung auf Deutsch ist mir zu förmlich.
```

**Kopieren.** Claude legt eine Fassung direkt in die Zwischenablage. Unter Windows fügst du im Git-Bash-Fenster per Rechtsklick ein, mehr in [details.md](details.md).
```
Kopier mir die Instagram-Fassung auf Englisch.
```

**Weitere Marke.** Jede Marke bekommt einen eigenen Stil-Korpus.
```
Hier sind Beispieltexte für die Marke ADAN Careers: content/beispiele-careers/
```

## Das kommt dabei heraus

- `content/ausgabe/<datum>-<thema>/` mit einer Datei je Fassung, etwa `linkedin-de.txt`
- `uebersicht.md` im selben Ordner mit allen Fassungen und einem Design-Auftrag fürs Bild je Fassung
- `content/voice.md` als dein Stil-Korpus, bei mehreren Marken `content/stil/<marke>/voice.md`
- `content/_alt/` mit früheren Fassungen

## Grenzen

- Claude verwendet nur, was in deinem Text steht. Zahlen, Namen, Termine oder Links werden nie erfunden.
- Die englische Fassung ist eine eigene Fassung für englische Leser, keine Wort-für-Wort-Übersetzung.
- Nur Deutsch und Englisch, keine Bilder. Bilder macht der Use Case social-post, Videos motion-graphic.
- Claude postet nichts und plant keine Veröffentlichungen.

## Mehr dazu

Ein Beispiel mit Design-Auftrag, Startwerte je Marke, die Pflege des Stil-Korpus, die Verbotsliste und alle Grenzen stehen in [details.md](details.md).
