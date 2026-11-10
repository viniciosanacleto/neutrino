---
name: neutrino-fr
description: Neutrino phase 3 (Functional Requirements). Turns the F-n flows into testable FR-n requirements with priority, Given/When/Then acceptance criteria and error cases, through question rounds. Use when the intent's STATE.md points to the Functional Requirements phase or when that phase is reopened.
---

# Functional Requirements (loop)

Turns the flows into testable requirements and stresses each one. The result of this phase is what Construction will implement and what the tests will validate, so each requirement must be verifiable: someone has to be able to tell, by looking at the system, whether it was met or not.

Read first, in `../neutrino/references/`: `core.md`, `loop.md`, `questions.md`, `conflicts.md`, `audit.md`.

## Inputs

- `ideation/IDEATION.md` (`F-n` flows, scope, assumptions, open items);
- `init/INIT.md`, `.neutrino/context/`, `AUDIT.md`.

If Ideation was skipped, there are no `F-n`: derive the requirements from `INIT.md` and leave the source flow as `-`.

## Focus of the questions

For each flow, ask what the code will need to decide:

- **Validations:** required fields, formats, sizes, uniqueness.
- **Permissions:** who can do, see and change what.
- **States:** which exist, which transitions are allowed, what happens on forbidden ones.
- **Business rules:** calculations, conditions, deadlines, exceptions.
- **Error messages:** what the user sees on each failure.
- **Limits:** maximum quantities, pagination, sizes, expiry times.
- **Concurrency:** two actions at the same time on the same data, the same request repeated.

Progression (`loop.md`): main flow, alternatives, errors and exceptions, limits and concurrency. Use the assumptions and open items from Ideation as questions in the first rounds.

Round files: `fr/question-fr-NN.md`.

## Phase document

`fr/FR.md`, following the template `../neutrino/templates/FR.md`. Each `FR-n` has:

- **Description** in the form "The system must...";
- **Source flow** (`F-n`);
- **Priority:** Must, Should or Could;
- **Acceptance criteria** in Given / When / Then;
- **Error cases:** condition and system response.

Writing rules:

- One requirement, one behavior. If the description needs "and also", split it.
- Acceptance criteria use concrete values ("password with fewer than 8 characters"), not adjectives ("weak password").
- Priority is the user's decision. Suggest, but ask when it is not obvious; `Must` means the intent is not delivered without it.
- Do not write a requirement the user neither asked for nor confirmed. A gap becomes a question or an **Open item**, never an assumed requirement.

## Coverage summary

At the end of each round, show per flow:

- which `F-n` have requirements and which do not;
- which `FR-n` still lack acceptance criteria or error cases;
- which focus categories (validations, permissions, states, limits, concurrency) have not been touched yet in each flow;
- open items and accepted conflicts.

Example: "F-1 to F-3 covered; F-4 has no error cases; concurrency not discussed in F-2".

Recommend moving on when every flow has requirements with acceptance criteria and the `Must` ones have error cases.

## Ending

When the user decides to move on, follow "Ending a phase" in `core.md`. Commit: `docs(neutrino): consolidate functional requirements for intent NNN-slug`.

## Reopening

If the phase was reopened, run rounds restricted to the point under review and follow the reopening procedure in `conflicts.md`: a change to an `FR-n` must be propagated to the `M-n` and `T-n` that cite it.
