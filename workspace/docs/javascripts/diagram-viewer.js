// Upgrades every generated diagram (an <img> pointing at an .svg) into a
// pan/zoom viewer. Inline: drag to pan, +/- buttons or ctrl/cmd+wheel to
// zoom, and double-click (or the "Open full page" link) to open the diagram
// in a new tab. That tab is diagram-viewer.html, which loads this same
// script and shows the diagram full window with the same pan/zoom (plain
// wheel and double-click zoom there too, as there's nothing to scroll).
// A plain mouse wheel still scrolls the docs page. The markdown keeps a
// plain ![]() image, so the raw files and anything reading them are unaffected.
// If svg-pan-zoom fails to load (e.g. offline), diagrams stay plain images.
(function () {
  // Captured now: document.currentScript is null once the script has run.
  var SCRIPT_SRC = document.currentScript && document.currentScript.src;
  var CONTROLS_ID = "svg-pan-zoom-controls";

  function pageUrl(svgUrl, title) {
    var u = new URL("diagram-viewer.html", SCRIPT_SRC);
    u.searchParams.set("src", svgUrl);
    if (title) u.searchParams.set("title", title);
    return u.href;
  }

  // Wire svg-pan-zoom into an <object> holding an SVG. opts.fullPage: fill
  // the window and zoom with the plain wheel / double-click. Otherwise
  // (inline): opts.box is resized to the diagram, zoom needs ctrl/cmd+wheel,
  // and double-click calls opts.onOpen.
  function attach(obj, opts) {
    var full = !!opts.fullPage;

    obj.addEventListener("load", function () {
      var doc = obj.contentDocument;
      if (!doc) return;
      var svg = doc.documentElement;

      // Inline only: size the box to the diagram's aspect ratio, within
      // sensible bounds. The 220px floor also applies to the 75%-of-window
      // cap, so a page loaded in a zero-size window (e.g. a background tab)
      // can't collapse the box; it's redone on resize to pick up the real size.
      var vb = (svg.getAttribute("viewBox") || "").split(/[\s,]+/).map(Number);
      function sizeBox() {
        if (full || !opts.box || vb.length !== 4 || !(vb[2] > 0)) return;
        var h = Math.round((opts.box.clientWidth * vb[3]) / vb[2]);
        var max = Math.max(220, Math.round(window.innerHeight * 0.75));
        opts.box.style.height = Math.min(Math.max(h, 220), max) + "px";
      }
      sizeBox();

      // Let the SVG fill its frame (BPMN SVGs ship fixed pixel sizes, Mermaid
      // ones a max-width) so svg-pan-zoom can fit and centre it. No text
      // selection: a double-click would otherwise highlight a word.
      svg.setAttribute("width", "100%");
      svg.setAttribute("height", "100%");
      svg.style.maxWidth = "none";
      svg.style.userSelect = "none";

      var pz = svgPanZoom(svg, {
        zoomEnabled: true,
        controlIconsEnabled: true,
        fit: true,
        center: true,
        minZoom: 0.2,
        maxZoom: 20,
        mouseWheelZoomEnabled: full,
        dblClickZoomEnabled: full
      });

      if (!full) {
        doc.addEventListener(
          "wheel",
          function (e) {
            if (!(e.ctrlKey || e.metaKey)) return;
            e.preventDefault();
            pz.zoomAtPointBy(e.deltaY < 0 ? 1.25 : 0.8, { x: e.clientX, y: e.clientY });
          },
          { passive: false }
        );

        doc.addEventListener("dblclick", function (e) {
          // Rapid clicks on the +/- buttons shouldn't open the page.
          if (e.target.closest && e.target.closest("#" + CONTROLS_ID)) return;
          if (opts.onOpen) opts.onOpen();
        });
      }

      window.addEventListener("resize", function () {
        sizeBox();
        pz.resize();
        pz.fit();
        pz.center();
      });
    });
  }

  function enhance(img) {
    if (img.dataset.diagramViewer || typeof svgPanZoom === "undefined") return;
    img.dataset.diagramViewer = "1";

    var alt = img.getAttribute("alt") || "Diagram";
    var url = pageUrl(img.src, alt);

    var box = document.createElement("div");
    box.className = "diagram-viewer";
    var obj = document.createElement("object");
    obj.type = "image/svg+xml";
    obj.data = img.getAttribute("src");
    obj.setAttribute("aria-label", alt);

    // Double-click can't be done from a keyboard or a touch screen, and
    // isn't discoverable, so offer the same action as a link.
    var open = document.createElement("a");
    open.className = "diagram-viewer__open";
    open.href = url;
    open.target = "_blank";
    open.rel = "noopener";
    open.textContent = "Open full page";
    open.title = "Open full page (or double-click the diagram)";

    box.appendChild(obj);
    box.appendChild(open);
    img.replaceWith(box);

    attach(obj, {
      box: box,
      onOpen: function () {
        window.open(url, "_blank");
      }
    });
  }

  // The standalone page (diagram-viewer.html): show ?src= full window.
  function initFullPage() {
    var params = new URLSearchParams(location.search);

    function fail(message) {
      var p = document.createElement("p");
      p.className = "diagram-page__error";
      p.textContent = message;
      document.body.appendChild(p);
    }

    // Only ever embed one of this site's own .svg files, so the page can't be
    // pointed at arbitrary external content.
    var src = null;
    try {
      src = new URL(params.get("src") || "", location.href);
    } catch (e) {}
    if (!src || src.origin !== location.origin || !/\.svg$/i.test(src.pathname)) {
      fail("No diagram to show: ?src= must be an .svg file on this site.");
      return;
    }

    var title = params.get("title") || src.pathname.split("/").pop();
    document.title = title;

    var obj = document.createElement("object");
    obj.type = "image/svg+xml";
    obj.data = src.href;
    obj.setAttribute("aria-label", title);
    document.body.appendChild(obj);

    if (typeof svgPanZoom !== "undefined") attach(obj, { fullPage: true });
  }

  function run() {
    if (document.body.classList.contains("diagram-page")) {
      initFullPage();
      return;
    }
    document.querySelectorAll('.md-content img[src$=".svg"]').forEach(enhance);
  }

  if (window.document$ && window.document$.subscribe) window.document$.subscribe(run);
  else document.addEventListener("DOMContentLoaded", run);
})();
