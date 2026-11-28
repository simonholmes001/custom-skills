---
name: repository-bootstrap
description: Prepare a new or existing GitHub repository with Simon’s standard local hook, push and PR checks, single Codex review, main protection, changesets, releases and deployment controls. Use when asked to create a repo with the usual controls, harden a repository, or verify its initial delivery setup.
metadata:
  category: github
  subdomain: repository-controls
  owner: custom
---

# Repository bootstrap

Deliver working repository controls first. Leave application scaffolding to its own iteration. Apply the owner's latest decisions and the target repository's accepted stack.

## Establish the baseline

1. Read the repository guidance and README. Inspect the actual default branch, hooks, workflow files, installed review apps, check runs and commit statuses, rulesets and bypass actors, collaborators, teams, secret **names**, GitHub Environments, release tags and open PRs. Reconcile existing tickets and Project cards before creating anything.
2. Inspect the working equivalents in Simon's repositories. Start with [project-template](https://github.com/simonholmes001/project-template) for PR conventions, review, releases and deployment patterns, [voxa](https://github.com/simonholmes001/voxa) for hook installation, CI and security, and [Waveform_One](https://github.com/tinyrobotcompany/Waveform_One) for the short hook and shared validation command. Record the files and commit revisions actually used. Verify event triggers, visible checks and permissions before adopting a pattern.
3. Follow branch-discipline. Keep each agent's branch in its own worktree under the project root's ignored `.worktrees/`. Keep temporary clones, fixtures and tool caches there too. Preserve active work. Before relocating or removing an agent's directory, coordinate with its owner, transfer changes, verify them and confirm the old directory is idle. Reuse the implementation PR for failure and recovery evidence.
4. Use the existing project stack. Keep Python out of the delivered repository, including hooks, validation, workflows, fixtures, dependency manifests and tool installation. The only exception is a C/C++ firmware repository invoking the vendor's Python-based build/flash toolchain (e.g. `idf.py`, `esptool.py`) as an external tool. Existing Python controls are legacy and must not be extended. Use shell and Node's standard library for repository controls. Pin and lock any necessary dependencies. Create no GitHub Environments by default. Use repository secrets and scope each secret to the step that consumes it. An environment is allowed only when Simon approves it for that repository (for example an external customer's repository that mandates one), and the exception is recorded in the repository guidance.

## Install the hook once

Commit a short pre-commit hook that calls the same validation entry point as CI (for example `exec sh scripts/test.sh`, as in Waveform_One). Keep all stack-specific test logic in that entry point, not in the hook. Set repository-local `core.hooksPath` during the existing clone/bootstrap or devcontainer setup. Make repeated setup safe. A plain Git clone does not activate versioned hooks by itself. If there is no setup entry point, document the single opt-in command per independent clone. Verify the effective setting in linked worktrees. Avoid machine-wide configuration.

Check the staged snapshot. Prove that an unstaged correction cannot mask a broken staged file. In a fresh clone and a linked worktree, attempt a bad commit, correct it and commit successfully. A missing required tool, failed test or selected suite discovering zero tests must fail visibly.

## Validate pushes and pull requests

Run repository validation on feature-branch pushes before a PR exists, updates to a PR targeting main, and pushes to main. Cover merge queue events if enabled. Check branch names and Conventional Commit PR titles. Re-evaluate title edits at the same SHA. Share path-selection rules across local and hosted checks. Include shared contracts and workflow changes, handle new branches and renames, and select conservatively when a change cannot be classified.

Give each required control a stable visible name. Run its final job on docs-only changes and after child failures. Report which jobs were intentionally skipped. Fail on failed selection or a selected child that failed, was cancelled or never ran. Demonstrate one red child reaching the required result, recovery on the same PR and a conclusive docs-only result. Record future build gates against their scaffold tickets while the application is absent.

## Activate exactly one Codex code review

Start with the working Codex review in the reference repository Simon named. Record the workflow path and revision, the name and source of the check GitHub displays, and a PR run showing a completed review. Compare these with the target PR's check runs, commit statuses and installed review apps. Reuse that implementation, including its trigger and reporting behaviour, wherever it meets Simon's requirements. If the references disagree or a requirement forces a different design, explain the specific difference and ask Simon before substituting another mechanism. Wait for his answer.

Put the active workflow in `.github/workflows/` on the trusted default branch. Cover PR opening, reopening, new commits (`synchronize`), edits and ready-for-review. Use the repository secret `OPENAI_API_KEY` only in the provider step. With privileged events, execute scripts from the trusted base SHA and read the proposed diff as data. Keep write permissions minimal. Attach the outcome to the reviewed head SHA and prevent an older run from overwriting a newer result. Report through the reference implementation's single review control. Adding a second status, job or review app that presents another Codex review fails acceptance.

Log the stage, reviewed SHA, model, provider status and request ID when available. Keep credentials, source diffs and raw provider payloads out of logs. Test missing credentials, provider errors, incomplete or malformed responses and blocking findings offline. Each must produce a visible failure. If a live review fails, read that run's logs, identify the failing step and use offline evidence to check the correction wherever possible. Do not edit a PR description, push an empty commit, open a proof PR or repeatedly rerun the workflow simply to trigger another paid attempt.

Verify on the existing implementation PR when it targets a base that already contains the workflow. Otherwise use the next authorised PR against that base. On opening and again after a genuine change, record the head SHA, run link, visible check name and outcome. Inspect both GitHub's Checks view and the head commit's checks and statuses. Acceptance requires exactly one visible Codex review and evidence that the provider completed a review of that revision. A legitimate blocking finding proves the reviewer ran and must leave the check red. If the key is missing or only offline tests have passed, report the workflow as installed and live review as unverified.

## Protect main and verify enforcement

Read back effective GitHub rules after applying them. Require a PR and the exact observed checks from their intended producers, including the single Codex review. Restrict direct and force pushes and branch deletion. Inspect actor bypasses. Map CODEOWNERS and approval settings to actual maintainers. For a sole maintainer, use zero required human approvals so the owner can merge their own PR. Agents still need Simon's explicit authorisation to merge. GitHub cannot distinguish an agent using Simon's account from Simon himself.

Demonstrate a failing check blocks a PR and correction restores eligibility. Exercise destructive cases on a disposable branch with equivalent rules. If private-repository plan limits or missing permissions block enforcement, record the API response, affected rule and exact owner action. Preserve repository visibility. A committed ruleset definition alone leaves enforcement outstanding.

## Security, releases and delivery

- Provide one reproducible local security command using the same scripts and pinned, checksum-verified tools as CI. Test from an empty project-local cache. Cover staged and history secret scanning, action pins and workflow permissions, dependency audits for present manifests, and infrastructure checks for the target stack. Generate harmless negative fixtures at test time. Report scanner failures, skipped suites and absent inputs distinctly.
- Require a human-readable changeset for releasable changes and document exceptions such as docs-only work. After the intended main commit passes required validation, compute its version, tag that exact commit and publish a GitHub Release containing the pending notes. Limit release writes to the publish job. Test two notes in one release, a mismatched SHA and a retry after tagging but before publication. Expect one tag and one release. Prove this in a fixture until live publication is authorised.
- Define which validated build produces the immutable artifact, its commit and checksum, the dev trigger, production promotion, authorisation, serialisation and recovery. Promote the same artifact. Keep GitHub Environments at zero even when the application has dev and prod targets, unless Simon has approved a recorded exception for that repository. For Azure, verify separate least-privilege OIDC identities and trusted workflow claims, supply the region through `AZURE_LOCATION` (default `francecentral`) and never hard-code it. For iOS, chain CI → Release → TestFlight with `workflow_run` on main as in Voxa, so an upload happens only for a tagged release. Do not trigger TestFlight on push to main. A manual trigger alone does not establish independent approval. Keep deployment and native signing disabled until prerequisites and the owner's production authorisation mechanism are in place. Use fixtures for preparation and identify which evidence needs real infrastructure, accounts or apps.

## Document and hand over

Update the root README with the one-time setup, commands, trigger and check-name matrix, security scans, changeset format and exceptions, versioning, release notes and retry behaviour, deploy and signing triggers, secrets by name, and troubleshooting. Distinguish active controls from preparation and external blockers. Link detailed runbooks and keep agent instructions consistent.

Report each control with its current state, tested commit, command or GitHub run, and any remaining owner decision. Keep incomplete tickets open. When Simon asks to relay work himself, provide one copyable instruction per agent with ticket numbers, ownership, reference files and acceptance evidence. Leave merges, live releases and deployments to the owner's explicit authorisation.
