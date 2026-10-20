# Ein Text, alle Kanäle, in deinem Ton (Details)

Ergänzung zur [README](README.md) in diesem Ordner. Hier steht alles, was über die Schritt-für-Schritt-Anleitung hinausgeht.

## Inhalt

- [Überblick](#überblick)
- [Gut zu wissen](#gut-zu-wissen)
- [Voraussetzungen](#voraussetzungen)
- [Erster Lauf](#erster-lauf)
- [So sieht das Ergebnis aus](#so-sieht-das-ergebnis-aus)
- [Beispieltexte nachreichen](#beispieltexte-nachreichen)
- [Nachbessern und kopieren](#nachbessern-und-kopieren)
- [Mehrere Marken](#mehrere-marken)
- [Dein Stil-Korpus pflegt sich selbst](#dein-stil-korpus-pflegt-sich-selbst)
- [Was die Verbotsliste verhindert](#was-die-verbotsliste-verhindert)
- [Grenzen](#grenzen)
- [Nächste Ausbaustufe](#nächste-ausbaustufe)
- [Was im Bundle liegt](#was-im-bundle-liegt)

## Überblick

Mit diesem Use Case machst du aus einer Idee oder einem fertigen Text die passenden Fassungen für LinkedIn, Instagram, Newsletter, Mail und Website, auf Deutsch und auf Englisch. Claude schreibt nichts Neues dazu, sondern formt deinen Text für jeden Kanal um. Damit die Texte nach dir klingen und nicht nach Standard-KI, merkt sich Claude deinen Ton in einem Stil-Korpus. Er startet mit sechs kurzen Fragen und wird mit jedem eigenen Text, den du nachreichst, genauer. Den Ton und die letzte Kontrolle behältst du.

## Gut zu wissen

- Der Skill wird einmal installiert und steht danach überall zur Verfügung, egal in welchem Ordner du gerade arbeitest. Du findest ihn danach auch im Dashboard unter Skills & Commands.

## Voraussetzungen

- Dein Setup ist installiert. Mehr brauchst du nicht.
- Optional 5 bis 10 eigene Texte (Posts, Newsletter, Website-Texte). Du kannst sie jederzeit nachreichen, zum Start reichen sechs kurze Fragen.

Zeitbedarf: Die sechs Fragen beim ersten Lauf dauern rund zwei Minuten. Danach dauert ein Text für alle fünf Kanäle in beiden Sprachen etwa 5 Minuten, das meiste davon arbeitet Claude allein.

## Erster Lauf

Öffne Claude in dem Ordner, in dem deine Texte entstehen sollen (zum Beispiel ein Kommunikations-Ordner). Sag Claude:

```
Mach aus diesem Text Fassungen für meine Kanäle:

<hier deinen Text oder deine Idee einfügen>
```

Das passiert dann:

1. Beim allerersten Mal stellt Claude dir sechs kurze Fragen zu deinem Ton (rund zwei Minuten): Du oder Sie, drei Wörter für deinen Ton, Humor, Emojis, Hashtags und je ein Text, der dir gefällt und nicht gefällt. Daraus entsteht dein Stil-Korpus `content/voice.md`, zunächst als vorläufige Fassung.
2. Ist dein Text nur eine kurze Idee, fragt Claude nach dem Kern in zwei, drei Sätzen.
3. Hast du mehrere Marken angelegt (siehe „Mehrere Marken“), fragt Claude zuerst, für welche Marke der Text ist. Dann eine Fragerunde mit vier Klicks: welche Kanäle, welche Sprachen, welcher Aufruf oder Link, gibt es Bild, Termin oder Deadline.
4. Claude schreibt je Kanal und Sprache eine Fassung und prüft jede selbst: Steht jede Aussage in deinem Text? Ist etwas aus der Verbotsliste drin? Stimmt die Länge für den Kanal?
5. Du bekommst alle Fassungen im Chat zum Kopieren, unter jeder Fassung einen kurzen Design-Auftrag fürs Bild. Fehlt etwas, das ein Kanal braucht (zum Beispiel ein Link oder ein Datum), steht an der Stelle `[FEHLT: ...]`. Claude rät nie.

Schreibst du Claude auf Englisch, stellt Claude die Fragen und Hinweise auf Englisch. Die Texte entstehen trotzdem auf Deutsch und Englisch, je nachdem, was du auswählst.

Alles zu einem Text liegt im Ordner `content/ausgabe/<datum>-<thema>/`, je Fassung eine Datei (zum Beispiel `linkedin-de.txt`) und eine `uebersicht.md` mit allen Fassungen und allen Design-Aufträgen auf einen Blick. Ab dem zweiten Lauf entfallen die sechs Fragen.

## So sieht das Ergebnis aus

Zu jeder Fassung gehört ein Design-Auftrag. Er beschreibt das Bild zum Post so knapp, dass du ihn direkt in Claude Design, in Figma oder an den Skill `social-post` weitergeben kannst. Farben, Schriften und Logo nennt er nicht, die kommen aus dem Design-System deiner Marke. Ein Beispiel:

```
Instagram, Deutsch, 812 Zeichen
──────────────────────────────
Neun Tandems haben sich beim Mentoring-Auftakt gefunden.
(... restlicher Post ...)

Design-Auftrag
Headline: Neun Tandems, ein Auftakt
Bildtext: Mentoring-Programm gestartet. Bewerbung für die nächste Runde bis [FEHLT: Datum]
Format: Instagram-Post 4:5 (1080 x 1350)
Kanal: Instagram
Marke: ADAN e.V.
Stimmung: Ruhig und zugewandt, Menschen im Gespräch statt Bühne und Applaus.
```

Headline und Bildtext stammen nur aus deinem Text. Fehlt etwas, steht auch hier `[FEHLT: ...]`. Alle Design-Aufträge eines Laufs stehen zusätzlich im Abschnitt „Design-Aufträge“ der `uebersicht.md`.

## Beispieltexte nachreichen

Mit fünf bis zehn eigenen Texten trifft Claude deinen Ton deutlich besser als nur mit den sechs Fragen. Solange sie fehlen, erinnert Claude dich am Ende einer Ausgabe mit einem halben Satz daran. Leg die Texte zum Beispiel in einen Ordner `content/beispiele/` (Deutsch und Englisch gemischt ist in Ordnung) und sag Claude:

```
Hier sind Beispieltexte für meine Voice: content/beispiele/
```

Das geht jederzeit, auch mitten in einem Lauf. Claude liest die Texte, ersetzt die Annahmen aus den Fragen durch Regeln mit wörtlichen Belegen aus deinen Texten, zeigt dir kurz die Änderungen und fragt, was nicht stimmt. Die vorherige Fassung deines Stil-Korpus bleibt in `content/_alt/` liegen. Du kannst `content/voice.md` jederzeit selbst öffnen und ändern, deine Änderungen gelten immer vor allem anderen.

## Nachbessern und kopieren

Sag zum Beispiel:

```
Die LinkedIn-Fassung auf Deutsch ist mir zu förmlich.
```

Claude ändert nur diese eine Fassung, die alte bleibt im Unterordner `_alt/` liegen. Sagst du dasselbe ein zweites Mal (etwa wieder „zu förmlich“), fragt Claude, ob das als feste Regel in deinen Stil-Korpus soll. So wird der Korpus mit jeder Runde genauer.

Soll eine Fassung direkt in die Zwischenablage, sag einfach „Kopier mir die Instagram-Fassung auf Englisch“ oder „Kopier mir den Design-Auftrag für Instagram“. Unter Windows kopiert Claude über PowerShell, damit Umlaute heil bleiben. Einfügen geht in Word, im Browser und überall sonst mit Strg+V, nur im Git-Bash-Fenster selbst nicht, dort mit Rechtsklick und Einfügen oder mit Umschalt+Einfg.

## Mehrere Marken

Schreibst du für mehr als eine Marke, etwa ADAN e.V., ADAN Impact und ADAN Careers, bekommt jede Marke ihren eigenen Stil-Korpus unter `content/stil/<marke>/voice.md`. Dann fragt Claude bei jedem Text zuerst nach der Marke und schreibt nur im Ton dieser Marke. Ein Profil legst du an, indem du Beispieltexte für die Marke nachreichst. Sag Claude:

```
Hier sind Beispieltexte für die Marke ADAN Careers: content/beispiele-careers/
```

Hast du vom Workshop-Team einen Ordner mit Startwerten je Marke bekommen (`voice/beispiele/` mit Texten von der Website und einen `voice-entwurf.md`), nennst du einfach diesen Ordner:

```
Hier sind Beispieltexte für die Marke ADAN e.V.: <Pfad zum Ordner>/voice/beispiele/
Nimm <Pfad zum Ordner>/voice/voice-entwurf.md als Ausgangspunkt für den Stil-Korpus.
```

Claude liest die Dateien nur, kopiert oder verschiebt sie nicht. Website-Texte sind ein guter Start, eigene Posts machen den Korpus genauer. Hast du bisher nur einen Korpus in `content/voice.md`, fragt Claude bei der zweiten Marke, zu welcher Marke der bisherige gehört. Dann zieht Claude ihn um (das Original bleibt in `content/_alt/`).

## Dein Stil-Korpus pflegt sich selbst

Damit dein Stil-Korpus mit der Zeit nicht ausufert, hat er ein festes Budget (120 Zeilen, höchstens zehn gelernte Regeln, höchstens 20 eigene Verbote). Wird es mehr, legt Claude eine Sicherung in `content/_alt/` ab, sortiert die gelernten Regeln ein, fasst Doppeltes zusammen und fragt dich, wenn sich zwei Regeln widersprechen.

## Was die Verbotsliste verhindert

Typische KI-Texte erkennt man an immer gleichen Mustern. Claude prüft jede Fassung dagegen und schreibt sie um, bis nichts mehr davon drin ist:

- Floskeln wie „In der heutigen schnelllebigen Welt“ oder „Lasst uns gemeinsam“
- Emojis als Aufzählungszeichen und drei Adjektive hintereinander
- rhetorische Fragen als Einstieg und Großbuchstaben zur Betonung
- Gedankenstriche, Hashtag-Teppiche und Sternchen oder Rauten, die auf LinkedIn und Instagram sichtbar wären

Eigene Verbotswörter trägst du in `content/voice.md` unter „Eigene Verbote“ ein.

## Grenzen

- Claude verwendet nur, was in deinem Text oder deinen Antworten steht. Zahlen, Namen, Zitate, Termine oder Links werden nie erfunden.
- Die englische Fassung ist eine eigene Fassung für englische Leser, keine Wort-für-Wort-Übersetzung. Übersetzte Zitate sind gekennzeichnet.
- Claude postet nichts und plant keine Veröffentlichungen. Du kopierst die Texte selbst in die Kanäle.
- Nur Deutsch und Englisch, keine Bilder. Claude liefert je Fassung nur den Design-Auftrag, das Bild entsteht in Claude Design, Figma oder mit dem Skill `social-post`. Für Videos gibt es den Use Case motion-graphic.

## Nächste Ausbaustufe

- Weitere Kanäle wie WhatsApp-Kanal, Pressemitteilung oder Förderbericht als eigene Kanalkarten.
- Varianten zur Auswahl, etwa zwei Einstiege für denselben LinkedIn-Post.

## Was im Bundle liegt

```
content-adapter/
├── README.md                          ← diese Anleitung
├── details.md                         ← Details und Beispiele zur Anleitung
├── install.sh                         ← Installation (Mac und Windows)
└── skills/
    └── content-adapter/
        ├── SKILL.md                   ← die Arbeitsanleitung für Claude
        ├── kanaele/                   ← Regeln je Kanal (LinkedIn, Instagram, Newsletter, Mail, Website)
        ├── verbotsliste.md            ← Muster, die nie in einen Text dürfen
        ├── voice-vorlage.md           ← Vorlage für deinen Stil-Korpus
        ├── korpus.md                  ← wie Claude den Stil-Korpus aufbaut und pflegt
        └── scripts/pruefen.sh         ← automatische Prüfung jeder Fassung
```

In deinem Arbeitsordner entsteht beim ersten Lauf:

```
content/
├── voice.md                           ← dein Stil-Korpus (bei nur einer Marke)
├── stil/<marke>/voice.md              ← je Marke ein eigener Stil-Korpus (bei mehreren Marken)
├── _alt/                              ← frühere Fassungen deines Stil-Korpus
├── beispiele/                         ← deine eigenen Texte als Quelle
└── ausgabe/<datum>-<thema>/           ← alle Fassungen eines Laufs
```
