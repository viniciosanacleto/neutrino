# Conventional Commits

Every commit made by Neutrino follows the [Conventional Commits](https://www.conventionalcommits.org/) standard:

```text
<type>(<scope>): <short description in the imperative>

<optional body: what changed and why>

Refs: T-4, FR-5, FR-6
```

- **Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `build`, `ci`, `perf`, `style`.
- **Scope:** the affected module or domain (`auth`, `billing`, `user`).
- **`Refs` footer:** mandatory in task commits, with the task and the requirements covered. It is what lets you find each task's commit with `git log --grep "T-4"`.
- **Breaking change:** `!` after the type and a `BREAKING CHANGE:` footer describing the impact.

## Task commits (Construction)

**One task, one commit.** Code, tests and the `PROGRESS.md` update go together, in the same commit.

```text
feat(auth): add Google sign-in

Create the OAuth callback and link the account to the existing user by email.

Refs: T-4, FR-5, FR-6
```

## Documentation commits (outside Construction)

Changes only in `.neutrino/` use `docs(neutrino): ...`, with the `Refs` footer when IDs are involved.

```text
docs(neutrino): consolidate functional requirements for intent 003-social-login

Refs: FR-1, FR-2, FR-3
```

Moments that produce a documentation commit: the end of each phase, plan approval, corrections coming from a reopening, a task block when there is nothing left to build, and Closing.

## Cautions

- Include in the commit only the files of the task or phase. Do not use `git add -A` blindly: check `git status` and leave out unrelated files the user may have modified.
- Do not push, amend existing commits, rebase or force unless the user asks.
- If the repository has commit hooks, they apply. A failing hook is a gate failure, not something to bypass with `--no-verify`.
