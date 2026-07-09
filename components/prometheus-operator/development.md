# Prometheus Operator — Development Guide

## Upstream Repository

- **OpenShift fork**: [openshift/prometheus-operator](https://github.com/openshift/prometheus-operator)
- **Upstream**: [prometheus-operator/prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)

## CMO Integration

Prometheus Operator is deployed by CMO as a Deployment. It runs in reconciliation group 1 (before all other components) because it manages the CRDs that everything else depends on.

### Jsonnet Source

`jsonnet/components/prometheus-operator.libsonnet` — Defines the Deployment, ClusterRole, ClusterRoleBinding, Service, ServiceMonitor, and related resources.

### Modifying the Deployment

1. Edit `jsonnet/components/prometheus-operator.libsonnet`
2. Run `make jsonnet-fmt generate`
3. Verify assets in `assets/prometheus-operator/`

## Version Bumps

1. Update `versions.prometheusOperator` in `jsonnet/versions.yaml`
2. Check for CRD changes — new PO versions may add/modify CRD fields
3. Run `make generate`
4. Run full test suite — CRD changes can have wide-reaching effects

## Key Files in CMO

| File | Purpose |
|---|---|
| `jsonnet/components/prometheus-operator.libsonnet` | Jsonnet defining PO Deployment and RBAC |
| `assets/prometheus-operator/` | Generated YAML manifests (do not edit) |
| `manifests/` | CVO-deployed CRDs (generated from Jsonnet) |

## Impact of Changes

Prometheus Operator changes have the widest blast radius in CMO because:

1. CRD changes affect all consumers (Prometheus, Alertmanager, users creating ServiceMonitors)
2. Reconciliation logic changes affect how all managed resources are synced
3. It must start before any other component can be deployed

Always run full E2E tests when modifying Prometheus Operator configuration.
