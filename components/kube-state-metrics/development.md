# kube-state-metrics — Development Guide

## Upstream Repository

- **OpenShift fork**: [openshift/kube-state-metrics](https://github.com/openshift/kube-state-metrics)
- **Upstream**: [kubernetes/kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)

## CMO Integration

kube-state-metrics is deployed by CMO as a Deployment. The Jsonnet source is at `jsonnet/components/kube-state-metrics.libsonnet`.

### Modifying the Deployment

1. Edit `jsonnet/components/kube-state-metrics.libsonnet`
2. Run `make jsonnet-fmt generate`
3. Verify generated assets in `assets/kube-state-metrics/`

## Version Bumps

1. Update `versions.kubeStateMetrics` in `jsonnet/versions.yaml`
2. Run `make generate`
3. Test with `make test-unit` and `make test-e2e`

## Key Files in CMO

| File | Purpose |
|---|---|
| `jsonnet/components/kube-state-metrics.libsonnet` | Jsonnet defining kube-state-metrics Deployment and RBAC |
| `assets/kube-state-metrics/` | Generated YAML manifests (do not edit) |
| `test/e2e/kube_state_metrics_test.go` | E2E tests for kube-state-metrics |

## Contributing Upstream

For changes to kube-state-metrics itself (new metric families, Kubernetes resource collectors), contribute to the community upstream repo.

- **Upstream**: [kubernetes/kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)
- **Contributing guide**: [CONTRIBUTING.md](https://github.com/kubernetes/kube-state-metrics/blob/main/CONTRIBUTING.md)
- **Communication**: [#kube-state-metrics on Kubernetes Slack](https://kubernetes.slack.com/messages/CJJ529RUY)
- **Commit format**: [Conventional Commits](https://www.conventionalcommits.org/) (e.g., `feat: add new metric`, `fix(scope): description`)

### Build and Test

```bash
make build
make test-unit
make lint
```

### Getting Your Change into OpenShift

After your upstream PR is merged and included in a release, [syncbot](https://github.com/rhobs/syncbot) will rebase `openshift/kube-state-metrics` onto the new release and update CMO's `jsonnet/versions.yaml`. See [development/contributing.md](../../development/contributing.md#end-to-end-workflow-upstream-change-to-openshift) for the full workflow.
