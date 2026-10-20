# Codex: ein zweiter Coding-Agent

Codex ist der Coding-Agent von OpenAI. Claude holt ihn bei Bedarf für eine zweite Meinung, einen Auftrag oder ein Bild dazu, angemeldet über dein ChatGPT-Konto.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

## Das brauchst du

- Dein Setup ist installiert. Node.js und npm sind damit schon da.
- Ein ChatGPT-Konto mit Plus oder höher. Einen API-Schlüssel brauchst du nicht.

## Schritt 1: Installieren

Sag Claude:
```
Installiere mir das Werkzeug codex aus meinem Setup-Repo ~/ai-os-core, in der aktuellsten Version.
Lies dafür zuerst ~/ai-os-core/claude/werkzeuge/codex/details.md und halte dich an die Schritte dort.
Sag mir am Ende in einfachen Worten, ob alles geklappt hat.
```

Starte danach eine neue Session, damit Claude die drei Skills kennt.

## Schritt 2: Erster Lauf

Melde dich einmalig selbst an. Tippe dafür in einem eigenen Terminal (unter Windows in Git Bash), nicht im Chat:
```
codex login
```

Öffne danach Claude in einem beliebigen Projektordner. Sag Claude:
```
/codex-ask Was fällt dir an der Struktur dieses Ordners auf?
```

## Schritt 3: So nutzt du es

**Auftrag.** Codex liest nur. Mit `write:` vor dem Auftrag darf Codex im aktuellen Ordner schreiben.
```
/codex Erklär mir, was die Skripte in diesem Ordner tun.
```

**Bild.** Codex erzeugt ein Bild und legt es als PNG im aktuellen Ordner ab.
```
/codex-image ein ruhiges Büro mit Blick auf einen Park, Morgenlicht
```

## Das kommt dabei heraus

- Antworten von Codex fasst Claude im Chat zusammen und sagt dir, wo Codex etwas anders sieht.
- Nach einem Auftrag mit `write:` zeigt Claude dir die Änderungen, Bilder liegen als PNG im aktuellen Ordner.

## Grenzen

- Codex verbraucht das Kontingent deines ChatGPT-Abos.
- Codex arbeitet nur im aktuellen Ordner, die Schutzschranken (Sandbox) bleiben immer an.
- Unter Windows läuft Codex in Git Bash, Sonderfälle stehen in [details.md](details.md).

## Mehr dazu

Die Installationsschritte für Claude, die Anmeldung im Detail und alle Grenzen stehen in [details.md](details.md).
