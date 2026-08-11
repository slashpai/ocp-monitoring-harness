# telemeter-client

For component details (repos, namespace, submodule path), see [ARCHITECTURE.md](../../ARCHITECTURE.md).

## Role in the Stack

telemeter-client collects a curated subset of Prometheus metrics and forwards them to Red Hat's telemetry service. This data helps Red Hat understand cluster health, identify common issues, and improve OpenShift.

It:

- **Reads** metrics from the in-cluster Prometheus via federate endpoint
- **Filters** to a curated allowlist of metrics defined in the telemeter configuration
- **Forwards** metrics to the Red Hat telemetry ingestion endpoint over HTTPS
- **Respects** cluster telemetry opt-out settings

## Key Metrics Exposed

| Metric | Type | Description |
|---|---|---|
| `metricsclient_request_send_total` | Counter | Total telemetry requests sent |
| `metricsclient_request_send_errors_total` | Counter | Failed telemetry requests |

## Jsonnet Source

`jsonnet/components/telemeter-client.libsonnet` — Defines the telemeter-client Deployment, RBAC, Service, and related resources.
