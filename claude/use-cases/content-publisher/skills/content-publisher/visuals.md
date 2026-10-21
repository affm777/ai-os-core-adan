# Visuals bauen

Teil des Skills content-publisher. Claude liest diese Datei, sobald im Lauf Visuals gewählt sind oder ein Bild nachgebessert werden soll. Pfade und Grundregeln stehen in der SKILL.md. Ergebnis: PNG-Bilder in Originalgröße im Laufordner unter `content-und-social/ausgabe/<lauf>/bilder/<marke>-<format>-<sprache>-NN.png`, der Arbeitsstand je Bild in `bilder/_build/<format>-<sprache>/`. Skripte immer aus dem Projektordner aufrufen.

## Welcher Design-Auftrag für welches Bild

- Instagram 1:1 oder 4:5, Story 9:16, Karussell: Design-Auftrag von `instagram-<sprache>`. Gibt es keine Instagram-Fassung, den von `linkedin-<sprache>`, sonst den der ersten Fassung dieser Sprache.
- LinkedIn 1:1: Design-Auftrag von `linkedin-<sprache>`, sonst wie oben.
- Je gewählter Sprache ein eigenes Bild. Bei „beide“ erst alle DE-Vorschauen bauen und prüfen, dann EN mit derselben Vorlage.
- „Passend zu den Kanälen“ heißt Instagram 4:5 für Instagram und LinkedIn 1:1 für LinkedIn. Sind weder Instagram noch LinkedIn als Kanal gewählt, einmal fragen, welches Format es sein soll.

## Vorlage wählen

Gibt es eine gewählte Referenz, gilt ihr Bildmuster (`referenzen.md`), sonst selbst entscheiden und in einem Satz sagen, etwa „Ich nehme die Vorlage Statement, weil der Text eine Kernaussage hat. Sag Bescheid, wenn du lieber Info willst.“
- **Statement**: große Headline auf Markenfarbe, Kicker darüber, Logo unten. Für eine Kernaussage, ein Ergebnis, ein Zitat.
- **Info**: Headline, genau drei nummerierte Stichpunkte, Call-to-Action auf Weiß. Für Termin, Ort, Anmeldung oder drei klar getrennte Fakten aus der Faktenliste.
- **Karussell**: nur wenn im Briefing gewählt. Titelseite, ein bis drei Inhaltsseiten, Abschlussseite mit Call-to-Action.

## 1. Vorbereiten

```bash
S=~/.claude/skills/content-publisher
bash "$S/scripts/vorbereiten.sh" <marke> <statement|info|karussell> content-und-social/ausgabe/<lauf>/bilder/_build/<format>-<sprache>
```

Liegen unter `content-und-social/brand/<slug>/logo/` eigene Logos, aber keine `content-und-social/brand/<slug>/logos.conf`, diese Datei anlegen (Aufbau wie `$S/marken/<slug>/logos.conf`, Pfade relativ zu `content-und-social/brand/<slug>/`, Rollen `auf-flaeche`, `auf-hell`, `wasserzeichen`) und den Nutzer fragen, welches Logo auf der Farbfläche stehen soll. Danach `vorbereiten.sh` erneut ausführen. Ohne eigene logos.conf nimmt das Skript die Logos aus dem Skill.

Meldet das Skript einen eigenen Guide (`content-und-social/brand/<slug>/STYLE-GUIDE.md`), den Guide lesen und Farben und Schrift in `bilder/_build/<...>/marke.css` damit abgleichen (nur die `--sp-*`-Werte, Schlüssel nie umbenennen). Dem Nutzer in einem Satz sagen, dass sein eigener Guide gilt.

## 2. inhalt.json schreiben

Mit dem Write-Tool nach `bilder/_build/<format>-<sprache>/inhalt.json` (UTF-8, gültiges JSON). Quelle ist der Design-Auftrag, nie neuer Text:

| Feld | Vorlage | Inhalt |
|---|---|---|
| `vorlage` | alle | `statement`, `info` oder `karussell` |
| `format` | alle | `ig-1x1`, `ig-4x5`, `story-9x16`, `li-1x1` |
| `sprache` | alle | `de` oder `en` |
| `kicker` | alle | aus `Kicker:`, optional, erscheint in Versalien |
| `headline` | alle | aus `Headline:`, ein Wort darf in `*Sternchen*` stehen und erscheint in Akzentfarbe |
| `subline` | statement, karussell (Titelseite) | aus `Bildtext:`, optional |
| `cta` | statement, info, karussell (Abschluss) | aus `CTA:`, ohne Pfeil, optional |
| `absender` | alle | Website oder Handle, nur wenn im Rohtext oder Marken-Guide genannt, optional |
| `punkte` | info | genau drei kurze Stichpunkte aus Bildtext und Faktenliste |
| `weiter` | karussell | `Wischen` oder `Swipe` |
| `seiten` | karussell | 1 bis 3 Inhaltsseiten, je `{ "kicker", "headline", "text" }` oder statt `text` eine Liste `punkte`, nur Fakten aus der Faktenliste |
| `abschluss` | karussell | Satz auf der letzten Seite über dem CTA |
| `farben` | alle | optional, überschreibt `--sp-*`-Werte nur für dieses Bild, etwa `{ "--sp-farbe-flaeche": "#BF2806" }`, mit Referenz deren `farben` |

Steht im Design-Auftrag ein `[FEHLT: ...]`, kommt diese Stelle nicht ins Bild. Das Feld bleibt weg oder der Satz wird ohne den fehlenden Teil gebaut, sofern er dann noch stimmt. Fehlt eine Zeile ganz (etwa `Kicker:`), bleibt das Feld weg. Richtwerte: Headline höchstens rund 8 Wörter, Subline rund 25, Stichpunkt rund 10, Karussell-Seite rund 35. Sehr lange Wörter mit `&shy;` als weicher Trennstelle.

## 3. Vorschau rendern

```bash
bash "$S/scripts/render.sh" content-und-social/ausgabe/<lauf>/bilder/_build/<format>-<sprache> content-und-social/ausgabe/<lauf>/bilder/_build/<format>-<sprache>/vorschau
```

Das Skript startet einen lokalen Server, öffnet die Seite mit playwright-cli, wartet auf Schrift und Einpassung, macht je Seite ein PNG (`vorschau-01.png`, ...) und räumt Browser und Server ab. Ausgabe lesen:
- `Rubik NICHT geladen`: Schriftdateien fehlen im Build-Ordner (`fonts/`). `vorbereiten.sh` erneut, hilft das nicht, Bundle neu installieren. Internet braucht der Render nicht.
- `ÜBERLAUF` (Exit-Code 3): Text passt auch verkleinert nicht. Kürzung vorschlagen, nicht still kürzen.
- Schriftgröße unter 85 Prozent: passt, wirkt aber gedrängt. Kürzere Headline vorschlagen.

**Sichtprüfung ist Pflicht.** Jede Vorschau mit dem Read-Tool ansehen, bevor sie der Nutzer sieht: Text lesbar, nichts abgeschnitten, Logo sichtbar, Umlaute korrekt, Kontrast ausreichend, kein `[FEHLT]` im Bild. Fällt etwas auf, erst selbst nachbessern.

## 4. Feedback

- Text kürzer, anders, andere Betonung: `inhalt.json` anpassen. Ändert sich dabei die Aussage, auch den Design-Auftrag in `uebersicht.md` nachziehen.
- Andere Farbe, etwa Hintergrund weiß statt Markenfarbe: `farben` in `inhalt.json`, nur Farben aus dem Marken-Guide. Farbe außerhalb des Guides nur nach kurzer Rückfrage.
- Andere Vorlage oder anderes Format: neuer Build-Ordner unter `bilder/_build/`, Inhalt übernehmen.
- Soll eine Änderung für alle künftigen Bilder der Marke gelten, fragen, ob sie als `content-und-social/brand/<slug>/marke.css` gespeichert werden soll (Kopie aus dem Build-Ordner, dann dort ändern).
- Nach jeder Änderung Schritt 3 wiederholen. Höchstens drei Runden ohne Rückfrage.

## 5. Ablegen

Wenn der Nutzer zufrieden ist (oder ausdrücklich gesagt hat, dass die erste Fassung reicht):

```bash
bash "$S/scripts/render.sh" content-und-social/ausgabe/<lauf>/bilder/_build/<format>-<sprache> content-und-social/ausgabe/<lauf>/bilder/<marke>-<format>-<sprache>
```

Gibt es Dateien mit dem Präfix schon, `-v2`, `-v3` an das Präfix hängen, nie überschreiben. Pfade im Abschnitt `## Visuals` der `uebersicht.md` eintragen. Danach folgt die Frage nach der Referenz (SKILL.md, Schritt 7). Zum Schluss Pfade, Pixelgröße (ig-1x1 1080 x 1080, ig-4x5 1080 x 1350, story-9x16 1080 x 1920, li-1x1 1200 x 1200) und ein Satz zu den Grenzen (Marken-Guide vorläufig, Feinschliff in Figma oder Claude Design möglich).

## Windows (Git Bash)

- Die Skripte suchen selbst `python3`, `python` oder `py -3` (`python3` ist unter Windows oft nur ein Store-Platzhalter).
- Zum Öffnen im Explorer Pfade mit Backslashes, die Skripte selbst arbeiten mit normalen Schrägstrichen.
- Meldet `render.sh`, dass der Browser fehlt: playwright-cli rendert mit Google Chrome. Nach Okay des Nutzers `playwright-cli install-browser chrome` (vorher sagen, dass gut 100 MB geladen werden).
