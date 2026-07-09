# Alertmanager — Useful PromQL Queries

## Health and Availability

```promql
# Alertmanager target health
up{job="alertmanager-main", namespace="openshift-monitoring"}

# Cluster members (should equal replica count)
alertmanager_cluster_members{namespace="openshift-monitoring"}

# Cluster health score (0 = healthy, higher = unhealthy)
alertmanager_cluster_health_score{namespace="openshift-monitoring"}
```

## Alert Traffic

```promql
# Active alerts by state
alertmanager_alerts{namespace="openshift-monitoring"}

# Alert receive rate
rate(alertmanager_alerts_received_total{namespace="openshift-monitoring"}[5m])

# Invalid alerts received (malformed, should be 0)
rate(alertmanager_alerts_invalid_total{namespace="openshift-monitoring"}[5m])
```

## Notification Delivery

```promql
# Notification send rate by integration (pagerduty, slack, email, webhook, etc.)
rate(alertmanager_notifications_total{namespace="openshift-monitoring"}[5m])

# Failed notifications by integration
rate(alertmanager_notifications_failed_total{namespace="openshift-monitoring"}[5m])

# Notification failure ratio (should be 0 or very low)
rate(alertmanager_notifications_failed_total{namespace="openshift-monitoring"}[5m])
  / rate(alertmanager_notifications_total{namespace="openshift-monitoring"}[5m])

# p99 notification latency
histogram_quantile(0.99, sum by (le, integration) (rate(alertmanager_notification_latency_seconds_bucket{namespace="openshift-monitoring"}[5m])))
```

## Silences

```promql
# Active silences
alertmanager_silences{namespace="openshift-monitoring", state="active"}

# Expired silences
alertmanager_silences{namespace="openshift-monitoring", state="expired"}
```

## Resource Usage

```promql
# Memory usage
container_memory_working_set_bytes{namespace="openshift-monitoring", pod=~"alertmanager-main-.*", container="alertmanager"}

# CPU usage
rate(container_cpu_usage_seconds_total{namespace="openshift-monitoring", pod=~"alertmanager-main-.*", container="alertmanager"}[5m])
```

## Cluster Gossip

```promql
# Peer info (verify cluster formation)
alertmanager_cluster_peers_joined_total{namespace="openshift-monitoring"}

# Cluster message send failures
rate(alertmanager_cluster_messages_publish_failures_total{namespace="openshift-monitoring"}[5m])
```

## Currently Firing Alerts (via Prometheus)

```promql
# All currently firing alerts
ALERTS{alertstate="firing"}

# Firing alerts by severity
count by (severity) (ALERTS{alertstate="firing"})

# Specific alert by name
ALERTS{alertname="MyAlertName", alertstate="firing"}
```
