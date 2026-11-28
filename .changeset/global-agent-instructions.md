---
"custom-skills": minor
---

Add global agent instructions for Codex (`global-instructions/AGENTS.md`) and Claude (`global-instructions/CLAUDE.md`), including the Agent in Chief multi-agent protocol. After a one-time install (`bash scripts/install-local-sync.sh`), the local Codex and Claude setup follows `main` automatically: every 5 minutes and at login it pulls the clone and links the skills and both instruction files.

The skills now share the owner's defaults:
- no Python, except calling the vendor's firmware flash tools;
- `francecentral` as the Azure region;
- no GitHub Environments by default;
- iOS builds go to TestFlight only after a release (CI → Release → TestFlight);
- a Codex review on every push to a PR;
- the changeset text is the release note;
- the pre-commit hook delegates to the shared CI test script and fails on any test failure or unit coverage below 80%.
