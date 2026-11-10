# Neutrino — Framework Specification

Nov 10, 2026 · @Vinicios

## Overview

Neutrino is a package of skills and agents that takes an idea to committed, tested code in a short cycle. The focus is building features in existing projects (brownfield) and building MVPs. Frameworks such as AI-DLC go through many long cycles and suit complete projects better; Neutrino cuts what adds no value in these two scenarios.

Principles:

- **The user is always in control.** The agent suggests, the user decides. Every question round can be ended by the user at any time.
- **Adaptable depth.** Not every intent goes through every phase. The agent proposes which phases make sense and the user confirms.
- **Everything is resumable.** The state of each intent is kept on disk. If the session dies, the next agent continues from where it stopped.
- **Everything is traceable.** Every decision goes to the audit, and every requirement has an ID that links idea, task, commit and test.
- **Portable.** The skills work in Claude Code and in other agent harnesses; harness-specific features are optional, never required.

## Concepts

### Intent

An intent is Neutrino's unit of work: the user's intention to build something. Every time the user starts a new cycle, an intent is created in `.neutrino/intents/NNN-slug/` (for example `003-social-login`). The number is sequential with three digits and the slug is a short kebab-case summary.

### Phases

An intent goes through **phases**. Some are single-pass; others are **loop phases**, in which the agent runs rounds until the user decides to move on. The full map is in the next section.

### Depth profiles

During Initiation, the agent classifies the intent into a profile and proposes which phases to run. The user confirms or adjusts, and the choice goes to the audit. The profiles are:

- **Backend feature:** a change with no new interface (API, job, integration, business rule).
- **Frontend feature:** a change with new or altered screens.
- **Full-stack feature:** both together.
- **MVP:** a new project, with no existing code.

The profile is only the starting point. The user can include or skip any phase, except Initiation, Pre-Construction, Construction and Closing, which are mandatory.

### Traceable IDs

Each artifact gets a prefixed ID, unique within the intent. The IDs reference each other, from flow to test.

| Prefix | What it identifies | Created in |
| --- | --- | --- |
| `F-n` | Usage flow | Ideation |
| `FR-n` | Functional requirement | Functional Requirements |
| `NFR-n` | Non-functional requirement | Non-Functional Requirements |
| `M-n` | Mockup screen | Refined Mockup |
| `T-n` | Construction task | Pre-Construction |
| `Qn` | Question in a round | Loop phases |

Example chain: `F-2` → `FR-5` → `M-3` → `T-4` → commit `feat(auth): ...` with `Refs: T-4, FR-5` → test that cites `FR-5`.

### Intent state

Each intent has a `STATE.md` with the current phase, the current round, the profile, the planned phases and the skipped ones. It is the first thing the agent reads when resuming. Every phase or round change updates this file before anything else.

## Phase map

There are eight phases, in the order below. The table shows which ones the agent proposes by default for each profile; the user can change this during Initiation.

| # | Phase | Type | Backend | Frontend | Full-stack | MVP |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Initiation | Single pass | Yes | Yes | Yes | Yes |
| 2 | Ideation | Loop | Yes | Yes | Yes | Yes |
| 3 | Functional Requirements | Loop | Yes | Yes | Yes | Yes |
| 4 | Non-Functional Requirements | Loop | Reduced | Reduced | Reduced | Full |
| 5 | Refined Mockup | Loop | No | Yes | Yes | Yes |
| 6 | Pre-Construction | Single pass | Yes | Yes | Yes | Yes |
| 7 | Construction | Automatic | Yes | Yes | Yes | Yes |
| 8 | Closing | Single pass | Yes | Yes | Yes | Yes |

**Reduced** means the phase starts from the stack and conventions already recorded in `.neutrino/context/` and only asks about what the intent changes or adds (a new library, a queue, a specific performance requirement).

**Going back a phase.** At any time, including during Construction, the user can reopen an earlier phase, on their own initiative or because the agent detected a conflict between decisions. The agent records the reopening in the audit, updates the phase document and reassesses the affected tasks in the plan before continuing.

## Phases in detail

### Common rules for loop phases

Ideation, Functional Requirements, Non-Functional Requirements and Refined Mockup follow the same cycle:

1. The agent reads the documents from earlier phases and the project context, so it does not repeat questions already answered.
2. The agent generates a round (questions in the format of the "Question format" section, or screens in the case of the Mockup).
3. The user answers.
4. The agent checks whether the answers conflict with earlier decisions (see "Conflicts between decisions"), then consolidates the answers into the phase document **at the end of every round** and records the decisions in the audit.
5. The agent shows a coverage summary (for example: "F-1 to F-3 covered; F-4 has no error cases") and a recommendation: another round or move on.
6. The user decides: another round, move on to the next phase, or end the phase in the middle of a round. The decision is always theirs.

Rounds evolve from the most common cases to the edge cases: main flow, then alternatives, then errors and exceptions, then limits and concurrency. Questions left unanswered when the user ends the phase go into the document as **Open items**.

### Conflicts between decisions

Every answer from the user, whether a suggested option or free text, is checked against the decisions already made before it is consolidated. The check covers `AUDIT.md`, the documents from earlier phases, the other answers in the same round and `.neutrino/context/`. It applies to all phases, including Pre-Construction and Construction.

The agent looks for three kinds of problem:

- **Direct contradiction:** the new decision cancels an earlier one (Ideation settled on "only administrators have access", and the answer in FR allows access to any user).
- **Implicit conflict:** the two decisions do not contradict each other in the text, but cannot both hold (an NFR says "no persistence", and an FR requires a change history).
- **Ambiguity:** the answer admits more than one reading, and each reading would lead to a different decision.

When it finds a problem, the agent stops before consolidating and:

1. Lays out for the user the new decision, the earlier decision (phase, ID and date of the audit entry) and why they conflict or are ambiguous, in plain language.
2. Asks how to proceed, in the standard question format, with the options:
   - **Revisit the earlier decision:** go back to the phase where it was made.
   - **Adjust the current answer:** keep the earlier decision and answer again.
   - **Move on:** keep both and record the conflict as accepted.
   - **Clarify** (ambiguity only): the user says which reading holds.
3. Records the conflict and the choice in the audit, with `Ref` pointing to both decisions.

**If the user decides to revisit:**

1. `STATE.md` records the origin phase (where the intent was) and the reopened phase.
2. The agent goes back to the reopened phase and runs question rounds focused on the point in conflict. The user can ask for more rounds there, as in any loop.
3. The agent updates the reopened phase's document.
4. The agent walks through the later phases, up to the origin, and marks for review the IDs affected by the change (`FR-n`, `NFR-n`, `M-n`, `T-n`). For each one, it asks the necessary questions or shows the proposed correction for the user to approve.
5. The agent resumes the origin phase from where it was.

**If the user decides to move on:** the phase document gets an **Accepted conflict** note that links the two IDs. In Pre-Construction, all accepted conflicts are listed along with the plan, for the user to see before approving. During Construction, a conflict discovered while working on a task blocks the task and follows this same flow.

### 1. Initiation

Turns the user's idea into a registered intent, with a defined profile and phases.

- **Input:** free text or the path of a file containing the idea.
- **Steps:**
  1. Creates the intent folder and saves to `INIT.md` the user's original input, unedited, and the references cited.
  2. If the project has code and `.neutrino/context/` does not exist, invokes the code analysis agent to create it. If it already exists, updates it incrementally from the git diff since the last commit recorded in the context.
  3. Summarizes in `INIT.md` the idea and the parts of the code it should touch.
  4. Classifies the profile, proposes the phases and asks the user for confirmation.
  5. Creates `STATE.md`.
- **Output:** `INIT.md`, `STATE.md` and the updated project context.

### 2. Ideation (loop)

Answers the **what** and the **why**. It does not go into business rule detail; that belongs to Functional Requirements.

- **Focus of the questions:** problem to solve, goal, actors, usage flows, what is in and out of scope.
- **Output:** `IDEATION.md` with problem, goal, actors, `F-n` flows (summarized step by step), scope in and out, assumptions and open items.

### 3. Functional Requirements (loop)

Turns the flows into testable requirements and stresses each one.

- **Focus of the questions:** validations, permissions, states, business rules, error messages, limits, behavior under concurrency.
- **Output:** `FR.md`, where each `FR-n` has:
  - a description in the form "The system must...";
  - source flow (`F-n`);
  - priority (Must, Should, Could);
  - acceptance criteria in Given / When / Then;
  - error cases.

### 4. Non-Functional Requirements (loop)

Defines how the system will be built. In brownfield, it starts from what is already in `.neutrino/context/` and only asks about what changes.

- **Focus of the questions:** stack, architecture, persistence, integrations, security, performance, observability, deployment and test tooling (unit test framework for backend and e2e framework for frontend).
- **Output:** `NFR.md` with the `NFR-n` requirements and a short record of each decision: what was decided, alternatives considered, reason and door type.

### 5. Refined Mockup (loop)

Turns the flows into visible screens to validate the experience before the code.

- **Format:** static HTML and CSS, one file per `M-n` screen, and an `index.html` that navigates between the screens in flow order.
- **Brownfield:** reuses the CSS, the design tokens and the visual patterns the project already has.
- **Round:** the agent generates or adjusts the screens; the user approves or points out corrections; each correction opens a new round. The feedback from each round is kept in `REVIEW.md`.
- **Output:** approved screens, each one stating the `FR-n` it serves.

### 6. Pre-Construction

Turns all the documentation into a task plan ordered by dependency.

- **Steps:**
  1. Reads all of the intent's documents and the project context.
  2. Breaks the work into `T-n` tasks, each small enough to fit in one commit and be tested in isolation.
  3. Generates one file per task in `plan/tasks/`.
  4. Generates `DEPEND.md` with the mermaid graph and the waves of tasks that can run in parallel.
  5. Checks coverage: every `FR-n` with Must priority must be in at least one task.
  6. Presents the plan to the user for approval before starting Construction.
- **Naming:** `T-n Summary in a few words` (for example `T-1 Sign-up`, `T-2 Login Flow`). File: `T-1-sign-up.md`.
- **Content of each task:** goal, requirements covered (`FR-n`, `NFR-n`, `M-n`), dependencies, acceptance criteria, test type (unit, e2e or both) and files likely to be touched.
- **Output:** `plan/tasks/`, `DEPEND.md` and `PROGRESS.md` initialized with all tasks as Pending.

### 7. Construction (automatic)

Implements the tasks, one by one, in topological order, without user intervention unless something blocks.

- **Branch:** one per intent, `neutrino/NNN-slug`.
- **Cycle of each task:**
  1. Marks the task as In progress in `PROGRESS.md`.
  2. Implements the code.
  3. Writes the task's tests: **unit tests for backend, e2e for frontend**; full-stack tasks get both, each on its own side. Each test cites the `FR-n` it validates.
  4. Runs the gates: build, lint and the whole test suite (to catch regressions).
  5. The reviewer agent checks the result against the task's acceptance criteria.
  6. Marks the task as Done in `PROGRESS.md` and makes a commit following Conventional Commits (code, tests and `PROGRESS.md` in the same commit).
- **Blocking:** if the gates fail three times in a row, or if the task depends on something ambiguous in the documents, the agent marks the task as Blocked with the reason, carries on with the tasks that do not depend on it and asks the user when there is nothing left to do. It never invents a requirement.
- **Parallelism:** optional. When the harness supports subagents with isolated workspaces, the tasks in the same wave can run in parallel. Without that support, execution is sequential.
- **Resuming:** reads `STATE.md` and `PROGRESS.md`. A task In progress with no commit has its working tree inspected: the agent continues the work if it is consistent, or discards it and restarts the task.

### 8. Closing

Confirms that the intent delivered what it promised and leaves the project ready for the next one.

- **Steps:**
  1. Builds the coverage matrix `FR-n` → `T-n` → test and points out gaps.
  2. Runs the full suite one last time.
  3. Updates `.neutrino/context/` with what changed (stack, conventions, new modules) and records the last commit.
  4. Generates `SUMMARY.md`.
  5. Offers to open the pull request, if the harness has access to the remote repository.
- **Output:** `SUMMARY.md` with what was delivered, the coverage matrix, the main decisions and what is pending or blocked. `STATE.md` moves to Done.

## Question format

### Channel

- **Up to 3 questions:** asked directly in the conversation, through the harness's native question mechanism when it exists (in Claude Code, multiple-choice questions), or as text when it does not. Questions and answers are saved afterwards to a round file, in the same format below.
- **More than 3 questions:** the agent creates the round file in the phase folder, gives the user the path and waits. The user answers in the file itself and says when done.

File name: `question-<phase>-<NN>.md`, with the phase matching the folder name (`ideation`, `fr`, `nfr`) and a two-digit sequential number. Example: `ideation/question-ideation-02.md`. Recommendation: at most 8 questions per round, so the round does not turn into a form.

### Template for each question

```markdown
Q1 - [Question for the user]

Context: [Why the question matters and what it affects]
Door Type: [One-way | Two-way]

Options:
A. (Suggested) [Option recommended by the agent]
B. [Option B]
C. [Option C]
X. Other option. Describe.

Answer:
```

Template rules:

- Option A is always the one suggested by the agent.
- The `Answer:` field is left empty for the user to fill in with the letter or with free text.
- A question may accept multiple choices; in that case, the wording says so explicitly.

### Door Type

The door type is **informational only**: it helps the user calibrate how much attention to give each decision, but it does not change the flow. The agent asks everything that is relevant and never decides on its own because a decision is two-way.

- **One-way:** hard or expensive to reverse later (data model, database, public API contract, authentication provider).
- **Two-way:** easy to change later (button text, field order, utility library).

## Audit

Every decision made during the intent becomes an entry in the intent's `AUDIT.md`. The file is append-only: entries are never edited or deleted, and a correction becomes a new entry.

**What creates an entry:** each answered question, the choice of profile and phases, the approval of screens and of the plan, each phase advance or reopening, each conflict between decisions that was detected and what the user chose to do, each blocked task and each decision the agent made on its own during Construction.

**Format:** entries separated by a `---` line with a blank line before and after.

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

Fields with no content hold `-`. The timestamp uses the local time zone of the user's machine. The **Actor** and **Ref** fields are new compared to the original version: the first separates what the user decided from what the agent decided on its own, and the second links the entry to the traceable IDs.

## Folder structure

```text
.neutrino/
├── context/
│   ├── CODEBASE.md
│   ├── STACK.md
│   └── CONVENTIONS.md
└── intents/
    └── 001-slug/
        ├── STATE.md
        ├── AUDIT.md
        ├── SUMMARY.md
        ├── init/
        │   └── INIT.md
        ├── ideation/
        │   ├── IDEATION.md
        │   └── question-ideation-01.md
        ├── fr/
        │   ├── FR.md
        │   └── question-fr-01.md
        ├── nfr/
        │   ├── NFR.md
        │   └── question-nfr-01.md
        ├── refined-mockups/
        │   ├── index.html
        │   ├── M-1-login.html
        │   ├── styles.css
        │   └── REVIEW.md
        └── plan/
            ├── DEPEND.md
            ├── PROGRESS.md
            └── tasks/
                └── T-1-sign-up.md
```

Folders for skipped phases are not created.

| Path | Content |
| --- | --- |
| `.neutrino/` | The framework's base folder, hidden. Holds all the documentation and the decisions. |
| `context/` | Project knowledge shared across intents. Created in the first brownfield intent and updated at the Closing of each one. |
| `context/CODEBASE.md` | Code map: modules, responsibilities, entry points and the last analyzed commit. |
| `context/STACK.md` | Languages, frameworks, database, infrastructure and test tooling in use. |
| `context/CONVENTIONS.md` | Code patterns, naming, folder and test organization. |
| `intents/NNN-slug/` | One folder per intent, numbered in sequence with three digits. |
| `STATE.md` | Current phase and round, profile, planned and skipped phases, overall status of the intent. |
| `AUDIT.md` | All of the intent's audit entries. |
| `SUMMARY.md` | Final summary generated at Closing, with the coverage matrix. |
| `init/INIT.md` | The user's original input, unedited, plus the summary of the idea and of the affected code. |
| `ideation/IDEATION.md` | Consolidated Ideation document, with the `F-n` flows. |
| `fr/FR.md` | Functional requirements `FR-n` with acceptance criteria. |
| `nfr/NFR.md` | Non-functional requirements `NFR-n` and the record of technical decisions. |
| `question-<phase>-NN.md` | Question round files, inside the phase folder. |
| `refined-mockups/` | `M-n` screens in HTML and CSS, the navigation `index.html` and `REVIEW.md` with the feedback from each round. |
| `plan/tasks/` | One file per `T-n` task. |
| `plan/DEPEND.md` | Mermaid dependency graph and the waves of parallel tasks. |
| `plan/PROGRESS.md` | Status of each task (Pending, In progress, Done, Blocked), what is in progress now and the reason for each block. |

## Skill and agent architecture

The package separates **what the framework does** (skills, agent roles and templates, in harness-neutral Markdown) from **how each harness runs it** (thin adapters). This keeps the logic in one place and working in Claude Code and in other harnesses.

The rule for dividing: **what talks to the user is a skill**, run in the main conversation. **What is heavy, isolated work is an agent role**, run as a subagent when the harness allows it.

### Components

| Component | Type | Responsibility |
| --- | --- | --- |
| `neutrino` | Orchestrator skill | Commands `new`, `resume`, `status` and `reopen`. Reads `STATE.md` and calls the right phase skill. |
| `neutrino-init` | Skill | Initiation: creates the intent, classifies the profile, confirms the phases. |
| `neutrino-ideation` | Skill | Ideation loop. |
| `neutrino-fr` | Skill | Functional Requirements loop. |
| `neutrino-nfr` | Skill | Non-Functional Requirements loop. |
| `neutrino-mockup` | Skill | Refined Mockup loop. |
| `neutrino-plan` | Skill | Pre-Construction: invokes the planner and walks through the plan approval. |
| `neutrino-build` | Skill | Construction: walks the graph, invokes builder and reviewer per task, makes commits. |
| `neutrino-close` | Skill | Closing: coverage, context, summary and PR. |
| `codebase-analyzer` | Agent | Creates and updates `.neutrino/context/`. |
| `planner` | Agent | Generates tasks, `DEPEND.md` and `PROGRESS.md`. |
| `task-builder` | Agent | Implements one task with its tests and runs the gates. |
| `reviewer` | Agent | Checks a task against the acceptance criteria and the requirements before the commit. |

### Package layout

```text
neutrino/
├── skills/            # one SKILL.md per skill, with references
├── agents/            # one .md per agent role (prompt + inputs + outputs)
├── templates/         # question, audit entry, STATE, FR, NFR, task, PROGRESS
└── adapters/
    ├── claude-code/   # subagents, commands and installation
    └── generic/       # AGENTS.md and instructions for harnesses without native support
```

### Portability

The skills use the `SKILL.md` format (frontmatter with `name` and `description`, Markdown body). For harnesses that do not load skills, the generic adapter provides an `AGENTS.md` that points to them. No skill depends on a harness-exclusive feature; when the feature is missing, the fallback applies:

| Feature | When the harness has it | When it does not |
| --- | --- | --- |
| Native multiple-choice questions | Used for rounds of up to 3 questions | Questions as text in the chat, same format |
| Subagents | Agent roles run in an isolated context | The skill performs the role in the main conversation, reading the same prompt |
| Isolated workspaces | Tasks in a wave run in parallel | Sequential execution |
| Commands (slash commands) | `/neutrino new`, `/neutrino resume` | The user asks by the skill's name |
| Remote repository access | Closing opens the PR | Closing shows the PR text for the user to paste |

The state lives entirely in `.neutrino/` and in git, never in the harness's memory. This makes it possible to start an intent in one harness and finish it in another.

## Assumptions and general rules

### Brownfield

If the project already has code and `.neutrino/context/` does not exist yet, Initiation analyzes and summarizes the code before anything else, in addition to recording the user's input. In later intents, the context is updated incrementally, from the diff since the last recorded commit.

### Conventional Commits

Every commit made by Neutrino follows the [Conventional Commits](https://www.conventionalcommits.org/) standard:

```text
<type>(<scope>): <short description in the imperative>

<optional body: what changed and why>

Refs: T-4, FR-5, FR-6
```

- **Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `build`, `ci`, `perf`, `style`.
- **Scope:** the affected module or domain (`auth`, `billing`, `user`).
- **`Refs` footer:** mandatory, with the task and the requirements covered. It is what lets you find each task's commit with `git log --grep "T-4"`.
- **Breaking change:** `!` after the type and a `BREAKING CHANGE:` footer describing the impact.
- **One task, one commit.** Code, tests and the `PROGRESS.md` update go together. Changes only to Neutrino documentation, outside Construction, use `docs(neutrino): ...`.

### Tests

- Tests are written **in every task**, never left for the end.
- **Backend:** unit tests. **Frontend:** e2e tests. **Full-stack:** both, each on its own side.
- The test frameworks come from `NFR.md` or, in brownfield, from `context/STACK.md`.
- A task is only done with build, lint and the whole suite passing.

### User control

- The user can end any round and move on at any time.
- The user can reopen any earlier phase at any time.
- The agent never invents a requirement: if information is missing during Construction, the task is blocked and the user is consulted.
- The plan only becomes code after the user approves it.

### Versioning

The `.neutrino/` folder is versioned in git along with the code. This keeps the documentation, the audit and the progress in sync with every commit, and lets another person or another harness resume the intent.

### Language

The intent's documents are written in the language the user is using in the conversation. File names, folder names, IDs and template field names stay fixed, as defined in this specification.
