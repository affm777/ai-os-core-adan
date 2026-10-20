/* =============================================================================
   social-post: füllt die Vorlage aus inhalt.json, passt zu lange Texte an
   und setzt danach die Klasse "sp-bereit" am body (Signal für render.sh).
   Texte werden nur als Text eingesetzt (kein HTML), *Sternchen* markieren
   ein hervorgehobenes Wort in Akzentfarbe.
   ============================================================================= */
(function () {
  "use strict";

  var FORMATE = ["ig-1x1", "ig-4x5", "story-9x16", "li-1x1"];

  function setzeText(el, text) {
    el.textContent = "";
    if (!text) { return; }
    var teile = String(text).split("*");
    teile.forEach(function (teil, i) {
      if (!teil) { return; }
      if (i % 2 === 1) {
        var s = document.createElement("span");
        s.className = "akzent";
        s.textContent = teil;
        el.appendChild(s);
      } else {
        el.appendChild(document.createTextNode(teil));
      }
    });
  }

  function fuelleSlots(wurzel, daten) {
    wurzel.querySelectorAll("[data-slot]").forEach(function (el) {
      var key = el.getAttribute("data-slot");
      if (key === "punkte") {
        el.textContent = "";
        (daten.punkte || []).filter(Boolean).forEach(function (p) {
          var li = document.createElement("li");
          setzeText(li, p);
          el.appendChild(li);
        });
        return;
      }
      if (Object.prototype.hasOwnProperty.call(daten, key)) { setzeText(el, daten[key]); }
    });
  }

  function seitenzahlen() {
    var frames = document.querySelectorAll(".sp-frame");
    frames.forEach(function (f, i) {
      f.querySelectorAll("[data-seitenzahl]").forEach(function (el) {
        el.textContent = String(i + 1).padStart(2, "0") + " / " + String(frames.length).padStart(2, "0");
      });
    });
  }

  function ueberlauf(frame) {
    var innen = frame.querySelector(".sp-innen");
    if (!innen) { return false; }
    if (innen.scrollHeight > innen.clientHeight + 2) { return true; }
    var mitte = frame.querySelector(".sp-mitte");
    if (mitte && mitte.scrollHeight > mitte.clientHeight + 2) { return true; }
    return Array.prototype.some.call(frame.querySelectorAll("h1, h2, .sp-subline, .sp-text, li, .sp-cta"), function (el) {
      return el.scrollWidth > el.clientWidth + 2;
    });
  }

  /* Verkleinert die Schrift im Frame schrittweise, bis alles passt (bis auf rund 60 Prozent). */
  function einpassen(frame) {
    var stufe = 1;
    var ziele = frame.querySelectorAll("h1, h2, .sp-subline, .sp-text, .sp-punkte li");
    var basis = Array.prototype.map.call(ziele, function (el) { return parseFloat(getComputedStyle(el).fontSize); });
    while (ueberlauf(frame) && stufe > 0.62) {
      stufe -= 0.04;
      ziele.forEach(function (el, i) { el.style.fontSize = (basis[i] * stufe).toFixed(1) + "px"; });
    }
    frame.setAttribute("data-stufe", stufe.toFixed(2));
    if (ueberlauf(frame)) { frame.setAttribute("data-ueberlauf", "ja"); }
  }

  function fertig(meldung) {
    if (meldung) { document.body.setAttribute("data-fehler", meldung); }
    document.body.classList.add("sp-bereit");
  }

  fetch("inhalt.json", { cache: "no-store" })
    .then(function (r) { if (!r.ok) { throw new Error("inhalt.json fehlt"); } return r.json(); })
    .then(function (d) {
      var format = FORMATE.indexOf(d.format) >= 0 ? d.format : "ig-1x1";
      document.body.classList.add("fmt-" + format);
      document.documentElement.lang = d.sprache === "en" ? "en" : "de";

      if (d.farben && typeof d.farben === "object") {
        Object.keys(d.farben).forEach(function (k) {
          if (/^--sp-[a-z0-9-]+$/.test(k)) { document.body.style.setProperty(k, String(d.farben[k])); }
        });
      }

      /* Karussell: Inhaltsseiten aus der Vorlage <template id="sp-seite"> klonen */
      var vorlageSeite = document.getElementById("sp-seite");
      var anker = document.getElementById("sp-seiten-anker");
      if (vorlageSeite && anker) {
        (d.seiten || []).forEach(function (s) {
          var knoten = vorlageSeite.content.firstElementChild.cloneNode(true);
          fuelleSlots(knoten, Object.assign({ absender: d.absender }, s));
          anker.parentNode.insertBefore(knoten, anker);
        });
        anker.remove();
      }

      document.querySelectorAll(".sp-frame").forEach(function (f) {
        if (!f.hasAttribute("data-eigene-daten")) { fuelleSlots(f, d); }
      });
      seitenzahlen();
      return document.fonts.ready;
    })
    .then(function () {
      document.querySelectorAll(".sp-frame").forEach(einpassen);
      fertig();
    })
    .catch(function (e) { fertig(String(e && e.message || e)); });
})();
