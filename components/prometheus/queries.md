# Prometheus — Useful PromQL Queries

## Health and Availability

```promql
# Prometheus target health (1=up, 0=down)
up{job="prometheus-k8s", namespace="openshift-monitoring"}

# Prometheus readiness
prometheus_ready{namespace="openshift-monitoring"}
```

## TSDB Health

```promql
# Active time series count (per instance)
prometheus_tsdb_head_series{namespace="openshift-monitoring"}

# Rate of new samples ingested
rate(prometheus_tsdb_head_samples_appended_total{namespace="openshift-monitoring"}[5m])

# WAL corruptions (should be 0)
prometheus_tsdb_wal_corruptions_total{namespace="openshift-monitoring"}

# Failed compactions (should be 0)
prometheus_tsdb_compactions_failed_total{namespace="openshift-monitoring"}

# TSDB disk size
prometheus_tsdb_storage_blocks_bytes{namespace="openshift-monitoring"}

# Head chunks in memory
prometheus_tsdb_head_chunks{namespace="openshift-monitoring"}

# Time of most recent successful compaction
prometheus_tsdb_compactions_last_completed_timestamp_seconds{namespace="openshift-monitoring"}
```

## Resource Usage

```promql
# Memory usage
container_memory_working_set_bytes{namespace="openshift-monitoring", pod=~"prometheus-k8s-.*", container="prometheus"}

# CPU usage
rate(container_cpu_usage_seconds_total{namespace="openshift-monitoring", pod=~"prometheus-k8s-.*", container="prometheus"}[5m])

# Memory as percentage of limit
container_memory_working_set_bytes{namespace="openshift-monitoring", pod=~"prometheus-k8s-.*", container="prometheus"}
  / on(pod, container) kube_pod_container_resource_limits{resource="memory", namespace="openshift-monitoring", pod=~"prometheus-k8s-.*", container="prometheus"}
```

## Scrape Performance

```promql
# Scrape duration by target (find slow targets)
topk(10, scrape_duration_seconds{namespace="openshift-monitoring"})

# Samples scraped per target
topk(10, scrape_samples_scraped{namespace="openshift-monitoring"})

# Targets that are down
up{namespace="openshift-monitoring"} == 0

# Scrape failures
rate(prometheus_target_scrapes_exceeded_sample_limit_total{namespace="openshift-monitoring"}[5m])
```

## Query Performance

```promql
# Query duration p99
histogram_quantile(0.99, sum by (le) (rate(prometheus_engine_query_duration_seconds_bucket{namespace="openshift-monitoring"}[5m])))

# Active queries
prometheus_engine_queries{namespace="openshift-monitoring"}

# Query timeouts
rate(prometheus_engine_query_duration_seconds_count{namespace="openshift-monitoring", slice="inner_eval"}[5m])
```

## Rule Evaluation

```promql
# Rule evaluation duration (per group)
prometheus_rule_group_last_duration_seconds{namespace="openshift-monitoring"}

# Missed rule evaluations
rate(prometheus_rule_group_iterations_missed_total{namespace="openshift-monitoring"}[5m])

# Failed rule evaluations
rate(prometheus_rule_evaluation_failures_total{namespace="openshift-monitoring"}[5m])
```

## Alerting Pipeline (Prometheus Side)

```promql
# Notifications sent to Alertmanager
rate(prometheus_notifications_sent_total{namespace="openshift-monitoring"}[5m])

# Failed notifications to Alertmanager
rate(prometheus_notifications_errors_total{namespace="openshift-monitoring"}[5m])

# Current notification queue length
prometheus_notifications_queue_length{namespace="openshift-monitoring"}

# Dropped notifications
prometheus_notifications_dropped_total{namespace="openshift-monitoring"}
```

## Cardinality Investigation

```promql
# Top 10 metrics by series count
topk(10, count by (__name__) ({namespace="openshift-monitoring"}))

# Total active time series
prometheus_tsdb_head_series{namespace="openshift-monitoring"}

# Series created rate (high churn indicates label instability)
rate(prometheus_tsdb_head_series_created_total{namespace="openshift-monitoring"}[5m])
```
