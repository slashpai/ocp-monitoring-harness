# Namespace Topology

## openshift-monitoring

The primary namespace for all platform monitoring components. Created by CMO.

### Key Workloads

| Resource | Kind | Component |
|---|---|---|
| `cluster-monitoring-operator` | Deployment | CMO itself |
| `prometheus-operator` | Deployment | Prometheus Operator |
| `prometheus-operator-admission-webhook` | Deployment | Validates PrometheusRule and AlertmanagerConfig CRDs |
| `prometheus-k8s` | StatefulSet (2 replicas) | Platform Prometheus |
| `alertmanager-main` | StatefulSet (2 replicas) | Alertmanager cluster |
| `thanos-querier` | Deployment (2 replicas) | Thanos Querier |
| `kube-state-metrics` | Deployment | kube-state-metrics |
| `node-exporter` | DaemonSet | node-exporter (runs on every node) |
| `openshift-state-metrics` | Deployment | OpenShift-specific state metrics |
| `monitoring-plugin` | Deployment (2 replicas) | Console monitoring plugin |
| `metrics-server` | Deployment (2 replicas) | Kubernetes resource metrics |
| `telemeter-client` | Deployment | Telemetry forwarding to Red Hat |

### Key ConfigMaps

| Name | Purpose |
|---|---|
| `cluster-monitoring-config` | User-provided platform monitoring configuration |
| `prometheus-k8s-rulefiles-0` | Alerting and recording rules |
| `serving-certs-ca-bundle` | CA bundle for TLS |

### Key Secrets

| Name | Purpose |
|---|---|
| `alertmanager-main` | Alertmanager configuration (routing, receivers) |
| `prometheus-k8s-tls` | Prometheus TLS certificates |

## openshift-user-workload-monitoring

Created only when User Workload Monitoring (UWM) is enabled via `cluster-monitoring-config`. Contains a separate Prometheus instance for scraping user application metrics.

### Key Workloads (UWM)

| Resource | Kind | Component |
|---|---|---|
| `prometheus-operator` | Deployment | UWM Prometheus Operator |
| `prometheus-user-workload` | StatefulSet (2 replicas) | UWM Prometheus |
| `thanos-ruler` | StatefulSet | Thanos Ruler for user-defined alerting rules |
| `alertmanager-user-workload` | StatefulSet | UWM Alertmanager (when `enableUserAlertmanagerConfig: true`) |

### Enabling UWM

Set in the `cluster-monitoring-config` ConfigMap in `openshift-monitoring`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
    enableUserWorkload: true
```

## Interaction Between Namespaces

- **Thanos Querier** (in `openshift-monitoring`) queries both platform Prometheus and UWM Prometheus, providing a unified query view
- **Thanos Ruler** (in `openshift-user-workload-monitoring`) evaluates user-defined rules against user workload metrics
- Platform Prometheus does **not** scrape user application metrics — that's the UWM Prometheus's job
