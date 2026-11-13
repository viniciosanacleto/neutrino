## Neutrino

This project uses Neutrino, a framework that takes an idea to committed, tested code through short phases. The state of each piece of work (an intent) lives in `.neutrino/intents/NNN-slug/` and is versioned in git.

When the user asks for `neutrino new <idea>`, `neutrino resume`, `neutrino status` or `neutrino reopen <phase>`, or asks to start or resume an intent:

1. Read `{{SKILLS_DIR}}/neutrino/SKILL.md` and follow its instructions. It says which phase skill to load.
2. Each phase has its own skill. Read the current phase's `SKILL.md` and the references it points to before acting.

| Phase | Skill |
| --- | --- |
| Orchestration (`new`, `resume`, `status`, `reopen`) | `{{SKILLS_DIR}}/neutrino/SKILL.md` |
| 1. Initiation | `{{SKILLS_DIR}}/neutrino-init/SKILL.md` |
| 2. Ideation | `{{SKILLS_DIR}}/neutrino-ideation/SKILL.md` |
| 3. Functional Requirements | `{{SKILLS_DIR}}/neutrino-fr/SKILL.md` |
| 4. Non-Functional Requirements | `{{SKILLS_DIR}}/neutrino-nfr/SKILL.md` |
| 5. Refined Mockup | `{{SKILLS_DIR}}/neutrino-mockup/SKILL.md` |
| 6. Pre-Construction | `{{SKILLS_DIR}}/neutrino-plan/SKILL.md` |
| 7. Construction | `{{SKILLS_DIR}}/neutrino-build/SKILL.md` |
| 8. Closing | `{{SKILLS_DIR}}/neutrino-close/SKILL.md` |

Rules that always apply:

- The `KIT` mentioned in the skills is `{{SKILLS_DIR}}/neutrino/` (with `references/`, `templates/` and `agents/`).
- The agent roles (`codebase-analyzer`, `planner`, `task-builder`, `reviewer`) are in `{{SKILLS_DIR}}/neutrino/agents/`. If you have subagents, run each role in a subagent with that file as its prompt. If you do not, read the file and perform the role yourself.
- Without native multiple-choice questions, ask the questions as text, in the format of `{{SKILLS_DIR}}/neutrino/references/questions.md`.
- Without isolated workspaces, Construction is sequential.
- An intent can be built in its own git worktree, `.neutrino/worktrees/NNN-slug`, so that several intents run at the same time; Initiation asks the user. The rules are in `{{SKILLS_DIR}}/neutrino/references/worktrees.md`. If you cannot change your working directory, use absolute paths under the worktree and `git -C <worktree>`.
- Without remote repository access, Closing shows the PR text for the user to paste.
- If an intent is in progress (in `.neutrino/intents/` or in a worktree under `.neutrino/worktrees/`), read its `STATE.md` before touching the related code.
- When you change project files outside an intent (the files are not on a `neutrino/NNN-slug` branch), before ending the turn follow `{{SKILLS_DIR}}/neutrino/references/out-audit.md`: record the change in `.neutrino/out-audit/out-audit-<YYYY-MM-DD>.md` and update `.neutrino/context/` if the change makes it necessary.
