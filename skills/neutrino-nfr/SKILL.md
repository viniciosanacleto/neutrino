---
name: neutrino-nfr
description: Neutrino phase 4 (Non-Functional Requirements). Defines stack, architecture, persistence, integrations, security, performance, observability, deployment and test tooling in NFR.md with NFR-n requirements and a decision log. In brownfield it runs in reduced mode, starting from .neutrino/context/. Use when the intent's STATE.md points to the Non-Functional Requirements phase or when that phase is reopened.
---

# Non-Functional Requirements (loop)

Defines **how** the system will be built. `NFR.md` is the source of technical decisions for the plan and for Construction, including the build, lint and test commands that become the gates of each task.

Read first, in `../neutrino/references/`: `core.md`, `loop.md`, `questions.md`, `conflicts.md`, `audit.md`.

## Inputs

- `fr/FR.md`, `ideation/IDEATION.md`, `init/INIT.md`;
- `.neutrino/context/STACK.md`, `CONVENTIONS.md` and `CODEBASE.md`, if they exist;
- `AUDIT.md`;
- the phase mode in `STATE.md`: **Full** or **Reduced**.

## Modes

### Full (MVP)

Nothing is decided. Ask about every topic in the focus, starting with the one-way decisions (language and framework, database, architecture, authentication), because the rest depend on them.

### Reduced (brownfield)

Start from what is in `.neutrino/context/` and **only ask about what the intent changes or adds**: a new library, a queue, a table, a specific performance requirement, an integration.

- Do not ask what the context already answers. The existing stack is a decision already made.
- Record in `NFR.md`, in the **Inherited from context** section, what was inherited and from which file, so the plan does not need to reread everything.
- If the intent changes nothing on the technical side, tell the user, propose an `NFR.md` with only the inherited items, and ask whether they want to move on or discuss any point.
- If a functional requirement does not fit the current stack, that is a conflict with the context: follow `conflicts.md`.

## Focus of the questions

- **Stack:** language, framework, main libraries.
- **Architecture:** layers and modules, where the new code goes.
- **Persistence:** database, data model, migrations.
- **Integrations:** external services, contracts, failures and retries.
- **Security:** authentication, authorization, sensitive data, secrets.
- **Performance:** measurable targets (latency, volume, concurrency).
- **Observability:** logs, metrics, tracing, alerts.
- **Deployment:** environments, pipeline, configuration.
- **Test tooling:** unit test framework for backend and e2e framework for frontend, and the commands to run build, lint and tests.

Test tooling and the gate commands are mandatory in this phase: Construction does not close a task without them. In reduced mode, inherit them from `STACK.md`; if the project has no tests or lint configured, ask.

Round files: `nfr/question-nfr-NN.md`.

## Phase document

`nfr/NFR.md`, following the template `../neutrino/templates/NFR.md`:

- **Inherited from context** (reduced mode);
- **Requirements** `NFR-n`: verifiable statements ("The search endpoint must respond within 300 ms at p95 with 10 thousand records"), with the category and the related `FR-n` when there are any;
- **Gates:** build, lint and test commands;
- **Decision log:** for each technical decision, what was decided, alternatives considered, reason and door type;
- **Open items** and **Accepted conflicts**.

An NFR must be verifiable like an FR. "The system must be fast" is not a requirement; it becomes a question.

## Coverage summary

At the end of each round, show:

- which focus topics have a decision, which were inherited and which are missing (in reduced mode, only the ones the intent touches);
- whether the gates are defined;
- whether any `FR-n` requires something that has no technical decision yet (for example, a history FR with no persistence decision);
- open items and accepted conflicts.

Recommend moving on when the one-way decisions are made and the gates are defined.

## Ending

When the user decides to move on, follow "Ending a phase" in `core.md`. Commit: `docs(neutrino): consolidate non-functional requirements for intent NNN-slug`.

## Reopening

If the phase was reopened, run rounds restricted to the point under review and follow the reopening procedure in `conflicts.md`. Changing a one-way decision when tasks are already done usually creates correction tasks: make that cost clear to the user before they confirm.
