# Neutrino — core rules

Every Neutrino skill reads this file before acting. It gathers what applies to all phases.

## Principles

- **The user is always in control.** You suggest, the user decides. They can end any round, move on, or reopen a phase at any time.
- **Adaptable depth.** Not every intent goes through every phase. The planned phases are in `STATE.md`.
- **Everything is resumable.** State lives in `.neutrino/` and in git, never in the conversation's memory. Another agent, in another harness, must be able to continue with only what is on disk.
- **Everything is traceable.** Every decision goes to `AUDIT.md`, and every requirement has an ID that links flow, requirement, screen, task, commit and test.
- **Never invent a requirement.** If information is missing, ask. During Construction, block the task and consult the user.

## Where the kit files are

`KIT` is the folder of the `neutrino` skill (the orchestrator). It is a sibling of each phase skill's folder: from a phase `SKILL.md`, it is `../neutrino/`.

| Path | Content |
| --- | --- |
| `KIT/references/` | Shared rules (this file, `loop.md`, `questions.md`, `conflicts.md`, `audit.md`, `commits.md`) and `out-audit.md`, for changes made outside an intent. |
| `KIT/templates/` | Document templates. Copy the structure; do not rename fields. |
| `KIT/agents/` | The prompt for each agent role (`codebase-analyzer`, `planner`, `task-builder`, `reviewer`). |

## Structure of `.neutrino/`

```text
.neutrino/
├── context/                 # project knowledge, shared across intents
│   ├── CODEBASE.md
│   ├── STACK.md
│   └── CONVENTIONS.md
├── out-audit/               # changes made outside an intent, one file per day (see out-audit.md)
│   └── out-audit-YYYY-MM-DD.md
└── intents/
    └── NNN-slug/            # one folder per intent (e.g. 003-social-login)
        ├── STATE.md
        ├── AUDIT.md
        ├── SUMMARY.md
        ├── init/INIT.md
        ├── ideation/        # IDEATION.md, question-ideation-NN.md
        ├── fr/              # FR.md, question-fr-NN.md
        ├── nfr/             # NFR.md, question-nfr-NN.md
        ├── refined-mockups/ # index.html, M-n-slug.html, styles.css, REVIEW.md
        └── plan/            # DEPEND.md, PROGRESS.md, tasks/T-n-slug.md
```

When you invoke an agent role, always pass the path of the `KIT` and of the intent folder: the subagent starts without the conversation's context.

Folders for skipped phases are not created. File names, folder names, IDs and template field names are fixed.

## Phases

| # | Phase | Skill | Folder | Type |
| --- | --- | --- | --- | --- |
| 1 | Initiation | `neutrino-init` | `init/` | Single pass |
| 2 | Ideation | `neutrino-ideation` | `ideation/` | Loop |
| 3 | Functional Requirements | `neutrino-fr` | `fr/` | Loop |
| 4 | Non-Functional Requirements | `neutrino-nfr` | `nfr/` | Loop |
| 5 | Refined Mockup | `neutrino-mockup` | `refined-mockups/` | Loop |
| 6 | Pre-Construction | `neutrino-plan` | `plan/` | Single pass |
| 7 | Construction | `neutrino-build` | `plan/` | Automatic |
| 8 | Closing | `neutrino-close` | (intent root) | Single pass |

Initiation, Pre-Construction, Construction and Closing are mandatory. The others can be skipped by the user.

## Traceable IDs

| Prefix | What it identifies | Created in |
| --- | --- | --- |
| `F-n` | Usage flow | Ideation |
| `FR-n` | Functional requirement | Functional Requirements |
| `NFR-n` | Non-functional requirement | Non-Functional Requirements |
| `M-n` | Mockup screen | Refined Mockup |
| `T-n` | Construction task | Pre-Construction |
| `Qn` | Question in a round | Loop phases |

IDs are unique within the intent and are never reused: a removed item leaves a gap in the numbering. Each artifact cites the IDs it derives from (`FR-5` cites `F-2`; `T-4` cites `FR-5` and `M-3`; the commit cites `T-4, FR-5`; the test cites `FR-5`).

## STATE.md

`STATE.md` is the first thing you read when entering an intent and the first thing you update on every phase or round change, before any other write. If the session dies between the state update and the work, the next agent knows where to resume. Template in `KIT/templates/STATE.md`.

When resuming, check the state against the disk (does the current round file exist? does the phase document already contain the consolidated answers?) and continue from the first step that has not been done.

## Ending a phase

When the user decides to move on, do this in order:

1. Confirm that the phase document is consolidated, with the **Open items** listed.
2. Record the advance in `AUDIT.md` (see `audit.md`).
3. Update `STATE.md`: phase done, next planned phase as current, round `-`.
4. Commit the documentation: `docs(neutrino): <what the phase produced>` (see `commits.md`).
5. Tell the user, in one or two sentences, what the phase produced and which one is next. Load the next phase's skill (through the harness's skill mechanism or by reading its `SKILL.md`) and carry on.

## Git

- Each intent has one branch, `neutrino/NNN-slug`, created during Initiation. The intent's documents and code live on it.
- The `.neutrino/` folder is versioned along with the code.
- Documentation commits outside Construction use `docs(neutrino): ...`. During Construction the rule is "one task, one commit".
- Never push, force, rebase or touch other branches unless the user asks.

## Harness features and fallbacks

No step depends on a harness-exclusive feature. Use the feature when it exists and the fallback when it does not.

| Feature | When the harness has it | When it does not |
| --- | --- | --- |
| Native multiple-choice questions | Rounds of up to 3 questions (in Claude Code, `AskUserQuestion`) | Questions as text in the conversation, same format |
| Subagents | The role runs in an isolated context (in Claude Code, `neutrino-<role>`) | Read `KIT/agents/<role>.md` and perform the role yourself |
| Isolated workspaces | Tasks in the same wave run in parallel | Sequential execution |
| Remote repository access | Closing opens the PR | Closing shows the PR text for the user to paste |
| Hooks | A hook reminds you to record changes made outside an intent | Follow `out-audit.md` yourself after such a change |

## Date and time

Get the time from the machine clock (`date "+%Y-%m-%d %H:%M:%S"`), in the local time zone. Do not estimate it.

## Language

Write the intent's documents in the language the user is using in the conversation. File names, folder names, IDs and template field names are not translated.
