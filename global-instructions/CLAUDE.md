# Global instructions for Claude Code

The engineering operating model shared by all agents lives in one file. It is imported here so that Claude and Codex never drift apart:

@~/.codex/AGENTS.md

Everything in that file applies to Claude as written. The notes below only translate tool-specific details and add Claude-specific behaviour. If a repository has its own `CLAUDE.md` or `AGENTS.md`, read both. The repo-local rules refine the global ones.

This file is maintained in `simonholmes001/custom-skills` (`global-instructions/CLAUDE.md`) and linked into `~/.claude/CLAUDE.md` by `scripts/sync-local.sh`. Change it there through a PR, never in place.

## Using the skills in Claude Code

- Every custom skill is linked from the local `custom-skills` clone into `~/.claude/skills/<name>` by `scripts/sync-local.sh`. The `local.custom-skills.sync` LaunchAgent runs it at login and hourly, so new and removed skills appear without manual steps. If a skill seems missing, check `~/Library/Logs/custom-skills-sync.log`.
- Invoke skills with the **Skill tool** (Simon may type `/skill-name`). Where the shared file says `$skill-name`, that is Codex syntax for the same skill.
- Load the matching skill **before** the first action of a task, following the routing table in §1. For any repository change, load `branch-discipline` first, then `test-driven-development`.
- Built-in skills complement the custom ones: `code-review` / `security-review` for a local pass on the diff before pushing (in addition to the single CI `Codex Review`, never as a replacement for it), `simplify` for cleanup, and the `azure:*` plugin skills for live Azure operations. Custom skills win where both cover the same ground.

## Claude-specific behaviour

- **No Azure mutations from the session.** Azure MCP and `az` may be used for read-only inspection and diagnostics. Anything that creates, updates or deletes a resource goes through the pipeline after merge, unless Simon approves the exact command.
- **Committing and pushing:** make commits only within an agreed task on a feature branch in a worktree. Push and open PRs when the task calls for it, never merge, and never start `workflow_dispatch` runs or reruns.
- **Subagents** working in a repo get their own branch and worktree and follow the same rules. Pass the relevant skill names to them explicitly.
- **PR descriptions** follow the shared PR expectations (behaviour, implementation, tests run with evidence, risks, linked issue).
- **Work allocation** (Voxa model, unless the repo says otherwise): Claude typically takes PRD refinement, prompt and eval design, user stories, acceptance criteria and documentation-heavy work. When asked, it can do full implementation under the same TDD and branch rules.
