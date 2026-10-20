#!/usr/bin/env python3
"""Re-layers a Mermaid flowchart SVG (which includes every C4 diagram) so it
paints as: boxes at the back, then arrows, then all text on top.

Mermaid's own order inside each <g class="root"> is clusters (boundary rect
AND its title), arrows, arrow captions, nodes (box AND text together). That
hides arrows behind any box they cross and paints captions under boxes. The
layout can't be changed from the Mermaid/DSL source, so this runs after mmdc
as part of generate-docs.sh.

Elements are only moved (geometry and every other byte are unchanged), apart
from arrows being made unfilled (see relayer). Text moved out of its .node/.cluster group is
wrapped in a group with that group's class and transform, so Mermaid's CSS
(which keys on `.node .label` etc.) and the label positions still apply.

Not a flowchart (sequence, ER, ...), or already re-layered: file left alone.
Usage: layer-svg.py FILE.svg   (rewrites in place)
"""
import re
import sys

TAG = re.compile(r"<(/?)([A-Za-z][\w:.-]*)((?:[^>\"']|\"[^\"]*\"|'[^']*')*?)(/?)>")


class El:
    def __init__(self, name, open_tag, parent):
        self.name, self.open, self.parent = name, open_tag, parent
        self.items = []  # str (text/comments) | El
        self.close = ""  # "" for self-closing

    def attr(self, key):
        m = re.search(r'\b' + key + r'="([^"]*)"', self.open)
        return m.group(1) if m else None

    def classes(self):
        return (self.attr("class") or "").split()

    def children(self):
        return [i for i in self.items if isinstance(i, El)]

    def child(self, cls):
        for c in self.children():
            if c.name == "g" and cls in c.classes():
                return c
        return None

    def out(self):
        return self.open + "".join(i if isinstance(i, str) else i.out() for i in self.items) + self.close


def parse(text):
    root = El("#doc", "", None)
    cur, pos = root, 0
    for m in TAG.finditer(text):
        if m.start() > pos:
            cur.items.append(text[pos:m.start()])
        pos = m.end()
        closing, name, selfclose = m.group(1), m.group(2), m.group(4)
        if closing:
            if cur.name != name:
                raise ValueError(f"mismatched </{name}> inside <{cur.name}>")
            cur.close = m.group(0)
            cur = cur.parent
        else:
            el = El(name, m.group(0), cur)
            cur.items.append(el)
            if not selfclose:
                cur = el
    if cur is not root:
        raise ValueError(f"unclosed <{cur.name}>")
    cur.items.append(text[pos:])
    return root


def walk(el):
    for c in el.children():
        yield c
        yield from walk(c)


def wrapper(group):
    """Empty wrapper carrying the class/transform of the group a label came from."""
    cls, tf = group.attr("class"), group.attr("transform")
    return '<g' + (f' class="{cls}"' if cls else "") + (f' transform="{tf}"' if tf else "") + ">"


def take_label(group, label_cls):
    """Detach group's direct label child(ren); return them wrapped, or ''."""
    out = []
    for c in group.children():
        if c.name == "g" and label_cls in c.classes():
            group.items.remove(c)
            out.append(wrapper(group) + c.out() + "</g>")
    return "".join(out)


def relayer(root_g):
    layers = {n: root_g.child(n) for n in ("clusters", "edgePaths", "edgeLabels", "nodes")}
    if not all(layers.values()):
        return False
    # Structurizr's export styles every arrow with fill:#ffffff. An arrow is
    # an open curve, but that fills the area between its ends, which only
    # stayed invisible while boxes were painted over it. Now it would wipe out
    # the borders of any box it crosses, so make arrows unfilled.
    for path in walk(layers["edgePaths"]):
        if path.name == "path" and 'style="' in path.open:
            path.open = re.sub(
                r'style="[^"]*"',
                lambda m: re.sub(r"fill:[^;\"]*", "fill:none", m.group(0)),
                path.open,
            )

    text = []
    for cluster in layers["clusters"].children():
        if "cluster" in cluster.classes():
            text.append(take_label(cluster, "cluster-label"))
    for node in layers["nodes"].children():
        if "node" in node.classes():
            text.append(take_label(node, "label"))
    text.append(layers["edgeLabels"].out())

    top = El("g", '<g class="labels-top">', root_g)
    top.items = ["".join(text)]
    top.close = "</g>"
    root_g.items = [
        layers["clusters"],
        layers["nodes"],
        layers["edgePaths"],
        top,
    ]
    return True


def main(path):
    with open(path, encoding="utf-8", newline="") as f:
        src = f.read()
    doc = parse(src)
    if doc.out() != src:
        raise ValueError("parser round-trip changed the file; refusing to rewrite it")

    svg = next((c for c in doc.children() if c.name == "svg"), None)
    if svg is None or "flowchart" not in (svg.attr("class") or ""):
        print(f"   {path}: not a flowchart, left as is")
        return
    if any("labels-top" in c.classes() for c in walk(svg) if c.name == "g"):
        print(f"   {path}: already re-layered")
        return

    # Innermost roots first: a root's nodes group can hold nested roots.
    roots = [g for g in walk(svg) if g.name == "g" and "root" in g.classes()]
    changed = sum(relayer(g) for g in reversed(roots))
    if not changed:
        print(f"   {path}: no layered groups found, left as is")
        return
    result = doc.out()
    parse(result)  # must still be well-formed
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(result)
    print(f"   {path}: re-layered {changed} group(s)")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
