# openshift-state-metrics

## Overview

| | |
|---|---|
| **Repository** | [openshift/openshift-state-metrics](https://github.com/openshift/openshift-state-metrics) |
| **Namespace** | `openshift-monitoring` |
| **Kind** | Deployment |
| **Replicas** | 1 |

> **Note:** openshift-state-metrics is an OpenShift-only component with no community upstream.

## Role in the Stack

openshift-state-metrics exposes metrics about OpenShift-specific resources that are not covered by kube-state-metrics. It generates metrics from the Kubernetes API for OpenShift custom resources such as:

- `ClusterVersion`
- `ClusterOperator`
- `ClusterResourceQuota`
- `Route`
- `Build`, `BuildConfig`
- `DeploymentConfig`

This provides observability into OpenShift platform state that complements the Kubernetes-level metrics from kube-state-metrics.

## Deployment Topology

Containers in the pod:

- `openshift-state-metrics` — Main process generating metrics from OpenShift API objects
- `kube-rbac-proxy` — AuthN/AuthZ proxy for the metrics endpoints

## Key Configuration

In `cluster-monitoring-config` ConfigMap under the `openshiftStateMetrics` key:

| Setting | Default | Description |
|---|---|---|
| `resources` | (defaults) | CPU/memory requests and limits |
| `nodeSelector` | (none) | Node scheduling constraints |
| `tolerations` | (none) | Tolerations for tainted nodes |

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

See [development.md](development.md) for CMO integration details and contribution guide.
