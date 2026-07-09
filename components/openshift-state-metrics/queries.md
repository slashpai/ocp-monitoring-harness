# openshift-state-metrics — Useful PromQL Queries

## Health

```promql
# openshift-state-metrics pod health
up{job="openshift-state-metrics", namespace="openshift-monitoring"}
```

## Cluster Version and Operators

```promql
# Current cluster version
openshift_clusterversion_info

# ClusterOperator conditions (degraded, available, progressing)
openshift_clusteroperator_conditions{condition="Degraded"} == 1

# All available ClusterOperators
openshift_clusteroperator_conditions{condition="Available"} == 1
```

## Resource Quotas

```promql
# Cluster resource quota usage
openshift_clusterresourcequota_usage

# Quota utilization percentage
openshift_clusterresourcequota_usage / openshift_clusterresourcequota_hard * 100
```

## Resource Usage

```promql
# Memory usage
container_memory_working_set_bytes{namespace="openshift-monitoring", pod=~"openshift-state-metrics-.*", container!=""}

# CPU usage
rate(container_cpu_usage_seconds_total{namespace="openshift-monitoring", pod=~"openshift-state-metrics-.*", container!=""}[5m])
```
