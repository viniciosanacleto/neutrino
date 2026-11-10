# Claude Code adapter

| Claude Code feature | How Neutrino uses it |
| --- | --- |
| Skills (`.claude/skills/`) | The package's nine skills. The `neutrino` skill is also the command: `/neutrino new`, `/neutrino resume`, `/neutrino status`, `/neutrino reopen`. |
| Subagents (`.claude/agents/`) | The four roles, with the `neutrino-` prefix so they do not collide with the project's subagents. |
| `AskUserQuestion` | Rounds of up to 3 questions. |
| Subagents in isolated worktrees | Optional parallelism during Construction. |
| Authenticated `gh` | Opening the PR at Closing. |

## Installation

```bash
adapters/claude-code/install.sh /path/to/project   # into the project
adapters/claude-code/install.sh --global           # into ~/.claude
adapters/claude-code/install.sh --uninstall /path/to/project
```

The installer copies `skills/` to `.claude/skills/`, embeds `templates/` and `agents/` in the `neutrino` skill, and generates each subagent by joining the frontmatter in `agents/<role>.yml` with the harness-neutral prompt in `agents/<role>.md` at the package root. Each role's prompt exists in one place only.

To change a subagent's model or tools, edit the corresponding `.yml` (fields `model` and `tools`) and reinstall.
