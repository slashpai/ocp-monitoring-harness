# Adding or Modifying Alerting Rules

## Overview

Alerting rules in CMO are defined as `PrometheusRule` CRDs, generated from Jsonnet sources. Each component typically has its own set of alerting rules.

## Alert Structure

Each alert has:

```yaml
alert: AlertName
expr: <PromQL expression>
for: <duration>          # How long condition must be true before firing
labels:
  severity: <critical|warning|info>
  namespace: openshift-monitoring
annotations:
  summary: "Short description"
  description: "Detailed description with {{ $labels.instance }}"
  runbook_url: "https://..."
```

## Where Rules Come From

Most alerting and recording rules in CMO are **not** defined directly in the component libsonnet files. They come from upstream **kube-prometheus mixins** (imported via `mixin` configuration in `jsonnet/main.jsonnet`). Only a few components (e.g., `cluster-monitoring-operator.libsonnet`) define `PrometheusRule` resources directly.

If the alert you need already exists in an upstream mixin (e.g., `kubernetes-mixin`, `node-mixin`), you may only need to adjust `mixin._config` settings in `jsonnet/main.jsonnet` rather than writing a new rule from scratch.

## Adding a New Alert

### 1. Edit the Component's Jsonnet

In `jsonnet/components/<component>.libsonnet`, add to the `prometheusRule` section:

```jsonnet
{
  prometheusRule: {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'PrometheusRule',
    metadata: {
      name: '<component>-prometheus-rules',
      namespace: 'openshift-monitoring',
    },
    spec: {
      groups: [{
        name: '<component>.rules',
        rules: [
          {
            alert: 'MyNewAlert',
            expr: 'some_metric > threshold',
            'for': '15m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'Something is wrong with {{ $labels.instance }}',
              description: 'Detailed explanation of what this means and what to check.',
            },
          },
        ],
      }],
    },
  },
}
```

### 2. Regenerate and Test

```bash
make jsonnet-fmt generate
make test-rules    # Validate rules syntax with promtool
make test-e2e      # Verify alert fires as expected (requires cluster)
```

## Alert Severity Guidelines

| Severity | Meaning | Response |
|---|---|---|
| `critical` | Service is down or data loss is occurring/imminent | Requires immediate attention, pages on-call |
| `warning` | Service degradation or approaching limits | Needs attention during business hours |
| `info` | Notable event, no immediate action required | Informational, logged but not paged |

## OpenShift Alert Conventions

- Alert names should be CamelCase (e.g., `PrometheusHighMemory`, `AlertmanagerClusterDown`)
- Include a `namespace` label matching where the component runs
- Include a `runbook_url` annotation pointing to troubleshooting documentation
- Use `for` durations to avoid alerting on transient spikes (typically 5m-15m for warnings, 1m-5m for critical)
- Description annotations should include template variables for specificity: `{{ $labels.pod }}`, `{{ $value }}`

## Testing Alerts Locally

Rule tests live in `test/rules/` and are named after the alert or bug they cover (e.g., `TargetDown.yaml`, `NodeClockSkewDetected.yaml`, `OCPBUGS-86352.yaml`):

```bash
# Run all rule tests (syntax check + unit tests)
make test-rules

# Or test a single rule file manually
promtool test rules test/rules/MyAlert.yaml
```

## Modifying Alertmanager Routing

Alerting rules (what fires) are separate from routing (where alerts go). Routing is configured in the Alertmanager secret in `openshift-monitoring`, not in CMO's Jsonnet. Users configure routing via the `cluster-monitoring-config` ConfigMap or directly in the Alertmanager secret.
