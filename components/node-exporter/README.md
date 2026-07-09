# node-exporter

## Overview

| | |
|---|---|
| **Community Upstream** | [prometheus/node_exporter](https://github.com/prometheus/node_exporter) |
| **OpenShift Fork** | [openshift/node_exporter](https://github.com/openshift/node_exporter) |
| **Submodule** | `projects/node-exporter` |
| **Namespace** | `openshift-monitoring` |
| **Kind** | DaemonSet |
| **Replicas** | 1 per node |

## Role in the Stack

node-exporter runs on every node in the cluster and exposes hardware and OS-level metrics. It is the primary source of node-level metrics for the monitoring stack.

Key metric families include:

- `node_cpu_*` — CPU usage, frequency, guest time
- `node_memory_*` — Memory usage, buffers, cache, swap
- `node_disk_*` — Disk I/O, read/write bytes
- `node_filesystem_*` — Filesystem size, free space, usage
- `node_network_*` — Network interface bytes, packets, errors
- `node_load*` — System load averages (1m, 5m, 15m)
- `node_uname_info` — Kernel version, hostname

## Key Metrics

| Metric | Description |
|---|---|
| `node_cpu_seconds_total` | CPU time in each mode (user, system, idle, iowait, etc.) |
| `node_memory_MemTotal_bytes` | Total memory |
| `node_memory_MemAvailable_bytes` | Available memory |
| `node_filesystem_avail_bytes` | Available filesystem space |
| `node_filesystem_size_bytes` | Total filesystem size |
| `node_disk_io_time_seconds_total` | Time spent doing I/O |
| `node_network_receive_bytes_total` | Network bytes received |
| `node_network_transmit_bytes_total` | Network bytes transmitted |
| `node_load1` / `node_load5` / `node_load15` | System load averages |

## Deployment Notes

- Runs as a DaemonSet with `hostNetwork: true` and `hostPID: true` to access node-level metrics
- Uses a kube-rbac-proxy sidecar for metrics endpoint authentication
- Collectors can be configured via `cluster-monitoring-config` under the `nodeExporter` key

## Jsonnet Source

`jsonnet/components/node-exporter.libsonnet`

See [development.md](development.md) for CMO integration details, version bumps, and upstream contribution guide.
