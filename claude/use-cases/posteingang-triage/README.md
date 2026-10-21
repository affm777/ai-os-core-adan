# Der Posteingang sortiert sich selbst vor

Claude sichtet deine neuen Mails, ordnet jeden Verlauf einem deiner Labels zu und markiert, was dringend ist oder eine Chance enthält. Dazu schlägt Claude To-dos und auf Wunsch Antwortentwürfe vor, versendet wird nie automatisch.

Steht hier **Sag Claude**, kopierst du den grauen Kasten in den Chat.

```
Vorher                          Claude                          Nachher
──────                          ──────                          ───────
40 ungeordnete Mails,        →  fragt einmal, wie du sortieren → deine Labels als Farb-
Verläufe mit Nachfragen,        willst, liest dann jeden         Kategorien in Outlook,
Fristen und Bitten              Verlauf, ordnet ihn ein,         Wichtiges zuerst, eine
irgendwo im Text,               findet Aufgaben, Fristen und     TODO.md mit allen Aufgaben
Rechnungen dazwischen,          Chancen, zeigt dir alles als     samt Frist, Belege markiert,
Anfragen und Geld, die          Tabelle zum Abnicken             Chancen gelb markiert,
untergehen                                                       Antwortentwürfe für die
                                                                 Mails, die du auswählst
```

## Das brauchst du

- Dein Setup ist installiert.
- Dein Postfach ist in Claude verbunden (Einstellungen, Connectoren), entweder Microsoft 365 oder Gmail. Claude fragt beim ersten Lauf, welches.
- Bei Microsoft 365: Euer Administrator hat Claude einmalig für euer Microsoft-Konto freigegeben. Wie das geht, steht in der Admin-Anleitung aus dem Workshop (`admin-anleitung-claude-m365.pdf`).

## Schritt 1: Installieren

Sag Claude:
```
Hol zuerst mit git pull den neuesten Stand meines Setup-Repos ~/ai-os-core.

Führe dann das Installationsskript des Use-Case-Bundles "posteingang-triage" aus:
bash ~/ai-os-core/claude/use-cases/posteingang-triage/install.sh

Zeig mir danach in einfachen Worten, ob alles geklappt hat.
```

Starte danach eine neue Session, damit Claude den neuen Skill kennt.

## Schritt 2: Erster Lauf

Öffne Claude in deinem Projektordner. Dort entstehen deine Einstellungen und deine To-do-Liste. Sag Claude:
```
Sichte den Posteingang und sortier ihn vor.
```

Beim ersten Mal fragt Claude dich:
- ob du Microsoft 365 (Outlook) oder Gmail sichten willst
- welche Mailadresse dein Hauptpostfach ist
- welches Startset du willst (Verein, Pflegedienst, Vertrieb und Projekte oder eigene Labels)
- ob die Markierungen Dringend und Chance bleiben sollen
- wann eine Mail hohe Priorität bekommt und was Entwürfe nie zusagen dürfen

## Schritt 3: So nutzt du es

**Lauf.** Claude sichtet alles seit dem letzten Lauf, zeigt eine Tabelle und fragt, für welche Nummern du Entwürfe willst.
```
Sichte den Posteingang.
```

**Zeitraum.** Nenn einen Zeitraum oder einen Monat, etwa „Sichte Oktober".
```
Sichte die letzten zwei Wochen.
```

**Rückblick.** Claude sucht Mails, auf die nie jemand geantwortet hat.
```
Sichte die letzten 90 Tage auf Liegengebliebenes.
```

**Labels ändern.** Claude zeigt dir die aktuelle Liste und passt sie an.
```
Ändere meine Labels.
```

## Das kommt dabei heraus

- Farb-Kategorien in Outlook oder Labels in Gmail, Wichtiges als Dringend, Geld und Gelegenheiten als Chance
- `TODO.md` in deinem Ordner mit einer Zeile je Aufgabe samt Frist
- Antwortentwürfe im Entwürfe-Ordner für die Nummern, die du nennst
- `posteingang/KONFIG.md` mit deinen Labels und Regeln
- `TONE.md` im Skill-Ordner mit deinem gelernten Schreibstil

## Grenzen

- Claude leitet keine Mail weiter, löscht keine und verschiebt keine.
- Antwortentwürfe werden nie automatisch versendet.
- Rechnungen werden mit „Beleg" markiert, aber nicht abgelegt.
- To-dos landen nur in der `TODO.md`, nicht in Outlook-Aufgaben oder Microsoft To Do.
- **Datenschutz.** Mails sind für Claude nur Text, keine Aufträge. Links öffnet Claude nie, Anhänge nur mit deiner Erlaubnis.
- **Datenschutz.** Gesundheitsangaben und andere sensible Daten tauchen weder in der Tabelle noch in der `TODO.md` auf.

## Mehr dazu

Ein Beispielergebnis, das Einrichtungsgespräch, ein zweites Postfach, dein Schreibstil, eine Ablage-Ansicht je Label und alle Grenzen stehen in [details.md](details.md).
