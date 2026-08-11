# Prometheus

For component details (repos, namespace, submodule path), see [ARCHITECTURE.md](../../ARCHITECTURE.md).

## Role in the Stack

Prometheus is the core metrics collection and alerting engine. It:

- **Scrapes** metrics from all configured targets (kube-state-metrics, node-exporter, kubelet, API servers, etc.) via ServiceMonitors and PodMonitors
- **Stores** metrics in its local TSDB with configurable retention (default 15 days)
- **Evaluates** alerting and recording rules defined in PrometheusRules
- **Sends** firing alerts to Alertmanager
- **Serves** queries from Thanos Querier via its remote read/StoreAPI interface

## Key Metrics Exposed

Prometheus exposes metrics about its own operation:

| Metric                                        | Type      | Description                          |
|-----------------------------------------------|-----------|--------------------------------------|
| `prometheus_tsdb_head_series`                 | Gauge     | Number of active time series         |
| `prometheus_tsdb_head_chunks`                 | Gauge     | Number of chunks in memory           |
| `prometheus_tsdb_wal_corruptions_total`       | Counter   | WAL corruption count                 |
| `prometheus_tsdb_compactions_failed_total`    | Counter   | Failed compaction count              |
| `prometheus_tsdb_head_samples_appended_total` | Counter   | Total samples appended               |
| `prometheus_engine_query_duration_seconds`    | Histogram | Query execution duration             |
| `prometheus_rule_evaluation_duration_seconds` | Summary   | Rule evaluation duration             |
| `prometheus_rule_group_last_duration_seconds` | Gauge     | Last rule group evaluation duration  |
| `prometheus_notifications_sent_total`         | Counter   | Notifications sent to Alertmanager   |
| `prometheus_notifications_errors_total`       | Counter   | Failed notifications to Alertmanager |
| `scrape_duration_seconds`                     | Gauge     | Per-target scrape duration           |
| `scrape_samples_scraped`                      | Gauge     | Per-target samples scraped           |
| `up`                                          | Gauge     | Per-target health (1=up, 0=down)     |

## Jsonnet Source

`jsonnet/components/prometheus.libsonnet` — Defines the Prometheus StatefulSet, ServiceMonitors, PrometheusRules, RBAC, and related resources.
