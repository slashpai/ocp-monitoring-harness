# Prometheus Operator

## Overview

| | |
|---|---|
| **Community Upstream** | [prometheus-operator/prometheus-operator](https://github.com/prometheus-operator/prometheus-operator) |
| **OpenShift Fork** | [openshift/prometheus-operator](https://github.com/openshift/prometheus-operator) |
| **Submodule** | `projects/prometheus-operator` |
| **Namespace** | `openshift-monitoring` (platform), `openshift-user-workload-monitoring` (UWM) |
| **Kind** | Deployment |
| **Replicas** | 1 (per namespace) |
| **Pod Name Pattern** | `prometheus-operator-*` |

## Role in the Stack

Prometheus Operator is the foundational component that **must be deployed first** — it manages the CRDs that all other components depend on. It:

- **Defines CRDs**: `Prometheus`, `Alertmanager`, `ServiceMonitor`, `PodMonitor`, `PrometheusRule`, `ThanosRuler`, `AlertmanagerConfig`, `ScrapeConfig`, `PrometheusAgent`
- **Watches** CRD instances and generates the appropriate Prometheus/Alertmanager configuration
- **Manages** the lifecycle of Prometheus and Alertmanager StatefulSets based on their CRD specs

## CRDs Managed

| CRD | Purpose |
|---|---|
| `Prometheus` | Defines a Prometheus instance (replicas, retention, storage, etc.) |
| `Alertmanager` | Defines an Alertmanager cluster |
| `ServiceMonitor` | Defines which Services Prometheus should scrape |
| `PodMonitor` | Defines which Pods Prometheus should scrape (without a Service) |
| `PrometheusRule` | Defines alerting and recording rules |
| `ThanosRuler` | Defines a Thanos Ruler instance |
| `AlertmanagerConfig` | Namespace-scoped Alertmanager routing/receivers |
| `ScrapeConfig` | Low-level scrape configuration |
| `PrometheusAgent` | Defines a Prometheus Agent (metrics-only, no alerting) |

## Deployment Topology

### Platform Prometheus Operator

Single replica in `openshift-monitoring`. Watches all namespaces for CRDs related to platform monitoring.

Containers:

- `prometheus-operator` — Main operator process
- `kube-rbac-proxy` — AuthN/AuthZ sidecar for metrics endpoint

### UWM Prometheus Operator

Separate instance in `openshift-user-workload-monitoring` (when UWM is enabled). Watches user namespaces for ServiceMonitors, PodMonitors, and PrometheusRules.

## Key Configuration

Prometheus Operator itself has minimal configuration in `cluster-monitoring-config` under the `prometheusOperator` key:

| Setting | Default | Description |
|---|---|---|
| `resources` | (defaults) | CPU/memory requests and limits |
| `nodeSelector` | (none) | Node scheduling constraints |
| `tolerations` | (none) | Tolerations for tainted nodes |

## Key Metrics Exposed

| Metric | Type | Description |
|---|---|---|
| `prometheus_operator_reconcile_operations_total` | Counter | Total reconciliation operations |
| `prometheus_operator_reconcile_errors_total` | Counter | Failed reconciliation operations |
| `prometheus_operator_node_address_lookup_errors_total` | Counter | Node address lookup failures |
| `prometheus_operator_spec_replicas` | Gauge | Configured replicas for managed resources |
| `prometheus_operator_status_replicas` | Gauge | Actual replicas for managed resources |
| `prometheus_operator_triggered_total` | Counter | Times the operator was triggered |
| `prometheus_operator_list_operations_total` | Counter | List API calls |
| `prometheus_operator_watch_operations_total` | Counter | Watch API calls |

## Why It Must Run First

In CMO's reconciliation order, Prometheus Operator runs in **group 1** (before all other components) because:

1. It registers the CRDs (`Prometheus`, `Alertmanager`, `ServiceMonitor`, etc.)
2. All other components depend on these CRDs existing before they can be created
3. Without PO running, Kubernetes would reject any `ServiceMonitor`, `PrometheusRule`, etc. resources

## Jsonnet Source

`jsonnet/components/prometheus-operator.libsonnet` — Defines the Prometheus Operator Deployment, RBAC, and CRD resources.
