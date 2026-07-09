# openshift-state-metrics — Development Guide

## Repository

- **Downstream**: [openshift/openshift-state-metrics](https://github.com/openshift/openshift-state-metrics)

> **Note:** openshift-state-metrics is an OpenShift-only component with no community upstream.

## CMO Integration

openshift-state-metrics is deployed by CMO as a Deployment. The Jsonnet source is at `jsonnet/components/openshift-state-metrics.libsonnet`, which imports from the [openshift/openshift-state-metrics](https://github.com/openshift/openshift-state-metrics) Jsonnet library.

### Modifying the Deployment

1. Edit `jsonnet/components/openshift-state-metrics.libsonnet`
2. Run `make jsonnet-fmt generate`
3. Verify generated assets in `assets/openshift-state-metrics/`

## Version Bumps

There is no version key for openshift-state-metrics in `jsonnet/versions.yaml`. The library is imported as a Jsonnet dependency via `jsonnet/jsonnetfile.json`.

## Key Files in CMO

| File | Purpose |
|---|---|
| `jsonnet/components/openshift-state-metrics.libsonnet` | Jsonnet defining the Deployment |
| `pkg/tasks/openshiftstatemetrics.go` | Reconciliation task |
| `assets/openshift-state-metrics/` | Generated YAML manifests (do not edit) |

## Contributing

All changes go directly to [openshift/openshift-state-metrics](https://github.com/openshift/openshift-state-metrics).

### Getting Your Change into CMO

Changes to the openshift-state-metrics Jsonnet library are pulled into CMO via `jb update` (jsonnet-bundler), not via `versions.yaml`.
