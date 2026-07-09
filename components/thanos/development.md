# Thanos — Development Guide

## Upstream Repository

- **OpenShift fork**: [openshift/thanos](https://github.com/openshift/thanos)
- **Upstream**: [thanos-io/thanos](https://github.com/thanos-io/thanos)

## CMO Integration

CMO deploys two Thanos components:

- **Thanos Querier** — Deployment in `openshift-monitoring`, Jsonnet at `jsonnet/components/thanos-querier.libsonnet`
- **Thanos Ruler** — StatefulSet in `openshift-user-workload-monitoring`, Jsonnet at `jsonnet/components/thanos-ruler.libsonnet`

The Thanos sidecar is deployed as a container within Prometheus pods (defined in `jsonnet/components/prometheus.libsonnet`).

### Modifying Thanos Querier

1. Edit `jsonnet/components/thanos-querier.libsonnet`
2. Run `make jsonnet-fmt generate`
3. Verify generated assets in `assets/thanos-querier/`

### Modifying Thanos Ruler

1. Edit `jsonnet/components/thanos-ruler.libsonnet`
2. Run `make jsonnet-fmt generate`
3. Verify generated assets in `assets/thanos-ruler/`

## Version Bumps

1. Update `versions.thanos` in `jsonnet/versions.yaml`
2. Run `make generate`
3. Test with `make test-unit` and `make test-e2e`

All three Thanos components (Querier, Ruler, Sidecar) share the same image and version.

## Key Files in CMO

| File | Purpose |
|---|---|
| `jsonnet/components/thanos-querier.libsonnet` | Jsonnet defining Thanos Querier Deployment |
| `jsonnet/components/thanos-ruler.libsonnet` | Jsonnet defining Thanos Ruler StatefulSet |
| `assets/thanos-querier/` | Generated Querier manifests (do not edit) |
| `assets/thanos-ruler/` | Generated Ruler manifests (do not edit) |
| `test/e2e/thanos_querier_test.go` | E2E tests for Thanos Querier |
| `test/e2e/thanos_ruler_test.go` | E2E tests for Thanos Ruler |

## Contributing Upstream

For changes to Thanos itself (query engine, store gateway, compactor), contribute to the community upstream repo.

- **Upstream**: [thanos-io/thanos](https://github.com/thanos-io/thanos)
- **Contributing guide**: [CONTRIBUTING.md](https://github.com/thanos-io/thanos/blob/main/CONTRIBUTING.md)
- **Communication**: [#thanos on CNCF Slack](https://cloud-native.slack.com/archives/CL25937SP)
- **DCO**: Required (sign off commits with `git commit -s`)

### Build and Test

```bash
make build
make test
make lint
```

### Getting Your Change into OpenShift

After your upstream PR is merged and included in a release, [syncbot](https://github.com/rhobs/syncbot) will rebase `openshift/thanos` onto the new release and update CMO's `jsonnet/versions.yaml`. See [development/contributing.md](../../development/contributing.md#end-to-end-workflow-upstream-change-to-openshift) for the full workflow.
