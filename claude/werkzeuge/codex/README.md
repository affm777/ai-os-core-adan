# Codex: ChatGPT direkt aus Claude nutzen

Codex ist der KI-Assistent von OpenAI. Mit diesem Werkzeug verbindest du dein ChatGPT-Konto mit Claude und nutzt ChatGPT direkt aus dem Claude-Chat heraus, etwa für Bilder, zum Überarbeiten von Texten oder für eine zweite Meinung.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

## Das brauchst du

- Dein Setup ist installiert. Node.js und npm sind damit schon da.
- Ein ChatGPT-Konto mit Plus oder höher. Einen API-Schlüssel brauchst du nicht.

## Schritt 1: Installieren

Sag Claude:
```
Installiere mir das Werkzeug codex in der aktuellsten Version.
Hol dafür zuerst mit git -C ~/ai-os-core pull den neuesten Stand meines Setup-Repos (fehlt der Ordner, klon https://github.com/affm777/ai-os-core-adan.git nach ~/ai-os-core).
Lies danach ~/ai-os-core/claude/werkzeuge/codex/details.md und halte dich an die Schritte dort.
Sag mir am Ende in einfachen Worten, ob alles geklappt hat.
```

Starte danach eine neue Session, damit Claude die drei Skills kennt.

## Schritt 2: Anmelden

Melde dich einmalig selbst an. Tippe dafür in einem eigenen Terminal (unter Windows in Git Bash), nicht im Chat:
```
codex login
```

Der Browser öffnet die Anmeldeseite von ChatGPT. Melde dich an und bestätige den Zugriff, danach kannst du das Terminal schließen.

## Schritt 3: Erstes Bild

Öffne Claude in einem beliebigen Projektordner. Sag Claude:
```
Generier mir mit Codex ein Bild: ein ruhiges Büro mit Blick auf einen Park, Morgenlicht
```

Das Bild landet als PNG im aktuellen Ordner und öffnet sich.

## So nutzt du es

Du musst dir keine Befehle merken. Sobald du Codex im Satz nennst, holt Claude ihn dazu.

**Bild.** Etwa für Slides oder einen Post.
```
Generier mir mit Codex ein Bild für meine Slides: Menschen im Gespräch an einem Tisch, warmes Licht
```

**Text überarbeiten.** Als letzter Schritt, damit ein Text menschlicher klingt.
```
Lass Codex diesen LinkedIn-Post überarbeiten, damit er sich menschlicher anhört: <Text>
```

**Zweite Meinung.** Codex liest nur und ändert nichts.
```
Frag Codex, was ihm an diesem Entwurf auffällt.
```

## Grenzen

- Codex verbraucht das Kontingent deines ChatGPT-Abos.
- Codex arbeitet nur im aktuellen Ordner, die Schutzschranken (Sandbox) bleiben immer an.
- Unter Windows läuft Codex in Git Bash, Sonderfälle stehen in [details.md](details.md).

## Mehr dazu

Die Installationsschritte für Claude, die Anmeldung im Detail, die Befehle `/codex`, `/codex-ask` und `/codex-image` und alle Grenzen stehen in [details.md](details.md).
