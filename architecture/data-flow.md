# Data Flow

## Metrics Collection Pipeline

```text
                    Scrape Targets
                    ┌──────────────────────────┐
                    │ kube-state-metrics        │
                    │ node-exporter (DaemonSet) │
                    │ kubelet /metrics          │
                    │ kubelet /metrics/cadvisor  │
                    │ etcd                      │
                    │ kube-apiserver            │
                    │ kube-controller-manager   │
                    │ kube-scheduler            │
                    │ CoreDNS                   │
                    │ OpenShift API server      │
                    │ ... (ServiceMonitors)     │
                    └───────────┬──────────────┘
                                │
                         scraped by
                                │
                                ▼
                    ┌──────────────────────┐
                    │ Prometheus            │
                    │ (prometheus-k8s-0/1)  │
                    │                      │
                    │ • Stores in TSDB     │
                    │ • Evaluates rules    │
                    │ • Sends alerts to AM │
                    └──────────┬───────────┘
                               │
              ┌────────────────┼─────────────────┐
              │                │                  │
              ▼                ▼                  ▼
    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │ Thanos       │  │ Alertmanager │  │ Remote Write │
    │ Querier      │  │ (alertmgr-   │  │ (if config'd)│
    │              │  │  main-0/1)   │  │              │
    │ Unified      │  │              │  │ Telemetry,   │
    │ query view   │  │ • Routes     │  │ external     │
    └──────┬───────┘  │ • Groups     │  │ storage      │
           │          │ • Silences   │  └──────────────┘
           │          │ • Notifies   │
           ▼          └──────┬───────┘
    ┌──────────────┐         │
    │ Console      │         ▼
    │ (monitoring- │  ┌──────────────┐
    │  plugin)     │  │ Receivers    │
    │              │  │ • PagerDuty  │
    │ Dashboards,  │  │ • Slack      │
    │ Graphs,      │  │ • Email      │
    │ Alert UI     │  │ • Webhooks   │
    └──────────────┘  └──────────────┘
```

## Service Discovery

Prometheus discovers scrape targets through Kubernetes service discovery, configured via **ServiceMonitor** and **PodMonitor** CRDs:

1. **ServiceMonitors** (most common) — Define which Services to scrape, on which ports, and with what relabeling
2. **PodMonitors** — Scrape pods directly without requiring a Service

CMO deploys ServiceMonitors for all platform components. Users create their own ServiceMonitors/PodMonitors in their namespaces for UWM Prometheus to discover.

## Query Path

```text
User / Console / API
       │
       ▼
  Thanos Querier pod
  ┌─────────────────────────────────────────────┐
  │ kube-rbac-proxy (sidecar) ── AuthN/AuthZ    │
  │ prom-label-proxy (sidecar) ── namespace     │
  │                                filtering    │
  │ thanos-query (main container)               │
  └──────────────────┬──────────────────────────┘
                     │
       ┌─────────────┴─────────────┐
       │                           │
       ▼                           ▼
  Platform Prometheus       UWM Prometheus
  (openshift-monitoring)    (openshift-user-workload-monitoring)
```

- All queries go through **Thanos Querier**, which federates across Prometheus instances
- **kube-rbac-proxy** and **prom-label-proxy** run as sidecar containers in the Thanos Querier pod (not separate services)
- **kube-rbac-proxy** enforces Kubernetes RBAC on the query endpoint
- **prom-label-proxy** ensures non-admin users can only query metrics from namespaces they have access to

## Telemetry Pipeline

```text
Prometheus (prometheus-k8s)
       │
       │ federation/scrape
       ▼
telemeter-client ──────▶ Red Hat Telemetry (infogw)
(curated subset of
 cluster metrics)
```

- **telemeter-client** reads a curated set of metrics from Prometheus and forwards them to Red Hat
- Only deployed when telemetry is enabled (default on most clusters)
- Metrics are used for fleet health monitoring, SLA, and proactive support

## Alerting Pipeline

```text
Prometheus                    Alertmanager                    Receivers
┌──────────────┐         ┌──────────────────┐         ┌──────────────────┐
│ PrometheusRule│         │                  │         │                  │
│ evaluation   │────────▶│ Deduplication    │────────▶│ PagerDuty        │
│              │ alerts  │ Grouping         │ notify  │ Slack            │
│ Recording    │         │ Routing          │         │ Email            │
│ rules        │         │ Inhibition       │         │ Webhooks         │
│              │         │ Silencing        │         │                  │
└──────────────┘         └──────────────────┘         └──────────────────┘
```

1. **PrometheusRules** define alerting and recording rules
2. Prometheus evaluates rules and sends firing alerts to Alertmanager
3. Alertmanager deduplicates alerts across Prometheus replicas
4. Alertmanager routes alerts to receivers based on labels and routes configured in the Alertmanager secret
