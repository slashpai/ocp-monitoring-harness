# Testing

## Test Types

### Unit Tests

```bash
make test-unit
```

Runs Go unit tests in the main module. These test configuration parsing, manifest generation, and operator logic without requiring a cluster.

> **Note:** `make test` runs _all_ tests (`test-unit`, `test-rules`, `test-e2e`, `test-ginkgo`), not just unit tests. Use `make test-unit` for fast local iteration.

### E2E Tests

```bash
make test-e2e
```

Runs end-to-end tests against a live OpenShift cluster. **Requires**:

- `KUBECONFIG` environment variable set (not just `~/.kube/config`)
- Appropriate cluster permissions
- A running OpenShift cluster

E2E tests verify that:

- Components deploy correctly
- Prometheus scrapes expected targets
- Alerts fire under expected conditions
- Configuration changes propagate correctly

### OpenShift Tests Extension

CMO integrates with the OpenShift conformance test framework:

```bash
# Build the tests-ext binary
make tests-ext

# After modifying Ginkgo tests, update metadata
make tests-ext-update
```

### Verification

```bash
make verify
```

Checks that generated assets, rules, and runbooks are up to date:

- `check-assets` — Generated assets match Jsonnet sources
- `check-rules` — Prometheus rules are valid
- `check-runbooks` — Runbook URLs are reachable

### Formatting and Linting

```bash
make format
```

Runs all code formatting and linting:

- `go-fmt` — Go formatting
- `golangci-lint` — Go linting
- `shellcheck` — Shell script linting
- `jsonnet-fmt` — Jsonnet formatting
- `misspell` — Spell checking

## Running Tests Locally

### Prerequisites

```bash
# Ensure KUBECONFIG is set for E2E tests
export KUBECONFIG=/path/to/kubeconfig

# For running CMO locally
make run-local

# Or as current user (simpler permissions)
SWITCH_TO_CMO=false make run-local
```

### Common Test Issues

| Issue | Cause | Fix |
|---|---|---|
| E2E tests fail silently | `KUBECONFIG` not set | `export KUBECONFIG=...` |
| `ci/prow/images` fails | `make verify` fails locally | Run `make verify` and fix issues |
| Stale test fixtures | Assets out of sync | `make clean && make generate` |
| Permission denied | Running as CMO SA without proper RBAC | Use `SWITCH_TO_CMO=false` |

## CI Pipeline

Prow CI runs these jobs on PRs:

| Job | What It Checks |
|---|---|
| `ci/prow/images` | Builds images, runs `make verify` |
| `ci/prow/e2e` | Full E2E test suite on a test cluster |
| `ci/prow/generate` | Verifies generated assets are up to date |

### CI Artifacts

Results are stored in the Prow job page under `artifacts/`:

- `build-log.txt` — Main build/test output
- `artifacts/e2e-test/` — E2E test logs and must-gather data
- `artifacts/junit*.xml` — Structured test results (parseable by CI dashboards)
