# Prometheus Operator — Useful PromQL Queries

## Health and Availability

```promql
# Prometheus Operator target health
up{job="prometheus-operator", namespace="openshift-monitoring"}

# UWM Prometheus Operator health (if UWM enabled)
up{job="prometheus-operator", namespace="openshift-user-workload-monitoring"}
```

## Reconciliation

```promql
# Reconciliation rate
rate(prometheus_operator_reconcile_operations_total{namespace="openshift-monitoring"}[5m])

# Reconciliation error rate (should be 0)
rate(prometheus_operator_reconcile_errors_total{namespace="openshift-monitoring"}[5m])

# Error ratio
rate(prometheus_operator_reconcile_errors_total{namespace="openshift-monitoring"}[5m])
  / rate(prometheus_operator_reconcile_operations_total{namespace="openshift-monitoring"}[5m])
```

## Managed Resources

```promql
# Configured vs actual replicas (should match)
prometheus_operator_spec_replicas{namespace="openshift-monitoring"}
prometheus_operator_status_replicas{namespace="openshift-monitoring"}

# Replica mismatch (spec != status means something is wrong)
prometheus_operator_spec_replicas{namespace="openshift-monitoring"}
  != prometheus_operator_status_replicas{namespace="openshift-monitoring"}
```

## Operator Activity

```promql
# Trigger rate (how often the operator processes events)
rate(prometheus_operator_triggered_total{namespace="openshift-monitoring"}[5m])

# List operations (API calls)
rate(prometheus_operator_list_operations_total{namespace="openshift-monitoring"}[5m])

# Watch operations
rate(prometheus_operator_watch_operations_total{namespace="openshift-monitoring"}[5m])

# Node address lookup errors
rate(prometheus_operator_node_address_lookup_errors_total{namespace="openshift-monitoring"}[5m])
```

## Resource Usage

```promql
# Memory usage
container_memory_working_set_bytes{namespace="openshift-monitoring", pod=~"prometheus-operator-.*", container="prometheus-operator"}

# CPU usage
rate(container_cpu_usage_seconds_total{namespace="openshift-monitoring", pod=~"prometheus-operator-.*", container="prometheus-operator"}[5m])
```
