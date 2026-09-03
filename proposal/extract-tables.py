#!/usr/bin/env python3
"""Extract the timing tables and overview timeline from the week outline to CSV.

Reads proposal/week-outline-draft.md, finds each markdown table that sits under a
target heading, and writes ONE combined CSV to exports/ for Google Sheets
review. Each row is tagged with the section it came from.
Run from the repo root: python3 proposal/extract-tables.py
"""
import csv
import re
import sys
from pathlib import Path

SRC = Path("proposal/week-outline-draft.md")
OUT = Path("exports")
OUT.mkdir(exist_ok=True)
COMBINED = OUT / "aguasan-week-schedule.csv"

# Heading text -> (section label, kind). Only these sections are exported,
# in this order.
TARGETS = [
    ("Backdated timeline", "Timeline (overview)"),
    ("Monday - arrival and foundations", "Monday"),
    ("Tuesday", "Tuesday"),
    ("Wednesday", "Wednesday"),
    ("Thursday", "Thursday"),
    ("Friday", "Friday"),
]
TARGET_MAP = dict(TARGETS)
ORDER = {h: i for i, (h, _) in enumerate(TARGETS)}


def clean_cell(s: str) -> str:
    s = s.strip()
    s = re.sub(r"\\(.)", r"\1", s)          # unescape \~ -> ~
    return re.sub(r"\s+", " ", s)


def parse_table(lines, start):
    rows, i = [], start
    while i < len(lines) and lines[i].lstrip().startswith("|"):
        line = lines[i].strip()
        if re.match(r"^\|[\s:|-]+\|$", line):     # separator row
            i += 1
            continue
        cells = [clean_cell(c) for c in line.strip("|").split("|")]
        rows.append(cells)
        i += 1
    return rows, i


def main():
    text = SRC.read_text(encoding="utf-8").splitlines()
    collected = []  # (order, section, when, what)
    i = 0
    while i < len(text):
        m = re.match(r"^#{2,3}\s+(.*)$", text[i])
        if m and m.group(1).strip() in TARGET_MAP:
            heading = m.group(1).strip()
            section = TARGET_MAP[heading]
            j = i + 1
            while j < len(text) and not text[j].lstrip().startswith("|"):
                if re.match(r"^#{2,3}\s+", text[j]):
                    j = None
                    break
                j += 1
            if j is not None and j < len(text):
                rows, _ = parse_table(text, j)
                for r in rows[1:]:  # skip the header row of each table
                    when = r[0] if len(r) > 0 else ""
                    what = r[1] if len(r) > 1 else ""
                    collected.append((ORDER[heading], section, when, what))
        i += 1

    if not collected:
        print("No target tables found. Check headings in", SRC, file=sys.stderr)
        sys.exit(1)

    with COMBINED.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["Section", "When / Time", "What / Block"])
        for _, section, when, what in collected:
            w.writerow([section, when, what])

    print(f"  {COMBINED.name}  ({len(collected)} rows across {len(TARGETS)} sections)")


if __name__ == "__main__":
    main()
