# telemeter-client — Development Guide

## Repository

- **Upstream**: [openshift/telemeter](https://github.com/openshift/telemeter)

> **Note:** telemeter is an OpenShift-specific project. There is no separate community upstream.

## CMO Integration

telemeter-client is deployed by CMO as a Deployment, only when telemetry is enabled. The Jsonnet source is at `jsonnet/components/telemeter-client.libsonnet`, which imports from the [openshift/telemeter](https://github.com/openshift/telemeter) Jsonnet library.

### Modifying the Deployment

1. Edit `jsonnet/components/telemeter-client.libsonnet`
2. Run `make jsonnet-fmt generate`
3. Verify generated assets in `assets/telemeter-client/`

## Version Bumps

There is no version key for telemeter-client in `jsonnet/versions.yaml`. The telemeter library is imported as a Jsonnet dependency via `jsonnet/jsonnetfile.json`.

## Key Files in CMO

| File | Purpose |
|---|---|
| `jsonnet/components/telemeter-client.libsonnet` | Jsonnet defining telemeter-client Deployment |
| `assets/telemeter-client/` | Generated YAML manifests (do not edit) |
| `test/e2e/telemeter_test.go` | E2E tests for telemeter |

## Adding Telemetry Metrics

To add new metrics to the telemetry allowlist, see the [Sending metrics via Telemetry](https://rhobs-handbook.netlify.app/products/openshiftmonitoring/telemetry.md/) page and the CMO [data collection documentation](https://github.com/openshift/cluster-monitoring-operator/blob/main/Documentation/data-collection.md).

## Contributing

All changes go directly to [openshift/telemeter](https://github.com/openshift/telemeter).

### Getting Your Change into CMO

Changes to the telemeter Jsonnet library are pulled into CMO via `jb update` (jsonnet-bundler), not via `versions.yaml`.
