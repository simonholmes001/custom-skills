---
"custom-skills": minor
---

Add global agent instructions (`global-instructions/AGENTS.md` for Codex, `global-instructions/CLAUDE.md` for Claude) and a tested local sync (`scripts/sync-local.sh`, `scripts/install-local-sync.sh`) that keeps both runtimes linked to this repository. Align skills with the owner's defaults: no Python in the stack (except vendor firmware flash toolchains), `francecentral` as the default Azure region, no GitHub Environments by default, the Voxa CI → Release → TestFlight chain, and the pre-commit hook delegating to the shared CI validation entry point.
