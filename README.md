# ocp-monitoring-harness

> [!NOTE]
> This project is under active development. Content may be incomplete or change without notice.

A knowledge harness for the OpenShift [Cluster Monitoring Operator (CMO)](https://github.com/openshift/cluster-monitoring-operator) and all components it deploys.

This repository gives an AI coding agent deep domain knowledge about the OpenShift monitoring stack — architecture, development workflows, operational troubleshooting, PromQL query patterns, and per-component references — so it can effectively assist with development, debugging, and incident investigation.

## Components Covered

| Component | Role | Upstream |
|---|---|---|
| Prometheus | Metrics collection and alerting engine | [openshift/prometheus](https://github.com/openshift/prometheus) |
| Alertmanager | Alert routing, grouping, and notification | [openshift/prometheus-alertmanager](https://github.com/openshift/prometheus-alertmanager) |
| Prometheus Operator | CRD management for Prometheus, Alertmanager, and Thanos Ruler | [openshift/prometheus-operator](https://github.com/openshift/prometheus-operator) |
| kube-state-metrics | Kubernetes object state as metrics | [openshift/kube-state-metrics](https://github.com/openshift/kube-state-metrics) |
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
components/             Per-component references, queries, alerts, dev guides
development/            Guides for contributing to CMO and its components
projects/               Git submodules for CMO and all component repos
tasks/                  Active tasks (spec → plan → execution)
completed/              Archived completed tasks
templates/              Structured task template for implementation planning
CONVENTIONS.md          Coding and contribution conventions for CMO
```

## Projects (Git Submodules)

The `projects/` directory contains git submodules for CMO and every component it deploys, giving the agent direct access to real source code for grounded planning and implementation.

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

## Workflow

Each task follows a three-document workflow (inspired by [observability-ui/harness](https://github.com/observability-ui/harness) and [harness engineering](https://developers.redhat.com/articles/2026/04/07/harness-engineering-structured-workflows-ai-assisted-development)):

1. **Spec** ([`spec.md`](templates/spec.md)) — Problem statement, related projects, acceptance criteria
2. **Plan** ([`plan.md`](templates/plan.md)) — Repository impact map grounded in real code from `projects/`, broken into structured tasks. **Human reviews the plan before execution.**
3. **Execution** ([`execution.md`](templates/execution.md)) — Progress tracking with checkboxes and notes

The principle: **structure in, structure out**. The more you constrain the solution space, the more predictable the output.

## How to Use

### Prerequisites

- [Cursor](https://cursor.com) or [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- `git` with submodule support
- `podman` or `docker` (for markdown linting only)

### Getting Started

1. Clone the repo with submodules:

   ```bash
   git clone --recurse-submodules https://github.com/slashpai/ocp-monitoring-harness.git
   ```

2. Open the repo in your AI coding tool:
   - **Cursor** — `.cursor/rules/` files automatically feed the agent relevant context based on what you're working on
   - **Claude Code** — `CLAUDE.md` is automatically read for project context

3. Start asking questions or requesting tasks. The agent uses the harness content to ground its responses in accurate, CMO-specific knowledge.

### What You Can Do

**Ask about architecture and design:**

- "How does Thanos Querier aggregate metrics from multiple Prometheus instances?"
- "What happens when User Workload Monitoring is enabled?"
- "How does config flow from the cluster-monitoring-config ConfigMap to component manifests?"

**Troubleshoot issues:**

- "Prometheus pods are in CrashLoopBackOff, what should I check?"
- "Alertmanager is not sending notifications, help me debug"
- "kube-state-metrics is showing high memory usage"

**Develop and contribute:**

- "I need to add a new config option to CMO for Prometheus retention size"
- "How do I bump the Thanos version in CMO?"
- "Write an e2e test for the new alerting rule"

**Query live clusters (with MCP):**

If a Prometheus/Alertmanager MCP server (e.g., [obs-mcp](https://github.com/rhobs/obs-mcp)) is configured, the agent can combine harness knowledge with live metrics and alerts to investigate real cluster issues.

### Implementation Workflow

For non-trivial changes, follow the spec → plan → execution workflow:

1. Create a task directory: `mkdir tasks/<task-name>`
2. Write a `spec.md` using the [template](templates/spec.md) — define the problem and acceptance criteria
3. Have the agent produce a `plan.md` using the [template](templates/plan.md) — it will scan `projects/` submodules to build a grounded impact map
4. **Review the plan before execution** — catching a wrong assumption in a three-line impact map costs far less than catching it in a PR
5. Execute and track progress in `execution.md` using the [template](templates/execution.md)

### Keeping Submodules Updated

The `projects/` submodules give the agent direct access to component source code. Keep them current:

```bash
make submodule-update
```

## Acknowledgments

Initial harness documentation was drafted with AI assistance ([Claude Opus 4.6](https://www.anthropic.com/claude/opus) in [Cursor](https://cursor.com)) and refined with human input. Treat it like any other docs—review and improve via PR.

## References

- [CMO AGENTS.md](https://github.com/openshift/cluster-monitoring-operator/blob/main/AGENTS.md)
- [OpenShift Monitoring Docs](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/monitoring/)
- [Harness Engineering](https://developers.redhat.com/articles/2026/04/07/harness-engineering-structured-workflows-ai-assisted-development)

## License

[Apache-2.0](LICENSE)
