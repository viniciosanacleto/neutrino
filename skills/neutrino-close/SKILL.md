---
name: neutrino-close
description: Neutrino phase 8 (Closing). Builds the FR-n, T-n and test coverage matrix, runs the full suite, updates .neutrino/context/, generates SUMMARY.md and offers to open the pull request. Use when the intent's STATE.md points to the Closing phase.
---

# Closing

Confirms that the intent delivered what it promised and leaves the project ready for the next one. Single-pass, mandatory phase.

Read first, in `../neutrino/references/`: `core.md`, `worktrees.md`, `audit.md`, `commits.md`.

## Steps

### 1. Coverage matrix

Update `STATE.md` (Closing phase) and build the matrix `FR-n` → `T-n` → test:

- for each `FR-n` in `FR.md`: the tasks that cover it (from the files in `plan/tasks/`), the commit of each one (`git log --grep "T-n"`) and the tests that cite it (search for `FR-n` in the test files);
- status of each row: **Covered** (task done and a test that cites the requirement), **No test** (task done, no test cites it), **Not delivered** (task blocked or nonexistent).

Point out the gaps clearly, starting with the `Must` ones. Do not fix them on your own: a gap in a Must requirement is shown to the user, who decides between going back to Construction with a new task or accepting it as pending. Record the decision in the audit.

### 2. Full suite

Run build, lint and the whole test suite one last time. If something fails, show the failure to the user and ask: go back to Construction to fix it (recommended) or close with the failure recorded as pending. Do not close saying it passed if it did not.

### 3. Project context

Update `.neutrino/context/` with what the intent changed: stack, conventions, new modules. Invoke the `codebase-analyzer` role in **incremental** mode (or **create**, if the context does not exist yet, as in the first Closing of an MVP): subagent `neutrino-codebase-analyzer` in Claude Code, or `../neutrino/agents/codebase-analyzer.md` performed by you. Record the last analyzed commit in `CODEBASE.md`.

### 4. Summary

Generate `SUMMARY.md` in the intent root (template in `../neutrino/templates/SUMMARY.md`), with:

- **what was delivered**, in product language;
- **the coverage matrix**;
- **the main decisions**, taken from `AUDIT.md` and from the decision log in `NFR.md` (one-way ones first);
- **what is pending or blocked:** blocked tasks with the reason, undelivered requirements, open items, accepted conflicts, accepted gate failures.

### 5. Finish

1. Set `STATE.md` to **Done** and record the closing in `AUDIT.md`.
2. Commit: `docs(neutrino): close intent NNN-slug`, with `SUMMARY.md`, `STATE.md`, `AUDIT.md` and `.neutrino/context/`.

### 6. Pull request

Offer to open the pull request. Only push and open the PR if the user accepts.

- **With remote repository access** (for example, an authenticated `gh`): push the branch `neutrino/NNN-slug` and open the PR against the base branch recorded in `STATE.md` (for an intent with no `Base branch` field, ask the user).
- **Without access:** show the PR title and body for the user to paste.

The pull request always comes from the intent branch itself, in worktree mode too: the worktree is only a directory where that branch is checked out, so no other branch is created for the PR.

Title in Conventional Commits (`feat(auth): social login`). Body: what was delivered, the summarized coverage matrix, the pending items and the path of `SUMMARY.md`.

### 7. Worktree

Only when the intent's workspace is a worktree. Ask the user whether to remove it now, and follow "Removing the worktree" in `worktrees.md`: remove only if they accept and it has no uncommitted changes, never with `--force`. The branch and its commits stay; only the directory goes away. If they decline, or if they may still need it (review fixes on the PR), keep it and tell them the path and the command to remove it later.

## Output

`SUMMARY.md`, updated `.neutrino/context/` and `STATE.md` as Done.

End by telling the user, in a few lines: what was delivered, how many requirements are covered, what is pending, where the summary is and, in worktree mode, whether the worktree was kept or removed.
