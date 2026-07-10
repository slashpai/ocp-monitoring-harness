# Conventions

Coding and contribution conventions for the cluster-monitoring-operator and the OpenShift monitoring stack. The agent should follow these automatically when working on CMO code.

Reference: [OpenShift enhancements CONVENTIONS.md](https://github.com/openshift/enhancements/blob/master/CONVENTIONS.md)

## Code Style

### Go

- Follow standard `gofmt` formatting
- Use `golangci-lint` (config in `.golangci.yaml` in the CMO repo)
- Error messages should be lowercase, no trailing punctuation
- Wrap errors with context: `fmt.Errorf("failed to reconcile prometheus: %w", err)`
- Prefer table-driven tests

### Jsonnet

- Run `make jsonnet-fmt` before committing any Jsonnet changes
- Use `local` variables for values referenced more than once
- Component libsonnet files should export a single object with named fields for each K8s resource
- Labels must include `app.kubernetes.io/name` and `app.kubernetes.io/version`

### YAML (generated assets)

- Never edit files in `assets/` or auto-generated files in `manifests/` directly
- Always regenerate with `make generate` after Jsonnet changes

## Naming Conventions

### Kubernetes Resources

- Resource names use lowercase-hyphenated format: `prometheus-k8s`, `alertmanager-main`, `kube-state-metrics`
- ServiceMonitor names match the component they scrape
- PrometheusRule names follow `<component>-prometheus-rules` pattern

### Metrics

- Follow [Prometheus naming conventions](https://prometheus.io/docs/practices/naming/):
  - Use `snake_case`
  - Include unit as suffix: `_seconds`, `_bytes`, `_total`
  - Counters end in `_total`
  - Use base units (seconds not milliseconds, bytes not kilobytes)

### Alerts

- Alert names use CamelCase: `PrometheusHighMemory`, `AlertmanagerClusterDown`
- Include a `severity` label: `critical`, `warning`, or `info`
- Include a `namespace` label matching the component's namespace
- Include `summary` and `description` annotations
- Include a `runbook_url` annotation when a runbook exists

## Commit Messages

Format: `<subsystem>: <what changed>`

Examples:

- `jsonnet: update prometheus version to 3.12.0`
- `pkg/manifests: add CEL validation for retention field`
- `test: add e2e test for UWM prometheus retention`
- `docs: update development guide`

## Pull Request Titles

- Bug fixes: `OCPBUGS-12345: descriptive title`
- Features: `MON-1234: descriptive title`
- OCPBUGS issues are managed by jira-lifecycle-plugin (automated state transitions)
- MON issues must be transitioned manually

## Configuration Conventions

### Adding a New Config Option

1. Add the field to the struct in `pkg/manifests/types.go`
2. Use Go struct tags for JSON serialization and defaults
3. Add CEL validation expressions where appropriate
4. Handle the field in `pkg/manifests/config.go`
5. Apply the value in the relevant `pkg/manifests/<component>.go`
6. Always support zero-value (field not set) gracefully — use sensible defaults

### Config Field Naming

- Use camelCase in the YAML config (matching Go JSON struct tags)
- Group related fields in nested structs
- Document constraints via CEL validation, not just comments

## Testing Conventions

- Unit tests live alongside the code they test (`*_test.go`)
- E2E tests live in `test/e2e/`
- E2E tests require `KUBECONFIG` to be set explicitly
- Run `make tests-ext-update` after modifying Ginkgo tests
- Test names should describe the scenario, not the implementation

## Dependency Management

CMO has three Go modules — changes must be applied to all affected modules:

| Module | Path | Purpose |
|---|---|---|
| Main | `./` | Operator code |
| E2E tests | `test/monitoring/` | Test framework |
| Tools | `hack/tools/` | Development tools |

For each module: `go mod tidy && go mod vendor`

## CI Expectations

- `ci/prow/images` — Must pass; if it fails, `make verify` likely fails locally
- `ci/prow/e2e` — Full E2E suite on a real cluster
- All generated files must be committed (Jsonnet output, generated Go code)
- No new linter warnings allowed

## Harness Conventions

When updating this harness repository:

- Keep component READMEs factual — reference upstream documentation rather than duplicating it
- For operational PromQL, use CMO alert rules in `projects/cluster-monitoring-operator/assets/*/prometheus-rule.yaml` (generated from jsonnet) rather than duplicating queries in the harness
- For alert definitions, refer to the Jsonnet source in `projects/cluster-monitoring-operator/jsonnet/components/`
- After implementing in `projects/` submodules, run `make reset-projects` to restore clean upstream SHAs (push to your fork first)
- Cursor rules (`.mdc` files) should be concise — detailed content goes in the referenced docs
- Do not hardcode component versions anywhere in the harness — the source of truth is `projects/cluster-monitoring-operator/jsonnet/versions.yaml`
- Keep submodules up to date with `git submodule update --remote`
