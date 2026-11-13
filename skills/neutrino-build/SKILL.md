---
name: neutrino-build
description: Neutrino phase 7 (Construction). Walks the task graph in topological order and, for each T-n task, invokes the task-builder and the reviewer, runs the build, lint and test gates, updates PROGRESS.md and makes a Conventional Commits commit. Runs without user intervention unless something blocks. Use when the intent's STATE.md points to the Construction phase.
---

# Construction (automatic)

Implements the tasks of the approved plan, one by one, in topological order, without user intervention unless something blocks. You are the conductor: the `task-builder` implements, the `reviewer` checks, and you take care of the state, `PROGRESS.md` and the commits.

Read first, in `../neutrino/references/`: `core.md`, `worktrees.md`, `conflicts.md`, `audit.md`, `commits.md`.

## Before starting

1. Confirm that the plan approval is in `AUDIT.md`. Without it, go back to Pre-Construction.
2. Confirm that you are in the intent's workspace (`Workspace` in `STATE.md`): in worktree mode, the intent's worktree, with the environment prepared (`worktrees.md`); in both modes, on the branch `neutrino/NNN-slug`. Every command of this phase, yours and the subagents', runs there.
3. Update `STATE.md` (Construction phase).
4. Read `plan/DEPEND.md` and `plan/PROGRESS.md` and identify the gates (build, lint and test commands, at the top of `PROGRESS.md`).
5. If a task is In progress, follow **Resuming** before picking a new one.

## Choosing the next task

The next task is the lowest-numbered one that is Pending and whose dependencies are all Done. Tasks that depend, directly or indirectly, on a Blocked one are not eligible.

## Cycle of each task

1. **Mark** the task as In progress in `PROGRESS.md` and fill in **In progress now**.
2. **Implement.** Invoke the `task-builder` role with the path of the project root (the intent's workspace), of the task file and of the intent folder. With subagents, use the subagent (`neutrino-task-builder` in Claude Code); without subagents, read `../neutrino/agents/task-builder.md` and perform the role yourself. The builder implements the code, writes the tests and runs the gates. It does not commit.
3. **Task tests:** unit tests for backend, e2e for frontend; full-stack tasks get both, each on its own side. Each test cites the `FR-n` it validates. Tests are written in every task, never left for the end.
4. **Gates:** build, lint and the **whole test suite**, to catch regressions. Check in the builder's report that all three passed; when in doubt, run them yourself.
5. **Review.** Invoke the `reviewer` role (`neutrino-reviewer`, or `../neutrino/agents/reviewer.md`) with the task and the changes in the working tree. It checks the result against the acceptance criteria and the requirements.
   - **Approved:** carry on.
   - **Rejected:** send the findings back to the builder and repeat from step 2. This counts as one attempt.
6. **Finish.** Mark the task as Done in `PROGRESS.md`, clear **In progress now** and make **one commit** with code, tests and `PROGRESS.md` together, as described in `commits.md`, with the footer `Refs: T-n, FR-n...`.

After each commit, choose the next task. Do not stop to ask for confirmation between tasks: the plan approval has already been given.

## Decisions during Construction

- An implementation detail that does not change behavior defined in the documents (function name, internal structure, a choice between two equivalent forms): decide following `CONVENTIONS.md` and record it in `AUDIT.md` with `Actor: Agent`.
- Anything that changes what the user will see or what a requirement says: **do not decide**. It is an ambiguity or a conflict, and it blocks the task.
- **Never invent a requirement.** If the document does not say, the answer belongs to the user.

## Blocking

Block the task when:

- the gates or the review fail **three times in a row** on the same task;
- the task depends on something ambiguous, missing or open in the documents;
- a conflict between decisions shows up during implementation (`conflicts.md`).

When blocking:

1. Leave the working tree clean: discard the task's uncommitted changes (or keep them in a stash named `neutrino T-n` if there is work worth reusing, and note that in the reason).
2. Mark the task as Blocked in `PROGRESS.md`, with the reason: what failed, what was tried and what you need from the user.
3. Record the block in `AUDIT.md`.
4. **Carry on with the tasks that do not depend on it.**

When there is no eligible task left and there are blocked ones, commit `docs(neutrino): record block on T-n` and ask the user, one blocked task at a time, showing the reason and the options (standard question format). Depending on the answer:

- missing information: record it in the audit, update the corresponding phase document and the task file, set the task back to Pending and continue;
- conflict or requirement change: follow `conflicts.md`, including the reopening procedure;
- the user gives up on the task: keep it Blocked, with the reason updated; it will show up as pending at Closing.

## Parallelism (optional)

When the harness supports subagents with isolated workspaces (for example, git worktrees), the eligible tasks in the same wave of `DEPEND.md` can be implemented in parallel:

1. Invoke one `task-builder` per task, each in its own temporary workspace, created from the intent branch's current commit. These task workspaces are separate from the intent's worktree and are discarded after integration.
2. Integrate the results into the intent branch **one at a time**, in `T-n` order: apply the changes, run the full gates again, go through the `reviewer`, update `PROGRESS.md` and make the task's commit.
3. If integrating a task conflicts with one already integrated, discard its result and redo the task sequentially.

The end result is the same as sequential execution: one commit per task, with gates passing on each. Without isolated workspaces, execution is sequential.

## Resuming

Read `STATE.md` and `PROGRESS.md`. For a task In progress:

- **A commit for it already exists** (`git log --grep "T-n"`): `PROGRESS.md` is out of date. Fix the status and carry on.
- **No commit and the working tree has changes:** inspect them against the task file. If the work is consistent (it compiles, it heads in the task's direction), continue from it, passing the builder what already exists. If it is inconsistent, discard it and restart the task. Record the decision in `AUDIT.md` (`Actor: Agent`).
- **No commit and the working tree is clean:** restart the task.

## End of the phase

The phase ends when all tasks are Done, or when the user decides to proceed to Closing with blocked tasks. Follow "Ending a phase" in `core.md` (the documentation commit is only needed if there is an uncommitted change in `.neutrino/`) and load `neutrino-close`.
