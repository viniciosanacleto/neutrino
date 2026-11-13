# Out-audit

Changes made to the project **outside a Neutrino intent** are recorded in `.neutrino/out-audit/`, so the project keeps a trace of what was done without the phases and so `.neutrino/context/` does not go stale.

## When it applies

- You changed project files (code, configuration, tests, documentation) at the user's request, and the current branch is not an intent branch (`neutrino/NNN-slug`).
- On an intent branch it does not apply: the intent's `AUDIT.md` is the record (see `audit.md`).
- If you changed nothing in the turn (you only read, answered, committed, or the tree changed because of a checkout or a pull), write nothing.

In Claude Code a hook reminds you at the end of the turn. In other harnesses, do it yourself before ending the turn.

## Entry

One file per day: `.neutrino/out-audit/out-audit-<YYYY-MM-DD>.md`, with the date from the machine clock (`date +%Y-%m-%d`). If the file does not exist, create it with the title `# Out-audit — YYYY-MM-DD` followed by a blank line.

The file is **append-only**: entries are never edited or deleted, and new entries go at the end. Write one entry per turn that changed something, separated by a `---` line with a blank line before and after.

```markdown
**Timestamp**: [YYYY-MM-DD HH:mm:ss]
**Branch**: [Current branch]
**Request**: [What the user asked for]
**Changes**: [What was done and why, in two or three sentences]
**Files**: [Paths created, changed or removed]
**Context**: [Context files updated and what changed in them, or -]

---
```

## Field rules

- Fields with no content hold `-`.
- **Timestamp:** the machine's local time, taken from the clock (`date "+%Y-%m-%d %H:%M:%S"`).
- **Branch:** `git branch --show-current`; `detached HEAD` when there is none.
- **Request:** the user's request, verbatim when short, summarized when long.
- **Changes:** describe the result, not the steps. Cite decisions you made on your own.
- **Files:** paths relative to the project root, comma-separated. Check them against `git status`; do not list files under `.neutrino/`.
- **Context:** the files in `.neutrino/context/` you updated, with a few words on what changed (`STACK.md: added zod`).

Write the content in the language the user is using. Field names are not translated. Template in `KIT/templates/out-audit-entry.md`.

## Project context

Only when `.neutrino/context/` already exists; do not create it here (it is created by the first intent).

Update it when the change makes one of its files wrong or incomplete:

| File | Update when the change |
| --- | --- |
| `CODEBASE.md` | creates, removes, renames or moves a module or an entry point, or changes how modules relate |
| `STACK.md` | adds, removes or replaces a language, framework, dependency or service, or changes the build, lint or test commands |
| `CONVENTIONS.md` | introduces or replaces a pattern the project follows (naming, folder organization, error handling, tests) |

A bug fix, a text change or new code that follows the existing structure and patterns does not change the context: record `-`.

When you update:

- edit only what the change justifies, following the rules in `KIT/agents/codebase-analyzer.md` (describe what exists, be specific, be short, no secrets);
- update the **Updated at** date of the file, if it has one;
- **do not change the last analyzed commit** in `CODEBASE.md`. The change may not be committed yet, and keeping the hash makes the next incremental analysis review the same diff.

## Git

Do not commit or push on your own. The out-audit file and the context changes stay in the working tree, for the user to commit along with the change.
