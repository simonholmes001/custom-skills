---
name: production-incident-root-cause
description: Evidence-led production incident and regression workflow. Use when Codex handles broken deployments, failing CI/CD pipelines, runtime outages, App Service or cloud health failures, user-facing regressions, rollback/recovery decisions, or any urgent fix where a wrong first patch would waste deployment cycles. Requires logs, config state, current runtime-path tracing, replacement-path tracing, and verification before proposing or implementing fixes.
---

# Production Incident Root Cause

Use this skill to slow down the right parts of incident work: gather evidence first, identify the real failure mode, trace the proposed replacement path, and only then patch or advise a deployment rerun.

## Hard Rules

- Do not start with code changes unless the failure mechanism is already evidenced.
- Do not treat a visible bad setting as the full root cause until the replacement path has been traced end to end.
- Do not tell the user to rerun a deployment until the branch has tests or guardrails proving the fixed path can start and operate.
- Do not suppress, bypass, or loosen a guardrail just to make the deployment green.
- If live logs cannot be accessed, state exactly which log source is blocked and use the next best evidence source.

## Evidence Checklist

Collect the relevant evidence before diagnosis. For cloud incidents, include platform logs as well as pipeline logs.

- Pipeline logs: failed job, failed step, exact command, exit code, timestamps, branch, event type, commit SHA, image digest or artifact ID.
- Application logs: runtime exceptions, startup errors, structured logs, telemetry, health endpoint payloads.
- Platform logs: App Service logs, Kudu/SCM diagnostics when reachable, container logs, deployment logs, activity logs, restart/crash status, App Insights exceptions/traces.
- Configuration state: app settings, connection strings presence, feature flags, Key Vault references, deployed image, route/gateway config, secrets presence without printing secret values.
- Infrastructure state: current IaC parameters, actual deployed resources, network/private endpoint/egress state, APIM/backend routing, health probes.
- Source state: local branch, remote branch, commit history, dirty worktree status, diff from base branch.

For Azure App Service failures, explicitly try or explain why you cannot access:

- APIM or public health endpoint response.
- Direct App Service health response if allowed by network policy.
- App Service app settings and container image configuration.
- App Service log stream or log download.
- App Insights exceptions/traces.
- Azure Activity Log and deployment operation failures.
- Container startup/restart status.

Never quote secret values from logs or app settings.

## Diagnosis Workflow

1. Reproduce or confirm the symptom using the user-provided logs plus at least one independent check when possible.
2. Classify the failure as code, config, infrastructure, external dependency, pipeline, or mixed.
3. Trace the current failing path from trigger to failure:
   - request/job/deploy input
   - routing and infrastructure
   - runtime configuration
   - service registration or dependency construction
   - execution path
   - failure point
4. Identify the smallest evidenced root cause. If there are multiple contributors, list them separately as primary and contributing causes.
5. Trace the proposed fixed path before patching:
   - what changes after the fix
   - which dependencies must exist
   - what concrete service registrations/config values/routes will be used
   - what health endpoint should return
   - what user-facing workflow should do
6. Look for hidden replacement-path breakage. Ask: "If I remove the bad path, what exact path runs instead, and is every required dependency real and configured?"
7. Only then implement the fix.

## Fix Standards

Every production incident fix should include at least one of these verification mechanisms:

- A unit/integration test that proves the fixed runtime path is selected.
- A startup or health check guard that fails clearly when required dependencies are absent.
- A deployment guard that fails the pipeline when forbidden config or fake runtime paths are deployed.
- A smoke test that exercises the real route through the deployed gateway.

Prefer fixing the real path over making fallback behavior more permissive.

## Response Template

Before proposing or making code changes, report:

- Observed failure:
- Evidence checked:
- Evidence blocked or missing:
- Root cause hypothesis:
- Current failing path:
- Proposed fixed path:
- Verification plan:
- Residual risk:

After implementing, report:

- Files changed:
- Root cause fixed:
- Tests/validations run:
- Deployment or rerun instructions:
- What to check after deployment:

## Anti-Patterns

- "The setting is wrong, so just flip it" without proving the replacement path works.
- "The key might be missing" when config evidence shows it is present.
- "Rerun the pipeline" after an external failure without checking whether a later stage will fail deterministically.
- Relying only on CI logs while ignoring App Service logs, app logs, telemetry, and deployed config.
- Declaring root cause from source code alone when runtime config or cloud state could differ.
