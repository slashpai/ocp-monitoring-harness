# CMO Architecture Overview

The Cluster Monitoring Operator (CMO) manages the Prometheus-based monitoring stack in OpenShift. It is deployed by the Cluster Version Operator (CVO) and runs in the `openshift-monitoring` namespace.

## High-Level Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                    OpenShift Cluster                         │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │            openshift-monitoring namespace             │   │
│  │                                                      │   │
│  │  ┌─────────────────┐    ┌──────────────────────┐     │   │
│  │  │ Cluster         │    │ Prometheus Operator   │     │   │
│  │  │ Monitoring      │───▶│ (manages CRDs for    │     │   │
│  │  │ Operator (CMO)  │    │  Prometheus, AM, etc) │     │   │
│  │  └─────────────────┘    └──────────────────────┘     │   │
│  │           │                        │                  │   │
│  │           ▼                        ▼                  │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │   │
│  │  │ Prometheus   │  │ Alertmanager │  │ Thanos     │  │   │
│  │  │ (prometheus- │  │ (alertmanager│  │ Querier    │  │   │
│  │  │  k8s-0/1)    │  │  -main-0/1) │  │            │  │   │
│  │  └──────┬───────┘  └──────────────┘  └─────┬──────┘  │   │
│  │         │                                   │         │   │
│  │         │ scrapes                    queries │         │   │
│  │         ▼                                   ▼         │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │   │
│  │  │ kube-state-  │  │ node-        │  │ kube-rbac- │  │   │
│  │  │ metrics      │  │ exporter     │  │ proxy      │  │   │
│  │  │              │  │ (DaemonSet)  │  │ (sidecar)  │  │   │
│  │  └──────────────┘  └──────────────┘  └────────────┘  │   │
│  │                                                      │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │   │
│  │  │ metrics-     │  │ monitoring-  │  │ prom-label-│  │   │
│  │  │ server       │  │ plugin       │  │ proxy      │  │   │
│  │  └──────────────┘  └──────────────┘  └────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │   openshift-user-workload-monitoring namespace       │   │
│  │   (only when User Workload Monitoring is enabled)    │   │
│  │                                                      │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │   │
│  │  │ Prometheus   │  │ Prometheus   │  │ Thanos     │ │   │
│  │  │ (UWM)        │  │ Operator     │  │ Ruler      │ │   │
│  │  │              │  │ (UWM)        │  │            │ │   │
│  │  └──────────────┘  └──────────────┘  └────────────┘ │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## How CMO Works

### 1. Deployment

CMO is deployed by the Cluster Version Operator (CVO) from manifests in the `manifests/` directory of the CMO repo. CVO ensures CMO is running and manages its lifecycle.

### 2. Reconciliation

CMO watches for changes to its configuration ConfigMaps and cluster state. Its `sync()` function in `pkg/operator/operator.go` runs reconciliation tasks in three ordered groups:

1. **Prometheus Operator + MetricsScrapingClientCA** — Must run first because Prometheus Operator manages CRDs that all other components depend on
2. **All other components** — Run in parallel (Prometheus, Alertmanager, node-exporter, kube-state-metrics, Thanos, UWM, etc.)
3. **ConfigurationSharing + DefaultDenyNetworkPolicy** — Must run last because they depend on resources created by group 2

### 3. Manifest Generation

CMO reads YAML manifests from `assets/` at runtime via `pkg/manifests/`. These manifests are generated from Jsonnet sources — see [jsonnet-workflow.md](../development/jsonnet-workflow.md).

### 4. Configuration

Configuration is provided via two ConfigMaps that get merged into a Go struct — see [configuration.md](configuration.md).

## Component Relationships

- **Prometheus Operator** → Creates/manages Prometheus and Alertmanager instances via CRDs (`Prometheus`, `Alertmanager`, `ServiceMonitor`, `PrometheusRule`, etc.)
- **Prometheus** → Scrapes metrics from kube-state-metrics, node-exporter, and all other targets defined by ServiceMonitors
- **Prometheus** → Evaluates alerting rules and sends alerts to Alertmanager
- **Alertmanager** → Routes alerts to configured receivers (PagerDuty, email, webhooks, etc.)
- **Thanos Querier** → Provides a unified query endpoint across Prometheus instances (platform + UWM)
- **kube-rbac-proxy** → Deployed as a sidecar to protect metrics endpoints with Kubernetes RBAC
- **prom-label-proxy** → Enforces namespace-level label filtering for multi-tenant query access
- **monitoring-plugin** → Provides the monitoring UI in the OpenShift console, queries via Thanos Querier
- **metrics-server** → Provides resource metrics API for HPA/VPA (separate from Prometheus metrics pipeline)
