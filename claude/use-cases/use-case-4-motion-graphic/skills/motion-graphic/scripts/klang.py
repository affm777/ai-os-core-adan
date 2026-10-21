"""Legt Geräusche und Musik framegenau nach derselben Timeline an, aus der auch das Bild liest.

Standard sind Dateien von ElevenLabs (vorher mit sfx_zuschnitt.sh auf ihren Kern geschnitten).
Nur ohne ElevenLabs-Anbindung und auf Wunsch des Nutzers synthetisiert es Effekte und Beat selbst.

    python -I klang.py <film>/timeline.js <ausgabe-ordner> [--stimme stimme.wav]

timeline.js ist die eine Zeitquelle des Films. Sie beginnt mit `window.TL = ` und enthält danach
reines JSON (keine Kommentare, keine Funktionen), damit Komposition und dieses Script dieselben
Zeiten lesen. Felder, die dieses Script nutzt:

    "dauer": 12,                       Gesamtlänge in Sekunden
    "bpm": 120,                        Tempo des Beats (Standard 120)
    "drop": 4.0,                       ab hier volle Musik, davor nur Intro (optional)
    "musik": {"art": "datei", "pfad": "ton/musik.wav", "db": -6}   ElevenLabs-Musik oder eigene Datei
             {"art": "beat", "grundton": 55, "intro_db": -12}    synthetisch (nur Ersatz)
             null                                                keine Musik
    "klang": [ {"t": 0.4, "datei": "ton/klick.wav", "db": -6}, {"t": 1.1, "typ": "ding", "ton": 1318}, ... ]

Ein Ereignis mit "datei" legt diese Datei bei t an (Pfad relativ zur timeline.js, WAV 48 kHz).
Ein Ereignis mit "typ" synthetisiert den Klang (Ersatz ohne ElevenLabs).

Synthetische Typen: klick, tipp, ding, pop, whoosh, glas, aufprall, riser, powerdown, schimmer.
Optionale Felder je Ereignis: db (Pegel), ton (Hz), dauer (s, bei whoosh, riser, powerdown), pan (-1 bis 1).
Ein riser endet bei t (er beginnt dauer Sekunden früher), alle anderen beginnen bei t.

Schreibt sfx.wav, musik.wav (falls Musik) und mix-roh.wav (48 kHz, Stereo, 24 bit). Mit --stimme
wird die Stimme in den Mix gelegt und die Musik in Sprechphasen um 15 dB abgesenkt.
mix-roh.wav geht danach in master.sh (-14 LUFS, -1 dBTP), geprüft wird mit lautheit.sh.
Deterministisch: gleicher Input, gleiche Datei (geseedetes Rauschen).
"""
import json
import pathlib
import sys

import numpy as np
import soundfile as sf
from scipy.signal import butter, sosfilt

SR = 48000
RNG = np.random.default_rng(7)


def db(x):
    return 10 ** (x / 20)


def t_arr(dauer):
    return np.arange(int(dauer * SR)) / SR


def filt(x, art, f):
    sos = butter(2 if art != "band" else 2, f, btype={"tief": "low", "hoch": "high", "band": "band"}[art], fs=SR, output="sos")
    return sosfilt(sos, x)


def env(n, a, d):
    """Hüllkurve: a Sekunden Anstieg, dann exponentieller Abfall mit Zeitkonstante d."""
    t = np.arange(n) / SR
    e = np.exp(-np.maximum(t - a, 0) / d)
    if a > 0:
        e *= np.minimum(t / a, 1)
    return e


def rausch(n):
    return RNG.standard_normal(n)


def sweep(f0, f1, dauer, kurve="exp"):
    t = t_arr(dauer)
    f = f0 * (f1 / f0) ** (t / dauer) if kurve == "exp" else f0 + (f1 - f0) * t / dauer
    return np.sin(2 * np.pi * np.cumsum(f) / SR)


# ---------------------------------------------------------------- Effekte
def klick(e):
    n = int(0.06 * SR)
    burst = filt(rausch(n), "hoch", 2500) * env(n, 0, 0.004)
    body = np.sin(2 * np.pi * e.get("ton", 1900) * t_arr(0.06)) * env(n, 0, 0.012) * 0.5
    return burst + body


def tipp(e):
    return filt(klick(e), "tief", 5000) * 0.6


def ding(e):
    f, n = e.get("ton", 1318), int(1.2 * SR)
    t = t_arr(1.2)
    x = np.sin(2 * np.pi * f * t) * env(n, 0.002, 0.35) + 0.35 * np.sin(2 * np.pi * f * 2.76 * t) * env(n, 0.002, 0.12)
    return x * 0.8


def pop(e):
    n = int(0.09 * SR)
    return sweep(e.get("ton", 620), 180, 0.09) * env(n, 0.001, 0.03)


def whoosh(e):
    d = e.get("dauer", 0.5)
    n = int(d * SR)
    x = rausch(n)
    halb = n // 2
    a = filt(x[:halb], "band", [300, 1400])
    b = filt(x[halb:], "band", [900, 4200])
    y = np.concatenate([a, b])
    form = np.sin(np.pi * np.arange(n) / n) ** 2
    return y * form * 0.9


def glas(e):
    n = int(0.25 * SR)
    t = t_arr(0.25)
    f = e.get("ton", 1850)
    x = np.sin(2 * np.pi * f * t) * env(n, 0, 0.05) + 0.6 * np.sin(2 * np.pi * f * 1.47 * t) * env(n, 0, 0.03)
    return x + filt(rausch(n), "hoch", 4000) * env(n, 0, 0.003) * 0.4


def aufprall(e):
    n = int(0.9 * SR)
    sub = sweep(e.get("ton", 90), 38, 0.9) * env(n, 0.002, 0.25)
    knall = filt(rausch(n), "tief", 1800) * env(n, 0, 0.05) * 0.6
    return sub + knall


def riser(e):
    d = e.get("dauer", 1.5)
    n = int(d * SR)
    y = filt(rausch(n), "hoch", 800) * 0.4 + sweep(e.get("ton", 220), e.get("ton", 220) * 4, d) * 0.3
    return y * (np.arange(n) / n) ** 2


def powerdown(e):
    d = e.get("dauer", 0.7)
    n = int(d * SR)
    return filt(sweep(e.get("ton", 420), 40, d), "tief", 2500) * env(n, 0.005, d / 2.5)


def schimmer(e):
    n, f = int(1.6 * SR), e.get("ton", 2093)
    t = t_arr(1.6)
    x = sum(np.sin(2 * np.pi * f * k * t + k) * env(n, 0.03 * k, 0.5) / k for k in (1, 1.5, 2, 3))
    return x * 0.4


EFFEKTE = {"klick": (klick, -16), "tipp": (tipp, -20), "ding": (ding, -19), "pop": (pop, -16), "whoosh": (whoosh, -18),
           "glas": (glas, -18), "aufprall": (aufprall, -9), "riser": (riser, -20), "powerdown": (powerdown, -16),
           "schimmer": (schimmer, -21)}


# ---------------------------------------------------------------- Beat
def beat(dauer, bpm, drop, grundton, intro_db):
    n = int(dauer * SR)
    voll = np.zeros(n)
    intro = np.zeros(n)
    sl = 60 / bpm

    def setze(spur, start, x):
        i = int(start * SR)
        if i >= n:
            return
        x = x[: n - i]
        spur[i:i + len(x)] += x

    kick = sweep(150, 45, 0.3) * env(int(0.3 * SR), 0.001, 0.09)
    hat_n = int(0.04 * SR)
    snare_n = int(0.22 * SR)
    akkord = [1, 1.2, 1.5, 1.8]  # Moll-Septakkord über dem Grundton
    folge = [1, 1, 1.335, 1.122]  # Grundton, Grundton, Quarte, große Sekunde je Takt
    b = 0
    while b * sl < dauer:
        t0 = b * sl
        takt = (b // 4) % 4
        root = grundton * folge[takt]
        setze(voll, t0, kick)
        hat = filt(rausch(hat_n), "hoch", 7000) * env(hat_n, 0, 0.012) * 0.35
        setze(voll, t0 + sl / 2, hat)
        setze(intro, t0 + sl / 2, hat * 0.5)
        if b % 4 in (1, 3):
            sn = filt(rausch(snare_n), "band", [180, 5000]) * env(snare_n, 0, 0.06) * 0.6
            setze(voll, t0, sn)
        for k in (0, 1):
            bn = int(sl / 2 * SR)
            tt = np.arange(bn) / SR
            saw = 2 * ((tt * root * 2) % 1) - 1
            setze(voll, t0 + k * sl / 2, filt(saw, "tief", 400) * env(bn, 0.005, 0.12) * 0.5)
        if b % 4 == 0:
            pn = int(4 * sl * SR)
            tt = np.arange(pn) / SR
            pad = sum(2 * ((tt * root * 4 * a) % 1) - 1 for a in akkord) / 4
            pad = filt(pad, "tief", 1200) * np.minimum(np.minimum(tt / 0.4, 1), np.minimum((4 * sl - tt) / 0.4, 1)) * 0.22
            setze(voll, t0, pad)
            setze(intro, t0, filt(pad, "tief", 600) * 1.4)
        b += 1
    if drop is None:
        musik = voll
    else:
        i = int(drop * SR)
        musik = np.concatenate([intro[:i] * db(intro_db + 2), voll[i:]])
    aus = int(1.5 * SR)
    musik[-aus:] *= np.linspace(1, 0, aus)
    return musik


# ---------------------------------------------------------------- Ablauf
def lade_timeline(pfad):
    text = pathlib.Path(pfad).read_text(encoding="utf-8")
    return json.loads(text[text.index("{"): text.rindex("}") + 1])


def lade_wav(pfad):
    x, sr = sf.read(str(pfad), always_2d=True)
    if sr != SR:
        sys.exit(f"{pfad} hat {sr} Hz, erwartet {SR} Hz (mit sfx_zuschnitt.sh umwandeln).")
    return x if x.shape[1] == 2 else np.repeat(x[:, :1], 2, axis=1)


def stereo(x, pan=0.0):
    w = (pan + 1) * np.pi / 4
    return np.stack([x * np.cos(w), x * np.sin(w)], axis=1) * np.sqrt(2)


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    tl = lade_timeline(sys.argv[1])
    out = pathlib.Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)
    dauer = float(tl["dauer"])
    n = int(dauer * SR)

    basis = pathlib.Path(sys.argv[1]).resolve().parent
    sfx = np.zeros((n, 2))
    for e in tl.get("klang", []):
        start = e["t"]
        if "datei" in e:
            x2 = lade_wav(basis / e["datei"]) * db(e.get("db", 0))
            if e.get("pan"):
                x2 = stereo(x2.mean(axis=1), e["pan"]) / np.sqrt(2)
        else:
            fn, std = EFFEKTE[e["typ"]]
            x2 = stereo(fn(e) * db(e.get("db", std)), e.get("pan", 0.0))
            if e["typ"] == "riser":
                start -= e.get("dauer", 1.5)
        i = max(0, int(start * SR))
        x2 = x2[: n - i]
        sfx[i:i + len(x2)] += x2
    sf.write(out / "sfx.wav", sfx, SR, subtype="PCM_24")

    mix = sfx.copy()
    m = tl.get("musik")
    if m and m.get("art") in ("beat", "datei"):
        if m["art"] == "datei":
            mm = lade_wav(basis / m["pfad"]).mean(axis=1)[:n]
            musik = np.pad(mm, (0, n - len(mm))) * db(m.get("db", 0))
            aus = int(1.5 * SR)
            musik[-aus:] *= np.linspace(1, 0, aus)
        else:
            musik = beat(dauer, tl.get("bpm", 120), tl.get("drop"), m.get("grundton", 55), m.get("intro_db", -12)) * db(m.get("db", -3))
        if len(sys.argv) > 4 and sys.argv[3] == "--stimme":
            st, sr_st = sf.read(sys.argv[4], always_2d=True)
            if sr_st != SR:
                sys.exit(f"Stimme muss {SR} Hz haben, hat {sr_st} Hz (vorher mit ffmpeg -ar {SR} umwandeln).")
            st = st.mean(axis=1)[:n]
            st = np.pad(st, (0, n - len(st)))
            huelle = np.convolve(np.abs(st), np.ones(int(0.3 * SR)) / (0.3 * SR), mode="same")
            duck = np.where(huelle > 0.01, db(-15), 1.0)
            duck = np.convolve(duck, np.ones(int(0.15 * SR)) / (0.15 * SR), mode="same")
            musik = musik * duck
            mix += stereo(st) / np.sqrt(2)
        sf.write(out / "musik.wav", stereo(musik), SR, subtype="PCM_24")
        mix += stereo(musik)
    elif len(sys.argv) > 4 and sys.argv[3] == "--stimme":
        st, _ = sf.read(sys.argv[4], always_2d=True)
        st = st.mean(axis=1)[:n]
        mix += stereo(np.pad(st, (0, n - len(st)))) / np.sqrt(2)

    # Höhen ab 16 kHz weich abrollen (synthetische Kanten überschießen sonst zwischen den Samples),
    # sanft begrenzen und auf -3 dBFS Spitze bringen, die Endlautheit setzt master.sh.
    mix = np.stack([filt(mix[:, k], "tief", 16000) for k in (0, 1)], axis=1)
    mix = np.tanh(mix * 1.2) / 1.2
    spitze = np.max(np.abs(mix)) or 1.0
    mix *= db(-3) / spitze
    sf.write(out / "mix-roh.wav", mix, SR, subtype="PCM_24")
    print(f"sfx.wav, {'musik.wav, ' if m else ''}mix-roh.wav in {out} ({dauer:.1f} s, {len(tl.get('klang', []))} Effekte)")


if __name__ == "__main__":
    main()
