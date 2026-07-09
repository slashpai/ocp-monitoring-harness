# monitoring-plugin — Development Guide

## Repository

- **Downstream**: [openshift/monitoring-plugin](https://github.com/openshift/monitoring-plugin)

> **Note:** monitoring-plugin is an OpenShift-only component with no community upstream.

## CMO Integration

monitoring-plugin is deployed by CMO as a Deployment (2 replicas). The Jsonnet source is at `jsonnet/components/monitoring-plugin.libsonnet`.

### Modifying the Deployment

1. Edit `jsonnet/components/monitoring-plugin.libsonnet`
2. Run `make jsonnet-fmt generate`
3. Verify generated assets in `assets/monitoring-plugin/`

## Version Bumps

1. Update `versions.monitoringPlugin` in `jsonnet/versions.yaml`
2. Run `make generate`
3. Test the console monitoring UI after deploying

## Key Files in CMO

| File | Purpose |
|---|---|
| `jsonnet/components/monitoring-plugin.libsonnet` | Jsonnet defining monitoring-plugin Deployment |
| `assets/monitoring-plugin/` | Generated YAML manifests (do not edit) |

## Contributing

Since there is no community upstream, all changes go directly to [openshift/monitoring-plugin](https://github.com/openshift/monitoring-plugin).

- **Language**: TypeScript (React-based OpenShift console plugin)
- **Build**: `make build`
- **Test**: `make test`

### Getting Your Change into CMO

After your PR is merged to `openshift/monitoring-plugin`, [syncbot](https://github.com/rhobs/syncbot) will update CMO's `jsonnet/versions.yaml` with the new version.
