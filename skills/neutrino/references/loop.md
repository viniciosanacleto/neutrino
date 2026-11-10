# Common rules for loop phases

Ideation, Functional Requirements, Non-Functional Requirements and Refined Mockup follow the same cycle. Each phase's skill defines the focus of the questions and the document format; the cycle is this one.

## Cycle of a round

1. **Read before asking.** Read `INIT.md`, the documents from earlier phases, `AUDIT.md` and `.neutrino/context/`. A question whose answer is already on disk wastes the user's attention.
2. **Update `STATE.md`** with the number of the round about to start.
3. **Generate the round.** Questions in the format of `questions.md` (or screens, in the Mockup phase). At most 8 questions, so the round does not turn into a form.
4. **Wait for the user to answer.**
5. **Check for conflicts** between each answer and earlier decisions (`conflicts.md`). Resolve them with the user before consolidating.
6. **Consolidate** the answers into the phase document, at the end of every round, and record each decision in `AUDIT.md` (`audit.md`). The phase document is always the consolidated, readable version; round files are the raw history.
7. **Show coverage and recommend.** A short summary of what is covered and what is missing (for example: "F-1 to F-3 covered; F-4 has no error cases"), followed by a recommendation: another round or move on, with the reason.
8. **The user decides:** another round, move on to the next phase, or stop. The decision is always theirs, even if coverage is incomplete.

## Round progression

Rounds evolve from the most common cases to the edge cases:

1. main flow;
2. alternative flows;
3. errors and exceptions;
4. limits and concurrency.

Do not jump to edge cases while the main flow has gaps. Recommend moving on when a round's answers stop changing the document in any relevant way.

## Ending in the middle of a round

The user can end the phase at any time, including with unanswered questions. In that case:

- consolidate what was answered;
- record each unanswered question in the **Open items** section of the phase document, with the question ID and the round file;
- record the early ending in `AUDIT.md`.

Open items are not decisions. Later phases cannot treat them as resolved: they either ask again or carry them as open until Pre-Construction, which lists them for the user along with the plan.

## Resuming

If `STATE.md` points to a round in progress:

- the round file exists with answers and the document does not contain them yet: resume at step 5;
- the round file exists without answers: remind the user of the path and wait;
- there is no round file: generate the round again.
