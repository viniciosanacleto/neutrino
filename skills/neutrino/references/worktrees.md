# Workspaces: worktree or branch

Every intent has its own branch, `neutrino/NNN-slug`. Where that branch is checked out is the intent's **workspace**, chosen by the user during Initiation:

| Workspace | What it is | When it fits |
| --- | --- | --- |
| **Worktree** (suggested) | A second directory, `.neutrino/worktrees/NNN-slug`, with the intent branch checked out. The checkout the user started from keeps its branch and its files. | Always, unless the user prefers otherwise. It is what lets several intents be built at the same time, each in its own session. |
| **Branch** | The intent branch is checked out in the current directory, replacing the branch that was there. | The user wants a single directory, or worktrees are not available. Only one intent at a time can use the checkout. |

The choice is recorded in the `Workspace` field of `STATE.md` and in `AUDIT.md`. The branch is the same in both modes, and so is everything that happens on it: documents, commits, the pull request.

## Asking the user

During Initiation, before any git operation, ask in the standard question format (`questions.md`):

```markdown
Q1 - Where should this intent be built?

Context: A worktree is a separate directory for the intent, so the current checkout stays as it is and other intents can run in parallel. A common branch switches the current checkout to the intent branch.
Door Type: Two-way

Options:
A. (Suggested) New worktree in `.neutrino/worktrees/NNN-slug`
B. Common branch in the current directory
X. Other option. Describe.

Answer:
```

Worktree is always option A. If the user picks the worktree and git cannot create it (old git, a bare or shallow setup that refuses it, a file system error), show the error and offer the branch mode; do not switch modes on your own.

## Main checkout

The **main checkout** is the directory of the repository itself, where `.git/` is a folder. Worktrees are always created under it, even when the session is already inside another worktree:

```bash
main="$(cd "$(git rev-parse --git-common-dir)/.." && pwd)"
```

## Numbering

With intents on parallel branches, `.neutrino/intents/` in one checkout does not show the intents that live on the others. The next `NNN` is the highest number found in any of these places, plus one (`001` if there is none):

- the folders in `.neutrino/intents/` of the current checkout;
- the folders in `$main/.neutrino/worktrees/`;
- the branches `neutrino/NNN-slug`, local and remote.

```bash
{
  ls .neutrino/intents "$main/.neutrino/worktrees" 2>/dev/null
  git for-each-ref --format='%(refname)' refs/heads/neutrino refs/remotes | sed -n 's|.*/neutrino/||p'
} | sed -n 's/^\([0-9][0-9][0-9]\)-.*/\1/p' | sort -n | tail -n 1
```

Do not fetch to compute the number. This applies to both workspace modes.

## Creating the worktree

1. **A commit must exist.** In a repository with no commits, offer to create the first one (`git commit --allow-empty -m "chore: initial commit"`) before going on.
2. **Record the base branch:** `git branch --show-current` in the checkout the user started from. It goes in the `Base branch` field of `STATE.md` and is the target of the pull request at Closing. With a detached HEAD, ask the user which branch the pull request should target.
3. **Uncommitted changes do not block.** The worktree starts from the last commit (`HEAD`); changes that are not committed stay where they are and are not part of the intent. If there are any, say so in one sentence and carry on.
4. **Keep the folder out of git** without touching a versioned file. The first time, create `$main/.neutrino/worktrees/.gitignore` containing a single line, `*`. The folder ignores itself, including that file.
5. **Create it:**

   ```bash
   git worktree add -b neutrino/NNN-slug "$main/.neutrino/worktrees/NNN-slug" HEAD
   ```

## Working in the worktree

From here on, the **project root is the worktree root**. The intent folder is `<worktree>/.neutrino/intents/NNN-slug/`, the project context is `<worktree>/.neutrino/context/`, and build, lint, tests and commits run there. Nothing is written to the main checkout.

| The harness | What to do |
| --- | --- |
| Can switch the session's working directory | Switch into the worktree (in Claude Code, `EnterWorktree` with `path` set to the worktree). |
| Cannot | Stay where you are and use absolute paths under the worktree for every file, and `git -C <worktree>` (or `cd <worktree> && ...` in the same command) for every command. |

When you invoke an agent role, pass the worktree root as the project root, along with the paths of the `KIT` and of the intent folder. The subagent must not read or write the main checkout.

The `KIT` can be read from wherever the harness loaded it; it does not have to be the copy inside the worktree.

## Preparing the environment

A new worktree only has the versioned files. What git ignores is missing: installed dependencies, build output, local configuration.

1. **Dependencies:** if `.neutrino/context/STACK.md` exists and has an install command, run it in the worktree. If it does not exist yet (the first intent, an MVP), the installation happens when the stack is known: it is part of the first task or of the gates.
2. **Local configuration:** look in the main checkout for ignored configuration files the project needs to run (`.env`, `.env.local` and the like: `git -C "$main" status --ignored --short`). If there are any, list them and ask the user whether to copy them into the worktree. Never copy them without asking, and never commit them.
3. Record in `AUDIT.md` what was installed and what was copied.

When resuming, check that the environment is still prepared before running the gates (a recreated worktree starts empty again).

## Finding the intents

The list of worktrees comes from git, never from a path saved on disk:

```bash
git worktree list --porcelain
```

Each entry has the path (`worktree <path>`) and the branch (`branch refs/heads/neutrino/NNN-slug`). To list the intents of a project, join:

- the worktrees whose branch is `neutrino/*`: read `<path>/.neutrino/intents/NNN-slug/STATE.md`;
- the intents in `.neutrino/intents/` of the current checkout (the ones already merged, and an intent in branch mode).

The same intent can show up in both; the worktree's copy is the current one.

## Resuming

Read the `Workspace` field of the intent's `STATE.md`.

- **Worktree, and it is in the list:** switch into it (or use its path) and carry on.
- **Worktree, and it is not in the list** (another machine, or it was removed): recreate it from the existing branch and prepare the environment again.

  ```bash
  git worktree add "$main/.neutrino/worktrees/NNN-slug" neutrino/NNN-slug
  ```

  If the branch only exists on the remote, git creates the local one tracking it. If `git worktree list` shows the entry as `prunable` (the directory was deleted by hand), run `git worktree prune` first.
- **Branch:** check that the current branch is the intent's. If it is not, say so and ask before switching; do not switch with uncommitted changes in the working tree.
- **No `Workspace` field:** the intent was created before workspaces existed. Treat it as **Branch**. Do not migrate it unless the user asks.

A branch that is checked out in one worktree cannot be checked out in another. If git refuses for that reason, the intent is already open in the directory git names: use it.

## Removing the worktree

Only at Closing, after the pull request step, and only if the user accepts. Ask; do not remove on your own.

1. Check that the worktree has no uncommitted changes (`git -C <worktree> status --short`). If it has, do not remove: show them and let the user decide what to do with them.
2. If the session is inside the worktree, leave it first (in Claude Code, `ExitWorktree` with `action: "keep"`), going back to the main checkout.
3. Remove it, without `--force`:

   ```bash
   git worktree remove "$main/.neutrino/worktrees/NNN-slug"
   ```

Removing the worktree deletes only that directory. The branch `neutrino/NNN-slug`, its commits and the pull request are untouched, and **no other branch is created**: the pull request is opened from the intent branch itself. Never delete the branch unless the user asks.

If the user declines, tell them the path and the command to remove it later.

## Task workspaces during Construction

The isolated workspaces used for parallel tasks (`neutrino-build`, "Parallelism") are a different thing: they are temporary, one per task, created from the intent branch's current commit and discarded after the task is integrated. They exist in both workspace modes and never replace the intent's worktree.
