# Changelog

All notable changes to Neutrino are recorded in this file.

Versions follow the `<major>.<minor>.<fix>` format:

- **major**: changes that break existing installations or intents (renamed skills, a different `.neutrino/` layout, incompatible templates).
- **minor**: new features that keep compatibility (new skills, agents, phases or options).
- **fix**: corrections that do not change behavior on purpose (bugs, typos, documentation).

## [1.2.0] - 2026-11-13

### Added

- Workspaces: during Initiation the agent asks where the intent will be built, in a new git worktree (`.neutrino/worktrees/NNN-slug`, the suggested option) or as a common branch in the current directory. With worktrees, several intents can be built at the same time, one session each. Rules in `skills/neutrino/references/worktrees.md`.
- `STATE.md` has two new fields, `Base branch` and `Workspace`; `SUMMARY.md` has `Base branch`. Intents without them keep working and are treated as branch mode.
- `resume` and `status` find intents in their worktrees, and `resume` recreates a worktree that no longer exists.
- Closing opens the pull request against the recorded base branch and, in worktree mode, asks whether to remove the worktree (the branch is kept).

### Changed

- The next intent number also takes into account the existing worktrees and the `neutrino/*` branches, so parallel intents do not get the same number.
- `new` no longer asks for confirmation when another intent is in progress.
- Agent roles receive the project root from the caller, which is the intent's worktree in worktree mode.

## [1.1.0] - 2026-11-12

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

[1.2.0]: https://github.com/viniciosanacleto/neutrino/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/viniciosanacleto/neutrino/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/viniciosanacleto/neutrino/releases/tag/v1.0.0
