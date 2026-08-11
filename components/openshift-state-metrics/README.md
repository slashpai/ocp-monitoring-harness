# openshift-state-metrics

OpenShift-only component with no community upstream. For component details (repos, namespace, submodule path), see [ARCHITECTURE.md](../../ARCHITECTURE.md).

## Role in the Stack

openshift-state-metrics exposes metrics about OpenShift-specific resources that are not covered by kube-state-metrics. It generates metrics from the Kubernetes API for OpenShift custom resources such as:

- `ClusterVersion`
- `ClusterOperator`
- `ClusterResourceQuota`
- `Route`
- `Build`, `BuildConfig`
- `DeploymentConfig`

This provides observability into OpenShift platform state that complements the Kubernetes-level metrics from kube-state-metrics.

## Key Metrics Exposed

| Metric | Type | Description |
|---|---|---|
| `openshift_clusterversion_info` | Gauge | Cluster version information |
| `openshift_clusteroperator_conditions` | Gauge | ClusterOperator condition status |
| `openshift_clusterresourcequota_usage` | Gauge | Cluster resource quota usage |
| `openshift_route_info` | Gauge | Route metadata |
| `openshift_build_info` | Gauge | Build metadata |

## Jsonnet Source

`jsonnet/components/openshift-state-metrics.libsonnet` — Defines the openshift-state-metrics Deployment, RBAC, and related resources.

