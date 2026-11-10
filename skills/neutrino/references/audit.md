# Audit

Every decision made during the intent becomes an entry in the intent's `AUDIT.md`. The file is **append-only**: entries are never edited or deleted. A correction becomes a new entry whose `Ref` points to what it corrects.

## What creates an entry

- each answered question (one entry per question);
- the choice of profile and phases;
- the approval or correction of screens, and the approval of the plan;
- each phase advance, early ending or reopening;
- each conflict between decisions that was detected and what the user chose to do;
- each blocked task and each unblocking;
- each decision the agent made on its own during Construction (for example: choosing between two equivalent implementations, naming a new module, discarding an inconsistent working tree).

## Format

Entries are separated by a `---` line, with a blank line before and after. New entries always go at the end of the file.

```markdown
**Timestamp**: [YYYY-MM-DD HH:mm:ss]
**Phase**: [Initiation | Ideation | Functional Requirements | Non-Functional Requirements | Refined Mockup | Pre-Construction | Construction | Closing]
**Actor**: [User | Agent]
**Ref**: [Related ID, if any: Q3, FR-5, T-4]
**Input**: [The user's free text, when they did not pick a suggested option]
**Options**: [Options presented by the agent]
**Choice**: [The choice made]
**Artifact**: [Path of the artifact created or changed]

---
```

## Field rules

- Fields with no content hold `-`.
- **Timestamp:** the machine's local time, taken from the clock (`date "+%Y-%m-%d %H:%M:%S"`).
- **Phase:** the phase in which the decision was made. In a reopening, it is the reopened phase.
- **Actor:** `User` for what the user decided; `Agent` only for what you decided on your own.
- **Ref:** the IDs involved, comma-separated. For a question, the `Qn` and the IDs the answer created or changed (`Q3, FR-5`). For a conflict, both decisions.
- **Input:** the user's text, verbatim, when they answered with free text.
- **Options:** the options presented, summarized on one line (`A. Email and password | B. Social login | X. Other`).
- **Choice:** the choice, with letter and text (`A. Email and password`), or a summary of the decision when there were no options.
- **Artifact:** the path, relative to the intent folder, of the file created or changed. For a question, the round file, which identifies which round the `Qn` belongs to.

Template in `KIT/templates/audit-entry.md`.
