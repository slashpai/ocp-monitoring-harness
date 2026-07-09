# monitoring-plugin

## Overview

| | |
|---|---|
| **Community Upstream** | *(OpenShift-only, no upstream)* |
| **OpenShift Repo** | [openshift/monitoring-plugin](https://github.com/openshift/monitoring-plugin) |
| **Submodule** | `projects/monitoring-plugin` |
| **Namespace** | `openshift-monitoring` |
| **Kind** | Deployment |
| **Replicas** | 2 |

## Role in the Stack

The monitoring plugin provides the **monitoring UI** in the OpenShift web console. It is a console dynamic plugin that adds:

- Metrics explorer and PromQL query interface
- Alert list and detail views
- Silence management
- Dashboard views
- Target status pages

## How It Works

- Registered as a `ConsolePlugin` CRD with the OpenShift console
- Queries metrics via **Thanos Querier** (not directly from Prometheus)
- Queries alerts via the **Alertmanager** API
- Access is controlled by Kubernetes RBAC — non-admin users see only metrics from their allowed namespaces (enforced by prom-label-proxy)

## Jsonnet Source

`jsonnet/components/monitoring-plugin.libsonnet`
