# Configuration API

## ConfigMap-Based Configuration

CMO is configured via two ConfigMaps:

### cluster-monitoring-config

Located in `openshift-monitoring`. Controls platform monitoring configuration.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
    enableUserWorkload: true
    prometheusK8s:
      retention: 15d
      resources:
        requests:
          cpu: 200m
          memory: 2Gi
      volumeClaimTemplate:
        spec:
          resources:
            requests:
              storage: 40Gi
    alertmanagerMain:
      resources:
        requests:
          cpu: 10m
          memory: 50Mi
```

### user-workload-monitoring-config

Located in `openshift-user-workload-monitoring`. Controls user workload monitoring configuration. Only effective when UWM is enabled.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: user-workload-monitoring-config
  namespace: openshift-user-workload-monitoring
data:
  config.yaml: |
    prometheus:
      retention: 24h
      resources:
        requests:
          cpu: 200m
          memory: 2Gi
```

## How Configuration Flows

```text
ConfigMap (YAML)
     │
     ▼
pkg/manifests/config.go     (parses YAML into Config struct)
     │
     ▼
pkg/manifests/types.go      (defines Config struct, fields, CEL validations)
     │
     ▼
pkg/manifests/*.go          (uses Config to parameterize component manifests)
     │
     ▼
Kubernetes resources        (Deployments, StatefulSets, etc. with applied config)
```

## Configurable Components

Each component has its own configuration section in the ConfigMap:

| Config Key | Component | Common Settings |
|---|---|---|
| `prometheusK8s` | Platform Prometheus | retention, resources, storage, remoteWrite, additionalAlertmanagerConfigs |
| `alertmanagerMain` | Alertmanager | resources, storage, secrets (for receiver config) |
| `prometheusOperator` | Prometheus Operator | resources |
| `prometheusOperatorAdmissionWebhook` | Prometheus Operator Admission Webhook | resources |
| `kubeStateMetrics` | kube-state-metrics | resources |
| `nodeExporter` | node-exporter | resources, collectors |
| `thanosQuerier` | Thanos Querier | resources |
| `metricsServer` | metrics-server | resources |
| `openshiftStateMetrics` | openshift-state-metrics | resources |
| `monitoringPlugin` | monitoring-plugin | resources |
| `telemeterClient` | telemeter-client | resources |

## UWM Configurable Components

The `user-workload-monitoring-config` ConfigMap uses a separate struct (`UserWorkloadConfiguration`):

| Config Key | Component | Common Settings |
|---|---|---|
| `alertmanager` | UWM Alertmanager | enabled, resources, storage, secrets |
| `prometheus` | UWM Prometheus | retention, resources, remoteWrite, enforcedSampleLimit |
| `prometheusOperator` | UWM Prometheus Operator | resources |
| `thanosRuler` | Thanos Ruler | resources, additionalAlertmanagerConfigs |

## Configuration Validation

CMO validates configuration using:

- Go struct tags and defaults
- CEL validation expressions defined in `pkg/manifests/types.go`
- Runtime validation in `pkg/manifests/config.go`

Invalid configuration causes the CMO to set a `Degraded` condition on the `ClusterOperator` resource.
