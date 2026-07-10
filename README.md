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
components/             Per-component references, queries, alerts, dev guides
development/            Guides for contributing to CMO and its components
projects/               Git submodules for CMO and all component repos
tasks/                  Active tasks (spec → plan → execution) — local, gitignored
completed/              Archived completed tasks — local, gitignored
templates/              Structured task template for implementation planning
CONVENTIONS.md          Coding and contribution conventions for CMO
```

## Projects (Git Submodules)

The `projects/` directory contains git submodules for CMO and every component it deploys, giving the agent direct access to real source code for grounded **planning** (read-only).

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

## Workflow

Each task follows a three-document workflow (inspired by [observability-ui/harness](https://github.com/observability-ui/harness) and [harness engineering](https://developers.redhat.com/articles/2026/04/07/harness-engineering-structured-workflows-ai-assisted-development)):

1. **Spec** ([`templates/spec.md`](templates/spec.md)) — Problem statement, related projects, acceptance criteria
2. **Plan** (`tasks/<name>/plan.md`) — Repository impact map from `projects/`, plus structured tasks per [templates/plan.md](templates/plan.md). **Human reviews before execution.**
3. **Execution** ([`templates/execution.md`](templates/execution.md)) — Progress tracking with checkboxes and notes

The principle: **structure in, structure out**. The more you constrain the solution space, the more predictable the output.

## How to Use

This harness is a **domain knowledge and workflow layer** for AI-assisted CMO work. It is not the SDLC itself — Jira, GitHub, and CI still own tracking and delivery. The harness gives the agent structured context so its output is grounded in real code and reviewable by humans.

### Prerequisites

- [Cursor](https://cursor.com) or [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- `git` with submodule support
- `podman` or `docker` (for markdown linting only)
- A local clone of your fork with push access (e.g. `~/github.com/<you>/cluster-monitoring-operator`) — required for implementation and PRs

### Getting Started

1. Fork the repository on GitHub, then clone **your fork** with submodules:

   ```bash
   git clone --recurse-submodules https://github.com/<you>/ocp-monitoring-harness.git
   cd ocp-monitoring-harness
   make submodule-init   # if submodules were not cloned recursively
   ```

2. Open the repo in your AI coding tool:
   - **Cursor** — `.cursor/rules/` automatically feeds the agent context based on what you're working on
   - **Claude Code** — `CLAUDE.md` is automatically read for project context

3. Start with a prompt. The agent uses harness content plus `projects/` submodules to ground responses.

### Where User Input Goes

Unstructured input (chat, Jira, alerts) becomes structured task documents before code changes:

```text
Your prompt / Jira ticket
        ↓
Agent creates tasks/<name>/spec.md     ← you review
        ↓
Agent creates tasks/<name>/plan.md      ← you review (required gate)
        ↓
Agent implements in your fork clone       ← local filesystem path + branch
        ↓
Agent updates tasks/<name>/execution.md ← audit trail (local)
        ↓
PR opened in target repo                ← Jira/GitHub are system of record
```

**Default:** you prompt → agent drafts `spec.md` → you review → you prompt again → agent drafts `plan.md` → you review → you prompt again → agent implements.

**Optional:** write `spec.md` yourself when the Jira ticket is already clear, then ask the agent to produce the plan.

Task directories under `tasks/` are **local working documents** and are gitignored. See [tasks/README.md](tasks/README.md).

### Workflows by Task Type

#### Develop or fix CMO (non-trivial)

Use the spec → plan → execution workflow:

1. Prompt the agent to create a task from [templates/spec.md](templates/spec.md)
2. Review `tasks/<name>/spec.md`
3. Ask the agent to produce `plan.md` — it must scan `projects/` for real file paths
4. **Review the plan before any implementation**
5. Agent implements in your **implementation repo** — the local filesystem path to your fork clone (not a GitHub URL; never `projects/` submodules)
6. Track progress in `execution.md`; open PR in the component repo, not in this harness

Copy and adapt these — one prompt per phase, with an explicit stop after each:

**Phase 1 — spec only**

```text
New task: disable-kubelet-endpoints

Ticket: OCPBUGS-85522 — platform prometheus-operator logs v1 Endpoints
deprecation warnings for kube-system/kubelet. Kubelet scraping already uses
EndpointSlice (CMO PR #2696).

Create tasks/disable-kubelet-endpoints/spec.md from templates/spec.md:
- Related projects: cluster-monitoring-operator, prometheus-operator
- Acceptance criteria: PO stops managing kubelet Endpoints; kubelet targets stay up
- References: https://issues.redhat.com/browse/OCPBUGS-85522

Stop after spec.md. Do not write plan.md or change code until I review.
```

**Phase 2 — plan only (after you approve the spec)**

```text
For tasks/disable-kubelet-endpoints, write plan.md:

1. Repository impact map — scan projects/ for real file paths and symbols;
   do not guess. Include dependencies and risks.
2. Structured tasks — break the work into steps using templates/plan.md
   (one section per task: files, implementation notes, tests).

Stop before any implementation or execution.md updates so I can review the plan.
```

**Phase 3 — implement (after you approve the plan)**

```text
Plan approved for disable-kubelet-endpoints.

Implementation repo (local path): ~/github.com/you/cluster-monitoring-operator
Branch: OCPBUGS-85522
PR target: openshift/cluster-monitoring-operator

Use projects/cluster-monitoring-operator/ in this harness only for reading
source during planning — never edit submodules; they have no push access.
Make all edits in the implementation repo path above.

Track progress in tasks/disable-kubelet-endpoints/execution.md.
Open the PR when ready.
```

#### Troubleshoot a live cluster

No task folder required. Provide symptoms, alert names, or pod/namespace details in chat.

If a Prometheus/Alertmanager MCP server (e.g. [obs-mcp](https://github.com/rhobs/obs-mcp)) is configured, the agent combines harness knowledge (expected metrics, alerts, architecture) with live cluster data.

#### Learn architecture or design

Ask in chat. The agent reads `architecture/`, `components/`, and `projects/` as needed. No task folder unless the question becomes a code change.

### What You Can Ask

**Architecture and design:**

- "How does Thanos Querier aggregate metrics from multiple Prometheus instances?"
- "What happens when User Workload Monitoring is enabled?"
- "How does config flow from cluster-monitoring-config to component manifests?"

**Troubleshooting:**

- "Prometheus pods are in CrashLoopBackOff — what should I check?"
- "Alertmanager is not sending notifications — help me debug"

**Development:**

- "Add a new config option to CMO for Prometheus retention size"
- "How do I bump the Thanos version in CMO?"
- "Where do I change kubelet ServiceMonitor discovery?"

### Where Code Changes Go

| Change | Where to implement (local path) | Where to open PR |
|---|---|---|
| CMO manifest, config API, operator logic | `~/github.com/<you>/cluster-monitoring-operator` | `openshift/cluster-monitoring-operator` |
| Upstream component fix | `~/github.com/<you>/<component>` | Community repo or OpenShift fork |
| Harness docs only | This repo (`architecture/`, `components/`, etc.) | This repo |

**Planning vs implementation:**

- **Read** source from `projects/` submodules when building impact maps
- **Edit and commit** only in your fork clone — submodules are read-only and have no push access
- In Phase 3, give three fields: **local filesystem path** (`~` or absolute — not a GitHub URL), **branch**, and **PR target**

```text
Implementation repo (local path): ~/github.com/<you>/cluster-monitoring-operator
Branch: OCPBUGS-85522
PR target: openshift/cluster-monitoring-operator
```

For Jsonnet changes in CMO: edit `jsonnet/components/*.libsonnet`, run `make jsonnet-fmt generate`, commit sources and regenerated `assets/` together. Never edit `assets/` by hand.

### Agentic SDLC Fit

In a typical agentic SDLC, this harness covers the **context and planning substrate**:

| SDLC phase | Harness role |
|---|---|
| Intake / triage | `architecture/`, `components/` — map symptoms to components |
| Spec | `tasks/<name>/spec.md` from [templates/spec.md](templates/spec.md) |
| Plan | Impact map from `projects/` submodules — **human review gate** |
| Implement | Code in your fork clone at the local path you specify |
| Test | `development/testing.md` — `make test-unit`, e2e, etc. |
| Review | `plan.md` and `execution.md` document intent vs outcome |
| Operate | `components/*/queries.md` + optional live MCP tools |

The principle: **structure in, structure out**. Constrain the solution space before the agent writes code.

### Keeping Submodules Updated

```bash
make submodule-update
```

Submodules give the agent read-only access to component source. Keep them current before planning.

## Acknowledgments

Initial harness documentation was drafted with AI assistance ([Claude Opus 4.6](https://www.anthropic.com/claude/opus) in [Cursor](https://cursor.com)) and refined with human input. Treat it like any other docs—review and improve via PR.

## References

- [CMO AGENTS.md](https://github.com/openshift/cluster-monitoring-operator/blob/main/AGENTS.md)
- [OpenShift Monitoring Docs](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/monitoring/)
- [Harness Engineering](https://developers.redhat.com/articles/2026/04/07/harness-engineering-structured-workflows-ai-assisted-development)

## License

[Apache-2.0](LICENSE)
