# Google Workspace CLI: Claude arbeitet in Gmail, Kalender und Drive

Mit diesem Werkzeug arbeitet Claude direkt in deinem Google-Konto, also in Gmail, Kalender, Drive, Docs und Sheets. Das Programm dahinter heißt `gws` und kommt von Google selbst.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

## Das brauchst du

- Dein Setup ist installiert.
- Ein Google-Konto, mit dem du dich anmelden darfst. Bei einem Firmenkonto muss die IT den Zugriff eventuell freigeben.
- Rund 30 Minuten Zeit für den ersten Durchgang.

## Schritt 1: Installieren

Sag Claude:
```
Installiere mir das Werkzeug google-workspace-cli aus meinem Setup-Repo ~/ai-os-core, in der aktuellsten Version.
Lies dafür zuerst ~/ai-os-core/claude/werkzeuge/google-workspace-cli/details.md und halte dich an die Schritte dort.
Sag mir am Ende in einfachen Worten, ob alles geklappt hat und was ich als Nächstes selbst tun muss.
```

Claude führt dich danach durch die Einrichtung bei Google. Die Anmeldung im Browser machst du selbst.

## Schritt 2: Erster Lauf

Starte eine neue Session. Sag Claude:
```
Zeig mir meine nächsten drei Termine aus dem Google-Kalender.
```

Klappt das nicht, sagt Claude dir, welcher Schritt der Einrichtung noch fehlt.

## Schritt 3: So nutzt du es

**Gmail.** Claude sucht und liest Mails in deinem Postfach.
```
Such in meinem Gmail die Mails von dieser Woche mit Anhang.
```

**Drive.** Claude findet Dateien in deinem Google Drive.
```
Zeig mir die zuletzt geänderten Dateien in meinem Google Drive.
```

## Das kommt dabei heraus

- Ergebnisse aus Gmail, Kalender, Drive, Docs und Sheets direkt im Chat.

## Grenzen

- Unter Windows nur auf Rechnern mit Intel- oder AMD-Prozessor, Details in [details.md](details.md).
- `gws` ist kein offiziell unterstütztes Google-Produkt. Befehle können sich zwischen Versionen ändern.

## Mehr dazu

Die Installationsschritte für Claude, die Langanleitung zum Google-Cloud-Teil und alle Grenzen stehen in [details.md](details.md).
