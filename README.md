# AGUASAN Workshop 2027 - Topic Proposal

Working materials for a topic proposal to the [AGUASAN Workshop Series](https://aguasan.ch/workshops), in response to the Call for Topic Proposals from the AGUASAN Community of Practice and SDC's Water Network RésEAU.

The proposed topic is **Data, Digitization, and AI in WASH**: a five-day, hands-on workshop on getting WASH data into an open, reproducible, and AI-ready form, building on the [openwashdata](https://openwashdata.org) community.

Proposals are due to roger.schmid@skat.ch by **30 June 2026**.

## Repository structure

```
.
├── proposal/        The proposal itself and the official call
├── concept-note/    Standalone 1-page concept note (topic-only, no template)
├── references/      Curated reference material (web sources + index)
├── sources/         Source recordings and transcripts (local only, not tracked)
├── aguasan.Rproj    RStudio project file
└── README.md
```

### `proposal/`

- `aguasan-workshop-2027-proposal.qmd` - the filled proposal (working draft).
- `aguasan-workshop-2027-proposal-blank.qmd` - the same template with all entries reset to placeholders, for reuse.
- `aguasan-workshop-2027-call-for-proposals.docx` - the official call document received from the organisers.

### `concept-note/`

- `concept-note.qmd` - a self-contained one-pager describing the topic, independent of the AGUASAN proposal template. Synthesised from the source recordings and the reference material.

### `references/`

- `references.md` - the index of all reference material.
- One file per source, each recording the source URL and the date captured: openwashdata vision and mission, the data catalogue, the two academy cohorts, the Data Science for openwashdata course, and the ETH ORD Program projects that the work builds on.

### `sources/` (local only, not tracked)

- `recording-24.m4a`, `recording-25.m4a` - voice recordings capturing the proposer's thinking.
- `recording-24.md`, `recording-25.md` - transcripts of those recordings (whisper.cpp, medium.en model; lightly reformatted into paragraphs, wording preserved).

This folder is excluded from git (see `.gitignore`) because the recordings contain candid internal notes. It stays on the proposer's machine and is not part of the published repository.

## Rendering the documents

The `.qmd` files are [Quarto](https://quarto.org) documents that render to HTML, Word (`.docx`), and PDF.

- In RStudio or VS Code: open the file and use the **Render** button.
- From the command line: `quarto render proposal/aguasan-workshop-2027-proposal.qmd`

Render artifacts (`.html`, `*_files/`, `.quarto/`) are not tracked; see `.gitignore`.

## How these materials were produced

The transcripts were generated from the recordings, the concept note and proposal draft were written from those transcripts and the reference material, and the references folder was compiled from the sources listed in `references/references.md`. The recordings in `sources/` are the original input; everything else is derived from them. Because the recordings hold candid internal notes, `sources/` is kept local and out of the published repository.
