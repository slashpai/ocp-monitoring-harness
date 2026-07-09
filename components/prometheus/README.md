# Prometheus

## Overview

| | |
|---|---|
| **Community Upstream** | [prometheus/prometheus](https://github.com/prometheus/prometheus) |
| **OpenShift Fork** | [openshift/prometheus](https://github.com/openshift/prometheus) |
| **Submodule** | `projects/prometheus` |
| **Namespace** | `openshift-monitoring` (platform), `openshift-user-workload-monitoring` (UWM) |
| **Kind** | StatefulSet |
| **Replicas** | 2 (HA pair) |
| **Pod Name Pattern** | `prometheus-k8s-0`, `prometheus-k8s-1` |
| **CRD** | `Prometheus` (managed by Prometheus Operator) |

## Role in the Stack

Prometheus is the core metrics collection and alerting engine. It:

- **Scrapes** metrics from all configured targets (kube-state-metrics, node-exporter, kubelet, API servers, etc.) via ServiceMonitors and PodMonitors
- **Stores** metrics in its local TSDB with configurable retention (default 15 days)
- **Evaluates** alerting and recording rules defined in PrometheusRules
- **Sends** firing alerts to Alertmanager
- **Serves** queries from Thanos Querier via its remote read/StoreAPI interface

## Deployment Topology

### Platform Prometheus (`prometheus-k8s`)

Two replicas for high availability. Each replica independently scrapes all targets and evaluates all rules. Thanos Querier deduplicates query results from both replicas.

Containers in each pod:

- `prometheus` — Main Prometheus process
- `thanos-sidecar` — Exposes StoreAPI for Thanos Querier, optionally ships blocks to object storage
- `config-reloader` — Watches for config changes and triggers reloads (auto-injected by Prometheus Operator)
- `kube-rbac-proxy-web` — AuthN/AuthZ proxy for the web UI (port 9091)
- `kube-rbac-proxy` — AuthN/AuthZ proxy for the metrics and federate endpoints (port 9092)
- `kube-rbac-proxy-thanos` — AuthN/AuthZ proxy for the Thanos sidecar endpoint (port 10903)

### UWM Prometheus (`prometheus-user-workload`)

Separate Prometheus instance for user workload metrics. Only deployed when User Workload Monitoring is enabled. Scrapes only user-namespace ServiceMonitors and PodMonitors.

## Key Configuration

In `cluster-monitoring-config` ConfigMap under the `prometheusK8s` key:

| Setting | Default | Description |
|---|---|---|
| `retention` | `15d` | How long metrics are retained |
| `retentionSize` | (none) | Max TSDB size before oldest data is dropped |
| `resources` | (defaults) | CPU/memory requests and limits |
| `volumeClaimTemplate` | (none) | PVC template for persistent storage |
| `remoteWrite` | (none) | Remote write endpoints for external storage |
| `externalLabels` | (none) | Labels added to all metrics (useful for federation) |
| `additionalAlertmanagerConfigs` | (none) | Additional Alertmanager endpoints |
| `nodeSelector` | (none) | Node scheduling constraints |
| `tolerations` | (none) | Tolerations for tainted nodes |

## Key Metrics Exposed

Prometheus exposes metrics about its own operation:

| Metric | Type | Description |
|---|---|---|
| `prometheus_tsdb_head_series` | Gauge | Number of active time series |
| `prometheus_tsdb_head_chunks` | Gauge | Number of chunks in memory |
| `prometheus_tsdb_wal_corruptions_total` | Counter | WAL corruption count |
| `prometheus_tsdb_compactions_failed_total` | Counter | Failed compaction count |
| `prometheus_tsdb_head_samples_appended_total` | Counter | Total samples appended |
| `prometheus_engine_query_duration_seconds` | Histogram | Query execution duration |
| `prometheus_rule_evaluation_duration_seconds` | Summary | Rule evaluation duration |
| `prometheus_rule_group_last_duration_seconds` | Gauge | Last rule group evaluation duration |
| `prometheus_notifications_sent_total` | Counter | Notifications sent to Alertmanager |
| `prometheus_notifications_errors_total` | Counter | Failed notifications to Alertmanager |
| `scrape_duration_seconds` | Gauge | Per-target scrape duration |
| `scrape_samples_scraped` | Gauge | Per-target samples scraped |
| `up` | Gauge | Per-target health (1=up, 0=down) |

## Jsonnet Source

`jsonnet/components/prometheus.libsonnet` — Defines the Prometheus StatefulSet, ServiceMonitors, PrometheusRules, RBAC, and related resources.
