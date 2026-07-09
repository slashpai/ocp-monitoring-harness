# Alertmanager — Development Guide

## Upstream Repository

- **OpenShift fork**: [openshift/prometheus-alertmanager](https://github.com/openshift/prometheus-alertmanager)
- **Upstream**: [prometheus/alertmanager](https://github.com/prometheus/alertmanager)

## CMO Integration

Alertmanager is deployed by CMO via the `Alertmanager` CRD. The Jsonnet source is at `jsonnet/components/alertmanager.libsonnet`.

### Modifying Alertmanager Deployment

1. Edit `jsonnet/components/alertmanager.libsonnet`
2. Run `make jsonnet-fmt generate`
3. Verify generated assets in `assets/alertmanager/`

### Modifying Configuration Options

1. Add the field to the config struct in `pkg/manifests/types.go` (look for `AlertmanagerMainConfig`)
2. Handle the field in `pkg/manifests/config.go`
3. Use the field in `pkg/manifests/manifests.go`
4. Run `make generate`

## Version Bumps

1. Update `versions.alertmanager` in `jsonnet/versions.yaml`
2. Run `make generate`
3. Test with `make test` and `make test-e2e`

## Key Files in CMO

| File | Purpose |
|---|---|
| `jsonnet/components/alertmanager.libsonnet` | Jsonnet defining all Alertmanager K8s resources |
| `pkg/manifests/manifests.go` | Go code that applies config to Alertmanager manifests |
| `pkg/manifests/types.go` | Config struct (`AlertmanagerMainConfig`) |
| `assets/alertmanager/` | Generated YAML manifests (do not edit) |
| `test/e2e/alertmanager_test.go` | E2E tests for Alertmanager |

## Common Development Tasks

### Modifying Default Alertmanager Configuration

The default routing/receiver configuration is set in CMO's Go code, not in Jsonnet. Look in `pkg/manifests/manifests.go` for how the default `alertmanager.yaml` is generated.

### Adding a New Receiver Type

If a new notification integration needs to be supported:

1. The receiver type must be supported by upstream Alertmanager
2. CMO may need config struct changes to expose the new receiver type
3. Documentation updates in both CMO and OpenShift monitoring docs
