# kube-state-metrics

## Overview

| | |
|---|---|
| **Community Upstream** | [kubernetes/kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) |
| **OpenShift Fork** | [openshift/kube-state-metrics](https://github.com/openshift/kube-state-metrics) |
| **Submodule** | `projects/kube-state-metrics` |
| **Namespace** | `openshift-monitoring` |
| **Kind** | Deployment |
| **Replicas** | 1 |

## Role in the Stack

kube-state-metrics (KSM) generates metrics about the state of Kubernetes objects by listening to the Kubernetes API server. It does not modify or store state — it simply converts the current state of K8s objects into Prometheus metrics.

Key metric families include:

- `kube_pod_*` — Pod status, phase, conditions, resource requests/limits
- `kube_deployment_*` — Deployment replicas, conditions
- `kube_statefulset_*` — StatefulSet replicas, update status
- `kube_daemonset_*` — DaemonSet desired/current/ready counts
- `kube_node_*` — Node conditions, capacity, allocatable resources
- `kube_namespace_*` — Namespace status, labels
- `kube_job_*` / `kube_cronjob_*` — Job/CronJob status
- `kube_persistentvolumeclaim_*` — PVC status, capacity
- `kube_resourcequota_*` — Resource quota usage

## Key Metrics

| Metric | Description |
|---|---|
| `kube_pod_status_phase` | Pod phase (Pending/Running/Succeeded/Failed/Unknown) |
| `kube_pod_container_status_restarts_total` | Container restart count |
| `kube_pod_container_resource_requests` | Container CPU/memory requests |
| `kube_pod_container_resource_limits` | Container CPU/memory limits |
| `kube_deployment_status_replicas_available` | Available replicas |
| `kube_node_status_condition` | Node conditions (Ready, MemoryPressure, etc.) |
| `kube_node_status_allocatable` | Allocatable resources per node |

## Companion: openshift-state-metrics

CMO also deploys `openshift-state-metrics`, which generates metrics for OpenShift-specific resources (ClusterOperator, Route, Build, etc.). This runs as a separate Deployment in `openshift-monitoring`.

## Jsonnet Source

`jsonnet/components/kube-state-metrics.libsonnet`
