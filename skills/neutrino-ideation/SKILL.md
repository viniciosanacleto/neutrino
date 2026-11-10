---
name: neutrino-ideation
description: Neutrino phase 2 (Ideation). Runs question rounds about problem, goal, actors, usage flows and scope, and consolidates everything into IDEATION.md with F-n flows. Use when the intent's STATE.md points to the Ideation phase or when that phase is reopened.
---

# Ideation (loop)

Answers the **what** and the **why** of the intent. It does not go into business rules, validation or technology: that belongs to Functional and Non-Functional Requirements. If an answer from the user brings that level of detail, note it under **Assumptions** for the right phase to use, without opening questions about it here.

Read first, in `../neutrino/references/`: `core.md`, `loop.md`, `questions.md`, `conflicts.md`, `audit.md`.

## Inputs

- `init/INIT.md` (original input, summary and affected code);
- `.neutrino/context/`, if it exists;
- `AUDIT.md`.

## Focus of the questions

- **Problem:** what pain exists today, for whom, and how it is worked around.
- **Goal:** what changes once the intent is delivered; how to know it worked.
- **Actors:** who uses it, in what role; external systems that take part.
- **Usage flows:** the step by step of each use, from trigger to outcome.
- **Scope:** what is in and, explicitly, what is out.

Follow the progression in `loop.md`: first the main flow, then the alternatives, then what happens when something goes wrong. In brownfield, anchor the questions in what already exists ("the current sign-up asks for email and password; does social login replace it or live alongside it?").

Round files: `ideation/question-ideation-NN.md`.

## Phase document

`ideation/IDEATION.md`, following the template `../neutrino/templates/IDEATION.md`:

- **Problem** and **Goal**;
- **Actors**;
- **Flows** `F-n`: name, actor, trigger, summarized step by step and outcome;
- **Scope:** in and out;
- **Assumptions:** what is being taken as true;
- **Open items:** unanswered questions;
- **Accepted conflicts**, if any.

Consolidate at the end of every round. Each new flow gets the next `F-n`; a changed flow keeps its ID.

## Coverage summary

At the end of each round, assess and show:

- are the problem and goal clear?
- does each actor have at least one flow?
- does each flow have a trigger, steps and an outcome?
- is the out-of-scope list explicit?
- how many open items?

Recommend moving on when the main flows and the scope are defined. Detailed error cases do not hold Ideation back: they are a matter for Functional Requirements.

## Ending

When the user decides to move on, follow "Ending a phase" in `core.md`. Commit: `docs(neutrino): consolidate ideation for intent NNN-slug`.

## Reopening

If the phase was reopened, run rounds restricted to the point under review and follow the reopening procedure in `conflicts.md`: a change to an `F-n` must be propagated to the `FR-n`, `M-n` and `T-n` that cite it.
