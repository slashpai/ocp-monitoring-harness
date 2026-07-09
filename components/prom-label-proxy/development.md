# prom-label-proxy — Development Guide

## Upstream Repository

- **OpenShift fork**: [openshift/prom-label-proxy](https://github.com/openshift/prom-label-proxy)
- **Upstream**: [prometheus-community/prom-label-proxy](https://github.com/prometheus-community/prom-label-proxy)

## CMO Integration

prom-label-proxy is not a standalone deployment — it runs as a sidecar container in Alertmanager and Thanos Querier pods, enforcing tenant isolation by injecting namespace labels into queries.

### Where It's Configured

- Alertmanager: defined in `jsonnet/components/alertmanager.libsonnet`
- Thanos Querier: defined in `jsonnet/components/thanos-querier.libsonnet`

To modify prom-label-proxy configuration, edit the relevant component's Jsonnet.

## Version Bumps

1. Update `versions.promLabelProxy` in `jsonnet/versions.yaml`
2. Run `make generate`
3. Test with `make test-unit` and `make test-e2e`

## Key Files in CMO

| File | Purpose |
|---|---|
| `jsonnet/components/alertmanager.libsonnet` | prom-label-proxy sidecar in Alertmanager |
| `jsonnet/components/thanos-querier.libsonnet` | prom-label-proxy sidecar in Thanos Querier |

## Contributing Upstream

For changes to prom-label-proxy itself (label injection logic, query enforcement), contribute to the community upstream repo.

- **Upstream**: [prometheus-community/prom-label-proxy](https://github.com/prometheus-community/prom-label-proxy)

### Build and Test

```bash
make build
make test
```

### Getting Your Change into OpenShift

After your upstream PR is merged and included in a release, [syncbot](https://github.com/rhobs/syncbot) will rebase `openshift/prom-label-proxy` onto the new release and update CMO's `jsonnet/versions.yaml`. See [development/contributing.md](../../development/contributing.md#end-to-end-workflow-upstream-change-to-openshift) for the full workflow.
