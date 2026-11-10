# Generic adapter

For harnesses that do not load skills natively but read an `AGENTS.md` (or an equivalent project instructions file).

```bash
adapters/generic/install.sh /path/to/project
adapters/generic/install.sh /path/to/project --dir tools/skills   # another folder for the skills
adapters/generic/install.sh --uninstall /path/to/project
```

The installer:

1. copies the skills to `<project>/.agents/skills/` (or the `--dir` folder), with `templates/` and `agents/` embedded in `neutrino/`;
2. adds to the project's `AGENTS.md` a block between `<!-- neutrino:start -->` and `<!-- neutrino:end -->` that points to the skills. The rest of the file is preserved, and reinstalling replaces only the block.

If your harness reads a different instructions file (for example `GEMINI.md` or `.cursor/rules`), copy the block from `AGENTS.md` into it or make that file reference `AGENTS.md`.

If the harness loads skills in the `SKILL.md` format from another folder, point `--dir` at it: the skills are then loaded natively and the `AGENTS.md` block serves as reinforcement.
