# Upstream to Downstream Repository Mapping

Each component in the CMO stack has a **community upstream** project and an **OpenShift fork** (downstream). The OpenShift forks carry patches on top of upstream and are maintained in release-specific branches (e.g., `release-4.17`).

## Mapping

| Component | Community Upstream | OpenShift Fork | Submodule |
|---|---|---|---|
| Cluster Monitoring Operator | *(OpenShift-only, no upstream)* | [openshift/cluster-monitoring-operator](https://github.com/openshift/cluster-monitoring-operator) | `projects/cluster-monitoring-operator` |
| Prometheus | [prometheus/prometheus](https://github.com/prometheus/prometheus) | [openshift/prometheus](https://github.com/openshift/prometheus) | `projects/prometheus` |
| Alertmanager | [prometheus/alertmanager](https://github.com/prometheus/alertmanager) | [openshift/prometheus-alertmanager](https://github.com/openshift/prometheus-alertmanager) | `projects/prometheus-alertmanager` |
| Prometheus Operator | [prometheus-operator/prometheus-operator](https://github.com/prometheus-operator/prometheus-operator) | [openshift/prometheus-operator](https://github.com/openshift/prometheus-operator) | `projects/prometheus-operator` |
| kube-state-metrics | [kubernetes/kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) | [openshift/kube-state-metrics](https://github.com/openshift/kube-state-metrics) | `projects/kube-state-metrics` |
| node-exporter | [prometheus/node_exporter](https://github.com/prometheus/node_exporter) | [openshift/node_exporter](https://github.com/openshift/node_exporter) | `projects/node-exporter` |
| Thanos | [thanos-io/thanos](https://github.com/thanos-io/thanos) | [openshift/thanos](https://github.com/openshift/thanos) | `projects/thanos` |
| kube-rbac-proxy | [brancz/kube-rbac-proxy](https://github.com/brancz/kube-rbac-proxy) | [openshift/kube-rbac-proxy](https://github.com/openshift/kube-rbac-proxy) | `projects/kube-rbac-proxy` |
| metrics-server | [kubernetes-sigs/metrics-server](https://github.com/kubernetes-sigs/metrics-server) | [openshift/kubernetes-metrics-server](https://github.com/openshift/kubernetes-metrics-server) | `projects/kubernetes-metrics-server` |
| monitoring-plugin | *(OpenShift-only, no upstream)* | [openshift/monitoring-plugin](https://github.com/openshift/monitoring-plugin) | `projects/monitoring-plugin` |
| prom-label-proxy | [prometheus-community/prom-label-proxy](https://github.com/prometheus-community/prom-label-proxy) | [openshift/prom-label-proxy](https://github.com/openshift/prom-label-proxy) | `projects/prom-label-proxy` |
| telemeter-client | *(OpenShift-only, no upstream)* | [openshift/telemeter](https://github.com/openshift/telemeter) | `projects/telemeter` |
| openshift-state-metrics | *(OpenShift-only, no upstream)* | [openshift/openshift-state-metrics](https://github.com/openshift/openshift-state-metrics) | `projects/openshift-state-metrics` |

## When to Use Which Repo

| Task | Repo |
|---|---|
| Report a bug in core component behavior | Community upstream |
| Report an OpenShift-specific bug | OpenShift fork |
| Track an upstream feature for inclusion | Community upstream → OpenShift fork rebase |
| Version bump in CMO | Update `jsonnet/versions.yaml` after OpenShift fork rebases upstream |
| OpenShift-specific patches (RBAC, TLS, console integration) | OpenShift fork |
| Review upstream release notes before a bump | Community upstream releases page |

## Version Bump Workflow

Syncing from community upstream to OpenShift forks is automated by [syncbot](https://github.com/rhobs/syncbot) — a set of GitHub Actions workflows that rebase the OpenShift forks onto upstream releases.

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

- Runs as GitHub Actions workflows from [rhobs/syncbot](https://github.com/rhobs/syncbot)
- Rebases the OpenShift fork onto the latest upstream release (not upstream main)
- Preserves downstream-only changes: vendored dependencies, custom Dockerfile, Makefile tweaks, OWNERS, `.gitignore`
- Creates PRs to the downstream `openshift/` fork repos via GitHub Apps authentication

syncbot also [updates CMO's `jsonnet/versions.yaml`](https://github.com/rhobs/syncbot/blob/main/.github/workflows/update-cmo-deps-versions.yaml) — it runs `make versions generate` daily and creates a PR to CMO to synchronize the version metadata and regenerate assets.

### What syncbot does NOT do

- It does not handle `kube-rbac-proxy` (managed by the auth team)

## OpenShift-Only Components

Four components have no community upstream:

- **Cluster Monitoring Operator** — The operator itself is an OpenShift-specific project
- **monitoring-plugin** — The OpenShift console monitoring UI plugin
- **telemeter-client** — Telemetry forwarding to Red Hat
- **openshift-state-metrics** — OpenShift resource state as Prometheus metrics
