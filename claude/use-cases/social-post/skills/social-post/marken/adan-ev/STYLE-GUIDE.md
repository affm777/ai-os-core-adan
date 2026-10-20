# Style-Guide ADAN e.V.

> Kopie für den Skill social-post. Im Skill liegen nur die Logos aus `logo/`, die Ordner `material/` und `screenshots/` gehören nicht dazu. Die Werte für die Social-Vorlagen stehen in `marke.css` daneben. Liegt im Arbeitsordner `brand/<slug>/STYLE-GUIDE.md`, gilt jene Fassung.

Stand: vorläufig, aus Website https://ada-netzwerk.com vom 2026-10-16. Der Kunde korrigiert später, Werte sind aus dem CSS gemessen, nicht vom Verein bestätigt.

Marke: ADAN e.V. (Seitentitel „ADAN, Afro Diasporisches Akademisches Netzwerk“, im Impressum „Afro Deutsches Akademiker Netzwerk e.V.“, Berger Straße 69, 60316 Frankfurt). Der Claim auf der Seite lautet „THIS. IS. ADAN.“ und „Vielfalt sichtbar machen.“

## Farben

| Rolle | Hex | Beleg (wo gemessen) |
|---|---|---|
| Primärfarbe | `#ED6326` | Logo-Orange (Pixelzählung im Favicon 512 px), Hintergrund des Vollbild-Menüs (`rgba(237, 99, 38, 0.94)`) |
| Sekundärfarbe | `#BF2806` | Dunkles Rot der Logo-Faltung (Pixelzählung im Favicon) |
| Akzentfarbe | `#2EA3F2` | Links und Text-Buttons („Mitglied werden“, „Mehr erfahren“, „Jetzt anmelden“), `getComputedStyle` |
| Text | `#494949` | Body und alle Überschriften |
| Text zweitrangig | `#666666`, `#404044`, `#9194A0` | Fließtext in Modulen, Metadaten |
| Hintergrund | `#FFFFFF` | Body, fast alle Flächen |
| Formular-Button | `#F56C6C` | Newsletter-Button „Ich möchte den Newsletter erhalten!“ |

CSS-Variablen im Stylesheet: `--wp--preset--color--brand-color: #174EE2`, `--wp--preset--color--dark-strong: #24262B`, `--wp--preset--color--grey-strong: #6A707E`. Diese stammen aus dem Theme „Norebro“ und sind auf den geprüften Seiten nicht sichtbar im Einsatz, daher nicht als Markenfarbe übernehmen (nicht belegt).

Event-Grafik Career Day 2026 nutzt ein eigenes Teal-Grün plus Orange (Sub-Marke „ADAN Careers“), nicht aus dem CSS gemessen.

## Schriften

| Schrift | Gewichte im Einsatz | Herkunft | Lizenz |
|---|---|---|---|
| Rubik | 400 (Fließtext 14 px), 500 (Überschriften H1 52 px, H2 36 px, H3 bis 70 px im Hero), 600 (Kicker „THIS. IS. ADAN.“), 700 selten | Lokal gehostet: `https://ada-netzwerk.com/wp-content/uploads/fonts/d8b50e1db2318cbda7a2d1591df9951a/font.css` (Dateien `rubik-latin-v21-*.woff2`, lokale Kopie einer Google-Fonts-Schrift) | Auf der Seite nicht belegt. Rubik ist eine Google-Fonts-Schrift, für die Einbindung im Video die freie Fassung über Fontsource nutzen und Lizenz vor Freigabe prüfen. |
| Montserrat | wird von `fonts.gstatic.com` geladen, aber auf keinem gemessenen Element verwendet | Google Fonts (extern) | nicht belegt, nicht übernehmen |

Überschriften ohne Versalien, Groß- und Kleinschreibung normal. Der Kicker „THIS. IS. ADAN.“ steht in Versalien, auch vertikal am linken Rand.

## Logo

- Offizielles Logo: Bildmarke aus drei gefalteten Bändern (Orange `#ED6326` mit dunkelroter Faltung `#BF2806`), ohne Schriftzug. Eine Wortmarke als Bilddatei ist auf der Seite nicht vorhanden, der Name „ADAN“ steht als Text.
- Header-Logo URL: `https://ada-netzwerk.com/wp-content/uploads/2021/03/Icon-ADAN_final.png` (66 x 72 px), Retina `https://ada-netzwerk.com/wp-content/uploads/2021/02/Icon-ADAN_retina.png` (1244 x 1310 px).
- Hauptdatei für Videos: `logo/adan-ev-icon-farbig.png`. Für dunkle Flächen `logo/adan-ev-icon-weiss-fuer-dunkle-flaechen.png`.
- Keine SVG-Fassung auf der Seite gefunden.

## Bildsprache

Die Seite arbeitet fast nur mit Fotos, keine Illustrationen. Im Mittelpunkt stehen Schwarze Menschen und People of Colour, meist junge Erwachsene in Studium und Beruf, lachend, im Gespräch, in Gruppen bei Events oder im Büro, ergänzt um eine Fotocollage aus echten Vereinsevents in den Buchstaben „ADAN“. Die Farbstimmung ist hell und ausgeblichen (Fotos stark aufgehellt oder in Graustufen mit weißem Schleier), einzelne Zwischenbilder sind orange eingefärbt (Duoton) und tragen ein Wort in weißen Versalien wie „DIASPORA“, „MENTORING“ oder „GET TOGETHER“.

## Look und Feel

Viel Weißraum, breite Ränder und große Abstände zwischen den Modulen, dazu eine schmale feste Leiste links mit Menü, vertikalem Claim und Teilen-Knopf. Ecken sind meist eckig, Bilder und Flächen ohne Rundung, nur kleine Bedienelemente rund (Radius 50 px). Buttons sind keine Flächen, sondern blaue Textlinks mit Doppelpfeil, einzig das Newsletter-Formular hat einen roten Flächen-Button. Typografie dominiert, große Rubik-Überschriften in Dunkelgrau auf Weiß, Orange tritt nur über Logo, Menü-Overlay und Zwischenbilder auf. Die Energie ist ruhig und seriös mit warmem Unterton, eher Magazin als Kampagne.

## Assets

Logos (`logo/`):
- `logo/adan-ev-icon-farbig.png` (1244 x 1310, Retina-Header-Logo)
- `logo/adan-ev-icon-weiss-fuer-dunkle-flaechen.png` (351 x 370, weiße Fassung aus dem Startbildschirm)
- `logo/adan-ev-icon-hellgrau-wasserzeichen.png` (1138 x 1197, hellgraue Fassung)
- `logo/adan-ev-favicon-512.png` (512 x 512)
- `logo/adan-ev-icon-mobil-klein.png` (39 x 41, Mobil-Header)

Material (`material/`, Quellen in `material/QUELLEN.md`):
- Key Visuals: `material/keyvisual-orange-duoton.png`, `material/keyvisual-footer-gruppe-hell.png`
- Zwischenbilder mit Wort: `material/zwischenbild-get-together.png`, `material/zwischenbild-diaspora.png`, `material/zwischenbild-collaboration.png`, `material/zwischenbild-mentoring.png`
- Programmbilder: `material/programm-adan-inspires.png`, `material/programm-adan-academy.png`, `material/programm-fireside-chat.png`, `material/programm-axd-fellowship.png`
- Event-Grafik: `material/event-grafik-career-day-2026.jpg`

Kein og:image gesetzt, keine PDFs auf den geprüften Seiten verlinkt.

## Beispiel-Screenshots

- `screenshots/01-startseite-oben.png` (Desktop 1440 px, erster Bildschirm)
- `screenshots/02-startseite-ganz.png` (ganze Startseite)
- `screenshots/03-programme-unsere-arbeit.png` (Formate und Programme)
- `screenshots/04-ueber-uns-team.png` (Über uns, Vorstand, Regionalgruppen)
- `screenshots/05-startseite-mobil-390.png` (Mobil 390 px)
