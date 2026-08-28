# Resource Group Separation of Concerns

## Objective

Enforce systematic separation of Azure resources by architectural concern within subscriptions to improve manageability, security boundaries, lifecycle independence, and blast-radius containment.

## Mandatory Separation Rules

When deploying Azure resources, **ALWAYS** separate into distinct resource groups by architectural concern:

### 1. Networking Resources
**Resource Group Pattern**: `rg-{env}-{region}-network`

**Must contain**:
- Virtual Networks (VNets)
- Subnets
- Network Security Groups (NSGs)
- Route Tables
- NAT Gateways
- Public IPs (for gateways/firewalls)
- Azure Firewall / Application Gateway / Load Balancers
- Private DNS Zones
- VPN Gateways / ExpressRoute Gateways

**Rationale**: 
- Networking has different lifecycle from application code
- Network changes require different RBAC permissions
- Networking often managed by central platform team
- Security boundary: network controls should be isolated from workload teams

---

### 2. Compute Resources
**Resource Group Pattern**: `rg-{env}-{region}-compute-{workload}`

**Must contain**:
- Virtual Machines
- VM Scale Sets
- Azure Kubernetes Service (AKS) clusters
- Container Instances
- Azure Functions (compute aspect)
- App Service Plans
- Batch Accounts

**Rationale**:
- Compute resources scale and change frequently
- Different cost center from networking/data
- Separate lifecycle from stateful data resources
- Easier to manage compute-related alerts and monitoring

---

### 3. Data & Storage Resources
**Resource Group Pattern**: `rg-{env}-{region}-data-{workload}`

**Must contain**:
- Azure SQL Databases / Managed Instances
- Cosmos DB accounts
- Storage Accounts (persistent data)
- Azure Database for PostgreSQL/MySQL/MariaDB
- Redis Cache
- Azure Synapse / Data Lake
- Event Hubs / Service Bus (data plane)

**Rationale**:
- Data resources require stricter RBAC and audit controls
- Backup/DR policies differ from compute
- Prevent accidental deletion through separate lifecycle
- Data residency and compliance boundaries
- Performance tuning and scaling separate from compute

---

### 4. Security & Identity Resources
**Resource Group Pattern**: `rg-{env}-{region}-security`

**Must contain**:
- Key Vaults
- Managed Identity assignments (where applicable)
- Azure Bastion
- Private Endpoints (can be separate or co-located with services)
- Microsoft Defender configurations
- Security Center resources

**Rationale**:
- Security resources require highest privilege control
- Key Vaults have different rotation/audit lifecycle
- Centralized secret management across workloads
- Easier compliance auditing and secret scanning

---

### 5. Monitoring & Operations Resources
**Resource Group Pattern**: `rg-{env}-{region}-ops`

**Must contain**:
- Log Analytics Workspaces
- Application Insights
- Azure Monitor resources
- Diagnostic Settings (metadata)
- Action Groups / Alerts
- Automation Accounts
- Recovery Services Vaults (Backup)

**Rationale**:
- Monitoring outlives individual application deployments
- Centralized logging across multiple workloads
- Separate RBAC for ops team
- Cost allocation for observability separate from workload costs

---

### 6. Integration & Middleware Resources
**Resource Group Pattern**: `rg-{env}-{region}-integration-{workload}`

**Must contain**:
- API Management instances
- Logic Apps
- Service Bus namespaces
- Event Grid topics
- Azure Functions (integration/orchestration role)
- Data Factory pipelines

**Rationale**:
- Integration resources serve multiple workloads
- Different scaling and lifecycle from core business logic
- API Management may front multiple backend services
- Easier to manage cross-cutting integration patterns

---

## Anti-Patterns to ALWAYS Avoid

❌ **Single "everything" resource group**: Never put networking, compute, data, and security in one RG
❌ **Mixing dev and prod resources**: Never mix environment stages in same RG
❌ **Mixing unrelated workloads**: Each workload should have its own compute/data RGs
❌ **Lifecycle conflicts**: Don't mix ephemeral resources (e.g., test VMs) with persistent data resources

---

## Naming Convention

Use consistent naming:
```
rg-{environment}-{region}-{concern}-{workload}

Examples:
- rg-prod-eastus-network
- rg-prod-eastus-compute-api
- rg-prod-eastus-data-api
- rg-prod-eastus-security
- rg-prod-eastus-ops
- rg-dev-westeurope-compute-frontend
- rg-dev-westeurope-data-frontend
```

Where:
- `{environment}`: dev, test, staging, prod
- `{region}`: Azure region short code (eastus, westeurope, etc.)
- `{concern}`: network, compute, data, security, ops, integration
- `{workload}`: optional workload identifier when multiple workloads in same subscription

---

## Deployment Guidance

When generating IaC (Bicep/Terraform/ARM):

1. **Always create resource groups first** as separate deployment step
2. **Validate RG separation** before deploying resources
3. **Apply RBAC at RG level** based on concern:
   - Network RG: Network Contributor for platform team only
   - Compute RG: Contributor for application team
   - Data RG: SQL DB Contributor + strict audit
   - Security RG: Key Vault Administrator for security team only
4. **Tag all RGs** with:
   - `concern`: network/compute/data/security/ops/integration
   - `environment`: dev/test/prod
   - `cost-center`: for chargeback
   - `owner`: team contact

---

## Validation Checklist

Before completing any Azure deployment, verify:
- [ ] No single RG contains resources from multiple concerns
- [ ] Networking resources isolated in dedicated network RG
- [ ] Persistent data isolated in dedicated data RG
- [ ] Security resources (Key Vault, etc.) isolated in security RG
- [ ] Each RG follows naming convention
- [ ] RBAC assigned appropriately per concern
- [ ] Tags applied to all RGs

---

## Exception Process

If legitimate reason exists to deviate (document why):
1. Document rationale in deployment README
2. Get approval from architecture review
3. Add compensating controls (tags, RBAC, monitoring)
4. Set expiration date for review

**Valid exceptions** (rare):
- POC/sandbox environments (still should separate for learning)
- Tightly coupled resources with shared lifecycle (still prefer separation)
- Migration scenarios (temporary until refactored)

---

## Implementation Notes

- This separation applies **within subscriptions**
- Supplements subscription-level separation (platform vs workload)
- Can be combined with Azure Landing Zone patterns
- Applies to all IaC: Bicep, Terraform, ARM templates, Azure CLI scripts
- Should be enforced in CI/CD pipelines via policy checks

---

## Cross-References

- `landing-zone-blueprint.md` for subscription-level organization
- `governance-security-baseline.md` for RBAC and policy enforcement
- `decision-patterns.md` for when to further subdivide resource groups
