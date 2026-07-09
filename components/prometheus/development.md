# Prometheus — Development Guide

## Upstream Repository

- **OpenShift fork**: [openshift/prometheus](https://github.com/openshift/prometheus)
- **Upstream**: [prometheus/prometheus](https://github.com/prometheus/prometheus)

OpenShift carries patches on top of upstream Prometheus. These are maintained in release-specific branches (e.g., `release-4.17`).

## CMO Integration

Prometheus is deployed by CMO via the `Prometheus` CRD. The Jsonnet source is at `jsonnet/components/prometheus.libsonnet`.

### Modifying Prometheus Configuration

To change how Prometheus is deployed (not its runtime config):

1. Edit `jsonnet/components/prometheus.libsonnet`
2. Run `make jsonnet-fmt generate`
3. Verify generated assets in `assets/prometheus/`

### Modifying Default Configuration Options

To add or change what users can configure via the `cluster-monitoring-config` ConfigMap:

1. Add the field to the config struct in `pkg/manifests/types.go`
2. Handle the field in `pkg/manifests/config.go`
3. Use the field in `pkg/manifests/manifests.go` (or the relevant manifests file)
4. Run `make generate`
5. Add tests in the relevant `*_test.go` files

## Version Bumps

To update the Prometheus version:

1. Update `versions.prometheus` in `jsonnet/versions.yaml`
2. Update the Go dependency if needed (the Prometheus client or other Prometheus packages)
3. Run `make generate`
4. Run `make test` and `make test-e2e`

## Key Files in CMO

| File | Purpose |
|---|---|
| `jsonnet/components/prometheus.libsonnet` | Jsonnet defining all Prometheus K8s resources |
| `pkg/manifests/manifests.go` | Go code that applies config to Prometheus manifests |
| `pkg/manifests/types.go` | Config struct (look for `PrometheusK8sConfig`) |
| `assets/prometheus/` | Generated YAML manifests (do not edit) |
| `test/e2e/prometheus_test.go` | E2E tests for Prometheus |

## Common Development Tasks

### Adding a Command-Line Flag

Prometheus command-line flags are set in the `Prometheus` CRD spec in `jsonnet/components/prometheus.libsonnet`. Add flags to the `spec.containers[].args` field or use the CRD's native fields where available.

### Adding a ServiceMonitor Target

If a new component needs to be scraped by Prometheus, add a ServiceMonitor in the component's Jsonnet. Prometheus will automatically discover it through the ServiceMonitor CRD.

### Modifying Retention Settings

Retention is configurable via `cluster-monitoring-config`. The default is set in `pkg/manifests/types.go`. Changes flow through:

```text
types.go (default) → config.go (parse) → prometheus.go (apply to CRD) → Prometheus CRD (runtime)
```
