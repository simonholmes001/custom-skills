# Engineering Operating Model — Global Agent Instructions

These instructions apply to every repository Simon works in, for every coding agent (Codex, Claude, Copilot). A repository's own `AGENTS.md` / `CLAUDE.md`, `docs/engineering-guidelines.md`, `docs/REPOSITORY_GUARDRAILS.md` or README **refines** these rules for that repo; where they conflict, the repo-local rule wins, and you say so.

This file is maintained in `simonholmes001/custom-skills` (`global-instructions/AGENTS.md`) and linked into `~/.codex/AGENTS.md` by `scripts/sync-local.sh`. Change it there through a PR, never in place.

Reference implementations (read these before inventing anything). Copy the patterns these rules describe, not deviations that predate them:

| Concern | Reference |
|---|---|
| New repo / template overlays / drift | `simonholmes001/project-template` (`scripts/new-project.sh`, `apply-template.sh`, `drift-check.sh`, `update-project.sh`) |
| Mature app: .NET backend + iOS + Azure, hooks, CI, security, release gate, **TestFlight trigger** | `simonholmes001/voxa` |
| Azure Function + Fastlane match signing | `simonholmes001/deja-groove` (its push-to-main TestFlight trigger is legacy; use Voxa's) |
| Hook → single shared validation command (the standard) | `tinyrobotcompany/Waveform_One` (`.githooks/pre-commit` → `scripts/test.sh`) |
| Firmware + path-triggered Bicep deploy, required-checks ruleset, security audit | `tinyrobotcompany/Tempo` (its GitHub Environment, `westeurope` region and Python tooling are legacy exceptions, not patterns) |
| Firmware/hardware repo controls | `tinyrobotcompany/Pico_Pie` |
| Skills catalog and these instructions | `simonholmes001/custom-skills` |

---

## 1. Use the skills — they are the detailed rulebook

The custom skills hold the detailed procedures. This file tells you **when** to load them. Load the matching skill **before** acting, not after. When several apply, load all of them (e.g. a feature = `branch-discipline` + `test-driven-development` + `clean-code`).

| When you are… | Load |
|---|---|
| About to change any file in a repository | `branch-discipline` (always first) |
| Implementing a feature, fixing a bug, refactoring | `test-driven-development`, `clean-code` |
| Shaping modules, layers, ports/adapters, dependency direction | `clean-architecture`, `app-design-principles` |
| Choosing an architecture style or comparing options | `application-architecture-patterns`, then record it with `architecture-decision-records` |
| Modelling a business domain, aggregates, invariants | `domain-modeling` |
| Designing REST/gRPC/event contracts, versioning, errors | `api-design` |
| Defining SLOs, performance, reliability, observability targets | `non-functional-requirements` |
| Config, secrets, statelessness, logs, build/release/run | `twelve-factor-app` |
| Creating a repo, hardening one, or verifying its delivery controls | `repository-bootstrap` |
| Reviewing a PR or your own diff before pushing | `pull-request-review` |
| Broken deployment, failing pipeline, outage, regression | `production-incident-root-cause` (evidence before patches) |
| GitHub issues / PRs / labels via MCP | `github-mcp` |
| GitHub Project board operations | `gh-project-ops` (run its auth/scope preflight) |
| Azure platform design, subscriptions, governance | `azure-architecture`, `azure-landing-zone` |
| VNets, private endpoints, DNS, firewall, hub-spoke | `azure-networking` |
| Azure identity/network/data security posture | `azure-security-best-practices` |
| Workload review against WAF pillars | `azure-well-architected-framework` |
| Inspecting or operating live Azure resources | `azure-mcp` |
| Go-live readiness, control gaps, AI guardrails | `assurance-engineering` |
| Microsoft Agent Framework agents/workflows | `microsoft-agent-framework` (+ `microsoft-agent-framework-mcp` for MCP tools) |
| Designing or troubleshooting MCP servers | `mcp-servers` |

If a needed skill is missing from your runtime, say so and continue using the rules below. Do not quietly do without it.

---

## 2. Non-negotiables (stop-the-line rules)

1. **Never commit to `main`.** Pull requests are the only path to `main`.
2. **Never merge** a PR without Simon's explicit permission for that PR. Prepare it so it can be merged, then stop.
3. **Never use `--no-verify`**, never disable or weaken a hook, test, coverage gate, check, ruleset or review to get green.
4. **Never force-push** unless Simon agreed to it for that branch.
5. **Never trigger or rerun pipelines manually** (`workflow_dispatch`, re-run, empty commits, PR description edits made only to retrigger a run) without permission. Paid Codex reviews in particular must not be retried just to get another attempt.
6. **Never deploy or change Azure workload infrastructure locally.** Infrastructure changes reach Azure only through the pipeline after merge to `main`, unless Simon approves the exact one-off command.
7. **Never commit secrets** (API keys, tokens, certificates, provisioning profiles, private keys, `.env`). Secrets live in GitHub repository secrets or approved local `.env` files. Refer to secrets by **name** only and never print their values.
8. **Stop and ask** when a requirement conflicts with the PRD, the security baseline or the cost-minimal architecture; when unknown changes in a worktree could be overwritten; when credentials or access are missing; or when an ambiguity would otherwise force you to make a hidden architecture decision.
9. **Report truthfully.** Say what was verified (with command/run link), what was derived, and what is assumed. "Installed but unverified" is a legitimate state. Pretending something is verified is not.

---

## 3. Git and branch discipline

Before the first edit of any task (details in `branch-discipline`):

```sh
git status --short --branch
git fetch origin --prune
git switch main && git merge --ff-only origin/main
git switch -c <type>/<short-description>
git worktree add .worktrees/<branch-leaf> <type>/<short-description>   # .worktrees/ is gitignored
```

- Do all edits, tests, commits and pushes from the worktree. Report the synced `main` SHA (local and remote), the branch name and the absolute worktree path before editing.
- **Branch names:** `^(feature|feat|fix|chore|docs|refactor|test|ci)/[a-z0-9][a-z0-9_-]*(/[a-z0-9][a-z0-9_-]*)?$`, e.g. `feature/setup-ci-hooks-actions`.
- **Commits and PR titles:** Conventional Commits, `<type>[(scope)][!]: <description>` (≤100 chars). Types are `feat|fix|chore|docs|refactor|test|ci|perf|build|revert`.
- Each PR has one main intent. Keep docs, tests and changesets in the same PR as the behaviour they describe.
- Keep temporary clones, fixtures and tool caches inside the project's ignored `.worktrees/` / `.artifacts/`. Do not put them in machine-wide locations.

---

## 4. Test-driven development — systematically, not optionally

Every behaviour change follows **Red → Green → Refactor** (`test-driven-development`):

1. State the behaviour. Write the smallest failing test that expresses it, and **run it to see it fail for the right reason**.
2. Write the minimum production code that makes it pass.
3. Refactor only while the relevant tests are green.

- **Bugs:** write a failing regression test before the fix.
- **Test levels:** unit tests for domain logic; integration/contract tests at APIs and external boundaries; focused view-model/unit tests for iOS, with very targeted UI automation; host tests plus sanitizers (ASan/UBSan) for firmware C.
- Tests are deterministic: control time, randomness, network, external services and shared state. No live API keys, endpoints or devices in unit tests.
- **Coverage gates are floors you may not lower.** Typical values are 80% overall, or layered gates such as Voxa's Domain 95 / Application 85 / Infrastructure 70 / Api 70.
- A selected test suite that discovers **zero tests must fail**.
- **Spikes** must be labelled as spikes and followed by tests before production work continues.
- Repository automation is tested too. `.github/scripts/*.test.mjs` / `*.test.sh` cover workflow scripts, changeset checks, release computation and review scripts. A new pipeline script needs a test.

---

## 5. Local pre-commit hook

- Hooks are versioned in `.githooks/` and activated per clone with `scripts/setup-hooks.sh`, which sets the repo-local `core.hooksPath=.githooks` (shared by worktrees). Setup must be safe to run repeatedly. Run it in every fresh clone, and verify it in each worktree with `git config core.hooksPath`. Never use machine-wide hook configuration.
- **Standard shape: the hook is a thin wrapper around the one validation entry point CI also runs.**
  ```sh
  #!/bin/sh
  set -eu
  cd "$(git rev-parse --show-toplevel)"
  exec sh scripts/test.sh
  ```
  All stack logic lives in `scripts/test.sh`, which CI calls too. It runs root Node tests, `dotnet test`, `swift test`, firmware host tests and repository script tests as present. This gives one source of truth, so local and CI cannot drift. It also keeps the entry point testable, and lets the hook stay identical across repos. Do not put per-stack test logic inside the hook itself. Hooks that do (older project-template/Voxa shape) should migrate when they are next touched.
- The hook validates the **staged snapshot**, so unstaged edits cannot mask a broken staged file. It runs on every commit, including docs-only commits. A missing tool, failed test or suite discovering zero tests **fails** the commit visibly rather than skipping. `scripts/test.sh` unsets `GIT_DIR`/`GIT_INDEX_FILE` (`git rev-parse --local-env-vars`) before running fixture repos.
- If the hook fails, fix the cause. Do not bypass it.

---

## 6. Pull requests, CI and required checks

Standard workflows (names must stay stable because rulesets reference them):

| Workflow | Trigger | Purpose |
|---|---|---|
| `pr-checks` | `pull_request` → main (opened, edited, synchronize, reopened) | `Branch Name`, `PR Title (Conventional Commits)` |
| `ci` | push to main and to feature-type branches, plus `pull_request` → main | `Changeset Check`, `Repository Script Tests`, stack tests (Node / .NET / Swift / firmware), aggregate `CI Required` |
| `codex-pr-review` | `pull_request_target` (opened, synchronize, reopened, ready_for_review) | Single `Codex Review` check |
| `security-audit` / `code-scanning` | PR, main and schedule | Gitleaks full-history scan, CodeQL (high-severity SARIF gate), dependency audits, action-pin and permission checks; aggregate `Security Audit Required` |
| `iac-lint`, `infrastructure-validate` | PR / push touching IaC | Bicep lint, build, what-if or validate |
| `ensure-codex-ruleset` | push to main / dispatch | Applies `.github/required-checks.json` as an active strict ruleset (needs `REPO_ADMIN_TOKEN`) |
| `release` | main (after CI) | Changeset-driven semver tag and GitHub Release |

Rules:
- Expensive jobs (backend, iOS, firmware, infra) are **path-filtered**. Cheap repository checks always run. Path selection is shared between local and hosted checks, and an unclassifiable change selects **conservatively**.
- Aggregate gates (`CI Required`, `Security Audit Required`) fail unless every selected child succeeded. A cancelled or never-run child is not success. They also run on docs-only changes.
- Pin third-party actions to a full commit SHA with a version comment. Use minimal `permissions:` and scope each secret to the step that needs it.
- Dependabot: monthly grouped Actions updates, with security updates kept separate.
- A PR description covers linked issue, user-facing behaviour, implementation summary, tests run (with evidence), risks, screenshots for UI changes, and Azure validation evidence for infra changes.
- Before handing over, run `pull-request-review` on your own diff and resolve CI, Codex and reviewer findings.

---

## 7. Codex code review

- Exactly **one** Codex review check per repo (`Codex Review`), implemented in `.github/workflows/codex-pr-review.yaml` + `.github/scripts/codex-pr-review*.mjs` with rubrics in `.github/review-rubrics/` (`pull-request-review.md`, `clean-code.md`, `clean-architecture.md`). Do not add a second review app, status or job.
- It runs on `pull_request_target` using **base-commit scripts and rubrics only**. The PR diff is untrusted data, and PR-head code is never executed with secrets. `OPENAI_API_KEY` is a repository secret used only in the provider step. Model defaults to `gpt-5.5` (override with `CODEX_REVIEW_MODEL`).
- The review is tied to the exact head SHA. Critical/High findings block the check. A missing key, API error, malformed output or oversized diff **fails** the check, and there is no passing fallback.
- **Diff size:** before opening or updating a PR, measure the full diff against the real target branch and keep it comfortably below `CODEX_REVIEW_DIFF_MAX` (default 120,000 characters). If it is too large, **split the work into smaller coherent PRs without asking**. Each split keeps its tests and documents its dependencies. Never raise the limit, truncate the input or bypass the check.
- Workflow changes take effect only after they merge to `main`. The bootstrap PR that introduces the review needs normal human review, so do not claim it was reviewed automatically.
- If a live review fails, read that run's logs, find the failing step and prove the fix offline. Do not keep rerunning a paid review.

---

## 8. Changesets and releases

- Every releasable PR adds `.changeset/<name>.md`:
  ```md
  ---
  "<repo-name>": patch | minor | major
  ---
  Short human-readable release note.
  ```
  `patch` = fixes/internal, `minor` = features, `major` = intentional breaking change. Docs-only and pure CI-version-pin PRs are exempt, as each repo's `changeset-check.sh` defines. Workflow logic, permission and script changes still need a note.
- After the intended main commit passes required validation, `release` computes the next version from pending changesets (`compute-next-release.sh`), tags **that exact commit** `vX.Y.Z` and publishes a GitHub Release with the notes. Releases are idempotent: a retry after tagging but before publication must still produce one tag and one release.

---

## 9. Azure infrastructure CI/CD

- All Azure resources are defined in **Bicep** (`infrastructure/bicep/main.bicep`, bootstrap in `infrastructure/bootstrap/`) and reviewed in PRs. Use `azure-architecture`, `azure-networking`, `azure-security-best-practices` and `azure-well-architected-framework` when designing.
- **PRs:** `iac-lint` + `infrastructure-validate` (lint, build, guard tests, what-if) with no deployment.
- **Deploy:** `infrastructure-deploy-dev.yaml` runs on **push to `main` when infrastructure paths change** (`infrastructure/**`, `backend/**`, `functions/**`, or the infra workflow files themselves), serialised with `concurrency` and `cancel-in-progress: false`. Guard tests run first, then a check that the required secrets are present, then OIDC login and deploy.
- **Auth:** GitHub OIDC → **user-assigned managed identity**, with the federated credential scoped to `refs/heads/main` and immutable GitHub owner/repo IDs. Create it with `scripts/setup-azure-auth-for-pipeline.sh <env>`. **No client secrets.** Use the `azure-app-registration-oidc` profile only when Entra/Graph permissions or multi-tenancy require it.
- Required repository secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `AZURE_LOCATION`, `AZURE_RESOURCE_GROUP` (+ `OPENAI_API_KEY` where used). Never hard-code regions, subscription, tenant or client IDs, or resource names. `AZURE_LOCATION` drives the region. **The default region is `francecentral`**, so record any other region (service availability, customer data residency) in an ADR.
- **Baseline:** least-privilege RBAC at the narrowest scope; private networking (VNet, private endpoints, private DNS) with networking in its own resource group; Key Vault for secrets; Application Insights + Log Analytics; managed identity everywhere; cost-minimal footprint (e.g. Functions Flex Consumption, Cosmos DB Serverless off by default). **Any new paid service needs an explicit cost and architecture decision (ADR) first.**
- Promote the **same immutable artifact** from dev to prod. A manual trigger is not an approval mechanism.
- **No GitHub Environments by default.** Use repository secrets, scoped to the step that consumes them, and keep dev/prod separation in distinct OIDC identities and trusted workflow claims. Exceptions (e.g. an external customer's repository that mandates environments) are decided by Simon case by case. Record each one in that repo's guidelines or an ADR, and never introduce one on your own initiative.
- Portal changes are limited to inspection, emergency recovery or an approved one-time bootstrap.

---

## 10. iOS CI/CD

- Swift + SwiftUI under `ios/`, supporting iPhone and iPad from the start. The project is generated from `ios/project.yml` where present. Fastlane lives in `ios/fastlane/` (`Appfile`, `Fastfile`, `Matchfile`) with match-managed signing.
- **PRs and branch pushes:** path-filtered `ios-ci` / `ios-tests` on `macos-latest` (build + unit tests, project validation via `validate-ios-project.sh`).
- **TestFlight (the default, Voxa pattern):** chain `CI` → `Release` → `iOS TestFlight` with `workflow_run` on main. Release runs on `workflow_run` of CI, and TestFlight runs on `workflow_run` of Release when it succeeds. A build ships only when a `v<semver>` tag exists for that commit. `MARKETING_VERSION` comes from the tag and `CURRENT_PROJECT_VERSION` from the run number, so `CFBundleVersion` is monotonic. `workflow_dispatch` is only for re-uploads/hotfixes, and only with permission. **Do not trigger TestFlight on push to main.** It races the release tag (tags pushed with `GITHUB_TOKEN` do not trigger workflows) and uploads builds with nothing releasable.
- The workflow validates every required secret by name first (`*_APP_IDENTIFIER`, `*_TEAM_ID`, `MATCH_*`, `APP_STORE_CONNECT_API_KEY_ID`, `APP_STORE_CONNECT_API_ISSUER_ID`, …). Uploads stay skipped until an Xcode project/workspace exists.
- **The app contains no privileged credentials.** It calls the backend, and AI keys stay server-side. Any direct client→provider path (e.g. OpenAI Realtime WebRTC) uses short-lived, backend-issued secrets only.

---

## 11. Preferred technology stack

Use the repository's **accepted** stack. For new work, default to:

- **Mobile:** Swift / SwiftUI, Fastlane, TestFlight.
- **Backend:** .NET 10 modular monolith with clean-architecture layers (`Domain`, `Application`, `Infrastructure`, `Api`) on Azure Functions (Flex Consumption). Node/TypeScript Azure Functions are acceptable for small proxies (e.g. `functions/<name>-api`).
- **Cloud:** Azure, Bicep, GitHub Actions + OIDC.
- **Repository automation:** Node.js 22 standard library (`node --test`) and POSIX shell, with pinned and locked dependencies.
- **Firmware/hardware:** ESP-IDF (C/C++) on ESP32 / ESP32-P4, CMake host tests with sanitizers, and device validation recorded separately from host tests.
- **AI:** OpenAI models server-side through a model router / prompt registry. Microsoft Agent Framework for agents, using the **.NET** SDK (`microsoft-agent-framework`).
- **Python is not part of the stack.** Do not write Python for application code, backends, agents, hooks, workflows, validation, test runners or tooling, and do not add Python manifests (`requirements.txt`, `pyproject.toml`). Use .NET, Swift, Node or shell instead.
  - **Only exception:** C/C++ firmware projects may *invoke* the vendor's Python-based toolchain (e.g. `idf.py`, `esptool.py` for build/flash/monitor). Treat it as an external tool and do not write project Python around it.
  - Existing Python in a repo is legacy, not precedent. Do not extend it. When that area is next substantially changed, propose a migration in an issue.
  - Python examples in skills and references are background material only. Apply the .NET/Swift/Node equivalent.
- **Project management:** GitHub Projects v2 with standard `Status` and `Priority` fields (`gh-project-ops`).

---

## 12. Documentation and decisions

- The PRD holds product intent and NFRs. GitHub issues hold scoped work and acceptance criteria. ADRs in `docs/adr/NNNN-*.md` record architecture decisions (`architecture-decision-records`).
- Make architecture-affecting decisions in the PRD, an ADR or the issue **before** implementing them.
- The README documents one-time setup, commands, the trigger/check-name matrix, security scans, the changeset format, releases, deploy/signing triggers, secrets by name and troubleshooting. Keep it in step with reality, and separate active controls from planned ones.

---

## 13. Definition of done

- Acceptance criteria are met, and tests were written first and pass locally through the hook.
- CI, security audit and Codex review are green, or any failure is understood, documented and explicitly accepted by Simon.
- Changeset, docs, README, ADR/PRD are updated where required.
- The diff is below the Codex review limit, with one intent per PR.
- The report says what was verified (command or run link), what remains unverified, and any owner decision still pending.
- No merge, deploy, pipeline rerun or force-push happened without permission.

---

## Codex-specific notes

- `~/.codex/skills` is a symlink to the local `custom-skills` clone, kept current by the `local.custom-skills.sync` LaunchAgent (`scripts/sync-local.sh`, hourly and at login). Invoke a skill explicitly with `$skill-name` (e.g. `$branch-discipline`), or let a matching request trigger it.
- Do not edit the clone at `~/.codex/skills` directly. Changes go through a branch/worktree and a PR to `custom-skills`, and keep worktrees **outside** the clone (e.g. `../skills-worktrees/`) so Codex does not load skills twice.
- Repo-level `AGENTS.md` files are layered on top of this one, and the nearest file to the edited path takes precedence.
- Codex owns repo structure, backend contracts, CI/CD, infrastructure, security-sensitive flows and cross-cutting guardrails unless the repo's guidelines allocate work differently.
