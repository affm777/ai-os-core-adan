#!/usr/bin/env python3
"""Misst, ob eine Bewegung im gerenderten Video gleichmäßig läuft (z. B. langsamer Zoom auf eine Endkarte).

Aufruf (mit .venv im Videoordner):
  .venv/bin/python -I <skill>/scripts/bewegung_messen.py <video.mp4> <start-s> <dauer-s> <y0> <y1> <x0> <x1>

Im Ausschnitt [y0:y1, x0:x1] wird je Frame die Streuung dunkler Pixel um ihren Schwerpunkt berechnet.
Bei einem gleichmäßigen Zoom wächst sie in kleinen, ähnlichen Schritten. Viele Nullschritte mit
Sprüngen alle paar Frames bedeuten: Text rastet aufs Pixelraster (Abhilfe: will-change: transform).
Ausschnitt so wählen, dass nur ruhiger Text drin ist (keine Partikel, keine Einblendungen).
"""
import subprocess, sys
import numpy as np

f, t0, d = sys.argv[1], float(sys.argv[2]), float(sys.argv[3])
y0, y1, x0, x1 = map(int, sys.argv[4:8])
probe = subprocess.run(["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries", "stream=width,height", "-of", "csv=p=0", f],
                       capture_output=True, text=True).stdout.strip().split(",")
W, H = int(probe[0]), int(probe[1])
raw = subprocess.run(["ffmpeg", "-loglevel", "error", "-ss", str(t0), "-t", str(d), "-i", f, "-f", "rawvideo", "-pix_fmt", "gray", "-"],
                     capture_output=True).stdout
fr = np.frombuffer(raw, np.uint8).reshape(-1, H, W).astype(float)[:, y0:y1, x0:x1]
w = np.clip(200 - fr, 0, None)
ys = np.arange(fr.shape[1])[None, :, None]
cy = (w * ys).sum((1, 2)) / w.sum((1, 2))
sp = np.sqrt((w * (ys - cy[:, None, None]) ** 2).sum((1, 2)) / w.sum((1, 2)))
ds = np.diff(sp)
print(f"Frames {len(sp)}, Streuung {sp[0]:.3f} -> {sp[-1]:.3f}")
print(f"Schritt Mittel {ds.mean():.4f}  Streuung {ds.std():.4f}  min {ds.min():.4f}  max {ds.max():.4f}")
big = np.abs(ds) > max(4 * np.abs(ds.mean()), 0.02)
print(f"Sprünge {big.sum()} (Frames {[int(i) for i in np.where(big)[0][:12]]})")
print("Bewertung:", "ruckelt (Pixelraster)" if big.sum() >= 3 and np.median(np.abs(ds)) < np.abs(ds).max() / 6 else "gleichmäßig")
