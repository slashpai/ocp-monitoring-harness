# Prometheus Operator

For component details (repos, namespace, submodule path), see [ARCHITECTURE.md](../../ARCHITECTURE.md).

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

