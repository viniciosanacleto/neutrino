#!/usr/bin/env bash
# Neutrino out-audit hook for Claude Code.
#
#   neutrino-out-audit.sh snapshot   (UserPromptSubmit) records the working tree fingerprint
#   neutrino-out-audit.sh check      (Stop) if the turn changed code outside an intent,
#                                    sends the agent back to record the out-audit entry
#
# Stays silent on intent branches (neutrino/*): there the intent's AUDIT.md is the record.
# Never fails the session: any unexpected condition exits 0.

mode="${1:-}"
input="$(cat 2>/dev/null || true)"

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$project" 2>/dev/null || exit 0
project="$(pwd)"

git_dir="$(git rev-parse --absolute-git-dir 2>/dev/null)" || exit 0

# A global installation only acts in projects that already use Neutrino.
if [ ! -d "$project/.neutrino" ] && [ "$here" != "$project/.claude/hooks" ]; then
  exit 0
fi

branch="$(git symbolic-ref --short -q HEAD 2>/dev/null || true)"
case "$branch" in
  neutrino/*) exit 0 ;;
esac

session="$(printf '%s' "$input" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1 | tr -cd 'A-Za-z0-9_-')"
state_dir="$git_dir/neutrino-out-audit"
state="$state_dir/${session:-default}"

# Tree hash of the working tree, ignoring .neutrino/. Uses a temporary index so the
# real one is never touched; a turn that only commits does not change the result.
fingerprint() {
  local tmp tree
  tmp="$(mktemp "${TMPDIR:-/tmp}/neutrino-index.XXXXXX")" || return 1
  if [ -f "$git_dir/index" ]; then
    cp "$git_dir/index" "$tmp"
  else
    rm -f "$tmp"
  fi
  GIT_INDEX_FILE="$tmp" git add -A -- . ':(exclude).neutrino' >/dev/null 2>&1
  tree="$(GIT_INDEX_FILE="$tmp" git write-tree 2>/dev/null)"
  rm -f "$tmp" "$tmp.lock"
  [ -n "$tree" ] && printf '%s\n' "$tree"
}

save() {
  mkdir -p "$state_dir" 2>/dev/null || exit 0
  printf '%s\n' "$1" > "$state"
}

current="$(fingerprint)" || exit 0

case "$mode" in
  snapshot)
    save "$current"
    find "$state_dir" -type f -mtime +7 -delete 2>/dev/null
    exit 0
    ;;
  check)
    # The turn that writes the out-audit must not trigger another one.
    if printf '%s' "$input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
      save "$current"
      exit 0
    fi
    [ -f "$state" ] || exit 0
    [ "$(cat "$state")" = "$current" ] && exit 0
    save "$current"

    reference="$(dirname "$here")/skills/neutrino/references/out-audit.md"
    {
      echo "Neutrino out-audit: this turn changed files in the project outside a Neutrino intent (branch: ${branch:-detached HEAD})."
      echo "Before finishing, read $reference and follow it:"
      echo "1. append an entry to .neutrino/out-audit/out-audit-$(date +%Y-%m-%d).md describing what the user asked for and what you changed;"
      echo "2. update .neutrino/context/ if the change makes it necessary."
      echo "If you did not change any project file in this turn (for example, the tree changed because of a checkout or a pull), do nothing and finish."
    } >&2
    exit 2
    ;;
esac

exit 0
