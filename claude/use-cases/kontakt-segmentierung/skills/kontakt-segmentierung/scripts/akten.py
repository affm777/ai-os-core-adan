#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
akten.py: Firmenakten der Outreach-Pipeline anlegen, ergänzen, Status pflegen und den Stand zeigen.

Vier Aufrufe (alle Pfade relativ zum Arbeitsordner, Standard ist ./kontakte):

  1. Akten anlegen oder ergänzen (Phase C)
       python3 akten.py anlegen [--kontakte kontakte] [--arbeit <ordner>] [--segmente <segmente.md>]
                                [--datum JJJJ-MM-TT] [--cloud-ok]
     Liest kontakte.json und zuordnung-*.json aus Phase A (Standard: der neueste
     Ordner unter kontakte/arbeit/) und legt je Firma mit mindestens einem A- oder
     B-Kontakt eine Akte kontakte/firmen/<firma>.md an. Bestehende Akten werden nie
     überschrieben. Fehlt dort ein A- oder B-Kontakt, wird nur seine Zeile an die
     Kontakttabelle angehängt und im Verlauf vermerkt. Ein zweiter Lauf ohne neue
     Kontakte ändert keine Datei.

  2. Ansprache-Tabelle anlegen oder ergänzen (Phase E)
       python3 akten.py ansprache [--kontakte kontakte] [--cloud-ok]
     Baut aus allen Akten kontakte/anlass/ansprache.md (eine Zeile je Kontakt,
     A-Firmen zuerst). Bestehende Zeilen bleiben unverändert, neue kommen ans Ende.

  3. Status setzen (Phase D bis F)
       python3 akten.py status --firma <slug> --wert <status> [--kontakt "<Name>"] [--datum JJJJ-MM-TT]
     Ohne --kontakt: Status der Akte. Mit --kontakt: Status der Zeile in
     ansprache.md, die Akte rückt dabei höchstens vor, nie zurück.

  4. Stand zeigen (Wiedereinstieg)
       python3 akten.py stand [--kontakte kontakte]
     Gibt als JSON aus, welche Phasen erledigt sind und was als Nächstes dran ist.

Nur Standardbibliothek. Sendet nichts ins Netz, löscht nichts.
"""

import argparse
import datetime as dt
import glob
import json
import os
import re
import sys
import unicodedata

sys.dont_write_bytecode = True
HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
from einlesen import cloud_hinweis, firma_schluessel  # noqa: E402
import schreiben  # noqa: E402

FIRMEN_STATUS = ["offen", "recherchiert", "Entwurf", "angeschrieben", "geantwortet", "gestrichen"]
KONTAKT_STATUS = ["offen", "Entwurf", "angeschrieben", "geantwortet", "gestrichen"]
REIHENFOLGE = {"offen": 0, "recherchiert": 1, "Entwurf": 2, "angeschrieben": 3, "geantwortet": 4}

LEER_RECHERCHE = "Noch nicht recherchiert."
LEER_ANKNUEPFUNG = "Noch keine."
LEER_ENTWURF = "Noch kein Entwurf."
OFFEN = "offen"

KOPF_KONTAKTE = "| Name | Position | Segment | Priorität | Profil-Link | E-Mail (aus Export) |"
KOPF_ANSPRACHE = "| Nr | Kontakt | Firma | Priorität | Kanal | Kontext | Status |"


def fehler(text, code=2):
    print(json.dumps({"fehler": text}, ensure_ascii=False, indent=1))
    sys.exit(code)


def zelle(wert):
    """Text für eine Markdown-Tabellenzelle: einzeilig, ohne senkrechten Strich."""
    return re.sub(r"\s+", " ", str(wert or "")).replace("|", "/").strip()


def zellen(zeile):
    teile = zeile.strip().strip("|").split("|")
    return [t.strip() for t in teile]


def ist_trennzeile(zeile):
    return bool(re.match(r"^\|\s*:?-{3,}", zeile.strip()))


def slug(name):
    s = str(name or "").lower()
    for alt, neu in (("ä", "ae"), ("ö", "oe"), ("ü", "ue"), ("ß", "ss")):
        s = s.replace(alt, neu)
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode("ascii")
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return s[:60].strip("-") or "firma"


def datum_de(iso):
    try:
        return dt.date.fromisoformat(iso).strftime("%d.%m.%Y")
    except (TypeError, ValueError):
        return iso


def cloud_pruefen(pfad, cloud_ok):
    wolke = cloud_hinweis(pfad)
    if wolke and not cloud_ok:
        fehler(wolke + " Die Akten mit Namen und Positionen würden mitsynchronisiert. Vorschlag: ein lokaler "
               "Ordner wie ~/Kontakte-lokal. Wer trotzdem hier arbeiten will, startet erneut mit --cloud-ok.", 3)


# ---------------------------------------------------------------------------
# Akte lesen und schreiben
# ---------------------------------------------------------------------------

def abschnitte(zeilen):
    """Gibt {Überschrift: (start, ende)} für alle ##-Abschnitte zurück (start = Zeile der Überschrift)."""
    marken = [(i, z[3:].strip()) for i, z in enumerate(zeilen) if z.startswith("## ")]
    bereiche = {}
    for n, (i, titel) in enumerate(marken):
        ende = marken[n + 1][0] if n + 1 < len(marken) else len(zeilen)
        bereiche[titel] = (i, ende)
    return bereiche


def feld(zeilen, name):
    muster = re.compile(r"^\*\*%s:\*\*\s*(.*)$" % re.escape(name))
    for i, z in enumerate(zeilen):
        m = muster.match(z)
        if m:
            return i, m.group(1).strip()
    return -1, ""


def abschnitt_text(zeilen, bereiche, titel):
    if titel not in bereiche:
        return ""
    a, e = bereiche[titel]
    return "\n".join(zeilen[a + 1:e]).strip()


def akte_lesen(pfad):
    zeilen = open(pfad, encoding="utf-8").read().split("\n")
    bereiche = abschnitte(zeilen)
    titel = zeilen[0][2:].strip() if zeilen and zeilen[0].startswith("# ") else os.path.basename(pfad)
    titel = re.sub(r"^Firmenakte\s+", "", titel)
    kontakte = []
    if "Kontakte aus dem Export" in bereiche:
        a, e = bereiche["Kontakte aus dem Export"]
        for z in zeilen[a + 1:e]:
            if z.startswith("|") and not ist_trennzeile(z) and z.strip() != KOPF_KONTAKTE:
                c = zellen(z)
                while len(c) < 6:
                    c.append("")
                kontakte.append({"name": c[0], "position": c[1], "segment": c[2], "prioritaet": c[3],
                                 "url": c[4], "email": c[5]})
    stammdaten = {}
    if "Stammdaten" in bereiche:
        a, e = bereiche["Stammdaten"]
        for z in zeilen[a + 1:e]:
            if z.startswith("|") and not ist_trennzeile(z):
                c = zellen(z)
                if len(c) >= 2 and c[0] != "Feld":
                    stammdaten[c[0]] = c[1]
    recherche = abschnitt_text(zeilen, bereiche, "Recherche")
    anknuepfung = abschnitt_text(zeilen, bereiche, "Anknüpfungspunkte")
    entwurf = abschnitt_text(zeilen, bereiche, "Entwurf")
    return {
        "slug": os.path.splitext(os.path.basename(pfad))[0],
        "pfad": pfad,
        "firma": titel,
        "status": feld(zeilen, "Status")[1] or OFFEN,
        "prioritaet": (feld(zeilen, "Firmenpriorität")[1] or "B")[:1].upper(),
        "kontakte": kontakte,
        "stammdaten": stammdaten,
        "recherche": bool(recherche) and not recherche.startswith(LEER_RECHERCHE),
        "anknuepfung": bool(anknuepfung) and not anknuepfung.startswith(LEER_ANKNUEPFUNG),
        "entwurf": bool(entwurf) and not entwurf.startswith(LEER_ENTWURF),
    }


def kontakt_schluessel(k):
    url = (k.get("url") or "").strip().lower()
    return url if url else (k.get("name") or "").strip().lower()


def kontakt_zeile(z):
    name = ("%s %s" % (z["vorname"], z["nachname"])).strip()
    return "| %s | %s | %s | %s | %s | %s |" % (zelle(name), zelle(z["position"]) or "(leer)", zelle(z["segment"]),
                                               z["prioritaet"], zelle(z["url"]), zelle(z["email"]))


def akte_text(firma, prio, leute, quelle, datum):
    z = ["# Firmenakte %s" % zelle(firma), "",
         "**Status:** offen", "",
         "**Firmenpriorität:** %s" % prio, "",
         "Diese Akte entsteht aus der Segmentierung und wird Schritt für Schritt ergänzt. Recherche nur aus "
         "öffentlichen Firmenquellen, je Fakt mit Quelle und Datum. Nichts davon wird automatisch versendet.", "",
         "## Stammdaten", "",
         "| Feld | Wert |", "|---|---|",
         "| Name | %s |" % zelle(firma),
         "| Branche | %s |" % OFFEN,
         "| Größe | %s |" % OFFEN,
         "| Website | %s |" % OFFEN,
         "| Standort | %s |" % OFFEN, "",
         "## Kontakte aus dem Export", "",
         KOPF_KONTAKTE, "|---|---|---|---|---|---|"]
    z += [kontakt_zeile(p) for p in leute]
    z += ["", "## Recherche", "", LEER_RECHERCHE, "",
          "## Anknüpfungspunkte", "", LEER_ANKNUEPFUNG, "",
          "## Entwurf", "", LEER_ENTWURF, "",
          "## Verlauf", "",
          "- %s Akte angelegt aus der %s, %d Kontakt%s mit Priorität A oder B" % (
              datum_de(datum), quelle, len(leute), "" if len(leute) == 1 else "e"),
          ""]
    return "\n".join(z)


def akte_ergaenzen(pfad, neue, datum):
    """Hängt neue Kontaktzeilen an die Tabelle und eine Zeile an den Verlauf. Sonst bleibt alles unverändert."""
    zeilen = open(pfad, encoding="utf-8").read().split("\n")
    bereiche = abschnitte(zeilen)
    if "Kontakte aus dem Export" not in bereiche:
        return False
    a, e = bereiche["Kontakte aus dem Export"]
    letzte = None
    for i in range(a + 1, e):
        if zeilen[i].startswith("|"):
            letzte = i
    if letzte is None:
        einfuegen = [KOPF_KONTAKTE, "|---|---|---|---|---|---|"] + [kontakt_zeile(p) for p in neue]
        pos = a + 2 if a + 1 < len(zeilen) and zeilen[a + 1] == "" else a + 1
    else:
        einfuegen = [kontakt_zeile(p) for p in neue]
        pos = letzte + 1
    zeilen[pos:pos] = einfuegen
    vermerk = "- %s %d Kontakt%s aus neuer Segmentierung ergänzt" % (datum_de(datum), len(neue),
                                                                     "" if len(neue) == 1 else "e")
    zeilen = verlauf_anhaengen(zeilen, vermerk)
    with open(pfad, "w", encoding="utf-8") as f:
        f.write("\n".join(zeilen))
    return True


def verlauf_anhaengen(zeilen, vermerk):
    bereiche = abschnitte(zeilen)
    if "Verlauf" not in bereiche:
        while zeilen and zeilen[-1] == "":
            zeilen.pop()
        return zeilen + ["", "## Verlauf", "", vermerk, ""]
    a, e = bereiche["Verlauf"]
    pos = e
    while pos > a + 1 and zeilen[pos - 1] == "":
        pos -= 1
    zeilen[pos:pos] = [vermerk]
    return zeilen


def akten_laden(ordner):
    return [akte_lesen(p) for p in sorted(glob.glob(os.path.join(ordner, "*.md")))]


# ---------------------------------------------------------------------------
# 1. anlegen
# ---------------------------------------------------------------------------

def neuester_arbeitsordner(basis):
    kandidaten = []
    for d in glob.glob(os.path.join(basis, "arbeit", "*")):
        if os.path.isfile(os.path.join(d, "kontakte.json")) and glob.glob(os.path.join(d, "zuordnung-*.json")):
            kandidaten.append((os.path.basename(d), os.path.getmtime(d), d))
    if not kandidaten:
        return None
    return sorted(kandidaten)[-1][2]


def anlegen(args):
    basis = args.kontakte
    cloud_pruefen(basis, args.cloud_ok)
    arbeit = args.arbeit or neuester_arbeitsordner(basis)
    if not arbeit:
        fehler("Keine fertige Segmentierung gefunden (kontakte/arbeit/<datum>/ mit zuordnung-*.json). "
               "Zuerst Phase A ausführen.")
    ns = argparse.Namespace(arbeit=arbeit, segmente=args.segmente)
    meta, zeilen, segmente, _anrede, _texte = schreiben.laden(ns)

    gruppen, ohne_firma = {}, 0
    for z in zeilen:
        if z["prioritaet"] not in ("A", "B"):
            continue
        schluessel = firma_schluessel(z["firma"])
        if not schluessel or schluessel in schreiben.KEINE_FIRMA:
            ohne_firma += 1
            continue
        gruppen.setdefault(slug(schluessel), []).append(z)

    ordner = os.path.join(basis, "firmen")
    os.makedirs(ordner, exist_ok=True)
    quelle = "Segmentierung vom %s (Quelle %s)" % (datum_de(os.path.basename(os.path.normpath(arbeit))),
                                                 meta.get("quelle", "Export"))
    neu, ergaenzt, unveraendert, hinweise = [], [], [], []
    for s, leute in sorted(gruppen.items(), key=lambda kv: (min(p["prioritaet"] for p in kv[1]), kv[0])):
        prio = min(p["prioritaet"] for p in leute)
        pfad = os.path.join(ordner, s + ".md")
        if not os.path.exists(pfad):
            with open(pfad, "w", encoding="utf-8") as f:
                f.write(akte_text(leute[0]["firma"], prio, leute, quelle, args.datum))
            neu.append({"akte": s, "firma": leute[0]["firma"], "prioritaet": prio, "kontakte": len(leute)})
            continue
        akte = akte_lesen(pfad)
        vorhanden = {kontakt_schluessel(k) for k in akte["kontakte"]}
        fehlend = [p for p in leute if kontakt_schluessel(
            {"url": p["url"], "name": ("%s %s" % (p["vorname"], p["nachname"])).strip()}) not in vorhanden]
        if fehlend and akte_ergaenzen(pfad, fehlend, args.datum):
            ergaenzt.append({"akte": s, "neue_kontakte": len(fehlend)})
        else:
            unveraendert.append(s)
        if prio < akte["prioritaet"]:
            hinweise.append("%s: Segmentierung ergibt jetzt Priorität %s, die Akte sagt %s. Nicht geändert."
                            % (s, prio, akte["prioritaet"]))

    print(json.dumps({
        "ordner": ordner,
        "quelle": arbeit,
        "akten_neu": neu,
        "akten_ergaenzt": ergaenzt,
        "akten_unveraendert": len(unveraendert),
        "a_b_kontakte_ohne_firma": ohne_firma,
        "hinweise": hinweise,
    }, ensure_ascii=False, indent=1))


# ---------------------------------------------------------------------------
# 2. ansprache
# ---------------------------------------------------------------------------

def ansprache_lesen(pfad):
    if not os.path.isfile(pfad):
        return [], []
    zeilen = open(pfad, encoding="utf-8").read().split("\n")
    eintraege = []
    for z in zeilen:
        if z.startswith("|") and not ist_trennzeile(z) and z.strip() != KOPF_ANSPRACHE:
            c = zellen(z)
            while len(c) < 7:
                c.append("")
            eintraege.append({"nr": c[0], "kontakt": c[1], "firma": c[2], "prioritaet": c[3], "kanal": c[4],
                              "kontext": c[5], "status": c[6]})
    return zeilen, eintraege


def ansprache(args):
    basis = args.kontakte
    cloud_pruefen(basis, args.cloud_ok)
    akten = akten_laden(os.path.join(basis, "firmen"))
    if not akten:
        fehler("Noch keine Firmenakten in kontakte/firmen/. Zuerst Phase C (akten.py anlegen) ausführen.")
    pfad = os.path.join(basis, "anlass", "ansprache.md")
    zeilen, eintraege = ansprache_lesen(pfad)
    vorhanden = {(e["kontakt"].lower(), e["firma"].lower()) for e in eintraege}
    nr = max([int(e["nr"]) for e in eintraege if e["nr"].isdigit()] or [0])

    neue = []
    akten.sort(key=lambda a: (a["prioritaet"], a["firma"].lower()))
    for a in akten:
        if a["status"] == "gestrichen":
            continue
        for k in sorted(a["kontakte"], key=lambda k: (k["prioritaet"], k["name"].lower())):
            if (k["name"].lower(), zelle(a["firma"]).lower()) in vorhanden:
                continue
            nr += 1
            kanal = "E-Mail" if k["email"] else "LinkedIn"
            neue.append("| %d | %s | %s | %s | %s | %s | %s |" % (nr, zelle(k["name"]), zelle(a["firma"]),
                                                                 k["prioritaet"], kanal, OFFEN, OFFEN))
    if not zeilen:
        kopf = ["# Ansprache", "",
                "Eine Zeile je Kontakt aus den Firmenakten, A-Firmen zuerst. Claude füllt die Spalte Kontext mit "
                "Stichworten aus den Anknüpfungspunkten der Akte vor, du korrigierst sie. Kanal ist LinkedIn, außer "
                "der Export enthält eine E-Mail-Adresse. Status ist offen, Entwurf, angeschrieben, geantwortet oder "
                "gestrichen.", "",
                KOPF_ANSPRACHE, "|---:|---|---|---|---|---|---|"]
        os.makedirs(os.path.dirname(pfad), exist_ok=True)
        with open(pfad, "w", encoding="utf-8") as f:
            f.write("\n".join(kopf + neue) + "\n")
    elif neue:
        tabelle = [i for i, z in enumerate(zeilen) if z.startswith("|")]
        if tabelle:
            zeilen[tabelle[-1] + 1:tabelle[-1] + 1] = neue
        else:
            while zeilen and zeilen[-1] == "":
                zeilen.pop()
            zeilen += ["", KOPF_ANSPRACHE, "|---:|---|---|---|---|---|---|"] + neue + [""]
        with open(pfad, "w", encoding="utf-8") as f:
            f.write("\n".join(zeilen))
    print(json.dumps({"datei": pfad, "zeilen_neu": len(neue), "zeilen_gesamt": len(eintraege) + len(neue),
                      "davon_email": sum(1 for z in neue if "| E-Mail |" in z)}, ensure_ascii=False, indent=1))


# ---------------------------------------------------------------------------
# 3. status
# ---------------------------------------------------------------------------

def status(args):
    basis = args.kontakte
    pfad = os.path.join(basis, "firmen", args.firma + ".md")
    if not os.path.isfile(pfad):
        fehler("Akte %s gibt es nicht." % args.firma)
    zeilen = open(pfad, encoding="utf-8").read().split("\n")
    i, alt = feld(zeilen, "Status")
    if i < 0:
        fehler("In der Akte %s fehlt die Zeile **Status:**." % args.firma)
    ergebnis = {"akte": args.firma}

    if args.kontakt:
        if args.wert not in KONTAKT_STATUS:
            fehler("Kontakt-Status muss einer von %s sein." % ", ".join(KONTAKT_STATUS))
        firma = akte_lesen(pfad)["firma"]
        apfad = os.path.join(basis, "anlass", "ansprache.md")
        azeilen, _ = ansprache_lesen(apfad)
        treffer = None
        for n, z in enumerate(azeilen):
            if z.startswith("|") and not ist_trennzeile(z) and z.strip() != KOPF_ANSPRACHE:
                c = zellen(z)
                if len(c) >= 7 and c[1].lower() == args.kontakt.strip().lower() and c[2].lower() == zelle(firma).lower():
                    treffer = n
                    break
        if treffer is None:
            fehler("Kontakt %s bei %s steht nicht in ansprache.md." % (args.kontakt, firma))
        c = zellen(azeilen[treffer])
        ergebnis["kontakt_alt"], c[6] = c[6], args.wert
        azeilen[treffer] = "| " + " | ".join(c) + " |"
        with open(apfad, "w", encoding="utf-8") as f:
            f.write("\n".join(azeilen))
        ergebnis["kontakt"] = args.kontakt
        ergebnis["kontakt_neu"] = args.wert
        vermerk = "- %s %s: %s" % (datum_de(args.datum), zelle(args.kontakt), args.wert)
        neu_akte = args.wert if REIHENFOLGE.get(args.wert, -1) > REIHENFOLGE.get(alt, 0) else alt
    else:
        if args.wert not in FIRMEN_STATUS:
            fehler("Akten-Status muss einer von %s sein." % ", ".join(FIRMEN_STATUS))
        vermerk = "- %s Status %s" % (datum_de(args.datum), args.wert)
        neu_akte = args.wert

    zeilen[i] = "**Status:** %s" % neu_akte
    zeilen = verlauf_anhaengen(zeilen, vermerk)
    with open(pfad, "w", encoding="utf-8") as f:
        f.write("\n".join(zeilen))
    ergebnis["akte_alt"], ergebnis["akte_neu"] = alt, neu_akte
    print(json.dumps(ergebnis, ensure_ascii=False, indent=1))


# ---------------------------------------------------------------------------
# 4. stand
# ---------------------------------------------------------------------------

def bestaetigt(pfad):
    if not os.path.isfile(pfad):
        return False
    _, wert = feld(open(pfad, encoding="utf-8").read().split("\n"), "Bestätigt")
    return wert.lower().startswith("ja")


def stand(args):
    basis = args.kontakte
    if not os.path.isdir(basis):
        print(json.dumps({"ordner": basis, "vorhanden": False, "naechster_schritt": "A"}, ensure_ascii=False, indent=1))
        return
    segm = sorted(os.path.basename(p) for p in glob.glob(os.path.join(basis, "ausgabe", "segmentierung-*.xlsx")))
    arbeit = neuester_arbeitsordner(basis)
    anlass = os.path.join(basis, "anlass", "ANLASS.md")
    anlass_recherche = False
    if os.path.isfile(anlass):
        z = open(anlass, encoding="utf-8").read().split("\n")
        anlass_recherche = "Recherche" in abschnitte(z)
    akten = akten_laden(os.path.join(basis, "firmen"))
    aktiv = [a for a in akten if a["status"] != "gestrichen"]
    ohne_recherche = sorted([a for a in aktiv if not a["recherche"]], key=lambda a: (a["prioritaet"], a["slug"]))
    struktur = os.path.join(basis, "anlass", "STRUKTUR.md")
    apfad = os.path.join(basis, "anlass", "ansprache.md")
    _, eintraege = ansprache_lesen(apfad)
    kstatus = {}
    for e in eintraege:
        kstatus[e["status"] or OFFEN] = kstatus.get(e["status"] or OFFEN, 0) + 1
    entwuerfe = sorted(os.path.basename(p) for p in glob.glob(os.path.join(basis, "ausgabe", "entwuerfe-*.md")))
    astatus = {}
    for a in akten:
        astatus[a["status"]] = astatus.get(a["status"], 0) + 1

    if not arbeit:
        naechster = "A"
    elif not bestaetigt(anlass):
        naechster = "B"
    elif not akten:
        naechster = "C"
    elif ohne_recherche:
        naechster = "D"
    elif not bestaetigt(struktur) or not eintraege:
        naechster = "E"
    elif kstatus.get(OFFEN, 0):
        naechster = "F"
    else:
        naechster = "fertig"

    print(json.dumps({
        "ordner": basis,
        "vorhanden": True,
        "A_segmentierung": {"dateien": segm, "arbeitsordner": arbeit},
        "B_anlass": {"datei": os.path.isfile(anlass), "bestaetigt": bestaetigt(anlass), "recherche": anlass_recherche},
        "C_akten": {"anzahl": len(akten), "status": astatus,
                    "a_firmen": sum(1 for a in aktiv if a["prioritaet"] == "A")},
        "D_recherche": {"recherchiert": len(aktiv) - len(ohne_recherche), "offen": len(ohne_recherche),
                        "naechste": [a["slug"] for a in ohne_recherche[:10]]},
        "E_struktur": {"struktur": os.path.isfile(struktur), "bestaetigt": bestaetigt(struktur),
                       "ansprache_zeilen": len(eintraege),
                       "kontext_offen": sum(1 for e in eintraege if e["kontext"] in ("", OFFEN))},
        "F_entwuerfe": {"dateien": entwuerfe, "kontakte_status": kstatus},
        "naechster_schritt": naechster,
    }, ensure_ascii=False, indent=1))


def main():
    ap = argparse.ArgumentParser(description="Firmenakten der Outreach-Pipeline")
    basis = argparse.ArgumentParser(add_help=False)
    basis.add_argument("--kontakte", default="kontakte", help="Basisordner (Standard ./kontakte)")
    unter = ap.add_subparsers(dest="befehl")

    p = unter.add_parser("anlegen", parents=[basis], help="Akten aus der Segmentierung anlegen oder ergänzen")
    p.add_argument("--arbeit", help="Arbeitsordner aus Phase A (Standard: der neueste)")
    p.add_argument("--segmente", default=os.path.join(os.path.dirname(HIER), "segmente.md"))
    p.add_argument("--datum", default=dt.date.today().isoformat())
    p.add_argument("--cloud-ok", action="store_true")

    p = unter.add_parser("ansprache", parents=[basis], help="ansprache.md anlegen oder ergänzen")
    p.add_argument("--cloud-ok", action="store_true")

    p = unter.add_parser("status", parents=[basis], help="Status einer Akte oder eines Kontakts setzen")
    p.add_argument("--firma", required=True, help="Dateiname der Akte ohne .md")
    p.add_argument("--wert", required=True)
    p.add_argument("--kontakt", help="Name wie in ansprache.md")
    p.add_argument("--datum", default=dt.date.today().isoformat())

    unter.add_parser("stand", parents=[basis], help="Stand der Pipeline als JSON")

    args = ap.parse_args()
    if args.befehl == "anlegen":
        anlegen(args)
    elif args.befehl == "ansprache":
        ansprache(args)
    elif args.befehl == "status":
        status(args)
    elif args.befehl == "stand":
        stand(args)
    else:
        ap.print_help()


if __name__ == "__main__":
    main()
