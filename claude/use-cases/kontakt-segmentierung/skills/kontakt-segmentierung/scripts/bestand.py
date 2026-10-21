#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
bestand.py: eine Liste bisheriger Partner (Aussteller, Sponsoren, Kunden) gegen den
eingelesenen Export legen.

Aufruf:
  python3 bestand.py <partnerliste.csv|.xlsx> --arbeit <ordner> [--blatt <name>] [--spalte feld=Spaltenname ...]

Erwartet im Arbeitsordner kontakte.json aus einlesen.py. Liest die Partnerliste
(eine Zeile je Firma, Spalten etwa Firma, Art, Jahr, Notiz), ordnet die Firmen
über den Firmennamen den Kontakten zu und schreibt <ordner>/bestand.json.
schreiben.py und akten.py nehmen die Datei auf, wenn sie da ist (Spalte
Bestand, Abschnitt Reaktivierung, Vermerk in der Akte).

Gibt eine Übersicht als JSON aus: Partner gesamt, Partner mit Kontakt im
Export (und wie viele Kontakte), Partner ohne Kontakt im Export.

Nur Standardbibliothek plus openpyxl (nur für .xlsx). Ändert nie die
Eingabedatei, sendet nichts ins Netz.
"""

import argparse
import datetime as dt
import json
import os
import re
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from einlesen import blaetter_xlsx, datum_lesen, fehler, firma_schluessel, norm_kopf, zeilen_csv  # noqa: E402

# Spaltennamen, die in Partnerlisten üblich sind (Schreibweise egal, siehe norm_kopf)
KATALOG = {
    "firma": ["firma", "unternehmen", "company", "companyname", "organisation", "organization", "partner",
              "kunde", "name", "aussteller", "sponsor", "arbeitgeber"],
    "art": ["art", "typ", "type", "status", "rolle", "kategorie", "category", "beteiligung", "paket", "package",
            "partnerart", "partnerschaft"],
    "jahr": ["jahr", "year", "zuletzt", "letztesjahr", "seit", "datum", "date", "teilnahme", "letzteteilnahme",
             "event", "edition"],
    "ansprechperson": ["ansprechperson", "ansprechpartner", "kontakt", "contact", "contactname", "ansprechpartnerin"],
    "notiz": ["notiz", "notizen", "notes", "note", "bemerkung", "kommentar", "comment"],
}


def kopf_finden(zeilen, vorgaben):
    vorgabe_norm = {feld: norm_kopf(name) for feld, name in vorgaben.items()}
    katalog = {feld: {norm_kopf(n) for n in namen} for feld, namen in KATALOG.items()}
    bester = (-1, {}, 0)
    for i, zeile in enumerate(zeilen[:25]):
        koepfe = [norm_kopf(z) for z in zeile]
        zuordnung = {}
        for feld, name in vorgabe_norm.items():
            if name in koepfe:
                zuordnung[feld] = koepfe.index(name)
        belegt = set(zuordnung.values())
        for feld, namen in katalog.items():
            if feld in zuordnung:
                continue
            for j, k in enumerate(koepfe):
                if k and k in namen and j not in belegt:
                    zuordnung[feld] = j
                    belegt.add(j)
                    break
        if "firma" in zuordnung and len(zuordnung) > bester[2]:
            bester = (i, zuordnung, len(zuordnung))
    return bester[0], bester[1]


def main():
    ap = argparse.ArgumentParser(description="Partnerliste gegen den Export legen")
    ap.add_argument("datei", help="Partnerliste als .csv oder .xlsx, eine Zeile je Firma")
    ap.add_argument("--arbeit", required=True, help="Arbeitsordner dieses Laufs (mit kontakte.json)")
    ap.add_argument("--blatt", help="Tabellenblatt bei .xlsx")
    ap.add_argument("--spalte", action="append", metavar="FELD=SPALTE",
                    help="Zuordnung überschreiben, etwa --spalte firma=Unternehmen (Felder firma, art, jahr, ansprechperson, notiz)")
    args = ap.parse_args()

    kpfad = os.path.join(args.arbeit, "kontakte.json")
    if not os.path.isfile(kpfad):
        fehler("Noch kein Export eingelesen: %s fehlt. Zuerst einlesen.py ausführen." % kpfad)
    kontakte = json.load(open(kpfad, encoding="utf-8"))["kontakte"]

    pfad = os.path.expanduser(args.datei)
    if not os.path.isfile(pfad):
        fehler("Ich finde die Partnerliste nicht: %s" % pfad)
    endung = os.path.splitext(pfad)[1].lower()
    if endung in (".xlsx", ".xlsm"):
        blaetter = blaetter_xlsx(pfad)
        if args.blatt:
            blaetter = [b for b in blaetter if b[0] == args.blatt]
            if not blaetter:
                fehler("Das Tabellenblatt %s gibt es in der Partnerliste nicht." % args.blatt)
    elif endung in (".csv", ".txt", ".tsv"):
        blaetter = [(None, zeilen_csv(pfad))]
    else:
        fehler("Partnerlisten vom Typ %s kann ich nicht lesen. Bitte als .csv oder .xlsx speichern." % endung)

    vorgaben = {}
    for eintrag in args.spalte or []:
        if "=" not in eintrag:
            fehler("--spalte erwartet die Form feld=Spaltenname, etwa --spalte firma=Unternehmen.")
        feld, name = [t.strip() for t in eintrag.split("=", 1)]
        if feld not in KATALOG:
            fehler("Unbekanntes Feld %s. Möglich sind %s." % (feld, ", ".join(KATALOG)))
        vorgaben[feld] = name

    blatt, zeilen, kopf, spalten = None, [], -1, {}
    for name, inhalt in blaetter:
        k, s = kopf_finden(inhalt, vorgaben)
        if k >= 0:
            blatt, zeilen, kopf, spalten = name, inhalt, k, s
            break
    if kopf < 0:
        erste = next((z for _, inhalt in blaetter for z in inhalt if any(str(x or "").strip() for x in z)), [])
        fehler("Ich finde in der Partnerliste keine Spalte mit dem Firmennamen. Die erste Zeile lautet: %s. "
               "Sag mir, welche Spalte die Firma ist, dann lese ich mit --spalte firma=Spaltenname erneut ein."
               % ", ".join(str(x).strip() for x in erste if str(x or "").strip()))

    def wert(zeile, feld):
        j = spalten.get(feld)
        if j is None or j >= len(zeile) or zeile[j] is None:
            return ""
        v = zeile[j]
        if isinstance(v, (dt.date, dt.datetime)):
            return v.strftime("%Y") if feld == "jahr" else v.isoformat()
        return re.sub(r"\s+", " ", str(v)).strip()

    partner, gesehen, dubletten = [], set(), 0
    for zeile in zeilen[kopf + 1:]:
        firma = wert(zeile, "firma")
        if not firma:
            continue
        schluessel = firma_schluessel(firma)
        if not schluessel:
            continue
        if schluessel in gesehen:
            dubletten += 1
            continue
        gesehen.add(schluessel)
        jahr = wert(zeile, "jahr")
        m = re.search(r"(19|20)\d{2}", datum_lesen(jahr) if jahr else "")
        partner.append({
            "firma": firma,
            "schluessel": schluessel,
            "art": wert(zeile, "art"),
            "jahr": m.group(0) if m else jahr,
            "ansprechperson": wert(zeile, "ansprechperson"),
            "notiz": wert(zeile, "notiz"),
        })

    im_export = {}
    for k in kontakte:
        s = firma_schluessel(k["firma"])
        if s:
            im_export.setdefault(s, []).append(k)

    mit_kontakt, ohne_kontakt = [], []
    for p in partner:
        leute = im_export.get(p["schluessel"], [])
        if leute:
            mit_kontakt.append(dict(p, kontakte=len(leute), firma_im_export=leute[0]["firma"]))
        else:
            ohne_kontakt.append(p)

    ziel = os.path.join(args.arbeit, "bestand.json")
    with open(ziel, "w", encoding="utf-8") as f:
        json.dump({
            "quelle": os.path.basename(pfad),
            "blatt": blatt,
            "eingelesen_am": dt.date.today().isoformat(),
            "erkannte_spalten": [{"feld": feld, "spalte": str(zeilen[kopf][j]).strip()}
                                 for feld, j in sorted(spalten.items(), key=lambda kv: kv[1])],
            "partner": partner,
        }, f, ensure_ascii=False, indent=1)

    def kurz(p):
        teile = [p["firma"]]
        if p.get("art"):
            teile.append(p["art"])
        if p.get("jahr"):
            teile.append(p["jahr"])
        return ", ".join(teile)

    print(json.dumps({
        "datei": ziel,
        "quelle": os.path.basename(pfad),
        "blatt": blatt,
        "erkannte_spalten": [{"feld": feld, "spalte": str(zeilen[kopf][j]).strip()}
                             for feld, j in sorted(spalten.items(), key=lambda kv: kv[1])],
        "partner": len(partner),
        "dubletten_entfernt": dubletten,
        "partner_mit_kontakt_im_export": len(mit_kontakt),
        "kontakte_bei_partnern": sum(p["kontakte"] for p in mit_kontakt),
        "partner_ohne_kontakt_im_export": len(ohne_kontakt),
        "mit_kontakt": [kurz(p) + " (%d Kontakte)" % p["kontakte"] for p in mit_kontakt],
        "ohne_kontakt": [kurz(p) for p in ohne_kontakt],
        "hinweis": "Firmen werden über den Namen ohne Rechtsform verglichen. Schreibt sich eine Firma in beiden "
                   "Listen anders, erscheint sie unter ohne_kontakt. Dann die Partnerliste angleichen und erneut abgleichen.",
    }, ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main()
