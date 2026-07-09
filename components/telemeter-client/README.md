# telemeter-client

## Overview

| | |
|---|---|
| **Community Upstream** | [openshift/telemeter](https://github.com/openshift/telemeter) |
| **OpenShift Fork** | *(same repo — OpenShift-only component)* |
| **Namespace** | `openshift-monitoring` |
| **Kind** | Deployment |
| **Replicas** | 1 |
| **Conditional** | Only deployed when telemetry is enabled (default: enabled) |

## Role in the Stack

telemeter-client collects a curated subset of Prometheus metrics and forwards them to Red Hat's telemetry service. This data helps Red Hat understand cluster health, identify common issues, and improve OpenShift.

It:

- **Reads** metrics from the in-cluster Prometheus via federate endpoint
- **Filters** to a curated allowlist of metrics defined in the telemeter configuration
- **Forwards** metrics to the Red Hat telemetry ingestion endpoint over HTTPS
- **Respects** cluster telemetry opt-out settings

## Deployment Topology

Containers in the pod:

- `telemeter-client` — Main process that federates metrics from Prometheus and forwards them
- `kube-rbac-proxy` — AuthN/AuthZ proxy for the metrics endpoint
- `reload` — Watches for config changes and triggers reloads

## Key Configuration

In `cluster-monitoring-config` ConfigMap under the `telemeterClient` key:

| Setting | Default | Description |
|---|---|---|
| `resources` | (defaults) | CPU/memory requests and limits |
| `nodeSelector` | (none) | Node scheduling constraints |
| `tolerations` | (none) | Tolerations for tainted nodes |

Telemetry can be disabled cluster-wide via the `ClusterVersion` resource or pull secret configuration, which prevents telemeter-client from being deployed.

## Key Metrics Exposed

| Metric | Type | Description |
|---|---|---|
| `metricsclient_request_send_total` | Counter | Total telemetry requests sent |
| `metricsclient_request_send_errors_total` | Counter | Failed telemetry requests |

## Jsonnet Source

`jsonnet/components/telemeter-client.libsonnet` — Defines the telemeter-client Deployment, RBAC, Service, and related resources.

See [development.md](development.md) for CMO integration details, version bumps, and upstream contribution guide.
