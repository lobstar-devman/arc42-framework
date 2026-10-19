// Upgrades every generated diagram (an <img> pointing at an .svg) into a
// pan/zoom viewer: drag to pan, +/- buttons, double-click or ctrl/cmd+wheel
// to zoom. A plain mouse wheel still scrolls the page. The markdown keeps a
// plain ![]() image, so the raw files and anything reading them are unaffected.
// If svg-pan-zoom fails to load (e.g. offline), diagrams stay plain images.
(function () {
  function enhance(img) {
    if (img.dataset.diagramViewer || typeof svgPanZoom === "undefined") return;
    img.dataset.diagramViewer = "1";

    var box = document.createElement("div");
    box.className = "diagram-viewer";
    var obj = document.createElement("object");
    obj.type = "image/svg+xml";
    obj.data = img.getAttribute("src");
    obj.setAttribute("aria-label", img.getAttribute("alt") || "Diagram");
    box.appendChild(obj);
    img.replaceWith(box);

    obj.addEventListener("load", function () {
      var doc = obj.contentDocument;
      if (!doc) return;
      var svg = doc.documentElement;

      // Size the box to the diagram's aspect ratio, within sensible bounds.
      var vb = (svg.getAttribute("viewBox") || "").split(/[\s,]+/).map(Number);
      if (vb.length === 4 && vb[2] > 0) {
        var h = Math.round((box.clientWidth * vb[3]) / vb[2]);
        box.style.height =
          Math.min(Math.max(h, 220), Math.round(window.innerHeight * 0.75)) + "px";
      }

      // Let the SVG fill the box (BPMN SVGs ship fixed pixel sizes, Mermaid
      // ones a max-width) so svg-pan-zoom can fit and centre it.
      svg.setAttribute("width", "100%");
      svg.setAttribute("height", "100%");
      svg.style.maxWidth = "none";

      var pz = svgPanZoom(svg, {
        zoomEnabled: true,
        controlIconsEnabled: true,
        fit: true,
        center: true,
        minZoom: 0.2,
        maxZoom: 20,
        mouseWheelZoomEnabled: false
      });

      doc.addEventListener(
        "wheel",
        function (e) {
          if (!(e.ctrlKey || e.metaKey)) return;
          e.preventDefault();
          pz.zoomAtPointBy(e.deltaY < 0 ? 1.25 : 0.8, { x: e.clientX, y: e.clientY });
        },
        { passive: false }
      );

      window.addEventListener("resize", function () {
        pz.resize();
        pz.fit();
        pz.center();
      });
    });
  }

  function run() {
    document.querySelectorAll('.md-content img[src$=".svg"]').forEach(enhance);
  }

  if (window.document$ && window.document$.subscribe) window.document$.subscribe(run);
  else document.addEventListener("DOMContentLoaded", run);
})();
