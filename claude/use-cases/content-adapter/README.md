# Ein Text, alle Kanäle, in deinem Ton

Mit diesem Use Case machst du aus einer Idee oder einem fertigen Text die passenden Fassungen für LinkedIn, Instagram, Newsletter, Mail und Website, auf Deutsch und auf Englisch. Claude schreibt nichts Neues dazu, sondern formt deinen Text für jeden Kanal um. Damit die Texte nach dir klingen und nicht nach Standard-KI, legt Claude einmal einen Stil-Korpus aus deinen eigenen Texten an. Den Ton und die letzte Kontrolle behältst du.

```
Du                           Claude                          Ergebnis
──                           ──────                          ────────
gibst einen Text oder     →  fragt Kanäle, Sprachen,      →  je Kanal und Sprache
eine Idee                    Aufruf und Termine ab,          ein fertiger Text zum
                             formt um nach Kanalregeln       Kopieren, alles gesammelt
                             und deinem Stil, prüft          im Ordner content/ausgabe/
                             gegen die Verbotsliste
```

## Konventionen in dieser Anleitung

- Steht hier **„Sag Claude:"**, kopierst du den grauen Kasten darunter in die Chateingabe von Claude und schickst ihn ab.
- Der Skill wird einmal installiert und steht danach überall zur Verfügung, egal in welchem Ordner du gerade arbeitest. Du findest ihn danach auch im Dashboard unter Skills & Commands.

## Voraussetzungen

- Dein Setup ist installiert. Mehr brauchst du nicht.
- Für den Stil-Korpus 5 bis 10 eigene Texte (Posts, Newsletter, Website-Texte). Ohne eigene Texte geht es auch, dann stellt Claude dir sechs kurze Fragen zu deinem Ton.

Zeitbedarf: Der Stil-Korpus dauert einmalig etwa 10 Minuten. Danach dauert ein Text für alle fünf Kanäle in beiden Sprachen etwa 5 Minuten, das meiste davon arbeitet Claude allein.

## Schritt 1: Installieren

Sag Claude:

```
Hol zuerst mit git pull den neuesten Stand meines Setup-Repos ~/ai-os-core.

Führe dann das Installationsskript des Use-Case-Bundles "content-adapter" aus:
bash ~/ai-os-core/claude/use-cases/content-adapter/install.sh

Zeig mir danach in einfachen Worten, ob alles geklappt hat.
```

Starte danach eine neue Session, damit Claude den neuen Skill kennt.

## Schritt 2: Deinen Stil-Korpus anlegen (einmalig)

Öffne Claude in dem Ordner, in dem deine Texte entstehen sollen (zum Beispiel ein Kommunikations-Ordner). Leg dort am besten einen Ordner `content/beispiele/` an und kopiere 5 bis 10 eigene Texte hinein. Deutsch und Englisch gemischt ist in Ordnung. Sag Claude:

```
Leg meinen Stil-Korpus an. Meine Texte liegen in content/beispiele/.
```

Das passiert dann:

1. Claude liest deine Texte und leitet ab, wie du schreibst: Anrede, Satzlänge, typische Einstiege und Schlüsse, Wörter die du magst und nie nutzt, Emojis, Hashtags, Humor.
2. Zu jeder Regel stehen zwei wörtliche Belege aus deinen Texten, damit du siehst, woher sie kommt.
3. Du bekommst eine kurze Zusammenfassung und sagst, was nicht stimmt. Claude trägt deine Korrekturen sofort ein.

Das Ergebnis liegt in `content/voice.md`. Du kannst die Datei jederzeit selbst öffnen und ändern, deine Änderungen gelten immer vor allem anderen.

## Schritt 3: Einen Text für deine Kanäle aufbereiten

Sag Claude:

```
Mach aus diesem Text Fassungen für meine Kanäle:

<hier deinen Text oder deine Idee einfügen>
```

Das passiert dann:

1. Ist dein Text nur eine kurze Idee, fragt Claude zuerst nach dem Kern in zwei, drei Sätzen.
2. Eine Fragerunde mit vier Klicks: welche Kanäle, welche Sprachen, welcher Aufruf oder Link, gibt es Bild, Termin oder Deadline.
3. Claude schreibt je Kanal und Sprache eine Fassung und prüft jede selbst: Steht jede Aussage in deinem Text? Ist etwas aus der Verbotsliste drin? Stimmt die Länge für den Kanal?
4. Du bekommst alle Fassungen im Chat zum Kopieren. Fehlt etwas, das ein Kanal braucht (zum Beispiel ein Link oder ein Datum), steht an der Stelle `[FEHLT: ...]`. Claude rät nie.

Alles zu einem Text liegt im Ordner `content/ausgabe/<datum>-<thema>/`, je Fassung eine Datei (zum Beispiel `linkedin-de.txt`) und eine `uebersicht.md` mit allen Fassungen auf einen Blick.

## Schritt 4: Nachbessern und kopieren

Sag zum Beispiel:

```
Die LinkedIn-Fassung auf Deutsch ist mir zu förmlich.
```

Claude ändert nur diese eine Fassung, die alte bleibt im Unterordner `_alt/` liegen. Sagst du dasselbe ein zweites Mal (etwa wieder „zu förmlich“), fragt Claude, ob das als feste Regel in deinen Stil-Korpus soll. So wird der Korpus mit jeder Runde genauer.

Soll eine Fassung direkt in die Zwischenablage, sag einfach „Kopier mir die Instagram-Fassung auf Englisch“.

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
- Nur Deutsch und Englisch, keine Bilder. Für Bilder gibt es den designer-Skill, für Videos den Use Case motion-graphic.

## Nächste Ausbaustufe

- Weitere Kanäle wie WhatsApp-Kanal, Pressemitteilung oder Förderbericht als eigene Kanalkarten.
- Ein eigener Stil-Korpus je Marke (zum Beispiel ADAN e.V. und ADAN Impact).
- Varianten zur Auswahl, etwa zwei Einstiege für denselben LinkedIn-Post.

## Was im Bundle liegt

```
content-adapter/
├── README.md                          ← diese Anleitung
├── install.sh                         ← Installation (Mac und Windows)
└── skills/
    └── content-adapter/
        ├── SKILL.md                   ← die Arbeitsanleitung für Claude
        ├── kanaele/                   ← Regeln je Kanal (LinkedIn, Instagram, Newsletter, Mail, Website)
        ├── verbotsliste.md            ← Muster, die nie in einen Text dürfen
        ├── voice-vorlage.md           ← Vorlage für deinen Stil-Korpus
        └── scripts/pruefen.sh         ← automatische Prüfung jeder Fassung
```

In deinem Arbeitsordner entsteht beim ersten Lauf:

```
content/
├── voice.md                           ← dein Stil-Korpus
├── beispiele/                         ← deine eigenen Texte als Quelle
└── ausgabe/<datum>-<thema>/           ← alle Fassungen eines Laufs
```
