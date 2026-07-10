# ocp-monitoring-harness

> [!NOTE]
> This project is under active development. Content may be incomplete or change without notice.

A knowledge harness for the OpenShift [Cluster Monitoring Operator (CMO)](https://github.com/openshift/cluster-monitoring-operator) and all components it deploys.

This repository gives an AI coding agent deep domain knowledge about the OpenShift monitoring stack — architecture, development workflows, operational troubleshooting, PromQL query patterns, and per-component references — so it can effectively assist with development, debugging, and incident investigation.

## Quick Start

1. Fork and clone with submodules — see [USAGE.md](USAGE.md#getting-started)
2. Open in [Cursor](https://cursor.com) or [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
3. Follow the workflow in [USAGE.md](USAGE.md) — spec → plan → execution with human review gates

## Components Covered

| Component | Role | Upstream |
|---|---|---|
| Prometheus | Metrics collection and alerting engine | [openshift/prometheus](https://github.com/openshift/prometheus) |
| Alertmanager | Alert routing, grouping, and notification | [openshift/prometheus-alertmanager](https://github.com/openshift/prometheus-alertmanager) |
| Prometheus Operator | CRD management for Prometheus, Alertmanager, and Thanos Ruler | [openshift/prometheus-operator](https://github.com/openshift/prometheus-operator) |
| kube-state-metrics | Kubernetes object state as metrics | [openshift/kube-state-metrics](https://github.com/openshift/kube-state-metrics) |
| openshift-state-metrics | OpenShift resource state as metrics | [openshift/openshift-state-metrics](https://github.com/openshift/openshift-state-metrics) |
| node-exporter | Node hardware/OS metrics | [openshift/node_exporter](https://github.com/openshift/node_exporter) |
| Thanos (Querier, Ruler, Sidecar) | Unified query view, HA deduplication, rule evaluation | [openshift/thanos](https://github.com/openshift/thanos) |
| kube-rbac-proxy | AuthN/AuthZ sidecar for metrics endpoints | [openshift/kube-rbac-proxy](https://github.com/openshift/kube-rbac-proxy) |
| metrics-server | Resource metrics API for HPA/VPA | [openshift/kubernetes-metrics-server](https://github.com/openshift/kubernetes-metrics-server) |
| telemeter-client | Telemetry forwarding to Red Hat (deployed when telemetry is enabled) | [openshift/telemeter](https://github.com/openshift/telemeter) |
| monitoring-plugin | OpenShift console monitoring UI | [openshift/monitoring-plugin](https://github.com/openshift/monitoring-plugin) |
| prom-label-proxy | Label-based multi-tenant access control | [openshift/prom-label-proxy](https://github.com/openshift/prom-label-proxy) |

For current component versions, see [`projects/cluster-monitoring-operator/jsonnet/versions.yaml`](https://github.com/openshift/cluster-monitoring-operator/blob/main/jsonnet/versions.yaml).

## Repository Structure

```text
.cursor/rules/          Cursor rules — auto-loaded context for the AI agent
architecture/           Cross-cutting CMO architecture documentation
components/             Per-component references and development guides
development/            Guides for contributing to CMO and its components
projects/               Git submodules for CMO and all component repos (plan + implement)
scripts/                reset-projects.sh and other harness scripts
tasks/                  Active tasks (spec → plan → execution) — local, gitignored
completed/              Archived completed tasks — local, gitignored
templates/              Structured task templates (spec, plan, execution)
USAGE.md                How to use this harness with an AI agent
CONVENTIONS.md          Coding and contribution conventions for CMO
```

## Projects (Git Submodules)

The `projects/` directory contains git submodules for CMO and every component it deploys. Use them for planning and (by default) implementation — see [USAGE.md](USAGE.md#choosing-a-mode) for Mode A vs Mode B (single-task vs parallel work on the same repo).

| Submodule | Repository |
|---|---|
| `projects/cluster-monitoring-operator` | [openshift/cluster-monitoring-operator](https://github.com/openshift/cluster-monitoring-operator) |
| `projects/prometheus` | [openshift/prometheus](https://github.com/openshift/prometheus) |
| `projects/prometheus-alertmanager` | [openshift/prometheus-alertmanager](https://github.com/openshift/prometheus-alertmanager) |
| `projects/prometheus-operator` | [openshift/prometheus-operator](https://github.com/openshift/prometheus-operator) |
| `projects/kube-state-metrics` | [openshift/kube-state-metrics](https://github.com/openshift/kube-state-metrics) |
| `projects/node-exporter` | [openshift/node_exporter](https://github.com/openshift/node_exporter) |
| `projects/thanos` | [openshift/thanos](https://github.com/openshift/thanos) |
| `projects/kube-rbac-proxy` | [openshift/kube-rbac-proxy](https://github.com/openshift/kube-rbac-proxy) |
| `projects/kubernetes-metrics-server` | [openshift/kubernetes-metrics-server](https://github.com/openshift/kubernetes-metrics-server) |
| `projects/monitoring-plugin` | [openshift/monitoring-plugin](https://github.com/openshift/monitoring-plugin) |
| `projects/prom-label-proxy` | [openshift/prom-label-proxy](https://github.com/openshift/prom-label-proxy) |
| `projects/telemeter` | [openshift/telemeter](https://github.com/openshift/telemeter) |
| `projects/openshift-state-metrics` | [openshift/openshift-state-metrics](https://github.com/openshift/openshift-state-metrics) |

## Documentation

| Document | Purpose |
|---|---|
| [USAGE.md](USAGE.md) | Workflow, example prompts, where code changes go, agentic SDLC mapping |
| [tasks/README.md](tasks/README.md) | Local task workflow (spec → plan → execution) |
| [development/](development/) | Contributing to CMO — jsonnet, tests, alerts, metrics |
| [architecture/](architecture/) | Cross-cutting CMO architecture |
| [components/](components/) | Per-component references and development guides |

## Acknowledgments

Initial harness documentation was drafted with AI assistance ([Claude Opus 4.6](https://www.anthropic.com/claude/opus) in [Cursor](https://cursor.com)) and refined with human input. Treat it like any other docs—review and improve via PR.

## References

- [CMO AGENTS.md](https://github.com/openshift/cluster-monitoring-operator/blob/main/AGENTS.md)
- [OpenShift Monitoring Docs](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/monitoring/)
- [Harness Engineering](https://developers.redhat.com/articles/2026/04/07/harness-engineering-structured-workflows-ai-assisted-development)

## License

[Apache-2.0](LICENSE)
