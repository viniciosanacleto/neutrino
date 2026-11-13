---
name: neutrino-init
description: Neutrino phase 1 (Initiation). Creates the intent in .neutrino/intents/NNN-slug, records the original idea, analyzes the existing code when the project is brownfield, classifies the profile and confirms the phases with the user. Use when the neutrino skill starts a new intent or when STATE.md points to the Initiation phase.
---

# Initiation

Turns the user's idea into a registered intent, with a defined profile and phases. Single-pass phase.

Read first: `../neutrino/references/core.md`, `worktrees.md`, `audit.md` and `questions.md` (same folder).

**Input:** free text or the path of a file containing the idea.

## Steps

### 1. Create the intent

1. If the folder is not a git repository, tell the user and offer to run `git init`; Neutrino needs git for commits and resuming.
2. Find the next number, with three digits, as described in "Numbering" in `worktrees.md`: it looks at `.neutrino/intents/`, at the existing worktrees and at the `neutrino/*` branches, because other intents may be in progress on other branches.
3. Create a short kebab-case slug that summarizes the idea (`social-login`).
4. **Ask where the intent will be built**, with the question in "Asking the user" in `worktrees.md`: a new worktree (option A, always the suggested one) or a common branch. Ask every time; do not assume the answer from a previous intent.
5. Create the workspace, from the current branch (the **base branch**):
   - **Worktree:** follow "Creating the worktree", "Working in the worktree" and "Preparing the environment" in `worktrees.md`. Uncommitted changes in the current checkout do not block: they stay there and are not part of the intent. Every step from here on happens inside the worktree.
   - **Branch:** if the working tree has uncommitted changes, say so and ask how to proceed before creating the branch. Create and switch to the branch `neutrino/NNN-slug`.
6. Create `.neutrino/intents/NNN-slug/` and, in it, an empty `AUDIT.md` and the `STATE.md` (template in `../neutrino/templates/STATE.md`) with Initiation as the current phase, the base branch and the workspace. The state is created early so that a session failure in the middle of Initiation can be resumed; profile and phases are filled in at step 5 of this phase.
7. Record the workspace choice in `AUDIT.md` (`Actor: User`), with the options presented, and what was done to prepare the environment.
8. Save to `init/INIT.md` (template in `../neutrino/templates/INIT.md`) the **user's original input, unedited**. If the input was a file, copy the content verbatim and note the path. List the references cited (links, files, tickets).

### 2. Project context

Decide whether the project has code: are there source files beyond documentation and loose configuration?

- **Has code and `.neutrino/context/` does not exist:** invoke the `codebase-analyzer` role in **create** mode.
- **Has code and `.neutrino/context/` exists:** invoke `codebase-analyzer` in **incremental** mode, from the git diff since the last commit recorded in `context/CODEBASE.md`. If there have been no commits since then, skip.
- **No code (greenfield):** skip. The context will be created at Closing.

With subagents, use the subagent (`neutrino-codebase-analyzer` in Claude Code). Without subagents, read `../neutrino/agents/codebase-analyzer.md` and perform the role yourself.

### 3. Summarize the idea

Add to `INIT.md`, below the original input:

- **Idea summary:** what the user wants to build, in one paragraph, without adding requirements they did not ask for.
- **Affected code:** the modules and entry points from `context/CODEBASE.md` that the idea should touch, and why. In greenfield, write "New project".

### 4. Classify the profile and propose the phases

Classify the intent:

| Profile | When |
| --- | --- |
| Backend feature | A change with no new interface: API, job, integration, business rule. |
| Frontend feature | A change with new or altered screens. |
| Full-stack feature | Both together. |
| MVP | A new project, with no existing code. |

Phases proposed by default:

| Phase | Backend | Frontend | Full-stack | MVP |
| --- | --- | --- | --- | --- |
| Ideation | Yes | Yes | Yes | Yes |
| Functional Requirements | Yes | Yes | Yes | Yes |
| Non-Functional Requirements | Reduced | Reduced | Reduced | Full |
| Refined Mockup | No | Yes | Yes | Yes |

Initiation, Pre-Construction, Construction and Closing are mandatory and not up for negotiation. **Reduced** means the phase starts from the stack and conventions already recorded in `.neutrino/context/` and only asks about what the intent changes or adds.

The profile is only the starting point: adjust the proposal to the idea. A trivial backend feature may not need NFR; a rule change on an existing screen may not need a mockup. Give the reason for each adjustment.

Present to the user the profile, the proposed phases and the skipped ones, and ask for confirmation in the standard question format (up to 3 questions, in the conversation). They can include or skip any non-mandatory phase.

### 5. Record and move on

1. Fill in `STATE.md` with the profile, the planned phases (with the NFR mode: Full or Reduced) and the skipped ones.
2. Record in `AUDIT.md` the choice of profile and phases (`Actor: User`), with the options presented and what was adjusted.
3. End the phase as described in "Ending a phase" in `core.md`. Commit: `docs(neutrino): start intent NNN-slug`, including `.neutrino/context/` if it was created or updated.

## Output

`init/INIT.md`, `STATE.md`, `AUDIT.md` and the updated project context.

## Resuming

If `STATE.md` points to Initiation, check what already exists (the workspace recorded in `STATE.md`, and the worktree itself when that is the mode? `INIT.md` with the original input? with the summary? `context/`? profile filled in?) and continue from the first missing step.
