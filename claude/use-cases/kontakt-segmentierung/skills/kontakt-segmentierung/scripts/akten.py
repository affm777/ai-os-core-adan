#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
akten.py: Firmenakten der Outreach-Pipeline anlegen, ergänzen, Status pflegen und den Stand zeigen.

Sechs Aufrufe (alle Pfade relativ zum Arbeitsordner, Standard ist ./kontakte):

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
     Kanal ist immer LinkedIn, die Spalte "E-Mail möglich" zeigt nur, ob der
     Export eine Adresse enthält.

  3. Status setzen (Phase D bis F)
       python3 akten.py status --firma <slug> --wert <status> [--kontakt "<Name>"] [--datum JJJJ-MM-TT]
     Ohne --kontakt: Status der Akte. Mit --kontakt: Status der Zeile in
     ansprache.md, die Akte rückt dabei höchstens vor, nie zurück.

  4. Kanal setzen (Phase E)
       python3 akten.py kanal --firma <slug> --kontakt "<Name>" --wert LinkedIn|E-Mail [--bestaetigt]
     E-Mail nur mit Adresse aus dem Export und mit --bestaetigt (Nutzer hat
     Geschäftsbeziehung oder Einwilligung bestätigt). Vermerk im Verlauf der Akte.

  5. Phase als beendet merken (auch nach "Stopp, das reicht")
       python3 akten.py abschluss --phase <A-F> [--notiz "<text>"]
     Schreibt kontakte/.stand.json mit Phase, Datum und Notiz.

  6. Stand zeigen (Wiedereinstieg)
       python3 akten.py stand [--kontakte kontakte]
     Gibt als JSON aus, welche Phasen erledigt sind, was je Phase offen ist und
     was als Nächstes dran ist. Eine in D bewusst beendete Recherche hält den
     Wiedereinstieg nicht mehr in D fest.

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
from einlesen import cloud_hinweis, firma_schluessel, regeldatei  # noqa: E402
import schreiben  # noqa: E402

FIRMEN_STATUS = ["offen", "recherchiert", "Entwurf", "angeschrieben", "geantwortet", "gestrichen"]
KONTAKT_STATUS = ["offen", "Entwurf", "angeschrieben", "geantwortet", "gestrichen"]
REIHENFOLGE = {"offen": 0, "recherchiert": 1, "Entwurf": 2, "angeschrieben": 3, "geantwortet": 4}

LEER_RECHERCHE = "Noch nicht recherchiert."
LEER_ANKNUEPFUNG = "Noch keine."
LEER_ENTWURF = "Noch kein Entwurf."
OFFEN = "offen"

KOPF_KONTAKTE = "| Name | Position | Segment | Priorität | Profil-Link | E-Mail (aus Export) |"
KOPF_ANSPRACHE = "| Nr | Kontakt | Firma | Priorität | Kanal | E-Mail möglich | Kontext | Status |"
TRENN_ANSPRACHE = "|---:|---|---|---|---|---|---|---|"
KANAELE = ["LinkedIn", "E-Mail"]
PHASEN = ["A", "B", "C", "D", "E", "F"]
STAND_DATEI = ".stand.json"


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


def voller_name(z):
    """Name wie in Akte und ansprache.md, mit Titel (Dr., Prof.) davor, falls bekannt."""
    return " ".join(t for t in (z.get("titel", ""), z.get("vorname", ""), z.get("nachname", "")) if t).strip()


def kontakt_zeile(z):
    name = voller_name(z)
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
         "| Standort | %s |" % OFFEN]
    if leute[0].get("bestand"):
        z.append("| Bisheriger Partner | %s (aus der Partnerliste) |" % zelle(leute[0]["bestand"]))
    z += ["",
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
    ns = argparse.Namespace(arbeit=arbeit, segmente=regeldatei("segmente.md", basis, args.segmente))
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
            {"url": p["url"], "name": voller_name(p)}) not in vorhanden]
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

SPALTEN_ANSPRACHE = {"Nr": "nr", "Kontakt": "kontakt", "Firma": "firma", "Priorität": "prioritaet", "Kanal": "kanal",
                     "E-Mail möglich": "email_moeglich", "Kontext": "kontext", "Status": "status"}


def ansprache_lesen(pfad):
    """Gibt (zeilen, eintraege, spalten) zurück. Die Spalten kommen aus der Kopfzeile, so bleiben
    auch ältere Tabellen ohne Spalte "E-Mail möglich" lesbar. Jeder Eintrag kennt seine Zeilennummer."""
    if not os.path.isfile(pfad):
        return [], [], list(SPALTEN_ANSPRACHE.values())
    zeilen = open(pfad, encoding="utf-8").read().split("\n")
    spalten, eintraege = None, []
    for n, z in enumerate(zeilen):
        if not z.startswith("|") or ist_trennzeile(z):
            continue
        c = zellen(z)
        if spalten is None and c and c[0] == "Nr":
            spalten = [SPALTEN_ANSPRACHE.get(t, t) for t in c]
            continue
        if spalten is None:
            continue
        while len(c) < len(spalten):
            c.append("")
        e = dict(zip(spalten, c))
        e["_zeile"] = n
        eintraege.append(e)
    return zeilen, eintraege, spalten or list(SPALTEN_ANSPRACHE.values())


def ansprache_zeile(e, spalten):
    return "| " + " | ".join(e.get(s, "") for s in spalten) + " |"


def ansprache(args):
    basis = args.kontakte
    cloud_pruefen(basis, args.cloud_ok)
    akten = akten_laden(os.path.join(basis, "firmen"))
    if not akten:
        fehler("Noch keine Firmenakten in kontakte/firmen/. Zuerst Phase C (akten.py anlegen) ausführen.")
    pfad = os.path.join(basis, "anlass", "ansprache.md")
    zeilen, eintraege, spalten = ansprache_lesen(pfad)
    vorhanden = {(e.get("kontakt", "").lower(), e.get("firma", "").lower()) for e in eintraege}
    nr = max([int(e["nr"]) for e in eintraege if e.get("nr", "").isdigit()] or [0])

    neue = []
    akten.sort(key=lambda a: (a["prioritaet"], a["firma"].lower()))
    for a in akten:
        if a["status"] == "gestrichen":
            continue
        for k in sorted(a["kontakte"], key=lambda k: (k["prioritaet"], k["name"].lower())):
            if (k["name"].lower(), zelle(a["firma"]).lower()) in vorhanden:
                continue
            nr += 1
            neue.append({"nr": str(nr), "kontakt": zelle(k["name"]), "firma": zelle(a["firma"]),
                         "prioritaet": k["prioritaet"], "kanal": "LinkedIn",
                         "email_moeglich": "ja" if k["email"] else "nein", "kontext": OFFEN, "status": OFFEN})
    if not zeilen:
        kopf = ["# Ansprache", "",
                "Eine Zeile je Kontakt aus den Firmenakten, A-Firmen zuerst. Claude füllt die Spalte Kontext mit "
                "Stichworten aus den Anknüpfungspunkten der Akte vor, du korrigierst sie. Kanal ist immer LinkedIn. "
                "E-Mail möglich heißt nur, dass der Export eine Adresse enthält. Auf E-Mail wechselt ein Kontakt erst, "
                "wenn du bestätigst, dass ihr schon geschäftlich zu tun habt oder eine Einwilligung vorliegt. "
                "Status ist offen, Entwurf, angeschrieben, geantwortet oder gestrichen.", "",
                KOPF_ANSPRACHE, TRENN_ANSPRACHE]
        os.makedirs(os.path.dirname(pfad), exist_ok=True)
        with open(pfad, "w", encoding="utf-8") as f:
            f.write("\n".join(kopf + [ansprache_zeile(e, spalten) for e in neue]) + "\n")
    elif neue:
        tabelle = [i for i, z in enumerate(zeilen) if z.startswith("|")]
        neu_text = [ansprache_zeile(e, spalten) for e in neue]
        if tabelle:
            zeilen[tabelle[-1] + 1:tabelle[-1] + 1] = neu_text
        else:
            while zeilen and zeilen[-1] == "":
                zeilen.pop()
            zeilen += ["", KOPF_ANSPRACHE, TRENN_ANSPRACHE] + neu_text + [""]
        with open(pfad, "w", encoding="utf-8") as f:
            f.write("\n".join(zeilen))
    print(json.dumps({"datei": pfad, "zeilen_neu": len(neue), "zeilen_gesamt": len(eintraege) + len(neue),
                      "kanal": "LinkedIn für alle neuen Zeilen",
                      "email_moeglich": sum(1 for e in neue if e["email_moeglich"] == "ja")},
                     ensure_ascii=False, indent=1))


def ansprache_treffer(basis, firma_slug, kontakt):
    """Sucht die Zeile eines Kontakts in ansprache.md. Gibt (pfad, zeilen, eintrag, spalten, firma) zurück."""
    pfad = os.path.join(basis, "firmen", firma_slug + ".md")
    if not os.path.isfile(pfad):
        fehler("Akte %s gibt es nicht." % firma_slug)
    firma = akte_lesen(pfad)["firma"]
    apfad = os.path.join(basis, "anlass", "ansprache.md")
    azeilen, eintraege, spalten = ansprache_lesen(apfad)
    for e in eintraege:
        if e.get("kontakt", "").lower() == kontakt.strip().lower() and e.get("firma", "").lower() == zelle(firma).lower():
            return apfad, azeilen, e, spalten, firma
    fehler("Kontakt %s bei %s steht nicht in ansprache.md." % (kontakt, firma))


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
        apfad, azeilen, e, spalten, _firma = ansprache_treffer(basis, args.firma, args.kontakt)
        ergebnis["kontakt_alt"], e["status"] = e.get("status", ""), args.wert
        azeilen[e["_zeile"]] = ansprache_zeile(e, spalten)
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
# 3b. kanal
# ---------------------------------------------------------------------------

def kanal(args):
    """Kanal eines Kontakts setzen. E-Mail nur mit Adresse aus dem Export und mit --bestaetigt
    (der Nutzer hat gesagt, dass eine Geschäftsbeziehung oder Einwilligung besteht)."""
    if args.wert not in KANAELE:
        fehler("Kanal muss LinkedIn oder E-Mail sein.")
    basis = args.kontakte
    apfad, azeilen, e, spalten, firma = ansprache_treffer(basis, args.firma, args.kontakt)
    pfad = os.path.join(basis, "firmen", args.firma + ".md")
    if args.wert == "E-Mail":
        adresse = ""
        for k in akte_lesen(pfad)["kontakte"]:
            if k["name"].lower() == args.kontakt.strip().lower():
                adresse = k["email"]
        if not adresse:
            fehler("Für %s steht keine E-Mail-Adresse aus dem Export in der Akte. Ich rate keine Adressen, "
                   "der Kanal bleibt LinkedIn." % args.kontakt)
        if not args.bestaetigt:
            fehler("E-Mail geht nur, wenn du bestätigst, dass du mit %s schon geschäftlich zu tun hast oder eine "
                   "Einwilligung vorliegt. Eine LinkedIn-Verbindung allein reicht dafür nicht (§ 7 UWG). "
                   "Dann erneut mit --bestaetigt." % args.kontakt)
    alt = e.get("kanal", "")
    e["kanal"] = args.wert
    if "kanal" not in spalten:
        fehler("ansprache.md hat keine Spalte Kanal.")
    azeilen[e["_zeile"]] = ansprache_zeile(e, spalten)
    with open(apfad, "w", encoding="utf-8") as f:
        f.write("\n".join(azeilen))
    vermerk = "- %s %s: Kanal %s" % (datum_de(args.datum), zelle(args.kontakt), args.wert)
    if args.wert == "E-Mail":
        vermerk += ", Geschäftsbeziehung oder Einwilligung vom Nutzer bestätigt"
    zeilen = verlauf_anhaengen(open(pfad, encoding="utf-8").read().split("\n"), vermerk)
    with open(pfad, "w", encoding="utf-8") as f:
        f.write("\n".join(zeilen))
    print(json.dumps({"akte": args.firma, "kontakt": args.kontakt, "kanal_alt": alt, "kanal_neu": args.wert},
                     ensure_ascii=False, indent=1))


# ---------------------------------------------------------------------------
# 4. abschluss und stand
# ---------------------------------------------------------------------------

def stand_lesen(basis):
    pfad = os.path.join(basis, STAND_DATEI)
    try:
        daten = json.load(open(pfad, encoding="utf-8"))
        return daten if daten.get("phase") in PHASEN else {}
    except (OSError, ValueError, AttributeError):
        return {}


def abschluss(args):
    """Merkt sich die zuletzt beendete Phase (auch nach "Stopp, das reicht"), damit der Wiedereinstieg
    nicht an einer bewusst beendeten Phase hängen bleibt."""
    if args.phase not in PHASEN:
        fehler("Phase muss einer von %s sein." % ", ".join(PHASEN))
    basis = args.kontakte
    if not os.path.isdir(basis):
        fehler("Den Ordner %s gibt es noch nicht." % basis)
    daten = {"phase": args.phase, "datum": args.datum, "notiz": args.notiz or ""}
    with open(os.path.join(basis, STAND_DATEI), "w", encoding="utf-8") as f:
        json.dump(daten, f, ensure_ascii=False, indent=1)
    print(json.dumps(dict(daten, datei=os.path.join(basis, STAND_DATEI)), ensure_ascii=False, indent=1))


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
    _, eintraege, _spalten = ansprache_lesen(apfad)
    kstatus = {}
    for e in eintraege:
        kstatus[e.get("status") or OFFEN] = kstatus.get(e.get("status") or OFFEN, 0) + 1
    entwuerfe = sorted(os.path.basename(p) for p in glob.glob(os.path.join(basis, "ausgabe", "entwuerfe-*.md")))
    astatus = {}
    for a in akten:
        astatus[a["status"]] = astatus.get(a["status"], 0) + 1
    letzter = stand_lesen(basis)
    gestoppt = PHASEN.index(letzter["phase"]) if letzter else -1

    # Phase D darf bewusst unvollständig bleiben ("Stopp, das reicht"). Alle anderen Phasen sind
    # Voraussetzung für die nächste und zählen nur, wenn ihr Ergebnis wirklich da ist.
    erledigt = {
        "A": bool(arbeit),
        "B": bestaetigt(anlass),
        "C": bool(akten),
        "D": not ohne_recherche or gestoppt >= PHASEN.index("D"),
        "E": bestaetigt(struktur) and bool(eintraege),
        "F": bool(eintraege) and not kstatus.get(OFFEN, 0),
    }
    naechster = next((p for p in PHASEN if not erledigt[p]), "fertig")
    offen_je_phase = {}
    if ohne_recherche:
        offen_je_phase["D"] = "%d Akten ohne Recherche" % len(ohne_recherche)
    kontext_offen = sum(1 for e in eintraege if e.get("kontext") in ("", OFFEN))
    if kontext_offen:
        offen_je_phase["E"] = "%d Kontakte ohne Kontext" % kontext_offen
    if kstatus.get(OFFEN, 0):
        offen_je_phase["F"] = "%d Kontakte ohne Entwurf" % kstatus[OFFEN]

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
                       "ansprache_zeilen": len(eintraege), "kontext_offen": kontext_offen,
                       "email_bestaetigt": sum(1 for e in eintraege if e.get("kanal") == "E-Mail")},
        "F_entwuerfe": {"dateien": entwuerfe, "kontakte_status": kstatus},
        "letzter_stopp": letzter or None,
        "offen_je_phase": offen_je_phase,
        "naechster_schritt": naechster,
    }, ensure_ascii=False, indent=1))


def main():
    ap = argparse.ArgumentParser(description="Firmenakten der Outreach-Pipeline")
    basis = argparse.ArgumentParser(add_help=False)
    basis.add_argument("--kontakte", default="kontakte", help="Basisordner (Standard ./kontakte)")
    unter = ap.add_subparsers(dest="befehl")

    p = unter.add_parser("anlegen", parents=[basis], help="Akten aus der Segmentierung anlegen oder ergänzen")
    p.add_argument("--arbeit", help="Arbeitsordner aus Phase A (Standard: der neueste)")
    p.add_argument("--segmente", help="Segmentregeln (Standard: kontakte/segmente.md, sonst die im Skill-Ordner)")
    p.add_argument("--datum", default=dt.date.today().isoformat())
    p.add_argument("--cloud-ok", action="store_true")

    p = unter.add_parser("ansprache", parents=[basis], help="ansprache.md anlegen oder ergänzen")
    p.add_argument("--cloud-ok", action="store_true")

    p = unter.add_parser("status", parents=[basis], help="Status einer Akte oder eines Kontakts setzen")
    p.add_argument("--firma", required=True, help="Dateiname der Akte ohne .md")
    p.add_argument("--wert", required=True)
    p.add_argument("--kontakt", help="Name wie in ansprache.md")
    p.add_argument("--datum", default=dt.date.today().isoformat())

    p = unter.add_parser("kanal", parents=[basis], help="Kanal eines Kontakts setzen (LinkedIn oder E-Mail)")
    p.add_argument("--firma", required=True, help="Dateiname der Akte ohne .md")
    p.add_argument("--kontakt", required=True, help="Name wie in ansprache.md")
    p.add_argument("--wert", required=True, help="LinkedIn oder E-Mail")
    p.add_argument("--bestaetigt", action="store_true",
                   help="Nutzer hat Geschäftsbeziehung oder Einwilligung bestätigt (Pflicht für E-Mail)")
    p.add_argument("--datum", default=dt.date.today().isoformat())

    p = unter.add_parser("abschluss", parents=[basis], help="zuletzt beendete Phase merken (.stand.json)")
    p.add_argument("--phase", required=True, help="A bis F")
    p.add_argument("--notiz", help="kurze Notiz, etwa Stopp nach Batch 2")
    p.add_argument("--datum", default=dt.date.today().isoformat())

    unter.add_parser("stand", parents=[basis], help="Stand der Pipeline als JSON")

    args = ap.parse_args()
    if args.befehl == "anlegen":
        anlegen(args)
    elif args.befehl == "ansprache":
        ansprache(args)
    elif args.befehl == "status":
        status(args)
    elif args.befehl == "kanal":
        kanal(args)
    elif args.befehl == "abschluss":
        abschluss(args)
    elif args.befehl == "stand":
        stand(args)
    else:
        ap.print_help()


if __name__ == "__main__":
    main()
