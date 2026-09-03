# AGUASAN Workshop 2027 - Topic Proposal

This repository holds a topic proposal for the [AGUASAN Workshop Series](https://aguasan.ch/workshops), submitted in response to the Call for Topic Proposals from the AGUASAN Community of Practice and SDC's Water Network RésEAU. The proposed topic, **Publishing WASH Data Together: A Hands-On Retreat for an Open, AI-Ready Sector**, is a five-day working retreat where every participant arrives with a dataset and leaves having published it. The WASH sector is rich in data that is rarely shared, while AI now makes the question of whether that data is open, documented, and reusable urgent. The workshop teaches a small set of durable skills (Git and GitHub, Quarto, and the safe use of AI agents) and turns them into a body of published, FAIR data. It builds directly on the [openwashdata](https://openwashdata.org) community and the ETH Board's Open Research Data projects (2023-2026), carrying that work forward as ongoing sector practice. Proposals are due to roger.schmid@skat.ch by **30 June 2026**.

For the full rationale, vision, and supporting evidence, see the [concept note](concept-note/concept-note.qmd).

## Repository structure

```
.
├── proposal/        The proposal, the week outline draft, and the demand analysis
├── demand/          The figure script, gitignored survey extracts, the website plan
├── slides/          Pitch slides for the topic selection session
├── concept-note/    Standalone 1-page concept note (topic-only, no template)
├── references/      Curated reference material (web sources + index)
├── sources/         Source recordings and transcripts (local only, not tracked)
├── aguasan.Rproj    RStudio project file
└── README.md
```

### `proposal/`

- `README.qmd` - the proposal, filled in from the concept note. This is the version to submit.
- `README.md` - the rendered GFM output, so the proposal displays on GitHub when browsing the `proposal/` folder.
- `week-outline-draft.qmd` - the five-day week outline for the revised option (backdated timeline, participant selection, travel grants, case studies, day-by-day schedule, outputs). Renders in the openwashdata brand as Word and PDF: `quarto render proposal/week-outline-draft.qmd --to owd-docx` and `--to owd-typst`.
- `demand-analysis.qmd` - the demand evidence narrative around the nine figures in `proposal/figures/`; renders in the brand as PDF: `quarto render proposal/demand-analysis.qmd --to owd-typst`.
- `_extensions/` and `_brand/` - the vendored [openwashdata/quarto-owd](https://github.com/openwashdata/quarto-owd) extension and the brand mirror it reads. Refresh with `quarto update openwashdata/quarto-owd` (Word styles) and `quarto use brand openwashdata/brand` (brand file), run inside `proposal/`.
- `extract-tables.py` - writes the outline's timeline and daily tables to `week-schedule.csv` (one sheet: section, time, block) for sharing and review. Run from the repo root after editing the outline: `python3 proposal/extract-tables.py`.
- `week-schedule.csv` - the extracted schedule, regenerated from the outline; do not edit by hand.
- `make-schedule-xlsx.R` - writes the same rows to `week-schedule.xlsx` (one sheet) for sharing. Run after the extractor: `Rscript proposal/make-schedule-xlsx.R`.
- `week-schedule.xlsx` - the schedule as a single-sheet workbook, regenerated with the CSV; do not edit by hand.

### `slides/`

- `index.qmd` - the five-minute pitch deck for the topic selection session: a Quarto reveal.js presentation that pitches the proposal through Alex, a composite practitioner, across eight slides. The charts are computed at render time from a local clone of [openwashdata/washopenresearch](https://github.com/openwashdata/washopenresearch).
- `aguasan-2027-topic-pitch-openwashdata-lschoebitz.pdf` - the PDF export of the deck, linked for download from the final slide.
- `qa.md` - prepared answers for the clarification window after the pitch.
- `custom.scss` - the deck theme on the openwashdata palette; `_extensions/` vendors the roughnotation and fontawesome extensions the deck uses.

The rendered deck (`index.html`) is not tracked; render it with `quarto render index.qmd` from inside `slides/`.

### `concept-note/`

- `concept-note.qmd` - a self-contained one-pager describing the topic, independent of the AGUASAN proposal template. Synthesised from the source recordings and the reference material.

### `references/`

- `references.md` - the index of all reference material.
- One file per source, each recording the source URL and the date captured: openwashdata vision and mission, the data catalogue, the two academy cohorts, the Data Science for openwashdata course, and the ETH ORD Program projects that the work builds on.

### `sources/` (local only, not tracked)

- `recording-24.m4a`, `recording-25.m4a` - voice recordings capturing the proposer's thinking.
- `recording-24.md`, `recording-25.md` - transcripts of those recordings (whisper.cpp, medium.en model; lightly reformatted into paragraphs, wording preserved).

This folder is excluded from git (see `.gitignore`) because the recordings contain candid internal notes. It stays on the proposer's machine and is not part of the published repository.

## How these materials were produced

The transcripts were generated from the recordings, the concept note and proposal draft were written from those transcripts and the reference material, and the references folder was compiled from the sources listed in `references/references.md`. The recordings in `sources/` are the original input; everything else is derived from them. Because the recordings hold candid internal notes, `sources/` is kept local and out of the published repository.
