---
name: neutrino
description: Orchestrates the Neutrino framework, which takes an idea to committed, tested code through short phases (initiation, ideation, requirements, mockup, plan, construction, closing). Use when the user asks for /neutrino, "neutrino new", "neutrino resume", "neutrino status" or "neutrino reopen", wants to start a new intent or feature with Neutrino, or wants to resume an intent in .neutrino/intents/.
---

# Neutrino — orchestrator

You guide an **intent** (the user's intention to build something) through the Neutrino phases. This skill does not do the work of the phases: it reads the state, decides which phase skill to load, and handles the commands.

Before any command, read `references/core.md`. The other references (`loop.md`, `questions.md`, `conflicts.md`, `audit.md`, `commits.md`) are read by the phase skills when they need them.

## Commands

The user can use the command (`/neutrino new ...`) or ask in natural language ("start an intent for social login"). Interpret the intention.

### `new <idea | file path>`

Starts an intent. Load the `neutrino-init` skill, passing the user's input exactly as it came. If the input is empty, ask for the idea in one sentence before loading.

If an intent is already in progress, say which one and ask whether the user really wants to open another in parallel or resume the existing one.

### `resume [NNN-slug]`

Resumes an intent.

1. List the folders in `.neutrino/intents/` and read the `STATE.md` of each one that is not Done.
2. Only one in progress: resume it. More than one and no argument: show the list and ask which.
3. Check that the current branch is the intent's (`neutrino/NNN-slug`). If it is not, say so and ask before switching; do not switch with uncommitted changes in the working tree.
4. Say in two or three lines where the intent stopped (phase, round, next step from `STATE.md`).
5. If `STATE.md` records a reopening in progress, resume the reopening procedure in `references/conflicts.md`. Otherwise, load the current phase's skill (table in `core.md`); each skill knows how to resume midway.

### `status [NNN-slug]`

Read-only. Show, for the requested intent or for all that are not done:

- intent, profile, current phase and round;
- phases done, planned and skipped;
- if there is a plan: task count by status and the blocked ones with the reason (`plan/PROGRESS.md`);
- open items and accepted conflicts, if any;
- the next step.

Do not change any file.

### `reopen <phase>`

Reopens an earlier phase of the intent in progress, on the user's initiative. Valid at any time, including during Construction.

1. Confirm the phase and ask, if the user did not say, what they want to revisit.
2. Follow the **Reopening procedure** in `references/conflicts.md`.

If the requested phase was skipped during Initiation, reopening means running it now: move it from skipped to planned in `STATE.md`, record it in the audit and load its skill.

### No command

- An intent is in progress: show the short status and offer to resume.
- None exists: explain in two lines what Neutrino does and ask for the idea for `new`.

## Orchestration rules

- **`STATE.md` rules.** Do not infer the phase from the conversation; read the file.
- **One phase at a time.** Each phase skill ends by updating the state and loading the next one. If the harness does not load skills by itself, read the next phase's `SKILL.md` in the sibling folder (`../neutrino-<phase>/SKILL.md`).
- **The user can interrupt.** Between phases, they can stop, skip a planned phase or include a skipped one. Record the change in `STATE.md` and in the audit.
- **No `.neutrino/`:** only `new` makes sense. For `resume`, `status` and `reopen`, say there are no intents in this project.
