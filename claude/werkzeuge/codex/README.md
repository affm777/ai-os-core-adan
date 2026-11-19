# Codex: ChatGPT direkt aus Claude nutzen

Verbinde dein ChatGPT-Konto mit Claude und nutze ChatGPT direkt aus dem Claude-Chat, etwa für Bilder oder um Texte zu überarbeiten. Du brauchst ein ChatGPT-Konto mit Plus oder höher.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

## Schritt 1: Installieren

Sag Claude:
```
Installiere mir das Werkzeug codex in der aktuellsten Version.
Hol dafür zuerst mit git -C ~/ai-os-core pull den neuesten Stand meines Setup-Repos (fehlt der Ordner, klon https://github.com/affm777/ai-os-core-adan.git nach ~/ai-os-core).
Lies danach ~/ai-os-core/claude/werkzeuge/codex/details.md und halte dich an die Schritte dort.
Sag mir am Ende in einfachen Worten, ob alles geklappt hat.
```

Starte danach eine neue Session.

## Schritt 2: Anmelden

Öffne einmalig das Terminal (Windows: Git Bash) und tippe:
```
codex login
```

Im Browser mit deinem ChatGPT-Konto anmelden, fertig.

## Schritt 3: Loslegen

Nenn Codex im Satz, Claude holt ihn dann dazu.

**Bild**
```
Generier mir mit Codex ein Bild für meine Slides: Menschen im Gespräch an einem Tisch, warmes Licht
```

**Text überarbeiten**
```
Lass Codex diesen LinkedIn-Post überarbeiten, damit er sich menschlicher anhört: <Text>
```

**Zweite Meinung**
```
Frag Codex, was ihm an diesem Entwurf auffällt.
```

Bilder landen im Ordner, in dem du gerade arbeitest. Codex nutzt das Kontingent deines ChatGPT-Abos.

Technische Details für Claude stehen in [details.md](details.md).
