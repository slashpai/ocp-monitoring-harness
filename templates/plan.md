# Structured Task Template

Use this template when breaking work into implementation tasks. Every field is intentional — it constrains the AI's solution space so output is predictable and grounded in real code.

Reference: [Harness Engineering](https://developers.redhat.com/articles/2026/04/07/harness-engineering-structured-workflows-ai-assisted-development)

---

## Repository

_Single repository this task targets. Scoping to one repo avoids cross-repo confusion._

```text
openshift/cluster-monitoring-operator
```

## Description

_One-sentence summary of what this task does._

```text
Add CSV export endpoint for SBOM query results.
```

## Files to Modify

_Real paths found during the impact map phase — not guesses. Each entry explains what changes._

```text
- modules/sbom/src/service.rs — add CSV serialization method
- modules/sbom/src/endpoints.rs — add GET handler
```

## Implementation Notes

_Reference actual symbol names and existing patterns. When the AI reads "follow the existing pattern in FunctionX()", it can look up that function and mimic its structure._

```text
Follow the existing JSON export pattern in SbomService::export_json().
Reuse the QueryResult type from modules/sbom/src/model.rs.
```

## Acceptance Criteria

_Concrete checklist the AI can verify against._

```text
- [ ] GET /api/v2/sbom/export?format=csv returns valid CSV
- [ ] Existing JSON export still works
- [ ] No new linter warnings
```

## Test Requirements

_Specific test coverage required._

```text
- [ ] Integration test in modules/sbom/tests/ following existing test patterns
- [ ] Unit test for CSV serialization logic
```

---

## Why Each Field Matters

| Field | Purpose |
|---|---|
| **Repository** | Scopes the AI to a single repo, avoids cross-repo confusion |
| **Description** | Anchors the task with a clear goal |
| **Files to Modify** | Real paths from the impact map — the AI modifies only these files |
| **Implementation Notes** | References real symbols and patterns, eliminating guesswork |
| **Acceptance Criteria** | Concrete checklist for verification |
| **Test Requirements** | Ensures test coverage is part of the task, not an afterthought |

## CMO-Specific Notes

For cluster-monitoring-operator tasks, common file patterns:

| Change Type | Files Typically Involved |
|---|---|
| New/modified K8s resources | `jsonnet/components/<component>.libsonnet` → `make jsonnet-fmt generate` → `assets/<component>/` |
| New config option | `pkg/manifests/types.go` → `pkg/manifests/config.go` → `pkg/manifests/<component>.go` |
| New alerting rule | `jsonnet/components/<component>.libsonnet` (PrometheusRule section) |
| New scrape target | `jsonnet/components/<component>.libsonnet` (ServiceMonitor section) |
| Version bump | `jsonnet/versions.yaml` → `make generate` |
| E2E test | `test/e2e/<component>_test.go` |
