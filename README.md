# Custom Skills

[![Last Commit](https://img.shields.io/github/last-commit/simonholmes001/custom-skills/main)](https://github.com/simonholmes001/custom-skills/commits/main)
[![Open Issues](https://img.shields.io/github/issues/simonholmes001/custom-skills)](https://github.com/simonholmes001/custom-skills/issues)
[![Open PRs](https://img.shields.io/github/issues-pr/simonholmes001/custom-skills)](https://github.com/simonholmes001/custom-skills/pulls)
[![AI Skills](https://img.shields.io/badge/AI-Skills%20Catalog-0A66C2)](https://github.com/simonholmes001/custom-skills)

This repository provides a reusable catalog of custom AI assistant skills.

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/simonholmes001/custom-skills.git
   cd custom-skills
   ```
2. Link the clone into Codex and Claude, and keep it current automatically (macOS):
   ```bash
   ln -s "$PWD" ~/.codex/skills          # once; Codex reads skills straight from the clone
   bash scripts/install-local-sync.sh    # links AGENTS.md, CLAUDE.md and every skill; installs the hourly LaunchAgent
   ```
   The `local.custom-skills.sync` LaunchAgent runs `scripts/sync-local.sh` at login and hourly. It fast-forwards the clone to `origin/main` (only while it is on `main`), links `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md` to `global-instructions/`, links each skill into `~/.claude/skills/`, and prunes links to removed skills. Existing regular files are backed up, never overwritten. The log is at `~/Library/Logs/custom-skills-sync.log`.
3. Start your assistant runtime and use skills from this catalog.

Do not edit the linked clone directly. Make changes in a worktree **outside** the clone (e.g. `../skills-worktrees/<branch>`) so Codex does not load skills twice, then open a PR.

## Global Agent Instructions

`global-instructions/AGENTS.md` is the owner's engineering operating model for every agent: rules, the skill routing table, TDD, hooks, CI/CD, Codex review, releases, Azure and iOS delivery, and the stack. `global-instructions/CLAUDE.md` imports it for Claude Code and adds Claude-specific notes. Both are linked into place by `scripts/sync-local.sh`. Run `bash scripts/tests/sync-local.test.sh` after changing the sync scripts.

## How To Use Skills

- Browse available skills in `CATALOG.md`.
- Open each skill's `SKILL.md` to understand trigger conditions, workflow, and constraints.
- Invoke skills in your assistant by:
  - naming the skill directly (for example `$api-design`), or
  - using a request that clearly matches a skill's described use case.
- Treat `.system/` content as system-level support skills and assets rather than regular domain skills.

## Assistant Compatibility

- Skills in this repository are designed to be interchangeable across Codex, Claude, and GitHub Copilot agent workflows.
- Trigger phrases and exact behavior can vary by runtime, but the skill structure (`SKILL.md`, `references/`, `scripts/`, `assets/`) remains portable.
- For best results, validate new or changed skills in each assistant environment where you plan to use them.

## Repository Layout

- `CATALOG.md`: high-level skill catalog/index.
- `<skill-name>/SKILL.md`: primary instructions for each skill.
- `<skill-name>/references/`: supporting standards, templates, and source-backed guidance.
- `<skill-name>/scripts/`: helper scripts used by some skills.
- `<skill-name>/assets/`: images or static assets used by some skills.
- `.system/`: system-level skills and support assets/scripts.

## Contributing and Authoring

Contributions are welcome. If you want to add a new skill or improve an existing one:

1. Fork this repository (or create a branch if you already have write access).
2. Make your changes in the relevant skill folder.
3. Keep the main instructions in `SKILL.md`.
4. Add or update `references/` content for non-obvious or source-backed guidance.
5. Keep helper scripts scoped and repeatable.
6. Update `CATALOG.md` if you add, remove, or repurpose a skill.
7. Validate your change in local runs for the assistants you support (Codex, Claude, and/or GitHub Copilot).
8. Open a pull request that includes:
- what changed
- why it changed
- how you validated it
- any behavior changes or migration notes users should know

## Compatibility and Scope

- This repository stores skill content; execution happens when consumed by an assistant runtime (such as Codex, Claude, or GitHub Copilot).
- Skill behavior can vary with runtime updates; validate important changes in your environment.

## License

No root license file is currently defined for this repository. Add a `LICENSE` file before broad redistribution.
