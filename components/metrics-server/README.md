# metrics-server (Kubernetes Metrics Server)

## Overview

| | |
|---|---|
| **Community Upstream** | [kubernetes-sigs/metrics-server](https://github.com/kubernetes-sigs/metrics-server) |
| **OpenShift Fork** | [openshift/kubernetes-metrics-server](https://github.com/openshift/kubernetes-metrics-server) |
| **Submodule** | `projects/kubernetes-metrics-server` |
| **Namespace** | `openshift-monitoring` |
| **Kind** | Deployment |
| **Replicas** | 2 |

## Role in the Stack

Kubernetes Metrics Server replaced `prometheus-adapter` starting in OpenShift 4.16 as the provider of the **Resource Metrics API** (`metrics.k8s.io`). This is a separate pipeline from Prometheus and serves a specific purpose:

- Provides CPU and memory usage metrics for pods and nodes
- Powers `kubectl top pods` and `kubectl top nodes`
- Used by **Horizontal Pod Autoscaler (HPA)** and **Vertical Pod Autoscaler (VPA)** for scaling decisions
- Lightweight, in-memory store (no persistent storage)

## Important Distinction

Metrics Server is **not** part of the Prometheus metrics pipeline. It collects resource metrics directly from kubelets and serves them via the Kubernetes aggregated API server. Prometheus collects its own resource metrics (from cAdvisor) independently.

```text
Kubelet → Metrics Server → metrics.k8s.io API → HPA/VPA/kubectl top
Kubelet → cAdvisor → Prometheus scrape → Prometheus TSDB → PromQL queries
```

## Key APIs

| API | Path | Purpose |
|---|---|---|
| Node metrics | `/apis/metrics.k8s.io/v1beta1/nodes` | CPU/memory per node |
| Pod metrics | `/apis/metrics.k8s.io/v1beta1/pods` | CPU/memory per pod |

## Jsonnet Source

`jsonnet/components/metrics-server.libsonnet`

See [development.md](development.md) for CMO integration details, version bumps, and upstream contribution guide.
