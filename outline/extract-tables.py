#!/usr/bin/env python3
"""Extract the timing tables and overview timeline from the week outline to CSV.

Reads outline/week-outline-draft.md, finds each markdown table that sits under a
target heading, and writes one CSV per table to exports/ for Google Sheets review.
Run from the repo root: python3 outline/extract-tables.py
"""
import csv
import re
import sys
from pathlib import Path

SRC = Path("outline/week-outline-draft.md")
OUT = Path("exports")
OUT.mkdir(exist_ok=True)

# Heading text -> output CSV slug. Only these sections are exported.
TARGETS = {
    "Backdated timeline": "timeline-overview",
    "Monday - arrival and foundations": "day-monday",
    "Tuesday": "day-tuesday",
    "Wednesday": "day-wednesday",
    "Thursday": "day-thursday",
    "Friday": "day-friday",
}


def clean_cell(s: str) -> str:
    # unescape markdown escapes (\~ -> ~) and collapse whitespace
    s = s.strip()
    s = re.sub(r"\\(.)", r"\1", s)
    return re.sub(r"\s+", " ", s)


def parse_table(lines, start):
    """Parse a GFM table beginning at index `start` (the header row).
    Returns (rows, next_index). rows[0] is the header."""
    rows = []
    i = start
    while i < len(lines) and lines[i].lstrip().startswith("|"):
        line = lines[i].strip()
        # skip the separator row (|---|---|)
        if re.match(r"^\|[\s:|-]+\|$", line):
            i += 1
            continue
        cells = [clean_cell(c) for c in line.strip("|").split("|")]
        rows.append(cells)
        i += 1
    return rows, i


def main():
    text = SRC.read_text(encoding="utf-8").splitlines()
    written = []
    i = 0
    while i < len(text):
        line = text[i]
        m = re.match(r"^#{2,3}\s+(.*)$", line)
        if m:
            heading = m.group(1).strip()
            slug = TARGETS.get(heading)
            if slug:
                # find the next table (first line starting with '|') before the next heading
                j = i + 1
                while j < len(text) and not text[j].lstrip().startswith("|"):
                    if re.match(r"^#{2,3}\s+", text[j]):
                        j = None
                        break
                    j += 1
                if j is not None and j < len(text):
                    rows, _ = parse_table(text, j)
                    if rows:
                        out = OUT / f"aguasan-{slug}.csv"
                        with out.open("w", newline="", encoding="utf-8") as f:
                            csv.writer(f).writerows(rows)
                        written.append((heading, out.name, len(rows) - 1))
        i += 1

    if not written:
        print("No target tables found. Check headings in", SRC, file=sys.stderr)
        sys.exit(1)
    for heading, name, nrows in written:
        print(f"  {name:34} <- {heading}  ({nrows} rows)")


if __name__ == "__main__":
    main()
