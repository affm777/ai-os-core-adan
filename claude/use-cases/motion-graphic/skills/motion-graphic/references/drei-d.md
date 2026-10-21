# 3D im Film (Three.js in HyperFrames)

Lesen, wenn die Stilkarte 3D verlangt (`held-baut.md`) oder eine Szene echte Tiefe braucht (Glasflächen, Figur, Licht, fallende Paneele). Getestet am 21.10.2026 mit HyperFrames 0.8.145 und three 0.181.2 auf einem MacBook M3: 4 s Film in 7 s gerendert (Draft, 30 fps). Ohne Grafikkarte (Cloud PC) rendert Chrome per Software, deutlich langsamer, deshalb Geometrie schlank halten.

Warum nicht Blender: Blender rendert schöner (Cycles, echtes Glas), braucht dafür aber eine NVIDIA-Karte, rund 1 GB Installation und Stunden auf einem Laptop. Three.js läuft im selben HyperFrames-Render, deterministisch, auf Mac und Windows, ohne Installation. Was wir von der Blender-Methode übernehmen, ist das Prinzip: eine Timeline-Datei, jeder Frame eine reine Funktion der Zeit, Stills vor dem Render, Fixes mit Zahlen.

## Einrichten (einmal je Film)

Three.js lokal ablegen, keine Netzwerkzugriffe zur Renderzeit:

```bash
B=https://cdn.jsdelivr.net/npm/three@0.181.2
mkdir -p film-v1/vendor/three/addons
curl -sfL $B/build/three.module.min.js -o film-v1/vendor/three/three.module.min.js
curl -sfL $B/build/three.core.min.js   -o film-v1/vendor/three/three.core.min.js
curl -sfL $B/examples/jsm/geometries/RoundedBoxGeometry.js -o film-v1/vendor/three/addons/RoundedBoxGeometry.js
curl -sfL $B/examples/jsm/environments/RoomEnvironment.js  -o film-v1/vendor/three/addons/RoomEnvironment.js
```

`three.module.min.js` lädt `three.core.min.js` nach, beide Dateien müssen nebeneinander liegen. Weitere Addons genauso holen, sie importieren `three` über die Importmap.

```html
<script src="vendor/gsap.min.js"></script>
<script type="importmap">
  { "imports": { "three": "./vendor/three/three.module.min.js", "three/addons/": "./vendor/three/addons/" } }
</script>
<canvas id="gl" width="1920" height="1080" data-layout-allow-overflow></canvas>
```

`data-layout-allow-overflow` auf dem Canvas, sonst meldet `check` eine Warnung, weil die Szene bis an den Bildrand reicht. Root-`data-duration` ist Pflicht (Three hat keine eigene Dauer).

## Grundgerüst (getestet)

```js
import * as THREE from "three";
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, preserveDrawingBuffer: true });
renderer.setPixelRatio(1);                         /* nie devicePixelRatio */
renderer.setSize(W, H, false);
renderer.toneMapping = THREE.NeutralToneMapping;   /* nicht AgX, siehe Farbe */
renderer.outputColorSpace = THREE.SRGBColorSpace;
const pmrem = new THREE.PMREMGenerator(renderer);
scene.environment = pmrem.fromScene(new RoomEnvironment(), 0.04).texture;
scene.environmentIntensity = 0.2;                  /* höher macht schwarzen Glanzboden grau */
```

**Antrieb.** Alles in der Szene ist eine Funktion von `t`. Ein Proxy-Tween auf der HyperFrames-Zeitleiste ruft `render3d(t)` auf, zusätzlich hört die Szene auf `hf-seek`:

```js
const proxy = { t: 0 };
tl.to(proxy, { t: DUR, duration: DUR, ease: "none", onUpdate: () => render3d(proxy.t) }, 0);
window.addEventListener("hf-seek", (e) => render3d(e.detail.time));
render3d(0);
```

Für 3D-Bewegungen mit GSAP-Eases eine zweite, pausierte Zeitleiste `tl3d` bauen (nicht in `window.__timelines` eintragen) und in `render3d` mit `tl3d.seek(t, false)` setzen, danach rendern. Nie `requestAnimationFrame`, `Date.now()` oder `Math.random` (geseedeter Zufall).

## Die eine Timeline-Datei

`film-vN/timeline.js` ist die einzige Zeitquelle für Bild und Ton. Sie beginnt mit `window.TL = ` und enthält danach reines JSON, damit `scripts/klang.py` sie lesen kann. Die Komposition bindet sie mit `<script src="timeline.js"></script>` vor allen anderen Skripten ein.

```js
window.TL = {
  "dauer": 12, "bpm": 120, "drop": 4.0,
  "ui": { "breite": 1024, "hoehe": 600, "knoepfe": [ {"id": "titel", "x": 40, "y": 440, "b": 210, "h": 110, "label": "Titel"} ] },
  "spruenge": [ {"t": 2.0, "ziel": "titel"}, {"t": 2.5, "ziel": "datum"} ],
  "kamera": [ [0, "weit"], [1.5, "folgt"], [10.5, "ergebnis"] ],
  "musik": {"art": "beat", "grundton": 55, "intro_db": -12},
  "klang": [ {"t": 2.0, "typ": "klick"}, {"t": 4.0, "typ": "aufprall"} ]
}
```

Regel: Jede Landung ist ein Eintrag in `spruenge` und hat zur selben Zeit einen Eintrag in `klang`. Knopfpositionen stehen in UI-Pixeln, die Szene rechnet sie in Weltkoordinaten um. So trifft der Fuß den Knopf genau im Moment des Klicks, auch nach jeder Änderung.

## Oberfläche als Textur

Die nachgebaute App ist ein 2D-Canvas, der als `CanvasTexture` auf einer Fläche im Paneel liegt und in `render3d` je Frame aus dem Zustand neu gezeichnet wird (aktive Knöpfe, entstehender Titel). Material `MeshBasicMaterial({ map, toneMapped: false })`, damit Markenfarben exakt ankommen (gemessen Delta E 0). Textur `colorSpace = SRGBColorSpace`, `anisotropy = 8` gegen Unschärfe bei flachem Blickwinkel. Schrift im Canvas erst zeichnen, wenn `document.fonts.ready` erfüllt ist, sonst rendert der erste Frame mit Ersatzschrift.

Knopf in Weltkoordinaten:

```js
const btnWorld = (k) => {
  const u = (k.x + k.b / 2) / UI_W, v = (k.y + k.h / 2) / UI_H;
  panel.updateMatrixWorld(true);                   /* vor jedem Umrechnen, sonst landet alles am Ursprung */
  return new THREE.Vector3((u - 0.5) * PANEL_W, (0.5 - v) * PANEL_H, 0.07).applyMatrix4(panel.matrixWorld);
};
```

## Held, Sprung, Landung

- Figur aus einfachen Formen (`RoundedBoxGeometry`, Kugeln für Augen), abgeleitet aus der Bildmarke der Marke, nie ein fremdes Maskottchen.
- Sprung von A nach B: Position mit `easeInOut(p)` interpoliert, Höhe `sin(PI * p) * h`. Vor dem Absprung 0,08 s ducken (Squash 0,85), in der Luft strecken (1,08), bei der Landung wieder 0,85 und zurückfedern. Ohne Ducken und Federn wirkt der Sprung wie eine Fahrt.
- Bei der Landung ändert sich sichtbar etwas: Knopf leuchtet, ein Element erscheint in der Komposition, ein kleiner Ring dehnt sich aus. Jede Landung ohne Folge ist Leerlauf.
- Ein Schatten unter dem Helden erdet ihn (`shadowMap` mit einer 1024er Karte nur für das Hauptlicht, oder ein weicher dunkler Kreis als Fläche, dessen Größe mit der Höhe schrumpft).

## Licht und Glas

- Hauptlicht `DirectionalLight` plus Fülllicht `HemisphereLight` in den Farben der Bühne. Ohne Fülllicht wird die abgewandte Seite schwarz.
- Glanzboden: `MeshPhysicalMaterial({ color: 0x050607, roughness: 0.18, clearcoat: 1, clearcoatRoughness: 0.08 })`. Helle Bühne: Grundfarbe aus der Hellfläche der Marke, `roughness 0.3`.
- Glas-Paneel ohne `transmission` (teuer und im Render verrauscht): dunkle Platte mit `clearcoat: 1`, leuchtender Bildschirm davor, dünne helle Kante. Das liest sich als Glas.
- Große weiße Flecken auf den Bildschirmen heißen: ein Licht spiegelt sich. Licht versetzen oder `environmentIntensity` senken.

## Farbe

AgX-Tonemapping hellt und entsättigt Markenfarben. Gemessen am Helden in `#ED6326`: mit AgX `#D78863` (Delta E 35, lachsrosa), mit `NeutralToneMapping` und Fülllicht 1,1 `#DD550C` (Delta E 6). Deshalb immer `NeutralToneMapping`, dann messen:

```bash
node "$S/scripts/farbe_pruefen.mjs" _pruefung/v1-r1/frame-02-at-3.6s.png "#ED6326" --bereich <x,y,b,h>
```

Den Bereich auf die beleuchtete Vorderseite des Objekts legen (aus dem Snapshot abgelesen). Ziel unter 5, bei beleuchteten 3D-Körpern bis 8 vertretbar. Flächen mit `toneMapped: false` müssen exakt passen.

## Kamera

- Weit beginnen (ganze Bühne), dann dem Helden auf Augenhöhe folgen, mit Verzögerung: Zielposition je Frame aus der Heldenposition von `t - 0,15` berechnen, nie aus dem Vorframe (nicht seek-safe).
- Tiefe: `scene.fog` in der Bühnenfarbe für Abstand, Tiefenunschärfe über eine unscharfe DOM-Kopie des Vordergrunds statt Postprocessing.
- Am Ende allein auf dem Ergebnis landen, das letzte Bild muss als Plakat taugen.
- Kameraschnitte als Konstanten, nie als Literal an zwei Stellen (siehe `/hyperframes-animation`, Adapter `three.md`).

## Abgang

Paneele fallen nacheinander weg: Startzeit je Paneel aus der Timeline, Fall `y = y0 - 4.9 * dt * dt`, leichte Drehung, dazu `powerdown` im Klang und der Bildschirm wird dunkel (Textur auf Schwarz überblenden). Übrig bleibt nur das Ergebnis.

## 9:16

Eigene Komposition mit derselben `timeline.js`, Kamera näher und höher, weniger Paneele, größere Schrift in der UI-Textur. Nie die 16:9-Fassung beschneiden.

## Fehlerbilder

| Bild | Ursache und Fix |
|---|---|
| Held lachsrosa statt Markenfarbe | AgX-Tonemapping, auf `NeutralToneMapping`, Fülllicht nachregeln, messen |
| Boden grau statt schwarz | `environmentIntensity` zu hoch, auf 0,2 oder weniger |
| Objekte landen am Ursprung | `updateMatrixWorld(true)` vor dem Umrechnen oder Parenting |
| Erster Frame mit falscher Schrift | Canvas-Text erst nach `document.fonts.ready` zeichnen |
| Schwarzes Bild im Render | `preserveDrawingBuffer: true` fehlt oder `render3d` wird beim Seek nicht aufgerufen |
| Ruckeln an Haltepunkten | Kamerakurve mit Knick, monotone Hermite-Kurve wie in `helle-konstellation-kamerafahrt.md` |
