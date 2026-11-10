# Conflicts between decisions and reopening a phase

## When to check

Every answer from the user, whether a suggested option or free text, is checked against the decisions already made **before it is consolidated**. This applies to all phases, including Pre-Construction and Construction.

The check covers:

- the intent's `AUDIT.md`;
- the documents from earlier phases;
- the other answers in the same round;
- `.neutrino/context/`.

## What to look for

- **Direct contradiction:** the new decision cancels an earlier one. Example: Ideation settled on "only administrators have access", and the answer in FR allows access to any user.
- **Implicit conflict:** the two decisions do not contradict each other in the text, but cannot both hold. Example: an NFR says "no persistence", and an FR requires a change history.
- **Ambiguity:** the answer admits more than one reading, and each reading would lead to a different decision.

Flag only real problems. A new decision that details or narrows an earlier one without contradicting it is not a conflict.

## What to do when you find one

Stop before consolidating and:

1. **Lay out** for the user, in plain language: the new decision, the earlier decision (phase, ID and date of the audit entry) and why they conflict or are ambiguous.
2. **Ask how to proceed**, in the standard question format, with the options:
   - **Revisit the earlier decision:** go back to the phase where it was made.
   - **Adjust the current answer:** keep the earlier decision and answer again.
   - **Move on:** keep both and record the conflict as accepted.
   - **Clarify** (ambiguity only): the user says which reading holds.

   The suggested option is the one you consider most consistent with the decisions as a whole; give the reason in the context.
3. **Record** the conflict and the choice in `AUDIT.md`, with `Ref` pointing to both decisions.

Then:

- **Adjust the current answer:** ask the original question again and consolidate the new answer.
- **Clarify:** consolidate the chosen reading. If it conflicts with another decision, repeat the flow.
- **Move on:** consolidate the answer and add an **Accepted conflict** note to the phase document that links the two IDs and summarizes the conflict. Pre-Construction lists all accepted conflicts along with the plan.
- **Revisit the earlier decision:** follow the reopening procedure below.

During Construction, a conflict discovered while working on a task blocks the task and follows this same flow.

## Reopening procedure

Used when the user chooses to revisit an earlier decision and when they ask for `reopen <phase>` on their own initiative.

1. **State.** Record in `STATE.md` the origin phase (where the intent was, with the round) and the reopened phase. Record the reopening in `AUDIT.md`.
2. **Focused rounds.** Load the reopened phase's skill and run question rounds restricted to the point under review. The user can ask for more rounds there, as in any loop. Round files continue the phase's numbering.
3. **Document.** Update the reopened phase's document. Keep existing IDs; what changed is edited in place, what was removed is marked as removed (the ID is not reused).
4. **Propagation.** Walk through the later phases, from the reopened one to the origin, and identify the IDs affected by the change (`FR-n`, `NFR-n`, `M-n`, `T-n`). For each one, show the proposed correction for the user to approve or ask the necessary questions. Apply the approved corrections to the documents and record each one in the audit.
5. **Plan.** If a plan already exists, reassess the affected tasks:
   - Pending or Blocked task: update the task file and, if dependencies changed, `DEPEND.md`;
   - Done task whose requirement changed: create a new correction task `T-n` that depends on the original. Do not rewrite commits.
   - show the user what changed in the plan and ask for approval before continuing Construction.
6. **Resume.** Clear the reopening from `STATE.md`, commit the corrections with `docs(neutrino): ...`, and resume the origin phase from where it was.
