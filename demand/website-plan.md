# AGUASAN 2027 website - structure and content plan

Draft for review. Nothing is built from this yet. Decides pages, what goes on
each, what already exists to reuse, and what is missing.

## Decisions locked

- **Home repo:** `Global-Health-Engineering/aguasan` (where the proposal,
  pitch, outline, and figures already live). Transfer to `aguasan-2027` later
  only if the bid is selected and the workshop becomes ours to run; a GitHub
  repo transfer preserves history and redirects.
- **Audience/framing:** the selection committee (Roger, Sandra, SDC). A
  persuasive bid microsite, not a neutral community resource. Every page
  answers "why pick this proposal".
- **Publish:** built and previewed locally only. No GitHub Pages, no public
  URL, until explicitly approved.
- **Tool:** Quarto website, themed with `openwashdata/brand` so it matches the
  pitch deck (owd-purple #5b195b).

## Site map

| Page | Purpose (committee lens) | Source content |
|------|--------------------------|----------------|
| **Home** (`index.qmd`) | The bid in three sentences + the one ask; links onward | new, short |
| **The topic** (`topic.qmd`) | Working title, relevance, why now, what makes it different | `concept-note/concept-note.qmd` (problem, vision, why-now, what-different) |
| **Who it's for** (`demand.qmd`) | THE evidence of demand - the 7 figures + narrative | `proposal/figures/*` + `demand/make-figures.R`; proposal section 4.1 |
| **The week** (`week.qmd`) | Backdated timeline + day-by-day, retreat rhythm, evenings | `proposal/week-outline-draft.qmd` |
| **Selection** (`selection.qmd`) | How the 30 are chosen; case-study criteria | outline "Participant selection" + "Case studies"; ties to the pre-course survey as the screening instrument |
| **Outcomes** (`outcomes.qmd`) | What the week produces: published packages, DMPs, skills | concept-note "where it leads" + proposal section 5 |
| **The pitch** (`pitch.qmd`) | Embed the delivered reveal.js deck | `slides/index.html` (iframe) + PDF download |
| **Team & custodianship** (`team.qmd`) | Who convenes, engagement commitments | proposal sections 1 and 7 |
| **The proposal** (`proposal.qmd`) | The full submitted template, for the record | `proposal/README.qmd` |

Navigation: top nav in the order above. Home leads with the ask; Who-it's-for
is the centrepiece a committee remembers.

## The demand page (the centrepiece) - figure order and narrative

1. **Growth** (`07-growth.png`) - 421 registrations, two cohorts: demand is real and sustained.
2. **Sector** (`03-sector-by-cohort.png`) - cross-sector in both cohorts: the audience AGUASAN convenes.
3. **Geography** - (to re-add) 45 countries, Global-South-led. NOTE: the ranked-bar geography figure was in the first set; re-add it to the cohort set if wanted.
4. **Skill** (`01-skill-by-cohort.png`) - beginners in both cohorts: this exact training is needed.
5. **Data format** (`02-dataformat-by-cohort.png`) - ~70% in spreadsheets: why data is unpublished by default.
6. **AI adoption shift** (`04-llm-adoption-shift.png`) - 56% to 96%: the audience is adopting AI fast.
7. **AI platforms** (`05-llm-platforms.png`) - ChatGPT dominates, tools are consumer-grade.
8. **AI tasks** (`06-llm-tasks.png`) - they use AI for words, not yet for code and data: the gap the retreat fills.

One paragraph of plain-writing narrative per figure cluster (demand / skills /
AI), each naming the one point the committee should retain. The pre-course
survey is named as the same instrument that would screen and baseline
workshop participants - closing the loop between evidence and method.

## What already exists vs. what is missing

- **Exists, reuse directly:** proposal (full template), concept note, pitch
  deck + PDF, week outline, the 7 demand figures, references (graduate lists,
  data catalogue, VMOST).
- **Thin / placeholder:** case studies (outline says "no confirmed case
  studies yet"); venue (criteria only); exact event week (TBC). Mark these
  honestly as "in preparation" rather than inventing specifics.
- **Missing:** a short home-page framing; per-figure narrative; a team page
  pulling section 1 + 7 of the proposal.

## Pre-build hygiene (before the site goes anywhere public)

- **Remove the audio from the repo.** `sources/recording-24.m4a` (4.2 MB) and
  `recording-25.m4a` (0.6 MB) are tracked pitch-session recordings. They must
  not ship in a public site repo (size + they are session recordings, likely
  with voices/personal content). Recommend: move to the archive store and
  gitignore `sources/*.m4a`, or purge from history if the repo will go public.
  Decide before any Pages publish.
- **`sources/*.md` transcripts** - check they carry no personal data before a
  public build; exclude from the render regardless (they are working notes).
- Confirm the pitch deck embed does not expose anything unintended (it is
  already public-facing content, so low risk).

## Build sequence (once this plan is approved)

1. Branch `feature/website` off the current work.
2. `_quarto.yml` + `_brand.yml` (from openwashdata/brand) + nav shell.
3. Demand page first (figures + narrative) - the highest-value page.
4. Topic, week, selection, outcomes, pitch, team, proposal pages.
5. Local render + preview. No Pages, no publish.
6. Hygiene pass (audio/transcripts) before any public step.
