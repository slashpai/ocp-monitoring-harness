# prom-label-proxy

## Overview

| | |
|---|---|
| **Community Upstream** | [prometheus-community/prom-label-proxy](https://github.com/prometheus-community/prom-label-proxy) |
| **OpenShift Fork** | [openshift/prom-label-proxy](https://github.com/openshift/prom-label-proxy) |
| **Submodule** | `projects/prom-label-proxy` |
| **Namespace** | `openshift-monitoring` |
| **Kind** | Sidecar / proxy container |

## Role in the Stack

prom-label-proxy enforces **label-based access control** for multi-tenant query isolation. It ensures that non-admin users can only query metrics from namespaces they have RBAC access to.

## How It Works

```text
User query (via console or API)
       │
       ▼
  kube-rbac-proxy (AuthN/AuthZ)
       │
       ▼
  prom-label-proxy (injects namespace= label filter)
       │
       ▼
  Thanos Querier / Alertmanager
```

1. User submits a PromQL query
2. prom-label-proxy determines which namespaces the user has access to (via SubjectAccessReview)
3. It injects a `namespace=` label matcher into the query, scoping results to only authorized namespaces
4. The modified query is forwarded to Thanos Querier

This prevents users from querying metrics from namespaces they don't have access to, even if they craft PromQL expressions that would otherwise match.

## Deployment Context

prom-label-proxy runs as a sidecar/proxy in front of:

- **Thanos Querier** — Enforcing namespace isolation for metric queries
- **Alertmanager** — Enforcing namespace isolation for alert queries

## Jsonnet Source

prom-label-proxy containers are defined within Thanos Querier's and Alertmanager's Jsonnet. Look in `jsonnet/components/thanos-querier.libsonnet` and `jsonnet/components/alertmanager.libsonnet`.

See [development.md](development.md) for CMO integration details, version bumps, and upstream contribution guide.
