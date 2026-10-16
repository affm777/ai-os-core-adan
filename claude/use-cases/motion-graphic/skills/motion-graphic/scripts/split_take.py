#!/usr/bin/env python3
"""Schneidet einen Gesamttake der Sprecherstimme an den Pausen in Beats und schreibt die Zeitachse.

Aufruf (im Videoordner, mit .venv):
  .venv/bin/python <skill>/scripts/split_take.py beats.json take.mp3 --out audio/out --js hf/timing.js [--js weitere/timing.js]
        [--ersatz b9,b10=nachsprache.mp3] [--html hf/index.html]

beats.json:
  {"tail": 1.0, "endcard": 4.6,
   "beats": [{"key": "b0", "text": "Angezeigter Satz.", "tts": "Optionale Lautschrift.",
              "cues": {"Stichwort": "w_name"}, "pause": 0.6}, ...]}

Ergebnis: <out>/stimme.wav (Beats mit festen Pausen) und timing.js (window.T in Sekunden):
  bX (Bildstart 0,25 s vor dem ersten Wort), bX_vo, bX_end, Wort-Cues, end, dur.
Wort-Cues sind proportional zur Zeichenposition geschätzt. Liegt neben dem Take eine
<take>.spans.json ({"b0": [start, ende], ...}), werden diese geprüften Schnittpunkte genutzt.
Mit --html wird data-duration der Root-Komposition auf dur gesetzt.
"""
import argparse, json, re, subprocess
from pathlib import Path
import numpy as np
import soundfile as sf

SR = 48000


def silences(path):
    out = subprocess.run(["ffmpeg", "-hide_banner", "-i", str(path), "-af", "silencedetect=noise=-38dB:d=0.22", "-f", "null", "-"],
                         capture_output=True, text=True).stderr
    st = [float(v) for v in re.findall(r"silence_start: ([\d.]+)", out)]
    en = [float(v) for v in re.findall(r"silence_end: ([\d.]+)", out)]
    return list(zip(st, en))


def load(path):
    wav = Path(path).with_suffix(".48k.wav")
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", str(path), "-ar", str(SR), "-ac", "1", str(wav)], check=True)
    x, _ = sf.read(wav)
    return x, wav


def segment(path, beats):
    """Teilt eine Aufnahme an den Pausen in len(beats) Abschnitte (dynamische Programmierung über Pausenkandidaten)."""
    x, wav = load(path)
    dur = len(x) / SR
    sil = silences(wav)
    lead = sil[0][1] if sil and sil[0][0] < .05 else 0.0
    tail = sil[-1][0] if sil and sil[-1][1] > dur - .05 else dur
    if len(beats) == 1:
        return x, [(lead, tail)]
    cand = [(s, e) for s, e in sil if s > lead + .3 and e < tail - .3]
    chars = np.array([len(b.get("tts") or b["text"]) for b in beats], float)
    exp = lead + np.cumsum(chars)[:-1] / chars.sum() * (tail - lead)
    K, N = len(exp), len(cand)
    if N < K:
        raise SystemExit(f"Zu wenige Pausen im Take ({N}) für {K + 1} Beats. Take mit deutlicheren Pausen aufnehmen.")
    INF = 1e9
    cost = np.full((K, N), INF); prev = np.zeros((K, N), int)
    mid = [(s + e) / 2 for s, e in cand]; gap = [e - s for s, e in cand]
    for j in range(N):
        cost[0, j] = abs(mid[j] - exp[0]) - 3 * gap[j]
    for k in range(1, K):
        best, bi = INF, -1
        for j in range(N):
            if j > 0 and cost[k - 1, j - 1] < best:
                best, bi = cost[k - 1, j - 1], j - 1
            if bi >= 0:
                cost[k, j] = best + abs(mid[j] - exp[k]) - 3 * gap[j]; prev[k, j] = bi
    j = int(np.argmin(cost[K - 1])); cuts = []
    for k in range(K - 1, -1, -1):
        cuts.append(cand[j]); j = prev[k, j]
    cuts = cuts[::-1]
    bounds = [lead] + [c for pair in cuts for c in pair] + [tail]
    return x, [(bounds[2 * i], bounds[2 * i + 1]) for i in range(len(beats))]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("beats"); ap.add_argument("take")
    ap.add_argument("--out", default="audio/out")
    ap.add_argument("--js", action="append", default=[])
    ap.add_argument("--html")
    ap.add_argument("--ersatz", action="append", default=[])
    a = ap.parse_args()
    cfg = json.loads(Path(a.beats).read_text(encoding="utf-8"))
    beats = cfg["beats"]; byk = {b["key"]: b for b in beats}

    fix = Path(a.take).with_suffix(".spans.json")
    if fix.exists():
        x, _ = load(a.take); sp = json.loads(fix.read_text())
        pieces = {b["key"]: (x, tuple(sp[b["key"]])) for b in beats}
    else:
        x, spans = segment(a.take, beats)
        pieces = {b["key"]: (x, s) for b, s in zip(beats, spans)}
    for e in a.ersatz:
        keys, f = e.split("=")
        sub = [byk[k] for k in keys.split(",")]
        xe, spe = segment(f, sub)
        for b, s in zip(sub, spe):
            pieces[b["key"]] = (xe, s)

    T, track, t = {}, [], 0.0
    for b in beats:
        key = b["key"]; text = b.get("tts") or b["text"]
        xs, (s0, s1) = pieces[key]
        seg = xs[max(0, int((s0 - .03) * SR)): int((s1 + .15) * SR)]
        t += b.get("pause", 0.5)
        T[key] = round(t - 0.25, 3); T[key + "_vo"] = round(t, 3)
        for word, name in b.get("cues", {}).items():
            ci = max(0, text.find(word))
            T[name] = round(t + (s1 - s0) * ci / len(text), 3)
        track.append((t, seg)); t += len(seg) / SR
        T[key + "_end"] = round(t, 3)
        print(f"{key}: {s0:6.2f} bis {s1:6.2f}  {text[:50]}")
    t += cfg.get("tail", 1.0); T["end"] = round(t, 3); T["dur"] = round(t + cfg.get("endcard", 4.0), 3)

    out = Path(a.out); out.mkdir(parents=True, exist_ok=True)
    vo = np.zeros(int((T["dur"] + .5) * SR))
    for at, seg in track:
        i = int(at * SR); vo[i:i + len(seg)] += seg
    sf.write(out / "stimme.wav", vo.astype(np.float32), SR, subtype="FLOAT")
    js = "// Automatisch aus split_take.py. Sekunden. Nicht von Hand ändern.\nwindow.T = " + json.dumps(T, indent=1) + ";\n"
    for p in a.js:
        Path(p).write_text(js, encoding="utf-8")
    if a.html:
        h = Path(a.html).read_text(encoding="utf-8")
        h = re.sub(r'(data-composition-id="main"[^>]*?data-duration=")[\d.]+', lambda m: m.group(1) + str(T["dur"]), h)
        Path(a.html).write_text(h, encoding="utf-8")
    print(json.dumps({k: v for k, v in T.items() if not k.startswith("w_")}))


if __name__ == "__main__":
    main()
