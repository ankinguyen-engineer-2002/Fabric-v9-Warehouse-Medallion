# ADR-001: Adopt Hybrid Medallion v10 For Supply Chain Fabric Refactor

Date: 2026-04-30

Status: Proposed

## Context

The current v9 Supply Chain implementation is Warehouse-native and metadata-driven. It uses a single `SupplyChain_Warehouse` with `bronze`, `silver`, `gold`, and `meta` schemas, plus a strong control plane for registry-driven execution, generic load patterns, DAG/waves, DQ, lineage, logging, scheduling, and semantic model refresh.

Bob/DE team feedback identified that the current physical layout does not align with the standard Fabric medallion pattern:

- Bronze should not be duplicated inside the Supply Chain Warehouse when shortcut-backed Enterprise source access can represent logical Bronze.
- Silver should be grouped by logical process/metric schemas and reusable Silver should live in EnterpriseData ownership.
- Gold should be a dedicated serving boundary.
- Silver and Gold should follow Pascal Case naming.
- Significant enhancements to source data should not remain in Bronze.

Additional audit findings:

- [Verified] The shortcut-backed `Enterprise_Lakehouse` in SupplyChain Dev should be treated as logical Bronze.
- [Verified] The current Warehouse `bronze` schema is better interpreted as operational staging or `BronzeMirror`, not canonical Bronze.
- [Verified] Direct Lake serving should prefer physical Gold tables; non-materialized SQL views can trigger DirectQuery fallback depending on Direct Lake mode.
- [Need-verify] v9 smart skip has conflicting documentation and must be live-verified before claiming it is fully active.
- [Verified] DQ, schema contracts, performance baseline, cost monitor, alerting, and CI/CD have mixed maturity; some exist but are not fully wired into active pipeline flow.

## Decision

Adopt a **Hybrid Medallion v10** architecture:

```text
Enterprise_Data upstream products
  -> Enterprise_Access_Lakehouse shortcuts as logical Bronze
  -> optional Staging / BronzeMirror only for exceptions
  -> SupplyChain domain Silver schemas
  -> dedicated SupplyChain Gold Warehouse / serving item
  -> Direct Lake semantic model and reports
```

Preserve the v9 control plane as a horizontal operating layer:

- Asset registry / `sp_registry`.
- Generic SQL load runner / `meta.usp_generic_load`.
- Load pattern router.
- Mart routing engine.
- Schedule gate and smart skip, after verification or activation.
- DAG/wave planner.
- DQ gate engine.
- Source contract and source-target reconciliation gates.
- Lineage builder.
- Run/pipeline audit logging.
- Finalizer.
- Enterprise Dictionary Adapter.
- Timezone normalizer.
- Performance/cost monitoring.
- Semantic refresh controller.

## Consequences

Positive:

- Aligns with Fabric medallion expectations without rewriting the v9 framework.
- Removes mandatory Bronze duplication over time.
- Keeps optional staging for unstable sources, snapshot consistency, replay/debug, performance, and EDW supplement cases.
- Supports Bob's governance direction while adapting old SQL Server/ADW standards to Fabric and Direct Lake.
- Keeps Supply Chain domain agility while allowing enterprise-reusable Silver entities to move to EnterpriseData ownership.

Costs and risks:

- Requires metadata expansion for `access_mode`, `canonical_layer`, physical workspace/item, domain group, staging reason, source contract status, and approval status.
- Requires object classification and naming migration before implementation.
- Requires Direct Lake fallback validation when any compatibility views are introduced.
- Requires live verification for smart skip and other partially active v9 features.
- Requires a security matrix across Fabric workspace roles, item permissions, semantic RLS/OLS, and SQL endpoint grants.

## Rejected Alternatives

### Full Direct-Only Architecture

Rejected for now.

Reason:

- It removes operational staging, replay/debug, persisted snapshot, and EDW supplement capabilities too early.
- Current source contracts, completeness guarantees, and performance characteristics are not fully proven for all entities.

### Full Bronze Duplication In Warehouse

Rejected as the target state.

Reason:

- It preserves operational stability but conflicts with Bob's medallion feedback and creates avoidable duplication when governed shortcuts are stable.

### Full Lakehouse/Spark Rewrite

Rejected for this phase.

Reason:

- v9 is intentionally Warehouse/T-SQL-native.
- Existing CI/CD, error handling, lineage, DQ, and operational model are built around SQL Warehouse execution.
- A Spark rewrite would increase migration risk without evidence that it solves the current governance issue better.

## Implementation Notes

Implementation must proceed in phases:

1. Freeze v9 evidence and export registry, lineage, views, row counts, DQ state, and semantic dependencies.
2. Verify live pipeline Lookup SQL for smart skip.
3. Classify every object as logical Bronze, staging exception, domain Silver, enterprise-reusable Silver, Gold serving, or control-plane metadata.
4. Approve naming and ownership with Bob/Rakesh or assigned technical design approver.
5. Extend metadata and control-plane logic before physical moves.
6. Build v10 side-by-side, then run parallel validation before cutover.

## References

- `02_Architect_v10_May/10_final_v10_amendment_plan.md`
- `02_Architect_v10_May/07_v9_capability_evidence_ledger.md`
- `02_Architect_v10_May/08_v10_gap_matrix.md`
- `02_Architect_v10_May/09_bob_standards_mapping_matrix.md`
- Microsoft Direct Lake overview: https://learn.microsoft.com/en-us/fabric/fundamentals/direct-lake-overview
- Microsoft Fabric medallion architecture: https://learn.microsoft.com/en-us/fabric/onelake/onelake-medallion-lakehouse-architecture
