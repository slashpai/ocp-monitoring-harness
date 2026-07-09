# Thanos

## Overview

| | |
|---|---|
| **Community Upstream** | [thanos-io/thanos](https://github.com/thanos-io/thanos) |
| **OpenShift Fork** | [openshift/thanos](https://github.com/openshift/thanos) |
| **Submodule** | `projects/thanos` |
| **Namespace** | `openshift-monitoring` (Querier), `openshift-user-workload-monitoring` (Ruler) |

## Role in the Stack

Thanos provides a unified query view across multiple Prometheus instances and optionally long-term storage. In CMO, two Thanos components are deployed:

### Thanos Querier

| | |
|---|---|
| **Kind** | Deployment |
| **Replicas** | 2 |
| **Namespace** | `openshift-monitoring` |

The central query endpoint for all monitoring data. It:

- Federates queries across platform Prometheus and UWM Prometheus
- Deduplicates results from Prometheus HA replicas
- Provides the API used by the OpenShift console monitoring UI
- Is fronted by kube-rbac-proxy and prom-label-proxy for access control

### Thanos Ruler (UWM only)

| | |
|---|---|
| **Kind** | StatefulSet |
| **Namespace** | `openshift-user-workload-monitoring` |

Evaluates user-defined alerting and recording rules. Only deployed when User Workload Monitoring is enabled.

### Thanos Sidecar

Runs as a container within each Prometheus pod. Exposes the Thanos StoreAPI so Thanos Querier can query Prometheus data.

## Key Metrics

| Metric | Description |
|---|---|
| `thanos_query_gate_queries_total` | Total queries through the query gate |
| `thanos_query_store_apis_dns_lookups_total` | StoreAPI DNS lookups |
| `thanos_grpc_server_handled_total` | gRPC requests handled |
| `thanos_query_concurrent_selects` | Concurrent select queries |

## Jsonnet Source

- `jsonnet/components/thanos-querier.libsonnet`
- `jsonnet/components/thanos-ruler.libsonnet`
