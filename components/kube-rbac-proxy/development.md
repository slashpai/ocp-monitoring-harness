# kube-rbac-proxy — Development Guide

## Upstream Repository

- **OpenShift fork**: [openshift/kube-rbac-proxy](https://github.com/openshift/kube-rbac-proxy)
- **Upstream**: [brancz/kube-rbac-proxy](https://github.com/brancz/kube-rbac-proxy)

## CMO Integration

kube-rbac-proxy is not a standalone deployment — it runs as a sidecar container in multiple components. It is defined inline in each component's Jsonnet source, not in its own libsonnet file.

### Where It's Configured

Each component that uses kube-rbac-proxy defines its sidecar containers in its own `jsonnet/components/<component>.libsonnet`. To modify kube-rbac-proxy for a specific component, edit that component's Jsonnet.

## Version Bumps

1. Update `versions.kubeRbacProxy` in `jsonnet/versions.yaml`
2. Run `make generate`
3. Test with `make test-unit` and `make test-e2e`

A version bump affects all components that use kube-rbac-proxy as a sidecar.

## Key Files in CMO

| File | Purpose |
|---|---|
| `jsonnet/versions.yaml` | Version used across all sidecar instances |
| Component-specific `*.libsonnet` files | Each component defines its own kube-rbac-proxy sidecar |

## Contributing Upstream

- **Upstream**: [brancz/kube-rbac-proxy](https://github.com/brancz/kube-rbac-proxy)

> **Note:** kube-rbac-proxy syncing is not managed by syncbot — it is managed by the auth team.

### Build and Test

```bash
make build
make test
```

### Getting Your Change into OpenShift

Unlike other components, kube-rbac-proxy is not managed by [syncbot](https://github.com/rhobs/syncbot). The OpenShift fork is maintained by the auth team. Coordinate with them for version bumps and downstream patches.
