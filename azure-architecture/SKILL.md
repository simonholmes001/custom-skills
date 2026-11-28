---
name: azure-architecture
description: Design Azure cloud architectures and enterprise landing zones using Microsoft best practices. Use when Codex needs to plan or review Azure platform foundations, subscription hierarchy, management groups, identity and access, governance, networking, security controls, workload placement, resilience, cost optimization, or environment rollout patterns.
metadata:
  category: azure
  subdomain: platform-architecture
  owner: custom
---

# Azure Architecture

## Overview

Design production-ready Azure platforms and workload architectures with clear tradeoffs, guardrails, and rollout sequencing. Prioritize secure-by-default landing zones, operational simplicity, and scalable governance.

## Workflow

1. Gather business, compliance, and workload constraints.
2. Define landing zone baseline (identity, governance, network, security, operations).
3. Map workloads to architecture decisions (compute, data, integration, connectivity).
4. Validate against reliability, security, performance, cost, and operations criteria.
5. Produce phased implementation plan with validation and rollback points.

## Load References Selectively

- **MANDATORY**: For resource group separation rules, read `references/resource-group-separation.md` BEFORE generating any Azure IaC.
- For foundation and platform boundaries, read `references/landing-zone-blueprint.md`.
- For quality checks and architecture tradeoffs, read `references/architecture-review-checklist.md`.
- For governance, identity, and security guardrails, read `references/governance-security-baseline.md`.
- For service and topology choices, read `references/decision-patterns.md`.
- For Microsoft authoritative guidance and current best practices, read `references/official-docs.md`.

## Inputs Checklist

Collect before recommending architecture:
- Business criticality and recovery targets (RTO, RPO)
- Regulatory constraints and data residency requirements
- Environments (dev/test/stage/prod) and isolation model
- Connectivity requirements (Internet, on-prem, partner, multi-region)
- Identity model (Entra ID tenant boundaries, B2B/B2C needs)
- Cost envelope and scaling expectations
- Team operating model (central platform vs app team ownership)

## Design Rules

Apply these rules consistently:
1. **MANDATORY**: Enforce resource group separation by architectural concern (network, compute, data, security, ops, integration) per `references/resource-group-separation.md`. Never place resources from multiple concerns in the same resource group.
2. Separate platform foundation from workload subscriptions.
3. Use management groups and policy-as-code for guardrails first.
4. Use hub-and-spoke or Virtual WAN for shared connectivity at scale.
5. Prefer private service connectivity for sensitive data paths.
6. Standardize observability and security telemetry from day one.
7. Define failure domains and cross-zone/region strategy explicitly.
8. Design for least privilege with RBAC and managed identities.
9. Enforce tagging, naming, and budget controls at onboarding time.
10. Default region is `francecentral`, supplied through `AZURE_LOCATION` and never hard-coded. Record any other region choice (service availability, data residency) in an ADR.

## Landing Zone Scope

Always include:
- Management group hierarchy and subscription vending pattern
- Identity and access boundary model
- Network topology and egress strategy
- Policy initiatives and exemption process
- Logging/monitoring architecture and retention controls
- Backup/DR posture and key workload dependencies
- Secure software supply chain and deployment guardrails

## Output Contract

For every architecture answer:
1. Provide target-state architecture in concise bullets.
2. **Explicitly list resource groups** organized by separation of concerns (network/compute/data/security/ops/integration).
3. Explain major tradeoffs and why the recommendation fits.
4. List required guardrails and platform controls.
5. Provide phased rollout plan (foundation, migration, hardening).
6. Include validation checks, risks, and rollback strategy.
7. **Validate**: Confirm no single resource group contains resources from multiple concerns.

## Delivery Templates

When useful, structure output as:
- `Architecture Decision Record` bullets for major choices
- `Landing Zone Backlog` with prioritized work items
- `Control Matrix` mapping risks to Azure controls

## Cross-Skill Standards

Read and apply `references/cross-skill-standards.md` for:

- Evidence quality rubric (`Verified`, `Derived`, `Assumption`)
- Context-budget/loading policy
- Anti-pattern and handoff rules
- Source freshness policy
- Minimum output additions for non-trivial responses
