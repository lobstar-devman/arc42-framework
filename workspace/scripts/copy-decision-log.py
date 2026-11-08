#!/usr/bin/env python3
"""Copy the production decision log into arc42 chapter 9.

Reads the log table in docs/decisions/index.md and writes its production
rows (every row not marked "in the Development and Delivery log") into
docs/arc42/09-architecture-decisions.md, between the markers
<!-- decision-log:start --> and <!-- decision-log:end -->. Links are
rewritten to point at the Decisions page. The table between the markers
is generated; edit the Decisions page, never chapter 9's table.
"""
import os
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
SOURCE = os.path.join(ROOT, "docs", "decisions", "index.md")
TARGET = os.path.join(ROOT, "docs", "arc42", "09-architecture-decisions.md")
START = "<!-- decision-log:start -->"
END = "<!-- decision-log:end -->"
DELIVERY = "in the Development and Delivery log"
HEADER = "| # | Title | Status | Date |\n|---|---|---|---|"


def read(path):
    with open(path, encoding="utf-8", newline="") as f:
        return f.read()


def production_rows(text):
    """The production rows of the log table, with links made relative to docs/arc42/."""
    rows = [line for line in text.split("\n") if line.startswith("| [ADR-")]
    if not rows:
        sys.exit(f"No log table rows found in {SOURCE}")
    return [
        line.replace("](#adr-", "](../decisions/index.md#adr-", 1)
        for line in rows
        if DELIVERY not in line
    ]


def main():
    target = read(TARGET)
    if target.count(START) != 1 or target.count(END) != 1:
        sys.exit(f"{TARGET} needs exactly one {START} and one {END}")
    before, rest = target.split(START, 1)
    _, after = rest.split(END, 1)
    rows = production_rows(read(SOURCE))
    table = "\n".join([HEADER, *rows])
    updated = f"{before}{START}\n{table}\n{END}{after}"
    if updated != target:
        with open(TARGET, "w", encoding="utf-8", newline="") as f:
            f.write(updated)
    print(f"   - {len(rows)} production decisions")


if __name__ == "__main__":
    main()
