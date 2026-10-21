#!/usr/bin/env node
// Prüft, ob eine Markenfarbe im gerenderten Bild wirklich so ankommt (Tonemapping, Licht, Glühen verfälschen sie).
//   node farbe_pruefen.mjs <bild.png> <#hex> [--bereich x,y,b,h]
// Ohne --bereich: sucht alle Pixel im Farbton der Markenfarbe (±18 Grad, kräftig genug) und misst deren Median.
// Mit --bereich: misst den Median genau in diesem Rechteck (für ein 3D-Objekt, etwa den Helden).
// Abweichung als Delta E (CIE76 im Lab-Raum): unter 5 passt, 5 bis 10 sichtbar, über 10 falsch.
// Exit 0 = passt, Exit 2 = Abweichung über 5 oder Farbe nicht gefunden. Braucht nur Node und ffmpeg.
import { spawnSync } from "node:child_process";

const [bild, hex, ...rest] = process.argv.slice(2);
if (!bild || !/^#?[0-9a-fA-F]{6}$/.test(hex || "")) {
  console.error("Aufruf: node farbe_pruefen.mjs <bild.png> <#hex> [--bereich x,y,b,h]");
  process.exit(1);
}
let bereich = null;
const bi = rest.indexOf("--bereich");
if (bi >= 0) bereich = rest[bi + 1].split(",").map(Number);

const probe = spawnSync("ffprobe", ["-v", "error", "-select_streams", "v:0", "-show_entries", "stream=width,height", "-of", "csv=p=0", bild], { encoding: "utf8" });
const [W, H] = probe.stdout.trim().split(",").map(Number);
if (!W || !H) { console.error(`Bild nicht lesbar: ${bild}`); process.exit(1); }
const raw = spawnSync("ffmpeg", ["-v", "error", "-i", bild, "-frames:v", "1", "-f", "rawvideo", "-pix_fmt", "rgb24", "-"], { maxBuffer: W * H * 3 + 1024 }).stdout;

const toLin = (c) => { c /= 255; return c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4; };
function lab([r, g, b]) {
  const R = toLin(r), G = toLin(g), B = toLin(b);
  const f = (t) => (t > 0.008856 ? Math.cbrt(t) : 7.787 * t + 16 / 116);
  const x = f((R * 0.4124 + G * 0.3576 + B * 0.1805) / 0.95047), y = f(R * 0.2126 + G * 0.7152 + B * 0.0722), z = f((R * 0.0193 + G * 0.1192 + B * 0.9505) / 1.08883);
  return [116 * y - 16, 500 * (x - y), 200 * (y - z)];
}
function hsv([r, g, b]) {
  const mx = Math.max(r, g, b), mn = Math.min(r, g, b), d = mx - mn;
  let h = 0;
  if (d) h = mx === r ? ((g - b) / d) % 6 : mx === g ? (b - r) / d + 2 : (r - g) / d + 4;
  return [(h * 60 + 360) % 360, mx ? d / mx : 0, mx / 255];
}
const ziel = [0, 2, 4].map((i) => parseInt(hex.replace("#", "").slice(i, i + 2), 16));
const zielLab = lab(ziel), zielHsv = hsv(ziel);
const dE = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1], a[2] - b[2]);
const median = (arr) => { const s = [...arr].sort((a, b) => a - b); return s[Math.floor(s.length / 2)]; };
const hexOf = (c) => "#" + c.map((v) => Math.round(v).toString(16).padStart(2, "0")).join("").toUpperCase();

const px = [];
const [x0, y0, bw, bh] = bereich || [0, 0, W, H];
for (let y = Math.max(0, y0); y < Math.min(H, y0 + bh); y++) {
  for (let x = Math.max(0, x0); x < Math.min(W, x0 + bw); x++) {
    const i = (y * W + x) * 3, c = [raw[i], raw[i + 1], raw[i + 2]];
    if (!bereich) {
      const [h, s, v] = hsv(c), dh = Math.min(Math.abs(h - zielHsv[0]), 360 - Math.abs(h - zielHsv[0]));
      if (dh > 18 || s < 0.25 || v < 0.15) continue;
    }
    px.push(c);
  }
}
if (px.length < 20) {
  console.log(`Markenfarbe ${hex.toUpperCase()} nicht im Bild gefunden. Ist das Objekt zu dunkel, zu blass oder verdeckt?`);
  process.exit(2);
}
const mess = [0, 1, 2].map((k) => median(px.map((c) => c[k])));
const messLab = lab(mess), d = dE(messLab, zielLab);
const nah = px.filter((c) => dE(lab(c), zielLab) < 5).length / px.length;
const urteil = d < 5 ? "passt" : d < 10 ? "sichtbar abweichend" : "falsch";
console.log(`Ziel ${hex.toUpperCase()}, gemessen ${hexOf(mess)} (Median aus ${px.length} Pixeln${bereich ? " im Bereich" : " im Farbton"}), Delta E ${d.toFixed(1)}: ${urteil}`);
if (!bereich) console.log(`Anteil nah an der Markenfarbe (Delta E unter 5): ${(nah * 100).toFixed(0)} %`);
if (d >= 5) {
  const tipps = [];
  if (messLab[0] > zielLab[0] + 3) tipps.push("zu hell (Belichtung senken, Grundfarbe abdunkeln, Licht oder Glühen schwächer)");
  if (messLab[0] < zielLab[0] - 3) tipps.push("zu dunkel (Licht oder Fülllicht stärker)");
  if (Math.hypot(messLab[1], messLab[2]) < Math.hypot(zielLab[1], zielLab[2]) - 5) tipps.push("zu blass (Tonemapping entsättigt, Farbe kräftiger oder Material mit toneMapped: false für Flächen)");
  if (tipps.length) console.log("Hinweis: " + tipps.join("; "));
  process.exit(2);
}
