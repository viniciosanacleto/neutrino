#!/usr/bin/env bash
# Installs Neutrino for Claude Code.
#
#   adapters/claude-code/install.sh [PROJECT]      installs into PROJECT/.claude (default: current directory)
#   adapters/claude-code/install.sh --global       installs into ~/.claude (all projects)
#   adapters/claude-code/install.sh --uninstall [PROJECT | --global]
#   adapters/claude-code/install.sh --no-hooks ... installs without the out-audit hook
#
# The out-audit hook is registered in settings.json (needs python3; without it, the
# installer prints the block to paste).
#
# Never touches .neutrino/ (the intents' documentation).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common.sh
source "$HERE/../common.sh"

uninstall=0
global=0
hooks=1
target="$PWD"

while [ $# -gt 0 ]; do
  case "$1" in
    --global) global=1 ;;
    --uninstall) uninstall=1 ;;
    --no-hooks) hooks=0 ;;
    -h|--help) sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
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

hook_name="neutrino-out-audit.sh"
settings="$dest/settings.json"
if [ "$global" -eq 1 ]; then
  hook_cmd="\"$dest/hooks/$hook_name\""
else
  # shellcheck disable=SC2016
  hook_cmd='"$CLAUDE_PROJECT_DIR"/.claude/hooks/'"$hook_name"
fi

# Adds ($1 = add) or removes ($1 = remove) the out-audit hooks in settings.json,
# keeping everything else in the file. Returns non-zero if the file could not be changed.
update_settings() {
  local action="$1"
  if [ "$action" = remove ] && [ ! -f "$settings" ]; then
    return 0
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    return 1
  fi
  python3 - "$settings" "$action" "$hook_cmd" "$hook_name" <<'PY'
import json, os, sys

path, action, command, marker = sys.argv[1:5]
data = {}
if os.path.exists(path):
    try:
        with open(path) as f:
            data = json.load(f)
    except ValueError as e:
        sys.exit("error: %s is not valid JSON (%s)" % (path, e))
if not isinstance(data, dict) or not isinstance(data.get("hooks", {}), dict):
    sys.exit("error: unexpected structure in %s" % path)

hooks = data.get("hooks", {})

# Drop previous Neutrino entries (idempotent install, and uninstall).
for event in list(hooks):
    groups = hooks[event]
    if not isinstance(groups, list):
        continue
    kept = []
    for group in groups:
        if isinstance(group, dict) and isinstance(group.get("hooks"), list):
            inner = [h for h in group["hooks"]
                     if not (isinstance(h, dict) and marker in str(h.get("command", "")))]
            if len(inner) != len(group["hooks"]):
                if not inner:
                    continue
                group = dict(group, hooks=inner)
        kept.append(group)
    if kept:
        hooks[event] = kept
    else:
        del hooks[event]

if action == "add":
    for event, mode in (("UserPromptSubmit", "snapshot"), ("Stop", "check")):
        hooks.setdefault(event, []).append(
            {"hooks": [{"type": "command", "command": "%s %s" % (command, mode)}]})

if hooks:
    data["hooks"] = hooks
else:
    data.pop("hooks", None)

if not data and action == "remove":
    os.remove(path)
else:
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
PY
}

remove_hook() {
  rm -f "$dest/hooks/$hook_name"
  rmdir "$dest/hooks" 2>/dev/null || true
  update_settings remove
}

if [ "$uninstall" -eq 1 ]; then
  remove_skills "$dest/skills"
  remove_agents
  if ! remove_hook; then
    echo "warning: could not edit $settings; remove the $hook_name entries from it by hand." >&2
  fi
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

# Out-audit hook: records changes made outside an intent (see references/out-audit.md).
hook_manual=0
if [ "$hooks" -eq 1 ]; then
  mkdir -p "$dest/hooks"
  cp "$HERE/hooks/out-audit.sh" "$dest/hooks/$hook_name"
  chmod +x "$dest/hooks/$hook_name"
  if update_settings add; then
    hook_status="out-audit, registered in $settings"
  else
    hook_status="out-audit copied, but NOT registered (see below)"
    hook_manual=1
  fi
else
  hook_status="not installed (--no-hooks)"
  if ! remove_hook; then
    echo "warning: could not edit $settings; remove the $hook_name entries from it by hand." >&2
  fi
fi

echo "Neutrino installed into $dest"
echo "  skills:    $(skill_names | tr '\n' ' ')"
echo "  subagents: $(cd "$dest/agents" && ls neutrino-*.md | tr '\n' ' ')"
echo "  hook:      $hook_status"
if [ "$hook_manual" -eq 1 ]; then
  esc="${hook_cmd//\"/\\\"}"
  echo
  echo "Could not edit $settings automatically (python3 not found, or the file is not valid JSON)."
  echo "Add this to its \"hooks\" key:"
  echo
  echo "  \"UserPromptSubmit\": [{ \"hooks\": [{ \"type\": \"command\", \"command\": \"$esc snapshot\" }] }],"
  echo "  \"Stop\":             [{ \"hooks\": [{ \"type\": \"command\", \"command\": \"$esc check\" }] }]"
fi
echo
echo "Open (or restart) Claude Code in the project and run:  /neutrino new <your idea>"
