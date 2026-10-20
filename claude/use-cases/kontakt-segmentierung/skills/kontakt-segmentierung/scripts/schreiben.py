#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
schreiben.py: zugeordnete Kontakte als Excel-Datei und Markdown-Zusammenfassung schreiben.

Aufruf:
  python3 schreiben.py --arbeit <ordner> --segmente <segmente.md> --ausgabe <ordner> [--datum JJJJ-MM-TT] [--vorschau] [--cloud-ok]

Erwartet im Arbeitsordner:
  kontakte.json          aus einlesen.py
  zuordnung-*.json       je Block eine Liste [{"id": 1, "segment": "...", "prioritaet": "A", "begruendung": "..."}]
  bausteine.json         {"anrede": "Sie", "bausteine": {"<Segment>": "<Text>", ...}}

Mit --vorschau wird nur geprüft und eine Übersicht als Text ausgegeben, es
entsteht keine Datei. Ohne --vorschau entstehen
  <ausgabe>/segmentierung-<datum>.xlsx  (Blätter Kontakte, Firmen, Textbausteine)
  <ausgabe>/segmentierung-<datum>.md    (Zusammenfassung mit den Top-20-Firmen)
Bestehende Dateien werden nie überschrieben, dann entsteht -2, -3 usw.
Die Excel-Datei enthält keinen Autor, Bearbeiter oder Anwendungsnamen.
"""

import argparse
import datetime as dt
import glob
import json
import os
import re
import shutil
import sys
import tempfile
import zipfile

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from einlesen import cloud_hinweis, firma_schluessel  # noqa: E402

PRIOS = ("A", "B", "C")
# Angaben im Feld Firma, die keine Firma sind, landen in der Firmenübersicht unter (ohne Firma)
KEINE_FIRMA = {"selbststandig", "selbstständig", "freiberuflich", "freelance", "freelancer", "self employed",
               "selbstandig", "freiberufler", "freiberuflerin", "n a", "keine", "none", "ohne"}


def fehler(text, details=None, code=2):
    aus = {"fehler": text}
    if details:
        aus["details"] = details
    print(json.dumps(aus, ensure_ascii=False, indent=1))
    sys.exit(code)


def zahl(n):
    return "{:,}".format(n).replace(",", ".")


def datum_de(iso):
    try:
        return dt.date.fromisoformat(iso).strftime("%d.%m.%Y")
    except (TypeError, ValueError):
        return iso or ""


def segmente_lesen(pfad):
    namen = []
    for zeile in open(pfad, encoding="utf-8"):
        m = re.match(r"^##\s+Segment:\s*(.+?)\s*$", zeile)
        if m:
            namen.append(m.group(1))
    if not namen:
        fehler("In %s steht keine Überschrift der Form '## Segment: <Name>'." % pfad)
    if "Sonstiges" not in namen:
        namen.append("Sonstiges")
    return namen


def segment_finden(wert, segmente):
    w = str(wert or "").strip().lower()
    for s in segmente:
        if s.lower() == w:
            return s
    treffer = [s for s in segmente if s.lower().startswith(w) or w.startswith(s.lower().split(" und ")[0])]
    return treffer[0] if len(treffer) == 1 and w else None


def laden(args):
    kpfad = os.path.join(args.arbeit, "kontakte.json")
    if not os.path.isfile(kpfad):
        fehler("kontakte.json fehlt im Arbeitsordner. Zuerst einlesen.py ausführen.")
    daten = json.load(open(kpfad, encoding="utf-8"))
    kontakte = {k["id"]: k for k in daten["kontakte"]}
    segmente = segmente_lesen(args.segmente)

    probleme, zuordnung = [], {}
    dateien = sorted(glob.glob(os.path.join(args.arbeit, "zuordnung-*.json")))
    if not dateien:
        fehler("Keine zuordnung-*.json im Arbeitsordner gefunden.")
    for datei in dateien:
        try:
            inhalt = json.load(open(datei, encoding="utf-8"))
        except ValueError as e:
            fehler("%s ist kein gültiges JSON: %s" % (os.path.basename(datei), e))
        if isinstance(inhalt, dict):
            inhalt = [dict(v, id=int(k)) for k, v in inhalt.items()]
        for z in inhalt:
            try:
                kid = int(z.get("id"))
            except (TypeError, ValueError):
                probleme.append("%s: Eintrag ohne gültige id" % os.path.basename(datei))
                continue
            if kid not in kontakte:
                probleme.append("id %d gibt es nicht" % kid)
                continue
            if kid in zuordnung:
                probleme.append("id %d doppelt zugeordnet" % kid)
            seg = segment_finden(z.get("segment"), segmente)
            prio = str(z.get("prioritaet", "")).strip().upper()
            if not seg:
                probleme.append("id %d: Segment '%s' unbekannt" % (kid, z.get("segment")))
            if prio not in PRIOS:
                probleme.append("id %d: Priorität '%s' ist nicht A, B oder C" % (kid, z.get("prioritaet")))
            zuordnung[kid] = {"segment": seg, "prioritaet": prio,
                              "begruendung": re.sub(r"\s+", " ", str(z.get("begruendung", "")).strip())}
    fehlend = [i for i in kontakte if i not in zuordnung]
    if fehlend:
        probleme.append("%d Kontakte ohne Zuordnung, etwa id %s" % (len(fehlend), ", ".join(map(str, fehlend[:15]))))
    if probleme:
        fehler("Zuordnung unvollständig oder fehlerhaft.", probleme)

    bpfad = os.path.join(args.arbeit, "bausteine.json")
    bausteine = json.load(open(bpfad, encoding="utf-8")) if os.path.isfile(bpfad) else {"anrede": "", "bausteine": {}}
    texte = {}
    for name, text in (bausteine.get("bausteine") or {}).items():
        seg = segment_finden(name, segmente)
        if not seg:
            fehler("bausteine.json: Segment '%s' unbekannt." % name)
        texte[seg] = str(text).strip()

    zeilen = []
    for kid, k in kontakte.items():
        z = dict(k, **zuordnung[kid])
        zeilen.append(z)
    rang = {s: i for i, s in enumerate(segmente)}
    zeilen.sort(key=lambda z: (PRIOS.index(z["prioritaet"]), rang[z["segment"]],
                               z["firma"].lower() or "~", z["nachname"].lower()))
    return daten.get("meta", {}), zeilen, segmente, bausteine.get("anrede", ""), texte


def firmen_bilden(zeilen, segmente):
    rang = {s: i for i, s in enumerate(segmente)}
    gruppen = {}
    for z in zeilen:
        schluessel = firma_schluessel(z["firma"]) or "~ohne"
        if schluessel in KEINE_FIRMA:
            schluessel = "~ohne"
        gruppen.setdefault(schluessel, []).append(z)
    firmen = []
    for schluessel, leute in gruppen.items():
        bester = min(leute, key=lambda z: (PRIOS.index(z["prioritaet"]), rang[z["segment"]]))
        firmen.append({
            "firma": leute[0]["firma"] if schluessel != "~ohne" else "(ohne Firma)",
            "kontakte": len(leute),
            "a": sum(1 for z in leute if z["prioritaet"] == "A"),
            "b": sum(1 for z in leute if z["prioritaet"] == "B"),
            "segment": bester["segment"],
            "prioritaet": bester["prioritaet"],
            "kontakt": ("%s %s" % (bester["vorname"], bester["nachname"])).strip(),
            "position": bester["position"],
            "ohne": schluessel == "~ohne",
        })
    firmen.sort(key=lambda f: (f["ohne"], PRIOS.index(f["prioritaet"]), rang[f["segment"]],
                               -f["a"], -f["kontakte"], f["firma"].lower()))
    return firmen


def verteilung(zeilen, segmente):
    tab = {s: {p: 0 for p in PRIOS} for s in segmente}
    for z in zeilen:
        tab[z["segment"]][z["prioritaet"]] += 1
    return tab


def vorschau(meta, zeilen, segmente, anrede, texte):
    tab = verteilung(zeilen, segmente)
    print("Quelle: %s, %s Kontakte" % (meta.get("quelle", "?"), zahl(len(zeilen))))
    print("")
    print("Segment | A | B | C | Gesamt")
    for s in segmente:
        t = tab[s]
        print("%s | %d | %d | %d | %d" % (s, t["A"], t["B"], t["C"], sum(t.values())))
    print("")
    print("Top-20-Firmen: Rang | Firma | Kontakte | davon A | bestes Segment | beste Priorität | wichtigster Kontakt")
    for i, f in enumerate([f for f in firmen_bilden(zeilen, segmente) if not f["ohne"]][:20], 1):
        print("%d | %s | %d | %d | %s | %s | %s (%s)" % (i, f["firma"], f["kontakte"], f["a"], f["segment"],
                                                       f["prioritaet"], f["kontakt"], f["position"]))
    print("")
    a = [z for z in zeilen if z["prioritaet"] == "A"]
    print("Priorität A, %d Kontakte (bis zu 30 gezeigt): Name | Position | Firma | Segment | Begründung" % len(a))
    for z in a[:30]:
        print("%s %s | %s | %s | %s | %s" % (z["vorname"], z["nachname"], z["position"], z["firma"],
                                            z["segment"], z["begruendung"]))
    print("")
    fehlt = [s for s in segmente if sum(tab[s].values()) and s not in texte]
    print("Textbausteine: %d (Anrede %s)%s" % (len(texte), anrede or "offen",
                                               ", fehlen für " + ", ".join(fehlt) if fehlt else ""))


def freier_name(ordner, basis):
    n = 1
    while True:
        endung = "" if n == 1 else "-%d" % n
        if not (os.path.exists(os.path.join(ordner, basis + endung + ".xlsx")) or
                os.path.exists(os.path.join(ordner, basis + endung + ".md"))):
            return basis + endung
        n += 1


def metadaten_leeren(pfad):
    """Entfernt Autor, Bearbeiter und Anwendungsnamen aus der fertigen xlsx-Datei."""
    app_xml = ('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
               '<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" '
               'xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">'
               '<Application></Application></Properties>')
    fd, tmp = tempfile.mkstemp(suffix=".xlsx", dir=os.path.dirname(pfad))
    os.close(fd)
    with zipfile.ZipFile(pfad) as alt, zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as neu:
        for eintrag in alt.infolist():
            daten = alt.read(eintrag.filename)
            if eintrag.filename == "docProps/app.xml":
                daten = app_xml.encode("utf-8")
            elif eintrag.filename == "docProps/core.xml":
                text = daten.decode("utf-8")
                text = re.sub(r"<dc:creator>.*?</dc:creator>", "<dc:creator></dc:creator>", text, flags=re.S)
                text = re.sub(r"<cp:lastModifiedBy>.*?</cp:lastModifiedBy>", "<cp:lastModifiedBy></cp:lastModifiedBy>",
                              text, flags=re.S)
                daten = text.encode("utf-8")
            neu.writestr(eintrag, daten)
    shutil.move(tmp, pfad)


def excel_schreiben(pfad, meta, zeilen, segmente, anrede, texte, firmen):
    try:
        from openpyxl import Workbook
        from openpyxl.styles import Alignment, Font, PatternFill
        from openpyxl.utils import get_column_letter
    except ImportError:
        fehler("Für Excel-Dateien fehlt das Zusatzpaket openpyxl. Installieren mit: python3 -m pip install openpyxl "
              "(unter Windows py -3 -m pip install openpyxl).")

    fett = Font(bold=True, color="FFFFFF")
    kopf_fuellung = PatternFill("solid", fgColor="1F3A5F")
    prio_fuellung = {"A": PatternFill("solid", fgColor="C6EFCE"),
                     "B": PatternFill("solid", fgColor="FFEB9C"),
                     "C": PatternFill("solid", fgColor="EDEDED")}
    umbruch = Alignment(wrap_text=True, vertical="top")
    oben = Alignment(vertical="top")

    def text(zelle, wert):
        zelle.value = wert
        if isinstance(wert, str):
            zelle.data_type = "s"  # nie als Formel auswerten, auch wenn der Text mit = beginnt

    def blatt(ws, kopf, breiten):
        for j, (titel, breite) in enumerate(zip(kopf, breiten), 1):
            c = ws.cell(row=1, column=j)
            text(c, titel)
            c.font, c.fill, c.alignment = fett, kopf_fuellung, Alignment(vertical="center", wrap_text=True)
            ws.column_dimensions[get_column_letter(j)].width = breite
        ws.freeze_panes = "A2"

    wb = Workbook()
    wb.properties.creator = ""
    wb.properties.lastModifiedBy = ""
    wb.properties.title = None

    # Blatt 1: Kontakte
    ws = wb.active
    ws.title = "Kontakte"
    kopf = ["Priorität", "Segment", "Vorname", "Nachname", "Firma", "Position", "Begründung",
            "Verbunden seit", "Profil-Link", "E-Mail (aus Export)", "Status (für dich)"]
    blatt(ws, kopf, [10, 30, 16, 18, 30, 40, 50, 14, 38, 30, 18])
    for i, z in enumerate(zeilen, 2):
        werte = [z["prioritaet"], z["segment"], z["vorname"], z["nachname"], z["firma"], z["position"],
                 z["begruendung"]]
        for j, w in enumerate(werte, 1):
            text(ws.cell(row=i, column=j), w)
            ws.cell(row=i, column=j).alignment = oben
        ws.cell(row=i, column=1).fill = prio_fuellung[z["prioritaet"]]
        ws.cell(row=i, column=1).alignment = Alignment(horizontal="center", vertical="top")
        c = ws.cell(row=i, column=8)
        try:
            c.value = dt.date.fromisoformat(z["verbunden_seit"])
            c.number_format = "DD.MM.YYYY"
        except (TypeError, ValueError):
            text(c, z["verbunden_seit"])
        c = ws.cell(row=i, column=9)
        text(c, z["url"])
        if re.match(r"^https?://", z["url"] or ""):
            c.hyperlink = z["url"]
            c.font = Font(color="0563C1", underline="single")
        text(ws.cell(row=i, column=10), z["email"])
    ws.auto_filter.ref = "A1:%s%d" % (get_column_letter(len(kopf)), max(len(zeilen) + 1, 2))

    # Blatt 2: Firmen
    ws = wb.create_sheet("Firmen")
    kopf = ["Rang", "Firma", "Kontakte", "davon A", "davon B", "Bestes Segment", "Beste Priorität",
            "Wichtigster Kontakt", "Position"]
    blatt(ws, kopf, [7, 34, 11, 10, 10, 32, 12, 26, 40])
    for i, f in enumerate(firmen, 2):
        werte = [i - 1 if not f["ohne"] else None, f["firma"], f["kontakte"], f["a"], f["b"], f["segment"],
                 f["prioritaet"], f["kontakt"], f["position"]]
        for j, w in enumerate(werte, 1):
            c = ws.cell(row=i, column=j)
            text(c, w)
            if isinstance(w, int):
                c.number_format = "#,##0"
        ws.cell(row=i, column=7).fill = prio_fuellung[f["prioritaet"]]
        ws.cell(row=i, column=7).alignment = Alignment(horizontal="center")
    ws.auto_filter.ref = "A1:I%d" % max(len(firmen) + 1, 2)

    # Blatt 3: Textbausteine
    ws = wb.create_sheet("Textbausteine")
    kopf = ["Segment", "Anrede", "Kontakte im Segment", "Textbaustein (LinkedIn-Nachricht)", "Zeichen"]
    blatt(ws, kopf, [30, 9, 12, 90, 9])
    tab = verteilung(zeilen, segmente)
    zeile = 2
    for s in segmente:
        if s not in texte:
            continue
        t = texte[s]
        for j, w in enumerate([s, anrede, sum(tab[s].values()), t, len(t)], 1):
            c = ws.cell(row=zeile, column=j)
            text(c, w)
            c.alignment = umbruch
            if isinstance(w, int):
                c.number_format = "#,##0"
        ws.row_dimensions[zeile].height = min(409, 15 * (t.count("\n") + len(t) // 85 + 2))
        zeile += 1
    hinweis = ws.cell(row=zeile + 1, column=1)
    text(hinweis, "Platzhalter in eckigen Klammern vor dem Senden ersetzen. Jede Nachricht schickst du selbst, "
                  "nichts wird automatisch versendet.")
    hinweis.font = Font(italic=True, color="666666")

    wb.save(pfad)
    metadaten_leeren(pfad)


def markdown_schreiben(pfad, meta, zeilen, segmente, firmen, datum, xlsx_name):
    tab = verteilung(zeilen, segmente)
    z = []
    z.append("# Kontakt-Segmentierung für den ADAN Career Day, %s" % datum_de(datum))
    z.append("")
    ausgeschlossen = sum((meta.get("ausgeschlossen") or {}).values())
    z.append("Quelle %s, eingelesen am %s. %s Kontakte aus %s Firmen segmentiert%s. Die vollständige Liste steht in `%s`."
             % (meta.get("quelle", "?"), datum_de(meta.get("eingelesen_am", "")), zahl(len(zeilen)),
                zahl(len([f for f in firmen if not f["ohne"]])),
                (", %s Kontakt über die Ausschlussliste weggelassen" if ausgeschlossen == 1 else
                 ", %s Kontakte über die Ausschlussliste weggelassen") % zahl(ausgeschlossen) if ausgeschlossen else "",
                xlsx_name))
    z.append("")
    z.append("## Verteilung")
    z.append("")
    z.append("| Segment | A | B | C | Gesamt |")
    z.append("|---|---:|---:|---:|---:|")
    for s in segmente:
        t = tab[s]
        z.append("| %s | %s | %s | %s | %s |" % (s, zahl(t["A"]), zahl(t["B"]), zahl(t["C"]), zahl(sum(t.values()))))
    summe = {p: sum(tab[s][p] for s in segmente) for p in PRIOS}
    z.append("| **Gesamt** | **%s** | **%s** | **%s** | **%s** |" % (zahl(summe["A"]), zahl(summe["B"]),
                                                                     zahl(summe["C"]), zahl(len(zeilen))))
    z.append("")
    z.append("## Top-20-Firmen")
    z.append("")
    z.append("Sortiert nach bester Priorität, dann Segment, dann Zahl der A-Kontakte und Kontakte insgesamt.")
    z.append("")
    z.append("| Rang | Firma | Kontakte | davon A | Bestes Segment | Wichtigster Kontakt (Position) |")
    z.append("|---:|---|---:|---:|---|---|")
    for i, f in enumerate([f for f in firmen if not f["ohne"]][:20], 1):
        z.append("| %d | %s | %s | %s | %s (%s) | %s |" % (i, f["firma"].replace("|", "/"), zahl(f["kontakte"]),
                                                          zahl(f["a"]), f["segment"], f["prioritaet"],
                                                          (f["position"] or "ohne Position").replace("|", "/")))
    z.append("")
    z.append("## So geht es weiter")
    z.append("")
    z.append("- Liste in Excel öffnen, Blatt Kontakte nach Priorität A filtern und Zuordnungen kurz gegenlesen.")
    z.append("- Textbausteine im Blatt Textbausteine anpassen, Platzhalter in eckigen Klammern ersetzen.")
    z.append("- Nachrichten selbst über LinkedIn schicken. Nichts wurde versendet und nichts wird automatisch versendet.")
    z.append("- Bei der ersten Nachricht sagen, woher du den Kontakt hast (wir sind auf LinkedIn vernetzt), "
             "und anbieten, sich nicht wieder zu melden, wenn kein Interesse besteht.")
    z.append("- Datei lokal lassen, nicht in iCloud, OneDrive oder geteilte Ordner legen. Nicht mehr gebrauchte Listen selbst löschen.")
    z.append("")
    with open(pfad, "w", encoding="utf-8") as fobj:
        fobj.write("\n".join(z))


def main():
    ap = argparse.ArgumentParser(description="Segmentierte Kontakte als Excel und Markdown schreiben")
    ap.add_argument("--arbeit", required=True)
    ap.add_argument("--segmente", required=True)
    ap.add_argument("--ausgabe", default=os.path.join("kontakte", "ausgabe"))
    ap.add_argument("--datum", default=dt.date.today().isoformat())
    ap.add_argument("--vorschau", action="store_true")
    ap.add_argument("--cloud-ok", action="store_true",
                    help="Ausgabeordner in iCloud oder OneDrive bewusst zulassen (Nutzer hat entschieden)")
    args = ap.parse_args()

    meta, zeilen, segmente, anrede, texte = laden(args)
    if args.vorschau:
        vorschau(meta, zeilen, segmente, anrede, texte)
        return
    wolke = cloud_hinweis(args.ausgabe)
    if wolke and not args.cloud_ok:
        fehler(wolke + " Die Ergebnisliste würde mitsynchronisiert. Vorschlag: ein lokaler Ordner "
               "wie ~/Kontakte-lokal. Wer trotzdem hier speichern will, startet erneut mit --cloud-ok.", code=3)
    os.makedirs(args.ausgabe, exist_ok=True)
    basis = freier_name(args.ausgabe, "segmentierung-%s" % args.datum)
    firmen = firmen_bilden(zeilen, segmente)
    xlsx = os.path.join(args.ausgabe, basis + ".xlsx")
    md = os.path.join(args.ausgabe, basis + ".md")
    excel_schreiben(xlsx, meta, zeilen, segmente, anrede, texte, firmen)
    markdown_schreiben(md, meta, zeilen, segmente, firmen, args.datum, basis + ".xlsx")
    print(json.dumps({"excel": xlsx, "zusammenfassung": md, "kontakte": len(zeilen),
                      "firmen": len([f for f in firmen if not f["ohne"]])}, ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main()
