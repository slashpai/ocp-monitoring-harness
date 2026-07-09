# Adding or Modifying Metrics

## Overview

There are two aspects to metrics in the CMO stack:

1. **Metrics exposed by components** — Each component (Prometheus, kube-state-metrics, node-exporter, etc.) exposes its own metrics. Modifying these requires changes in the upstream component repos.
2. **Metrics scraped by Prometheus** — Controlled by ServiceMonitor and PodMonitor CRDs (managed by Prometheus Operator), defined in CMO's Jsonnet.

## Adding a New Scrape Target

To have Prometheus scrape a new target:

### 1. Create a ServiceMonitor in Jsonnet

Edit or create a `jsonnet/components/<component>.libsonnet`:

```jsonnet
{
  serviceMonitor: {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'ServiceMonitor',
    metadata: {
      name: 'my-component',
      namespace: 'openshift-monitoring',
      labels: {
        'app.kubernetes.io/name': 'my-component',
      },
    },
    spec: {
      selector: {
        matchLabels: {
          'app.kubernetes.io/name': 'my-component',
        },
      },
      endpoints: [{
        port: 'https',
        scheme: 'https',
        tlsConfig: {
          caFile: '/etc/prometheus/configmaps/serving-certs-ca-bundle/service-ca.crt',
          certFile: '/etc/prometheus/secrets/metrics-client-certs/tls.crt',
          keyFile: '/etc/prometheus/secrets/metrics-client-certs/tls.key',
          serverName: 'my-component.openshift-monitoring.svc',
        },
      }],
    },
  },
}
```

### 2. Regenerate

```bash
make jsonnet-fmt generate
```

### 3. Verify

Check that the ServiceMonitor YAML was generated in `assets/`.

## Adding Recording Rules

Recording rules pre-compute frequently used or expensive queries. Add them in the component's Jsonnet as PrometheusRules:

```jsonnet
{
  prometheusRule: {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'PrometheusRule',
    metadata: {
      name: 'my-recording-rules',
      namespace: 'openshift-monitoring',
    },
    spec: {
      groups: [{
        name: 'my-component.rules',
        rules: [{
          record: 'my_component:requests:rate5m',
          expr: 'sum(rate(my_component_requests_total[5m]))',
        }],
      }],
    },
  },
}
```

## Telemetry Metrics

Metrics sent via telemetry (to Red Hat) are defined separately. See the [Sending metrics via Telemetry](https://rhobs-handbook.netlify.app/products/openshiftmonitoring/telemetry.md/) page and the CMO [data collection documentation](https://github.com/openshift/cluster-monitoring-operator/blob/main/Documentation/data-collection.md).

## Modifying Upstream Component Metrics

If you need to add/change metrics exposed by a component itself (e.g., a new counter in kube-state-metrics), that change goes to the upstream repo (e.g., `openshift/kube-state-metrics`), then gets pulled into CMO via a version bump in `jsonnet/versions.yaml`.
