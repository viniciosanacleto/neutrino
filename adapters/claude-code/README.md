# Claude Code adapter

| Claude Code feature | How Neutrino uses it |
| --- | --- |
| Skills (`.claude/skills/`) | The package's nine skills. The `neutrino` skill is also the command: `/neutrino new`, `/neutrino resume`, `/neutrino status`, `/neutrino reopen`. |
| Subagents (`.claude/agents/`) | The four roles, with the `neutrino-` prefix so they do not collide with the project's subagents. |
| Hooks (`.claude/settings.json`) | The out-audit hook: when a turn changes project files outside an intent branch, the agent records the change in `.neutrino/out-audit/` and updates `.neutrino/context/` if needed. |
| `AskUserQuestion` | Rounds of up to 3 questions. |
| `git worktree` and `EnterWorktree` | One worktree per intent, in `.neutrino/worktrees/NNN-slug`, when the user chooses that workspace during Initiation. The worktree is created with `git worktree add` and the session moves into it with `EnterWorktree` (`path`). |
| Subagents in isolated worktrees | Optional parallelism during Construction. |
| Authenticated `gh` | Opening the PR at Closing. |

## Installation

```bash
adapters/claude-code/install.sh /path/to/project   # into the project
adapters/claude-code/install.sh --global           # into ~/.claude
adapters/claude-code/install.sh --uninstall /path/to/project
adapters/claude-code/install.sh --no-hooks /path/to/project   # without the out-audit hook
```

The installer copies `skills/` to `.claude/skills/`, embeds `templates/` and `agents/` in the `neutrino` skill, and generates each subagent by joining the frontmatter in `agents/<role>.yml` with the harness-neutral prompt in `agents/<role>.md` at the package root. Each role's prompt exists in one place only.

## Out-audit hook

The installer copies `hooks/out-audit.sh` to `.claude/hooks/neutrino-out-audit.sh` and registers it in `.claude/settings.json` for two events, keeping the hooks and settings the file already had:

| Event | Mode | What it does |
| --- | --- | --- |
| `UserPromptSubmit` | `snapshot` | Records a fingerprint of the working tree (a tree hash that ignores `.neutrino/`), in `.git/neutrino-out-audit/`. |
| `Stop` | `check` | If the fingerprint changed during the turn, blocks the stop once and tells the agent to follow `skills/neutrino/references/out-audit.md`. |

The hook stays silent on intent branches (`neutrino/*`), for work done inside an intent's worktree (the fingerprint ignores `.neutrino/`, where the worktrees live), outside git repositories and, in a `--global` installation, in projects that have no `.neutrino/` folder. It detects changes made by any tool, including shell commands; a turn that only commits does not trigger it. The real git index is never touched.

Editing `settings.json` needs `python3`. Without it, the installer copies the script and prints the block for you to paste. `--uninstall` removes the script and its entries from `settings.json`.

To change a subagent's model or tools, edit the corresponding `.yml` (fields `model` and `tools`) and reinstall.
