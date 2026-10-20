# Google Workspace CLI: Claude arbeitet in Gmail, Kalender und Drive

Mit diesem Werkzeug arbeitet Claude direkt in deinem Google-Konto, also in Gmail, Kalender, Drive, Docs und Sheets. Das Programm dahinter heißt `gws` und kommt von Google selbst. Es ist vor allem für Firmenkonten (Google Workspace) gedacht, funktioniert aber auch mit einem privaten Gmail-Konto.

Die ausführliche Anleitung mit allen Schritten zum Google-Cloud-Teil (eigenes Projekt, Zugangsdaten, Anmeldung, passende Skills) steht in [docs/google-workspace-cli.md](../../../docs/google-workspace-cli.md). Diese Seite ist nur der kurze Einstieg.

## Voraussetzungen

- Dein Setup ist installiert.
- Ein Google-Konto, mit dem du dich anmelden darfst. Bei einem Firmenkonto kann es sein, dass die IT den Zugriff erst freigeben muss.
- Rund 30 Minuten Zeit für den ersten Durchgang, der Google-Cloud-Teil ist einmalig.

## Installieren

Sag Claude:

```
Installiere mir das Werkzeug google-workspace-cli aus meinem Setup-Repo ~/ai-os-core, in der aktuellsten Version.
Lies dafür zuerst ~/ai-os-core/claude/werkzeuge/google-workspace-cli/README.md und halte dich an die Schritte dort.
Sag mir am Ende in einfachen Worten, ob alles geklappt hat und was ich als Nächstes selbst tun muss.
```

Das tut Claude dann:

1. Installiert das Programm in der aktuellsten Version. Auf dem Mac mit `brew install googleworkspace-cli` (ist es schon da, bringt `brew upgrade googleworkspace-cli` es auf den neuesten Stand). Unter Windows in Git Bash mit `npm install -g @googleworkspace/cli@latest`, npm ist durch das Setup schon vorhanden.
2. Prüft mit `gws --version`, ob das Programm gefunden wird. Unter Windows vorher Git Bash schließen und neu öffnen, falls `gws` nicht gefunden wird.
3. Führt dich danach Schritt für Schritt durch die Langanleitung [docs/google-workspace-cli.md](../../../docs/google-workspace-cli.md) ab Schritt 2 (gcloud, Google-Cloud-Projekt, Anmeldung, Skills). Die Anmeldung im Browser machst du selbst, Claude gibt nie ein Passwort ein.

## Grenzen

- Unter Windows gibt es keinen Weg über Homebrew oder winget, nur über npm. Das npm-Paket lädt beim ersten Aufruf das passende Programm von Google nach und unterstützt Windows nur auf Rechnern mit Intel- oder AMD-Prozessor (x64). Auf Windows-Rechnern mit ARM-Prozessor (zum Beispiel manche Surface-Geräte) läuft `gws` nicht.
- Die Einrichtung des Google-Cloud-Teils gilt unter Windows als weniger robust als auf dem Mac. Bricht sie ohne klare Meldung ab, hilft oft ein zweiter Versuch, Details in der Langanleitung.
- `gws` ist kein offiziell unterstütztes Google-Produkt, auch wenn es von Google stammt. Befehle können sich zwischen Versionen ändern.
- Ein Update der CLI aktualisiert nicht die daraus erzeugten Skills. Wie du sie neu erzeugst, steht in der Langanleitung.
