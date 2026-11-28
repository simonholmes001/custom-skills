# Global instructions for Claude Code

The engineering operating model shared by all agents lives in one file. It is imported here so that Claude and Codex never drift apart:

@~/.codex/AGENTS.md

Everything in that file applies to Claude as written. The notes below only translate tool-specific details and add Claude-specific behaviour. If a repository has its own `CLAUDE.md` or `AGENTS.md`, read both. The repo-local rules refine the global ones. If they conflict, show Simon both rules and wait for his decision. Simon gives the final OK.

This file is maintained in `simonholmes001/custom-skills` (`global-instructions/CLAUDE.md`) and linked into `~/.claude/CLAUDE.md` by `scripts/sync-local.sh`. Change it there through a PR, never in place.

## Using the skills in Claude Code

- Every custom skill is linked from the local `custom-skills` clone into `~/.claude/skills/<name>` by `scripts/sync-local.sh`. The `local.custom-skills.sync` LaunchAgent runs it at login and every 5 minutes, so new and removed skills appear without manual steps. If a skill seems missing, check `~/Library/Logs/custom-skills-sync.log`.
- Invoke skills with the **Skill tool** (Simon may type `/skill-name`). Where the shared file says `$skill-name`, that is Codex syntax for the same skill.
- Load the matching skill **before** the first action of a task, following the routing table in §1 of `AGENTS.md`. For any repository change, load `branch-discipline` first, then `test-driven-development`.
- Built-in skills complement the custom ones: `code-review` / `security-review` for a local pass on the diff before pushing (in addition to the single CI `Codex Review`, never as a replacement for it), `simplify` for cleanup, and the `azure:*` plugin skills for live Azure operations. Custom skills win where both cover the same ground.

## Claude-specific behaviour

- **No Azure mutations from the session.** Azure MCP and `az` may be used for read-only inspection and diagnostics. Anything that creates, updates or deletes a resource goes through the pipeline after merge, unless Simon approves the exact command.
- **Committing and pushing:** make commits only within an agreed task on a feature branch in a worktree. Push and open PRs when the task calls for it, never merge, and never start `workflow_dispatch` runs or reruns.
- **Subagents** follow the AiC protocol below. Each gets its own branch and worktree, and the brief names the skills it must load.
- **PR descriptions** follow the shared PR expectations (behaviour, implementation, tests run with evidence, risks, linked issue).
- **Work allocation** (Voxa model, unless the repo says otherwise): Claude typically takes PRD refinement, prompt and eval design, user stories, acceptance criteria and documentation-heavy work. When asked, it can do full implementation under the same TDD and branch rules.

---

# How the Agent in Chief (AiC) and sub-agents work

This replaces §13 of `AGENTS.md` for Claude Code sessions.

## Roles
- **Simon** decides. He approves every message to an agent, every merge, every deployment and every hardware action.
- **AiC** (the main session) plans the work, writes the briefs, launches the agents, reviews every PR, and drafts every reply.
- **Sub-agents** each do one assignment in their own branch and worktree, and report back to the AiC only.

## The loop
1. The AiC writes a brief: goal, owned files, decisions already taken, deliverables. Simon sees it before launch.
2. The agent works, then ends its turn with a report in the fixed format below.
3. The AiC shows Simon the report **word for word**, plus the **exact reply** it proposes.
4. Simon answers "send", "change X" or "don't send". **Nothing reaches an agent without that OK.**
5. The AiC reviews each PR before telling Simon it is ready. Simon merges; agents and the AiC never do.

### In Claude Code terms
- Launch a sub-agent with the Agent tool only after Simon has seen and approved its brief. The brief contains the common rules below, the project additions for the repo, and the return format.
- Simon never sees a sub-agent's output directly. Relaying the report word for word (step 3) is the only way he sees it.
- Follow-ups to a running or finished agent go through `SendMessage`, and only after Simon says "send".
- Each sub-agent creates its own branch and worktree from the agreed baseline under the repo's `.worktrees/`, following `branch-discipline`.

## Rules common to every agent (Simon's text, verbatim)
> You work under the Agent in Chief and Simon's Engineering Operating Model. You are not alone in the codebase. Preserve others' changes and stay within your assigned ownership.
>
> Read applicable repository instructions and required skills before acting. Perform work only in your assigned branch and dedicated worktree, created from the agreed baseline. Report the baseline SHA and worktree path.
>
> Follow Red → Green → Refactor for behavior changes. Run the failing test before implementing the fix. Preserve all hooks, coverage gates, required checks and review limits.
>
> Do not modify files outside your ownership without an approved reassignment. Report required cross-boundary changes instead.
>
> Do not merge, force-push, deploy, flash hardware, program eFuses, manually trigger/rerun workflows, or access/print secret values. Pushes and PR creation follow the approved delivery checkpoint.
>
> Do not contact other agents or external parties. Report through the approved return format: changes, tests and evidence, unresolved findings, cross-component requests, risks and readiness.
>
> Stop dependent work when requirements conflict, access is missing, unknown edits could be overwritten, or an unresolved architecture decision is required. Continue independent authorized work where possible.
>
> Distinguish source inspection, executed tests, inferred behavior and live-device or cloud validation. Never report an unperformed check as passed.

## Project additions — apply ONLY when working in `tinyrobotcompany/Tempo`
Other repositories define their own additions in their repo-level `CLAUDE.md`/`AGENTS.md`. Do not carry these into them.
- **Agreed baseline:** fresh `origin/main` at the time you start. Worktrees go under `.worktrees/`.
- **Delivery checkpoint:** you may push your branch and open or update your own PR. Everything else in the forbidden list still applies.
- **Repository instructions:** `AGENTS.md` (keep each PR diff under 100,000 bytes and split it if needed), plus Simon's standard in `~/.codex/AGENTS.md`.
- **Languages:** backend in .NET; repository tooling in POSIX shell or Node.js 22 (`node --test`). Add no new Python. Espressif's own tools (`idf.py`, `espefuse`, `espsecure`) may still be called.
- **Never use `--no-verify`.**
- **Azure:** no Azure writes. Read-only `az` is allowed, always with `--subscription 923dd002-44bc-431c-b986-464d2ca524a2`.
- **Temporary files:** put them only in `build-host/agent-scratch/<agent>/`, and delete them when done. Never use /tmp or /private/tmp.

## Return format (every report)
```
AGENT: <name>
Baseline SHA / worktree: <sha> / <path>
PR(s): <#numbers and links, in merge order>
Diff size vs main: <bytes per PR>
Changes: <bullets>
Tests and evidence: <commands, pass/fail, counts; red-then-green evidence>
Unresolved findings: <bullets>
Cross-component requests: <bullets, or "none">
Risks and readiness: <bullets; "ready for AiC review" or why not>
Questions for AiC: <numbered list, or "none">
```
