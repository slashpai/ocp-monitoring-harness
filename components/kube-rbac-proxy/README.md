# kube-rbac-proxy

## Overview

| | |
|---|---|
| **Community Upstream** | [brancz/kube-rbac-proxy](https://github.com/brancz/kube-rbac-proxy) |
| **OpenShift Fork** | [openshift/kube-rbac-proxy](https://github.com/openshift/kube-rbac-proxy) |
| **Submodule** | `projects/kube-rbac-proxy` |
| **Namespace** | `openshift-monitoring` |
| **Kind** | Sidecar container (not a standalone Deployment) |

## Role in the Stack

kube-rbac-proxy is an HTTP proxy that performs authentication and authorization using Kubernetes RBAC. It is deployed as a **sidecar container** in nearly every monitoring component to protect their `/metrics` endpoints.

Components that use kube-rbac-proxy as a sidecar:

- Prometheus (three instances: `kube-rbac-proxy-web`, `kube-rbac-proxy`, `kube-rbac-proxy-thanos`)
- Prometheus (UWM)
- Alertmanager (three instances: `kube-rbac-proxy-web`, `kube-rbac-proxy`, `kube-rbac-proxy-metric`)
- Alertmanager (UWM)
- Prometheus Operator
- Prometheus Operator (UWM)
- kube-state-metrics
- openshift-state-metrics
- node-exporter
- Thanos Querier (four instances: `kube-rbac-proxy-web`, `kube-rbac-proxy`, `kube-rbac-proxy-rules`, `kube-rbac-proxy-metrics`)
- Thanos Ruler
- telemeter-client

## How It Works

```text
Client → kube-rbac-proxy (AuthN/AuthZ via K8s RBAC) → Backend (/metrics endpoint)
```

1. Client sends a request with a bearer token or client certificate
2. kube-rbac-proxy validates the token via TokenReview API
3. kube-rbac-proxy checks authorization via SubjectAccessReview API
4. If authorized, proxies the request to the backend metrics endpoint

## Jsonnet Source

kube-rbac-proxy containers are defined within each component's Jsonnet. There is no standalone `kube-rbac-proxy.libsonnet` — look for `kube-rbac-proxy` container definitions in each component's libsonnet file.

See [development.md](development.md) for CMO integration details, version bumps, and upstream contribution guide.
