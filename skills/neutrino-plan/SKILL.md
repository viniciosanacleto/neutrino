---
name: neutrino-plan
description: Neutrino phase 6 (Pre-Construction). Invokes the planner to break the intent's documentation into T-n tasks ordered by dependency, with DEPEND.md and PROGRESS.md, checks coverage of the Must requirements and walks the user through approving the plan. Use when the intent's STATE.md points to the Pre-Construction phase.
---

# Pre-Construction

Turns all of the intent's documentation into a task plan ordered by dependency. Single-pass, mandatory phase. The plan only becomes code after the user approves it.

Read first, in `../neutrino/references/`: `core.md`, `questions.md`, `conflicts.md`, `audit.md`, `commits.md`.

## Steps

### 1. Generate the plan

Update `STATE.md` (Pre-Construction phase) and invoke the `planner` role: with subagents, the subagent (`neutrino-planner` in Claude Code); without subagents, read `../neutrino/agents/planner.md` and perform the role yourself.

Pass the planner the path of the intent folder. It reads all the documents and the project context and produces:

- `plan/tasks/T-n-slug.md`, one file per task;
- `plan/DEPEND.md`, with the mermaid graph and the waves;
- `plan/PROGRESS.md`, with all tasks as Pending;
- a report with the coverage and the doubts it found.

### 2. Check the plan

Before showing it to the user, check it yourself:

- **Coverage:** every `FR-n` with Must priority is in at least one task. A Must with no task is a defect in the plan: send it back to the planner.
- **Size:** each task fits in one commit and can be tested in isolation.
- **Dependencies:** the graph has no cycles, and no task depends on one from a later wave.
- **Tests:** every task declares a test type (unit, e2e or both) consistent with what it touches.
- **Planner's doubts:** an ambiguity or conflict in the documents that the planner pointed out follows `conflicts.md` with the user now, not during Construction.

### 3. Present for approval

Show the user:

1. the task list, by wave: `T-n Summary`, requirements covered and dependencies;
2. the dependency graph (or the path of `DEPEND.md`);
3. coverage: Must `FR-n` covered, and the Should and Could ones left out, if any;
4. **all accepted conflicts** recorded in the phase documents, with the IDs involved;
5. **all open items** the phases left behind, and how the plan handles them (a task that depends on an open item will start out blocked);
6. the gates that will be used (build, lint, tests).

Ask, in the standard format: approve, adjust the plan, or reopen a phase. Adjustments go back to the planner and the presentation repeats. Reopening follows `conflicts.md`.

### 4. Record and move on

1. Record the plan approval in `AUDIT.md` (`Actor: User`, `Artifact: plan/DEPEND.md`).
2. End the phase as described in "Ending a phase" in `core.md`. Commit: `docs(neutrino): add task plan for intent NNN-slug`.
3. Tell the user that Construction runs without intervention, unless something blocks, and load `neutrino-build`.

## Output

`plan/tasks/`, `plan/DEPEND.md` and `plan/PROGRESS.md` initialized with all tasks as Pending.

## Resuming

- `plan/` does not exist or is incomplete: generate it again from step 1.
- Complete plan with no approval entry in the audit: resume at step 2.
