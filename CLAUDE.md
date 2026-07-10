# OCP Monitoring Harness

This repository is a **knowledge harness** for the OpenShift Cluster Monitoring Operator (CMO) and all components it deploys. It provides structured knowledge to help with development, architecture understanding, and troubleshooting.

## Repository Layout

- `architecture/` — Cross-cutting CMO architecture (reconciliation, data flow, namespaces, configuration API)
- `components/<name>/` — Per-component references with README, queries, and development guides
- `development/` — Guides for contributing to CMO (jsonnet workflow, adding metrics/alerts, testing)
- `projects/` — Git submodules for CMO and all component repos (source of truth for code and versions)
- `tasks/` — Active tasks (spec → plan → execution) — local, gitignored; see [tasks/README.md](tasks/README.md)
- `completed/` — Archived completed tasks — local, gitignored
- `USAGE.md` — Workflow, example prompts, and where to implement changes; see [USAGE.md](USAGE.md)
- `templates/` — Templates for spec, plan, and execution documents

## Components Managed by CMO

All deployed in `openshift-monitoring` (platform) and `openshift-user-workload-monitoring` (UWM) namespaces:

1. **Prometheus** — Metrics collection and alerting engine
2. **Alertmanager** — Alert routing, grouping, silencing, notification
3. **Prometheus Operator** — Manages Prometheus, Alertmanager, and Thanos Ruler via CRDs
4. **kube-state-metrics** — Kubernetes object state as metrics
5. **node-exporter** — Node hardware/OS metrics
6. **Thanos** (Querier, Ruler, Sidecar) — Unified query view, HA deduplication, rule evaluation
7. **kube-rbac-proxy** — AuthN/AuthZ sidecar for metrics endpoints
8. **metrics-server** — Resource metrics for HPA/VPA
9. **telemeter-client** — Telemetry forwarding to Red Hat (deployed when telemetry is enabled)
10. **monitoring-plugin** — OpenShift console monitoring UI plugin
11. **prom-label-proxy** — Label-based access control for multi-tenant queries
12. **openshift-state-metrics** — OpenShift resource state as metrics

For current component versions, check `projects/cluster-monitoring-operator/jsonnet/versions.yaml`.

## CMO Architecture

### Jsonnet Manifest Generation

Kubernetes resources managed by CMO are generated using Jsonnet:

- **Sources**: `jsonnet/main.jsonnet` (entrypoint), `jsonnet/components/<component>.libsonnet` (per-component)
- **Outputs**: `assets/` directory (runtime manifests), `manifests/` directory (CVO-deployed resources)
- **Critical**: Changes must be made to jsonnet sources, then regenerated with `make jsonnet-fmt generate`. Direct edits to `assets/*/*.yaml` will be overwritten.

### Configuration API

Two ConfigMaps control monitoring configuration:

- `cluster-monitoring-config` in `openshift-monitoring` — Platform monitoring
- `user-workload-monitoring-config` in `openshift-user-workload-monitoring` — User workload monitoring

These are merged into the Config struct in `pkg/manifests/config.go`. Fields and CEL validations are defined in `pkg/manifests/types.go`.

### Reconciliation Task Ordering

The operator's `sync()` in `pkg/operator/operator.go` runs tasks in three ordered groups:

1. **PrometheusOperator + MetricsScrapingClientCA** — Must run first (PO manages CRDs that all others depend on)
2. **All other components** — Prometheus, Alertmanager, node-exporter, UWM, etc. (run in parallel)
3. **ConfigurationSharing + DefaultDenyNetworkPolicy** — Must run last (depend on resources from group 2)

### Key Namespaces

- `openshift-monitoring` — Platform monitoring stack
- `openshift-user-workload-monitoring` — User workload Prometheus, Thanos Ruler (only when UWM is enabled)

### Multi-Module Repository

CMO has three Go modules with separate `go.mod` and `vendor/`:
- `./` (main module)
- `test/monitoring/`
- `hack/tools/`

## Development Workflow

### Making Changes

**Modifying Kubernetes Resources:**
1. Edit the jsonnet source in `jsonnet/components/<component>.libsonnet`
2. Run `make jsonnet-fmt generate` to regenerate assets
3. Never edit `assets/*/*.yaml` directly

**Modifying Configuration Options:**
1. Add/modify fields in `pkg/manifests/types.go`
2. Update `pkg/manifests/config.go` to handle the new fields
3. Run `make generate` to update generated code

### Testing

- `make test-unit` — Unit tests
- `make test-e2e` — E2E tests (requires cluster + KUBECONFIG)
- `make run-local` — Run CMO locally against a cluster

### PR Conventions

- Bugs: `OCPBUGS-12345: descriptive title`
- Features: `MON-1234: descriptive title`
- Commit format: `<subsystem>: <what changed>`

## Troubleshooting

When troubleshooting, follow this order:

1. **Check firing alerts** — Alert labels provide exact identifiers for targeted queries
2. **Identify the component** — Map symptoms to components (see `components/` for per-component details)
3. **Query relevant metrics** — Use CMO alert rules in `projects/cluster-monitoring-operator/assets/<component>/prometheus-rule.yaml`, generic patterns in `.cursor/rules/04-promql-patterns.mdc`, and live MCP metric discovery when available
4. **Check logs** — `oc logs -n openshift-monitoring <pod>`
5. **Check configuration** — `oc get configmap cluster-monitoring-config -n openshift-monitoring -o yaml`

## Task Workflow

For non-trivial changes, follow the spec → plan → execution workflow. Task directories under `tasks/` are **local working documents** (gitignored); Jira and GitHub are the system of record.

1. **Spec** (`tasks/<name>/spec.md`) — Problem statement, acceptance criteria
2. **Plan** (`tasks/<name>/plan.md`) — Repository impact map from `projects/`, plus structured tasks per `templates/plan.md`
3. **Execution** (`tasks/<name>/execution.md`) — Progress tracking

Each phase requires an explicit prompt and a human review gate before the next phase.

**Implementation** — prefer **Mode A** (edit in `projects/<repo>/`, push to a `fork` remote, then `make reset-projects`). **Mode B** (external fork clone at a local path the user specifies) is fine when the fork is outside this workspace.

**Always search `projects/` submodules for real file paths and symbols** before creating impact maps or plans. Never guess.

**Stop and present the plan for human review before proceeding.** If the plan is wrong, the code will be wrong too.

## Source Code Access

All component repos are available as git submodules under `projects/`:

```text
projects/cluster-monitoring-operator    # The main operator
projects/prometheus                     # Prometheus
projects/prometheus-alertmanager        # Alertmanager
projects/prometheus-operator            # Prometheus Operator
projects/kube-state-metrics             # kube-state-metrics
projects/node-exporter                  # node-exporter
projects/thanos                         # Thanos
projects/kube-rbac-proxy                # kube-rbac-proxy
projects/kubernetes-metrics-server      # metrics-server
projects/monitoring-plugin              # Console monitoring plugin
projects/prom-label-proxy               # prom-label-proxy
projects/telemeter                      # telemeter-client
projects/openshift-state-metrics        # openshift-state-metrics
```
