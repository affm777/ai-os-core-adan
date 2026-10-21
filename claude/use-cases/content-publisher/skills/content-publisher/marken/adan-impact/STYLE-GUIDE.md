# Style-Guide ADAN Impact GmbH

> Kopie für den Skill content-publisher. Im Skill liegen nur die Logos aus `logo/`, die Ordner `material/` und `screenshots/` gehören nicht dazu. Die Werte für die Social-Vorlagen stehen in `marke.css` daneben. Liegt im Projektordner `content-und-social/brand/<slug>/STYLE-GUIDE.md`, gilt jene Fassung.

Stand: vorläufig, aus Website https://adan-impact.com (Englisch als Standard, Deutsch unter /de/) vom 2026-10-16. Der Kunde korrigiert später, Werte sind aus dem CSS gemessen, nicht vom Unternehmen bestätigt.

Marke: ADAN Impact GmbH, Bergerstraße 69, 60316 Frankfurt am Main, HRB 126773 Amtsgericht Frankfurt am Main (Impressum). Der Claim lautet „Develop Diverse. Grow sustainably.“

## Farben

| Rolle | Hex | Beleg (wo gemessen) |
|---|---|---|
| Primärfarbe | `#00AB97` | Elementor-Variable `--e-global-color-primary` und `--e-global-color-accent`, Buttons („MORE“, „Besuchen Sie ADAN Careers“), H2-Zwischentitel, Abschnitt „Leistungen“ als Vollfläche |
| Sekundärfarbe | `#ED6326` | Elementor-Variable `--e-global-color-cd52e4a`, Vollfläche „Woher wir kommen“, Labels der Programmgrafiken (Consulting, Recruitment, Employer Branding) |
| Akzent Mint | `#76C5BC`, `#A5D7D5` | Elementor-Variablen, Logo-Facetten, Illustrationen |
| Hellflächen | `#D2EAEA`, `#EDF7F8`, `#E4F2F2` | Hintergründe der Sektionen (Vision, Mission, Kontakt) |
| Text und Überschriften | `#000000` | H1, H2, Absätze |
| Text zweitrangig | `#7A7A7A` (`--e-global-color-text`), `#54595F` (`--e-global-color-secondary`) | Fließtext, Labels |
| Footer | `#5D6568` | Footer-Fläche |

## Schriften

| Schrift | Gewichte im Einsatz | Herkunft | Lizenz |
|---|---|---|---|
| Rubik | 300 und 400 (Fließtext 20 px), 500 (Sektionstitel H3 44 px in Versalien), 700 (H1 52 px, Kicker), 900 selten | Lokal gehostet als TTF: `https://adan-impact.com/wp-content/uploads/2022/11/Rubik-Regular.ttf` (dazu Light, SemiBold, Bold, ExtraBold, Black) | Auf der Seite nicht belegt. Rubik ist eine Google-Fonts-Schrift, für die Einbindung im Video die freie Fassung über Fontsource nutzen und Lizenz vor Freigabe prüfen. |
| Roboto Slab | als globale Sekundärschrift definiert (`--e-global-typography-secondary-font-family`), lokal über Elementor geladen | `https://adan-impact.com/wp-content/uploads/elementor/google-fonts/css/robotoslab.css` | nicht belegt, auf keinem gemessenen Element im Einsatz, nicht übernehmen |
| Systemschrift (-apple-system, Segoe UI, Roboto) | 400 | Theme-Standard für Text außerhalb der Elementor-Module | nicht für Videos verwenden |

Der Claim kombiniert Rubik dünn („Develop Diverse.“) mit Rubik fett („Grow sustainably.“). Sektionstitel stehen in Versalien.

## Logo

- Offizielles Logo: Wort-Bild-Marke aus facettierter Bildmarke in Teal und Mint (Dreiecke in Form des afrikanischen Kontinents), Schriftzug „ADAN“ in Schwarz mit stilisiertem A und „impact“ in Teal.
- Header-Logo URL: `https://adan-impact.com/wp-content/uploads/2022/11/adan-impact-logo-menu@2x.jpg` (598 x 228 px, JPG mit weißem Hintergrund, keine Transparenz).
- Runde Fassung mit Transparenz: `https://adan-impact.com/wp-content/uploads/2022/12/adan-impact-logo-header2@2x-1.png` (565 x 565 px).
- Hauptdatei für Videos: `logo/adan-impact-wortbildmarke-rund.png` (transparent), auf Weiß auch `logo/adan-impact-wortbildmarke-horizontal.jpg`. Eine reine Bildmarke liegt nur als Favicon (`logo/adan-impact-favicon-icon-512.jpg`, mit weißem Hintergrund) und als helles Wasserzeichen vor.
- Keine SVG-Fassung und keine weiße Fassung für dunkle Flächen auf der Seite gefunden (nicht belegt).

## Bildsprache

Die Seite mischt helle Stockfotos mit flachen Vektor-Illustrationen in Teal, Mint und Orange. Fotos zeigen Schwarze Menschen und People of Colour im Büro, an Bildschirmen und in Besprechungen, lächelnd und zugewandt, die Illustrationen zeigen diverse Gruppen und Handschläge. Die Farbstimmung ist frisch und kühl mit Teal-Stich, Orange setzt warme Kontraste.

## Look und Feel

Klare Corporate-Seite als Onepager mit großzügigen Sektionen und viel Weißraum. Sektionen werden durch schräge Kanten und Formteiler getrennt, Flächen wechseln zwischen Weiß, hellem Mint, vollem Teal und vollem Orange. Buttons sind flache Teal-Flächen mit weißer Schrift und eckigen Ecken, Logos, Icons und Porträts stehen in Kreisen. Zahlen-Zähler (450+, 85+, 35+, 11+) und Programmgrafiken im Organigramm-Stil geben Struktur. Die Energie ist professionell, zuversichtlich und beratend, deutlich businessnäher als die Vereinsseite.

## Assets

Logos (`logo/`):
- `logo/adan-impact-wortbildmarke-horizontal.jpg` (598 x 228, Header-Logo)
- `logo/adan-impact-wortbildmarke-rund.png` (565 x 565, transparent)
- `logo/adan-impact-og-image-rund.png` (400 x 400, og:image der Startseite)
- `logo/adan-impact-favicon-icon-512.jpg` (512 x 512, Bildmarke)
- `logo/adan-impact-icon-wasserzeichen-hell.png` (480 x 527, Footer-Hintergrund)
- `logo/adan-impact-network-logo-rund.png` (Sub-Marke „ADAN impact network“)
- `logo/adan-careers-logo-rund.png` (Sub-Marke „ADAN careers“)

Material (`material/`, Quellen in `material/QUELLEN.md`):
- Illustrationen: `material/illustration-gruppe-menschen.png`, `material/illustration-expertinnen.png`, `material/illustration-handschlag-case-studies.png`
- Programmgrafiken: `material/programmgrafik-consulting.png`, `material/programmgrafik-recruitment.png`, `material/programmgrafik-employer-branding.png`
- Icons: `material/icon-vision.png`, `material/icon-mission.png`, `material/icon-kontakt-dreieck.png`
- Header-Bilder: `material/header-bild-1-arbeitsplatz.jpg`, `material/header-bild-2-meeting.jpg`, `material/header-bild-5-teamrunde.jpg`
- Partnerlogo: `material/partnerlogo-adan-ev-rund.png` (ADAN e.V. auf der Impact-Seite)
- PDFs: drei Pressemitteilungen sind im Newsroom verlinkt, laut Auftrag nicht heruntergeladen, URLs in `material/QUELLEN.md`.

## Beispiel-Screenshots

- `screenshots/01-startseite-oben.png` (Desktop 1440 px, erster Bildschirm, englische Fassung lädt als Standard, Screenshot aus /de/)
- `screenshots/02-startseite-ganz.png` (ganze Seite, einige Sektionen laden erst beim Scrollen und erscheinen leer)
- `screenshots/03-leistungen-services.png` (Leistungen)
- `screenshots/04-ueber-uns-einstieg.png` (Einstieg und Claim)
- `screenshots/05-team-kontakt.png` (Geschäftsführung und Kontakt)
- `screenshots/06-startseite-mobil-390.png` (Mobil 390 px)
