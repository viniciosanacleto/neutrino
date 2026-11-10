# shellcheck shell=bash
# Functions shared by the installers. Use with `source`.

PKG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Names of the package's skills, one per line.
skill_names() {
  local d
  for d in "$PKG_ROOT"/skills/*/; do
    basename "$d"
  done
}

# Removes from directory $1 only the skills that belong to the package.
remove_skills() {
  local dest="$1" name
  for name in $(skill_names); do
    if [ -d "$dest/$name" ]; then
      rm -rf "${dest:?}/$name"
    fi
  done
}

# Installs the skills into $1 and embeds templates/ and agents/ in the `neutrino` skill (the KIT).
install_skills() {
  local dest="$1"
  mkdir -p "$dest"
  remove_skills "$dest"
  cp -R "$PKG_ROOT/skills/." "$dest/"
  cp -R "$PKG_ROOT/templates" "$dest/neutrino/templates"
  cp -R "$PKG_ROOT/agents" "$dest/neutrino/agents"
}

# Resolves the target project directory and fails if it does not exist.
resolve_target() {
  local target="$1"
  if [ ! -d "$target" ]; then
    echo "error: directory not found: $target" >&2
    exit 1
  fi
  (cd "$target" && pwd)
}
