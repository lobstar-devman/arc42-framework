#!/usr/bin/env python3
"""Replace `<!-- embed: PATH -->` placeholders in docs/**/*.md with real
Markdown image embeds, once the referenced file has actually been
generated under docs/. Placeholders whose target doesn't exist yet are
left untouched, so partially-populated sources of truth don't break the
build. Idempotent: already-linked images have no placeholder left to
match, so re-running is a no-op for them.
"""
import os
import re

DOCS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "docs"))

EMBED_BLOCK = re.compile(r"```\n<!-- embed: (?P<path>\S+) -->\n```")


def alt_text(path):
    name = os.path.splitext(os.path.basename(path))[0]
    return name.replace("-", " ").replace("_", " ").title()


def process(md_path):
    with open(md_path) as f:
        content = f.read()

    changed = []

    def replace(match):
        rel_target = match.group("path")
        abs_target = os.path.join(DOCS_DIR, rel_target)
        if not os.path.isfile(abs_target):
            return match.group(0)
        rel_from_doc = os.path.relpath(abs_target, os.path.dirname(md_path))
        changed.append(rel_target)
        return f"![{alt_text(rel_target)}]({rel_from_doc})"

    new_content = EMBED_BLOCK.sub(replace, content)
    if changed:
        with open(md_path, "w") as f:
            f.write(new_content)
        rel_md = os.path.relpath(md_path, DOCS_DIR)
        for target in changed:
            print(f"  linked {rel_md} -> {target}")


def main():
    for root, _, files in os.walk(DOCS_DIR):
        for fname in files:
            if fname.endswith(".md"):
                process(os.path.join(root, fname))


if __name__ == "__main__":
    main()
