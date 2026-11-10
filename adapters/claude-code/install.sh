#!/usr/bin/env bash
# Installs Neutrino for Claude Code.
#
#   adapters/claude-code/install.sh [PROJECT]      installs into PROJECT/.claude (default: current directory)
#   adapters/claude-code/install.sh --global       installs into ~/.claude (all projects)
#   adapters/claude-code/install.sh --uninstall [PROJECT | --global]
#
# Never touches .neutrino/ (the intents' documentation).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common.sh
source "$HERE/../common.sh"

uninstall=0
global=0
target="$PWD"

while [ $# -gt 0 ]; do
  case "$1" in
    --global) global=1 ;;
    --uninstall) uninstall=1 ;;
    -h|--help) sed -n '2,8p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "error: unknown option: $1" >&2; exit 1 ;;
    *) target="$1" ;;
  esac
  shift
done

if [ "$global" -eq 1 ]; then
  dest="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
else
  dest="$(resolve_target "$target")/.claude"
fi

remove_agents() {
  local fm
  for fm in "$HERE"/agents/*.yml; do
    rm -f "$dest/agents/neutrino-$(basename "$fm" .yml).md"
  done
}

if [ "$uninstall" -eq 1 ]; then
  remove_skills "$dest/skills"
  remove_agents
  echo "Neutrino removed from $dest (the projects' .neutrino/ folder was preserved)."
  exit 0
fi

install_skills "$dest/skills"

# Subagents: Claude Code frontmatter + the role's harness-neutral prompt.
mkdir -p "$dest/agents"
remove_agents
for fm in "$HERE"/agents/*.yml; do
  role="$(basename "$fm" .yml)"
  {
    echo '---'
    cat "$fm"
    echo '---'
    echo
    cat "$PKG_ROOT/agents/$role.md"
  } > "$dest/agents/neutrino-$role.md"
done

echo "Neutrino installed into $dest"
echo "  skills:    $(skill_names | tr '\n' ' ')"
echo "  subagents: $(cd "$dest/agents" && ls neutrino-*.md | tr '\n' ' ')"
echo
echo "Open (or restart) Claude Code in the project and run:  /neutrino new <your idea>"
