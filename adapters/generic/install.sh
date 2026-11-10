#!/usr/bin/env bash
# Installs Neutrino for harnesses without native support (any agent that reads AGENTS.md).
#
#   adapters/generic/install.sh [PROJECT] [--dir DIR]
#   adapters/generic/install.sh --uninstall [PROJECT] [--dir DIR]
#
# PROJECT  project root (default: current directory)
# --dir    skills folder, relative to the project (default: .agents/skills)
#
# Never touches .neutrino/ (the intents' documentation).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common.sh
source "$HERE/../common.sh"

uninstall=0
target="$PWD"
dir=".agents/skills"

while [ $# -gt 0 ]; do
  case "$1" in
    --uninstall) uninstall=1 ;;
    --dir) shift; dir="${1:?--dir needs a value}" ;;
    -h|--help) sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "error: unknown option: $1" >&2; exit 1 ;;
    *) target="$1" ;;
  esac
  shift
done

target="$(resolve_target "$target")"
dir="${dir%/}"
agents_md="$target/AGENTS.md"
start='<!-- neutrino:start -->'
end='<!-- neutrino:end -->'

# Prints AGENTS.md without the Neutrino block.
strip_block() {
  awk -v s="$start" -v e="$end" '
    index($0, s) { skip = 1; next }
    index($0, e) { skip = 0; next }
    !skip { print }
  ' "$agents_md"
}

if [ "$uninstall" -eq 1 ]; then
  remove_skills "$target/$dir"
  if [ -f "$agents_md" ] && grep -qF "$start" "$agents_md"; then
    tmp="$(mktemp)"
    strip_block > "$tmp"
    mv "$tmp" "$agents_md"
  fi
  echo "Neutrino removed from $target/$dir and from AGENTS.md (the .neutrino/ folder was preserved)."
  exit 0
fi

install_skills "$target/$dir"

# AGENTS.md block, idempotent: replaces the previous block, if any.
tmp="$(mktemp)"
if [ -f "$agents_md" ]; then
  strip_block > "$tmp"
  # make sure there is a blank line before the block
  if [ -s "$tmp" ] && [ -n "$(tail -n 1 "$tmp")" ]; then
    echo >> "$tmp"
  fi
fi
{
  echo "$start"
  sed "s|{{SKILLS_DIR}}|$dir|g" "$HERE/AGENTS.md"
  echo "$end"
} >> "$tmp"
mv "$tmp" "$agents_md"

echo "Neutrino installed into $target/$dir"
echo "  skills:    $(skill_names | tr '\n' ' ')"
echo "  AGENTS.md: Neutrino block updated in $agents_md"
echo
echo "In your agent, ask for:  neutrino new <your idea>"
