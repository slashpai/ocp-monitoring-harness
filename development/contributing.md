# Contributing to CMO

## Repository

- **Repo**: [openshift/cluster-monitoring-operator](https://github.com/openshift/cluster-monitoring-operator)
- **Language**: Go 82%, Jsonnet 16%, Shell 1%
- **License**: Apache-2.0

## Getting Started

### Prerequisites

- Go (version specified in `go.mod`)
- `jsonnet-bundler` (`jb`) for managing Jsonnet dependencies
- `jsonnet` and `gojsontoyaml` for manifest generation
- An OpenShift cluster + `KUBECONFIG` for E2E tests and local runs

### Fork, Clone, and Set Remotes

1. Fork [openshift/cluster-monitoring-operator](https://github.com/openshift/cluster-monitoring-operator) on GitHub
2. Clone your fork and set up remotes:

```bash
git clone https://github.com/<your-username>/cluster-monitoring-operator.git
cd cluster-monitoring-operator
git remote add upstream https://github.com/openshift/cluster-monitoring-operator.git
git remote set-url --push upstream no_push
```

3. Build:

```bash
make build
```

### Running Locally

```bash
# Run as CMO service account (requires cluster permissions)
make run-local

# Run as your current user (easier for development)
SWITCH_TO_CMO=false make run-local
```

## Code Organization

```text
cmd/                    Main entrypoint
pkg/
  operator/             Reconciliation logic (sync loop, task ordering)
  manifests/            Manifest generation from assets + configuration
    config.go           Config parsing (ConfigMap → Go struct)
    types.go            Config struct definition, CEL validations
  tasks/                Individual reconciliation tasks per component
jsonnet/
  main.jsonnet          Top-level Jsonnet entrypoint
  components/           Per-component Jsonnet (*.libsonnet)
  jsonnetfile.json      Jsonnet dependencies
assets/                 Generated YAML manifests (DO NOT EDIT DIRECTLY)
manifests/              CVO-deployed manifests
test/                   E2E tests (separate Go module)
hack/                   Development scripts and tools (separate Go module)
```

## Pull Request Workflow

### Branch Naming

No enforced convention, but descriptive names are preferred.

### PR Title Format

- **Bug fixes**: `OCPBUGS-12345: descriptive title`
- **Features**: `MON-1234: descriptive title`

### Commit Message Format

```text
<subsystem>: <what changed>
```

Examples:

- `jsonnet: update prometheus version`
- `pkg/manifests: add CEL validation for retention`
- `test: add e2e test for UWM prometheus`

### JIRA Integration

- **OCPBUGS** issues are managed automatically by [jira-lifecycle-plugin](https://github.com/openshift-eng/jira-lifecycle-plugin)
- **MON** issues must be transitioned manually through JIRA states

### CI

- `ci/prow/images` — Builds images; if this fails, `make verify` likely fails locally too
- `ci/prow/e2e` — Runs E2E tests against a real cluster
- Results are in `artifacts/` in the Prow job page: `build-log.txt`, `artifacts/e2e-test/`, `artifacts/junit*.xml`

## Conventions

Follow [openshift/enhancements CONVENTIONS.md](https://github.com/openshift/enhancements/blob/master/CONVENTIONS.md).

## Contributing to Upstream Components

CMO deploys components that come from community upstream projects. If your change belongs in the upstream project (e.g., a bug fix in Prometheus itself), the workflow is different from contributing to CMO directly.

### Upstream vs Downstream

See [architecture/repo-mapping.md](../architecture/repo-mapping.md) for the full mapping. Key distinction:

- **Upstream** (community) — `prometheus/prometheus`, `thanos-io/thanos`, etc. Uses GitHub Actions CI, community PR conventions, and DCO sign-off.
- **Downstream** (OpenShift fork) — `openshift/prometheus`, `openshift/thanos`, etc. Uses Prow CI, OpenShift PR conventions (`OCPBUGS-`/`MON-`), and is managed by [syncbot](https://github.com/rhobs/syncbot).

### When to Contribute Upstream

- Bug fixes in core component behavior (e.g., Prometheus query engine, Alertmanager routing logic)
- New features that should benefit the wider community
- Performance improvements in component internals

### When to Contribute to the OpenShift Fork

- OpenShift-specific patches (RBAC, TLS, console integration)
- Downstream-only build/CI changes (Dockerfile, OWNERS)
- Cherry-picks of upstream fixes to a specific OpenShift release branch

### End-to-End Workflow: Upstream Change to OpenShift

1. **Contribute upstream** — Submit a PR to the community repo, get it merged and released
2. **syncbot rebases** — [syncbot](https://github.com/rhobs/syncbot) automatically rebases the OpenShift fork onto the new upstream release
3. **CMO version bump** — syncbot also creates a PR to update `jsonnet/versions.yaml` in CMO
4. **Test in CMO** — Verify the change works in the OpenShift monitoring stack

### Testing an Upstream Change with CMO Locally

Before your upstream change is merged and released, you can test it against CMO:

1. Build a custom image of the component from your upstream branch
2. Override the image in CMO's `jsonnet/versions.yaml` or use `SWITCH_TO_CMO=false make run-local` with a modified image reference
3. Run `make generate` to regenerate assets
4. Deploy and test with `make run-local` or on a test cluster

### Upstream Contributing Guides

| Component | Contributing Guide |
|---|---|
| Prometheus | [prometheus/prometheus CONTRIBUTING.md](https://github.com/prometheus/prometheus/blob/main/CONTRIBUTING.md) |
| Alertmanager | [prometheus/alertmanager CONTRIBUTING.md](https://github.com/prometheus/alertmanager/blob/main/CONTRIBUTING.md) |
| Prometheus Operator | [prometheus-operator/prometheus-operator CONTRIBUTING.md](https://github.com/prometheus-operator/prometheus-operator/blob/main/CONTRIBUTING.md) |
| kube-state-metrics | [kubernetes/kube-state-metrics CONTRIBUTING.md](https://github.com/kubernetes/kube-state-metrics/blob/main/CONTRIBUTING.md) |
| node-exporter | [prometheus/node_exporter CONTRIBUTING.md](https://github.com/prometheus/node_exporter/blob/main/CONTRIBUTING.md) |
| Thanos | [thanos-io/thanos CONTRIBUTING.md](https://github.com/thanos-io/thanos/blob/main/CONTRIBUTING.md) |
| kube-rbac-proxy | [brancz/kube-rbac-proxy](https://github.com/brancz/kube-rbac-proxy) |
| metrics-server | [kubernetes-sigs/metrics-server](https://github.com/kubernetes-sigs/metrics-server) |
| prom-label-proxy | [prometheus-community/prom-label-proxy](https://github.com/prometheus-community/prom-label-proxy) |

### Upstream Build and Test Quick Reference

| Component | Build | Test | Lint |
|---|---|---|---|
| Prometheus | `go build ./cmd/prometheus/` | `make test` | `make lint` |
| Alertmanager | `make build` | `make test` | `make lint` |
| Prometheus Operator | `make build` | `make test-unit` | `make check` |
| kube-state-metrics | `make build` | `make test-unit` | `make lint` |
| node-exporter | `make build` | `make test` | — |
| Thanos | `make build` | `make test` | `make lint` |
