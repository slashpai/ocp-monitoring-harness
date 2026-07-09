# node-exporter — Development Guide

## Upstream Repository

- **OpenShift fork**: [openshift/node_exporter](https://github.com/openshift/node_exporter)
- **Upstream**: [prometheus/node_exporter](https://github.com/prometheus/node_exporter)

## CMO Integration

node-exporter is deployed by CMO as a DaemonSet (one pod per node). The Jsonnet source is at `jsonnet/components/node-exporter.libsonnet`.

### Modifying the DaemonSet

1. Edit `jsonnet/components/node-exporter.libsonnet`
2. Run `make jsonnet-fmt generate`
3. Verify generated assets in `assets/node-exporter/`

## Version Bumps

1. Update `versions.nodeExporter` in `jsonnet/versions.yaml`
2. Run `make generate`
3. Test with `make test-unit` and `make test-e2e`

## Key Files in CMO

| File | Purpose |
|---|---|
| `jsonnet/components/node-exporter.libsonnet` | Jsonnet defining node-exporter DaemonSet and RBAC |
| `assets/node-exporter/` | Generated YAML manifests (do not edit) |
| `test/e2e/node_exporter_test.go` | E2E tests for node-exporter |

## Contributing Upstream

For changes to node-exporter itself (new collectors, hardware metrics), contribute to the community upstream repo.

- **Upstream**: [prometheus/node_exporter](https://github.com/prometheus/node_exporter)
- **Contributing guide**: [CONTRIBUTING.md](https://github.com/prometheus/node_exporter/blob/master/CONTRIBUTING.md)
- **Communication**: [#prometheus-dev on Libera IRC](https://web.libera.chat/?channels=#prometheus-dev)
- **DCO**: Required (sign off commits with `git commit -s`)

### Build and Test

```bash
make build
make test
```

### Getting Your Change into OpenShift

After your upstream PR is merged and included in a release, [syncbot](https://github.com/rhobs/syncbot) will rebase `openshift/node_exporter` onto the new release and update CMO's `jsonnet/versions.yaml`. See [development/contributing.md](../../development/contributing.md#end-to-end-workflow-upstream-change-to-openshift) for the full workflow.
