# Changelog

All notable changes to Neutrino are recorded in this file.

Versions follow the `<major>.<minor>.<fix>` format:

- **major**: changes that break existing installations or intents (renamed skills, a different `.neutrino/` layout, incompatible templates).
- **minor**: new features that keep compatibility (new skills, agents, phases or options).
- **fix**: corrections that do not change behavior on purpose (bugs, typos, documentation).

## [Unreleased]

### Added

- Out-audit: changes made outside an intent (on a branch that is not `neutrino/NNN-slug`) are recorded in `.neutrino/out-audit/out-audit-<YYYY-MM-DD>.md`, and `.neutrino/context/` is updated when the change makes it necessary. Rules in `skills/neutrino/references/out-audit.md`, entry template in `templates/out-audit-entry.md`.
- Claude Code adapter: the installer copies the out-audit hook to `.claude/hooks/neutrino-out-audit.sh` and registers it in `.claude/settings.json` (`UserPromptSubmit` and `Stop`). New `--no-hooks` option; `--uninstall` removes the hook.
- Generic adapter: the `AGENTS.md` block has a rule for recording changes made outside an intent.

## [1.0.0] - 2026-11-10

First release.

### Added

- Eight-phase workflow that takes an idea to committed, tested code: Initiation, Ideation, Functional Requirements, Non-Functional Requirements, Refined Mockup, Pre-Construction, Construction and Closing, as described in [docs/specification.md](docs/specification.md).
- Skills: the `neutrino` orchestrator, with shared references (audit, commits, conflicts, core, loop, questions), and one skill per phase (`neutrino-init`, `neutrino-ideation`, `neutrino-fr`, `neutrino-nfr`, `neutrino-mockup`, `neutrino-plan`, `neutrino-build`, `neutrino-close`).
- Agent roles: `codebase-analyzer`, `planner`, `task-builder` and `reviewer`.
- Templates for intent documents (`INIT`, `IDEATION`, `FR`, `NFR`, `DEPEND`, `PROGRESS`, `REVIEW`, `STATE`, `SUMMARY`, audit entries) and for project context.
- Installers for Claude Code (per project or `--global`) and for harnesses that read an `AGENTS.md`.
- README with installation and usage instructions for new (greenfield) and existing (brownfield) projects.

[Unreleased]: https://github.com/viniciosanacleto/neutrino/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/viniciosanacleto/neutrino/releases/tag/v1.0.0
