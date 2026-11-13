# Neutrino

Neutrino is a package of skills and agents that takes an idea to committed, tested code in a short cycle. It targets two scenarios: building features in existing projects (brownfield) and building MVPs (greenfield).

You describe the idea. The agent asks questions in rounds, records every decision, builds a task plan, implements each task with tests, and closes with a summary and a coverage matrix. You decide when to move on, and everything is saved to disk so the work can be resumed later.

The full specification is in [docs/specification.md](docs/specification.md). The agent writes the content of each document in the language you use in the conversation; file names, IDs and template field names stay fixed in English.

## How it works

Each piece of work is an **intent**, stored in `.neutrino/intents/NNN-slug/`. An intent goes through up to eight phases:

| # | Phase | What it produces |
| --- | --- | --- |
| 1 | Initiation | The registered intent, its profile and the phases that will run |
| 2 | Ideation | Problem, goal, actors and usage flows (`F-n`) |
| 3 | Functional Requirements | Testable requirements (`FR-n`) with acceptance criteria |
| 4 | Non-Functional Requirements | Technical decisions (`NFR-n`) and the build, lint and test commands |
| 5 | Refined Mockup | HTML and CSS screens (`M-n`) to validate before any code |
| 6 | Pre-Construction | Task plan (`T-n`) ordered by dependency |
| 7 | Construction | Code and tests, one commit per task |
| 8 | Closing | Summary, coverage matrix and pull request |

Phases 2 to 5 are optional: during Initiation the agent proposes which ones make sense for your idea and you confirm.

## Requirements

- **git.** Neutrino creates one branch per intent and makes commits.
- **bash**, to run the installer (macOS, Linux or WSL).
- An agent harness: **Claude Code** (native support) or any agent that reads an `AGENTS.md`.

## Installation

Clone this repository anywhere on your machine:

```bash
git clone https://github.com/viniciosanacleto/neutrino.git ~/tools/neutrino
```

Then install it into the project you are going to work on. Installation is the same for new and existing projects; what changes is what happens in the first intent (see [New project](#new-project-greenfield) and [Existing project](#existing-project-brownfield)).

### Claude Code

```bash
~/tools/neutrino/adapters/claude-code/install.sh /path/to/your/project
```

This creates, inside the project:

```text
.claude/
├── skills/
│   ├── neutrino/              # orchestrator + references/, templates/ and agents/
│   ├── neutrino-init/
│   ├── neutrino-ideation/
│   ├── neutrino-fr/
│   ├── neutrino-nfr/
│   ├── neutrino-mockup/
│   ├── neutrino-plan/
│   ├── neutrino-build/
│   └── neutrino-close/
├── agents/
│   ├── neutrino-codebase-analyzer.md
│   ├── neutrino-planner.md
│   ├── neutrino-task-builder.md
│   └── neutrino-reviewer.md
├── hooks/
│   └── neutrino-out-audit.sh  # records changes made outside Neutrino
└── settings.json              # the hook is registered here
```

Skills, subagents, hooks and settings the project already had in `.claude/` are left untouched: the installer only adds its own hook entries to `settings.json` (this step needs `python3`; without it, the installer prints the block to paste). Use `--no-hooks` to install without the hook (see [Changes outside Neutrino](#changes-outside-neutrino)). Restart Claude Code in the project so it loads the skills.

To make Neutrino available in all your projects, install it into `~/.claude`:

```bash
~/tools/neutrino/adapters/claude-code/install.sh --global
```

Installing into the project has the advantage of versioning Neutrino with the code: anyone who clones the repository gets the skills, at the same version.

### Other harnesses

```bash
~/tools/neutrino/adapters/generic/install.sh /path/to/your/project
```

This copies the skills to `.agents/skills/` and adds a block to the project's `AGENTS.md` that tells the agent where to find them. The rest of `AGENTS.md` is preserved. Use `--dir` to choose another folder:

```bash
~/tools/neutrino/adapters/generic/install.sh /path/to/your/project --dir tools/skills
```

If your harness reads a different instructions file, copy the Neutrino block into it. Details in [adapters/generic/README.md](adapters/generic/README.md).

Without native harness features, Neutrino still works through fallbacks:

| Feature | With support | Without support |
| --- | --- | --- |
| Multiple-choice questions | Used for rounds of up to 3 questions | Questions as text, in the same format |
| Subagents | Each role runs in an isolated context | The main agent performs the role |
| Isolated workspaces | Tasks in the same wave run in parallel | Sequential execution |
| Commands | `/neutrino new` | You ask for "neutrino new ..." |
| Remote repository access | Closing opens the PR | Closing shows the PR text |
| Hooks | Changes outside Neutrino are always recorded | The agent records them by following a rule in `AGENTS.md` |

### Updating and uninstalling

To update, update your Neutrino clone and run the installer again: it replaces the package's skills and subagents.

```bash
git -C ~/tools/neutrino pull
~/tools/neutrino/adapters/claude-code/install.sh /path/to/your/project
```

To uninstall:

```bash
~/tools/neutrino/adapters/claude-code/install.sh --uninstall /path/to/your/project
~/tools/neutrino/adapters/generic/install.sh --uninstall /path/to/your/project
```

Installing, updating and uninstalling never change the project's `.neutrino/` folder, where your intents live.

## New project (greenfield)

1. Create the project folder and initialize git:

   ```bash
   mkdir my-mvp && cd my-mvp
   git init
   git commit --allow-empty -m "chore: initial commit"
   ```

2. Install Neutrino (see [Installation](#installation)).

3. Open the agent in the folder and start the intent:

   ```text
   /neutrino new An app to split expenses among friends, with groups, entries and settling up
   ```

   You can also pass a file: `/neutrino new docs/idea.md`.

What to expect:

- Since there is no code, the intent is classified as **MVP** and goes through every phase.
- The Non-Functional Requirements phase is **full**: you decide stack, database, architecture and test tooling.
- The first task in the plan usually sets up the project (structure, build, lint, test framework).
- The project context (`.neutrino/context/`) is created at Closing, for the next intents.

## Existing project (brownfield)

1. Leave the working tree clean (commit or stash your changes) and check out the branch the feature should start from.

2. Install Neutrino (see [Installation](#installation)).

3. Open the agent at the project root and start the intent:

   ```text
   /neutrino new Add Google sign-in to the login screen, keeping email and password login
   ```

What to expect:

- In the **first intent**, the agent analyzes the code and creates `.neutrino/context/` with three files: `CODEBASE.md` (module map), `STACK.md` (technologies and commands) and `CONVENTIONS.md` (project patterns). It is worth reading and correcting these files: every phase starts from them.
- In later intents, the context is updated only with what changed since the last analyzed commit.
- The intent is classified as a **backend**, **frontend** or **full-stack** feature. Backend features skip the Mockup phase by default.
- The Non-Functional Requirements phase is **reduced**: it starts from the existing stack and conventions and only asks about what the feature changes or adds.
- Mockups reuse the project's CSS and visual patterns.
- New code follows the recorded conventions, and each task runs the whole test suite to catch regressions.

If the project has no lint or tests configured yet, the agent asks how to handle that during the Non-Functional Requirements phase, because Construction depends on those commands to close each task.

## Usage

| Command | What it does |
| --- | --- |
| `/neutrino new <idea or file>` | Starts an intent |
| `/neutrino resume [NNN-slug]` | Resumes an intent where it stopped, even in another session or another harness |
| `/neutrino status [NNN-slug]` | Shows phase, task progress, blocks and pending items, without changing anything |
| `/neutrino reopen <phase>` | Reopens an earlier phase to revisit a decision |

In harnesses without commands, ask in plain text: "neutrino resume".

### Answering questions

- Rounds of **up to 3 questions** are asked in the conversation.
- Rounds with **more than 3 questions** arrive in a file, for example `.neutrino/intents/001-social-login/fr/question-fr-02.md`. Fill in the `Answer:` field of each question with the option letter or free text, and tell the agent when you are done.
- Option **A** is always the one the agent suggests. The **Door Type** tells you whether the decision is hard to reverse (one-way) or easy (two-way).
- At the end of each round, the agent shows what is covered and recommends continuing or moving on. The decision is yours, and you can end a phase at any time: unanswered questions are recorded as open items.

### During Construction

Construction runs without intervention. For each task, the agent implements it, writes the tests (unit tests for backend, e2e for frontend), runs build, lint and the whole suite, goes through a review against the acceptance criteria, and makes a commit:

```text
feat(auth): add Google sign-in

Refs: T-4, FR-5, FR-6
```

If a task fails the gates three times in a row, or depends on something the documents do not define, it is marked as **Blocked** and the agent carries on with the tasks that do not depend on it. It only stops and asks when there is nothing left to do. The agent does not invent requirements.

To find a task's commit: `git log --grep "T-4"`.

### Changes outside Neutrino

You can still ask the agent for a change without starting an intent. When Neutrino is installed and the current branch is not an intent branch (`neutrino/NNN-slug`), the agent ends the turn by:

- appending an entry to `.neutrino/out-audit/out-audit-<YYYY-MM-DD>.md` (one file per day) with what you asked for, what was done and the files changed;
- updating `.neutrino/context/` when the change makes it necessary (a new module, a new dependency, a changed command or convention).

```markdown
**Timestamp**: 2026-11-12 14:32:07
**Branch**: main
**Request**: Add a --verbose flag to the export command
**Changes**: Added the flag to the CLI parser and passed it down to the exporter, which now logs each file written.
**Files**: src/cli/export.ts, src/exporter/index.ts, tests/cli/export.test.ts
**Context**: -
```

In Claude Code this is enforced by a hook that compares the working tree at the start and at the end of each turn. In other harnesses it is a rule in the `AGENTS.md` block. The agent does not commit these files: they stay in the working tree for you to commit along with the change.

## What Neutrino creates in the project

```text
.neutrino/
├── context/                  # project knowledge, shared across intents
│   ├── CODEBASE.md
│   ├── STACK.md
│   └── CONVENTIONS.md
├── out-audit/                # changes made outside an intent, one file per day
│   └── out-audit-2026-11-12.md
└── intents/
    └── 001-social-login/
        ├── STATE.md          # current phase and round; this is where the agent resumes from
        ├── AUDIT.md          # every decision, append-only
        ├── SUMMARY.md        # final summary and coverage matrix
        ├── init/             # the original idea
        ├── ideation/         # IDEATION.md and question rounds
        ├── fr/               # FR.md and question rounds
        ├── nfr/              # NFR.md and question rounds
        ├── refined-mockups/  # HTML screens, index.html and REVIEW.md
        └── plan/             # tasks, DEPEND.md and PROGRESS.md
```

Version the `.neutrino/` folder along with the code. It is what lets an intent be resumed on another machine, by another person or in another harness.

Each intent lives on its own branch, `neutrino/NNN-slug`, created during Initiation. The agent only pushes and opens the pull request if you accept, at Closing.

## Package structure

```text
neutrino/
├── skills/            # one SKILL.md per skill; skills/neutrino/references/ holds the shared rules
├── agents/            # one .md per agent role (prompt, inputs and outputs)
├── templates/         # document templates (question, audit entry, STATE, FR, NFR, task, PROGRESS...)
├── adapters/
│   ├── claude-code/   # subagent frontmatter, out-audit hook and installer
│   └── generic/       # AGENTS.md and installer for harnesses without native support
└── docs/
    └── specification.md
```

| Component | Type | Responsibility |
| --- | --- | --- |
| `neutrino` | Orchestrator skill | Commands `new`, `resume`, `status` and `reopen` |
| `neutrino-init` | Skill | Initiation |
| `neutrino-ideation` | Skill | Ideation loop |
| `neutrino-fr` | Skill | Functional Requirements loop |
| `neutrino-nfr` | Skill | Non-Functional Requirements loop |
| `neutrino-mockup` | Skill | Refined Mockup loop |
| `neutrino-plan` | Skill | Pre-Construction |
| `neutrino-build` | Skill | Construction |
| `neutrino-close` | Skill | Closing |
| `codebase-analyzer` | Agent | Creates and updates `.neutrino/context/` |
| `planner` | Agent | Generates tasks, `DEPEND.md` and `PROGRESS.md` |
| `task-builder` | Agent | Implements one task with its tests and runs the gates |
| `reviewer` | Agent | Checks a task against the acceptance criteria before the commit |

All of the framework's logic lives in `skills/`, `agents/` and `templates/`, as harness-neutral Markdown. The adapters only say how each harness loads it. To change how a phase behaves, edit the corresponding skill and reinstall.
