# Architecture

The Cluster Monitoring Operator (CMO) manages the Prometheus-based monitoring stack in OpenShift. This document is the **single catalog** for components, upstream/downstream repos, and submodule paths. For CMO internals (reconciliation, config API, namespace topology, data flow), see [`projects/cluster-monitoring-operator/AGENTS.md`](projects/cluster-monitoring-operator/AGENTS.md) ([upstream](https://github.com/openshift/cluster-monitoring-operator/blob/main/AGENTS.md)).

Components run in `openshift-monitoring` (platform) and, when enabled, `openshift-user-workload-monitoring` (UWM). For current versions, see `projects/cluster-monitoring-operator/jsonnet/versions.yaml`.

## Components

Each component has a **community upstream** and an **OpenShift fork** (downstream), except rows marked *(OpenShift-only)*. Forks carry downstream patches and live on release branches (e.g. `release-4.x`).

| Component                   | Role                                                                 | Community Upstream                                                                                    | OpenShift Fork                                                                                    | Submodule                              |
|-----------------------------|----------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|----------------------------------------|
| Cluster Monitoring Operator | Deploys and reconciles the monitoring stack                          | *(OpenShift-only)*                                                                                    | [openshift/cluster-monitoring-operator](https://github.com/openshift/cluster-monitoring-operator) | `projects/cluster-monitoring-operator` |
| Prometheus                  | Metrics collection and alerting engine                               | [prometheus/prometheus](https://github.com/prometheus/prometheus)                                     | [openshift/prometheus](https://github.com/openshift/prometheus)                                   | `projects/prometheus`                  |
| Alertmanager                | Alert routing, grouping, silencing, notification                     | [prometheus/alertmanager](https://github.com/prometheus/alertmanager)                                 | [openshift/prometheus-alertmanager](https://github.com/openshift/prometheus-alertmanager)         | `projects/prometheus-alertmanager`     |
| Prometheus Operator         | Manages Prometheus, Alertmanager, and Thanos Ruler via CRDs          | [prometheus-operator/prometheus-operator](https://github.com/prometheus-operator/prometheus-operator) | [openshift/prometheus-operator](https://github.com/openshift/prometheus-operator)                 | `projects/prometheus-operator`         |
| kube-state-metrics          | Kubernetes object state as metrics                                   | [kubernetes/kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)                     | [openshift/kube-state-metrics](https://github.com/openshift/kube-state-metrics)                   | `projects/kube-state-metrics`          |
| node-exporter               | Node hardware/OS metrics                                             | [prometheus/node_exporter](https://github.com/prometheus/node_exporter)                               | [openshift/node_exporter](https://github.com/openshift/node_exporter)                             | `projects/node-exporter`               |
| Thanos                      | Querier (unified queries), Ruler (UWM rules), Sidecar (store/upload) | [thanos-io/thanos](https://github.com/thanos-io/thanos)                                               | [openshift/thanos](https://github.com/openshift/thanos)                                           | `projects/thanos`                      |
| kube-rbac-proxy             | AuthN/AuthZ sidecar for metrics endpoints                            | [brancz/kube-rbac-proxy](https://github.com/brancz/kube-rbac-proxy)                                   | [openshift/kube-rbac-proxy](https://github.com/openshift/kube-rbac-proxy)                         | `projects/kube-rbac-proxy`             |
| metrics-server              | Resource metrics API for HPA/VPA (separate from Prometheus)          | [kubernetes-sigs/metrics-server](https://github.com/kubernetes-sigs/metrics-server)                   | [openshift/kubernetes-metrics-server](https://github.com/openshift/kubernetes-metrics-server)     | `projects/kubernetes-metrics-server`   |
| monitoring-plugin           | OpenShift console monitoring UI                                      | *(OpenShift-only)*                                                                                    | [openshift/monitoring-plugin](https://github.com/openshift/monitoring-plugin)                     | `projects/monitoring-plugin`           |
| prom-label-proxy            | Namespace label filtering for multi-tenant queries                   | [prometheus-community/prom-label-proxy](https://github.com/prometheus-community/prom-label-proxy)     | [openshift/prom-label-proxy](https://github.com/openshift/prom-label-proxy)                       | `projects/prom-label-proxy`            |
| telemeter-client            | Telemetry forwarding to Red Hat (when enabled)                       | *(OpenShift-only)*                                                                                    | [openshift/telemeter](https://github.com/openshift/telemeter)                                     | `projects/telemeter`                   |
| openshift-state-metrics     | OpenShift resource state as metrics                                  | *(OpenShift-only)*                                                                                    | [openshift/openshift-state-metrics](https://github.com/openshift/openshift-state-metrics)         | `projects/openshift-state-metrics`     |

## How they connect

- **Prometheus Operator** creates/manages Prometheus, Alertmanager, and Thanos Ruler instances via CRDs
- **Prometheus** scrapes ServiceMonitor targets (including kube-state-metrics and node-exporter) and sends firing alerts to **Alertmanager**
- **Thanos Sidecar** runs with each Prometheus; **Thanos Querier** federates platform + UWM for a unified query API
- **Thanos Ruler** evaluates UWM recording/alerting rules; **prom-label-proxy** enforces multi-tenant query access
- **monitoring-plugin** queries via Thanos Querier; **telemeter-client** forwards a curated metric set to Red Hat
- **metrics-server** is outside the Prometheus pipeline (HPA/VPA only)

## When to Use Which Repo

| Task                                                        | Repo                                                                 |
|-------------------------------------------------------------|----------------------------------------------------------------------|
| Report a bug in core component behavior                     | Community upstream                                                   |
| Report an OpenShift-specific bug                            | OpenShift fork                                                       |
| Track an upstream feature for inclusion                     | Community upstream → OpenShift fork rebase                           |
| Version bump in CMO                                         | Update `jsonnet/versions.yaml` after OpenShift fork rebases upstream |
| OpenShift-specific patches (RBAC, TLS, console integration) | OpenShift fork                                                       |
| Review upstream release notes before a bump                 | Community upstream releases page                                     |

## Version Bump Workflow

Syncing from community upstream to OpenShift forks is automated by [syncbot](https://github.com/rhobs/syncbot) — GitHub Actions that rebase OpenShift forks onto upstream releases.

```text
Community upstream releases v1.2.3
        │
        ▼
syncbot rebases OpenShift fork onto upstream v1.2.3
(adds downstream patches: vendor, Dockerfile, Makefile, OWNERS)
        │
        ▼
CMO updates jsonnet/versions.yaml
        │
        ▼
make generate → regenerates assets/
        │
        ▼
PR to openshift/cluster-monitoring-operator
```

### What syncbot does

- Runs as GitHub Actions from [rhobs/syncbot](https://github.com/rhobs/syncbot)
- Rebases the OpenShift fork onto the latest upstream release (not upstream main)
- Preserves downstream-only changes: vendored dependencies, custom Dockerfile, Makefile tweaks, OWNERS, `.gitignore`
- Creates PRs to the downstream `openshift/` fork repos via GitHub Apps authentication

syncbot also [updates CMO's `jsonnet/versions.yaml`](https://github.com/rhobs/syncbot/blob/main/.github/workflows/update-cmo-deps-versions.yaml) — it runs `make versions generate` daily and opens a PR to CMO.

### What syncbot does NOT do

- It does not handle `kube-rbac-proxy` (managed by the auth team)
