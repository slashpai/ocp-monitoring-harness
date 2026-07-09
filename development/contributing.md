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
