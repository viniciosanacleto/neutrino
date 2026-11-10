---
name: neutrino-mockup
description: Neutrino phase 5 (Refined Mockup). Generates M-n screens in static HTML and CSS, navigable through an index.html, so the user can validate the experience before any code, in review rounds recorded in REVIEW.md. Use when the intent's STATE.md points to the Refined Mockup phase or when that phase is reopened.
---

# Refined Mockup (loop)

Turns the flows into visible screens, so the user can validate the experience before any code exists. Fixing a screen in static HTML costs minutes; fixing it after implementation costs a task.

Read first, in `../neutrino/references/`: `core.md`, `loop.md`, `questions.md`, `conflicts.md`, `audit.md`.

## Inputs

- `ideation/IDEATION.md` (`F-n` flows) and `fr/FR.md` (`FR-n` requirements);
- `nfr/NFR.md`, if it exists (UI framework, constraints);
- `.neutrino/context/CONVENTIONS.md` and the existing frontend code;
- `AUDIT.md`.

## Format

Everything in `refined-mockups/`:

| File | Content |
| --- | --- |
| `M-n-slug.html` | One screen per file (`M-1-login.html`). Static HTML and CSS. |
| `styles.css` | Styles shared across the screens. |
| `index.html` | Navigation between the screens, **in flow order**, grouped by `F-n`. |
| `REVIEW.md` | The user's feedback in each round. |

Screen rules:

- **Static.** HTML and CSS, opening straight from disk, with no build and no network dependency. JavaScript only the minimum to navigate or toggle a state, when it is needed to understand the screen.
- **Traceable.** Each screen states the `FR-n` it serves, visibly (a discreet strip in the footer: `M-3 · FR-5, FR-6`) and in `<meta name="neutrino:frs" content="FR-5, FR-6">`.
- **Navigable.** Buttons and links lead to the next screen in the flow. Each screen has a link back to `index.html`.
- **States matter.** States the requirements define (empty, validation error, loading, no permission) are shown: as sections of the same screen or as their own screens when they change the layout a lot.
- **Realistic content.** Use text and data plausible for the domain, including the error messages defined in the requirements. No lorem ipsum.

Screen and index templates in `../neutrino/templates/mockup-screen.html` and `mockup-index.html`.

## Brownfield

Reuse what the project already has: the CSS, the design tokens (colors, typography, spacing) and the visual patterns of the existing components. Read the styles and a few of the project's screens before designing. The mockup must look like part of the product, because the user will judge the final experience by it. Copy the values you need into `styles.css`; do not reference project files through paths that break when opened from disk.

In an MVP, with no defined visual identity, ask in the first round the minimum about visual direction (references, tone, light or dark) before generating the screens.

## Round

The cycle in `loop.md`, with screens in place of questions:

1. Update `STATE.md` with the round.
2. **First round:** propose the list of screens (ID, name, flows and requirements served) and generate all of them. **Later rounds:** adjust only what the feedback asked for.
3. Give the user the path of `index.html` and say what changed in this round.
4. The user approves or points out corrections, screen by screen. Specific questions from you follow `questions.md`.
5. Check for conflicts: a correction request that contradicts an `FR-n` or a flow ("remove the password confirmation field", when FR-3 requires it) follows `conflicts.md` before being applied.
6. Record the feedback in `REVIEW.md` (template in `../neutrino/templates/REVIEW.md`): per round, each screen with its status (Approved or Correction requested) and the feedback text. Record approvals and corrections in `AUDIT.md`.
7. Show coverage and recommend. Every requested correction opens a new round.

An approved screen only changes again if the user asks.

## Coverage summary

- approved and pending screens;
- `F-n` with no screen;
- `FR-n` with an interface that no screen serves;
- error states defined in the requirements that are not shown yet.

Recommend moving on when all screens are approved and every requirement with an interface has a screen.

## Ending

When the user decides to move on, follow "Ending a phase" in `core.md`. Unapproved screens are marked as pending in `REVIEW.md` and become open items. Commit: `docs(neutrino): add mockups for intent NNN-slug`.

## Reopening

If the phase was reopened, adjust only the screens under review, in new rounds in `REVIEW.md`, and follow the reopening procedure in `conflicts.md`: a change to an `M-n` must be propagated to the `T-n` tasks that cite it.
