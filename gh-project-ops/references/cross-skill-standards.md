# Cross-Skill Standards

These standards apply to all custom skills.

## 1) Evidence Quality Rubric

Classify every major conclusion:

- `Verified`: directly supported by canonical source content and concrete artifacts.
- `Derived`: inferred from multiple verified signals.
- `Assumption`: not directly supported; requires validation.

Never present assumptions as verified facts.

## 2) Context Budget and Loading Policy

Use progressive disclosure to control context size:

1. Load only `SKILL.md` + source index first.
2. Load only the reference sections required by current scope.
3. Prefer scoped passes over full passes when the request is narrow.
4. If context pressure exists, prioritize: source index -> protocol -> domain references -> examples.

Always state what was intentionally not loaded.

## 3) Anti-Patterns and Handoff Rules

Avoid:

- Broad recommendations without explicit source coverage.
- Control claims without evidence artifacts.
- Overfitting to a preferred technology before requirements are explicit.
- Mixing verified facts with assumptions without labels.

Handoff to a different skill when problem scope primarily belongs to another domain.

## 4) Source Freshness Policy

For high-stakes guidance (security, legal, financial, production operations):

1. Re-check canonical sources for freshness before final recommendations.
2. Record source currency/date when available.
3. Flag stale or ambiguous references and reduce confidence accordingly.

## 5) Minimum Output Additions

Non-trivial responses must include:

1. `Source Coverage Summary`
2. `Evidence Quality Notes`
3. `Assumptions and Residual Risks`

## 6) Owner Defaults

Apply these defaults unless the target repository's accepted guidelines record a different, approved decision. The full operating model is `global-instructions/AGENTS.md` in this catalog.

- **Stack:** Swift/SwiftUI (iOS/iPadOS), .NET 10 backend on Azure Functions, Bicep + GitHub Actions OIDC for Azure, Node.js 22 standard library and POSIX shell for repository automation, ESP-IDF C/C++ for firmware. Microsoft Agent Framework uses the .NET SDK.
- **No Python.** Do not recommend or write Python for application code, agents, hooks, workflows, validation or tooling, and treat Python examples in references as background only. The only exception is C/C++ firmware projects *invoking* the vendor's Python-based toolchain (e.g. `idf.py`, `esptool.py`) to build and flash.
- **Azure region:** `francecentral` by default, supplied through `AZURE_LOCATION` and never hard-coded. Any other region needs an ADR.
- **GitHub Environments:** none by default. Use repository secrets scoped per step and separate OIDC identities per target. Exceptions (e.g. an external customer's repository) are decided by the owner case by case and recorded.
- **Delivery:** TDD, branch + worktree per change, the pre-commit hook calling the same validation entry point as CI and failing on any test failure or unit coverage below 80% per component, a Codex review of every push to a PR, changesets whose text is the release note, and no merge, deploy or pipeline rerun without the owner's explicit permission.
