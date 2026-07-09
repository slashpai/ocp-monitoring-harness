# metrics-server — Development Guide

## Upstream Repository

- **OpenShift fork**: [openshift/kubernetes-metrics-server](https://github.com/openshift/kubernetes-metrics-server)
- **Upstream**: [kubernetes-sigs/metrics-server](https://github.com/kubernetes-sigs/metrics-server)

> **Note:** metrics-server replaced prometheus-adapter since OpenShift 4.16.

## CMO Integration

metrics-server is deployed by CMO as a Deployment (2 replicas). The Jsonnet source is at `jsonnet/components/metrics-server.libsonnet`.

### Modifying the Deployment

1. Edit `jsonnet/components/metrics-server.libsonnet`
2. Run `make jsonnet-fmt generate`
3. Verify generated assets in `assets/metrics-server/`

## Version Bumps

1. Update `versions.kubernetesMetricsServer` in `jsonnet/versions.yaml`
2. Run `make generate`
3. Test with `make test-unit` and `make test-e2e`

## Key Files in CMO

| File | Purpose |
|---|---|
| `jsonnet/components/metrics-server.libsonnet` | Jsonnet defining metrics-server Deployment |
| `jsonnet/components/metrics-server-audit.libsonnet` | Audit logging configuration |
| `assets/metrics-server/` | Generated YAML manifests (do not edit) |
| `test/e2e/metrics_adapter_test.go` | E2E tests for metrics-server |

## Contributing Upstream

For changes to metrics-server itself (resource metrics collection, metrics.k8s.io API), contribute to the community upstream repo.

- **Upstream**: [kubernetes-sigs/metrics-server](https://github.com/kubernetes-sigs/metrics-server)

### Getting Your Change into OpenShift

After your upstream PR is merged and included in a release, [syncbot](https://github.com/rhobs/syncbot) will rebase `openshift/kubernetes-metrics-server` onto the new release and update CMO's `jsonnet/versions.yaml`. See [development/contributing.md](../../development/contributing.md#end-to-end-workflow-upstream-change-to-openshift) for the full workflow.
