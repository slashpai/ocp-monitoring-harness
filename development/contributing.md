# Contributing to Monitoring Components

This guide covers **cross-component** contribution workflows — when to contribute upstream vs downstream, and how changes flow from community repos into OpenShift. For CMO-specific development (build, test, PR conventions, code organization), see the [CMO Documentation](https://github.com/openshift/cluster-monitoring-operator/tree/main/Documentation).

## Upstream vs Downstream

See [ARCHITECTURE.md](../ARCHITECTURE.md) for the full component and repo mapping. Key distinction:

- **Upstream** (community) — `prometheus/prometheus`, `thanos-io/thanos`, etc. Uses GitHub Actions CI, community PR conventions, and DCO sign-off.
- **Downstream** (OpenShift fork) — `openshift/prometheus`, `openshift/thanos`, etc. Uses Prow CI, OpenShift PR conventions (`OCPBUGS-`/`MON-`), and is managed by [syncbot](https://github.com/rhobs/syncbot).

## When to Contribute Upstream

- Bug fixes in core component behavior (e.g., Prometheus query engine, Alertmanager routing logic)
- New features that should benefit the wider community
- Performance improvements in component internals

## When to Contribute to the OpenShift Fork

- OpenShift-specific patches (RBAC, TLS, console integration)
- Downstream-only build/CI changes (Dockerfile, OWNERS)
- Cherry-picks of upstream fixes to a specific OpenShift release branch

## End-to-End Workflow: Upstream Change to OpenShift

1. **Contribute upstream** — Submit a PR to the community repo, get it merged and released
2. **syncbot rebases** — [syncbot](https://github.com/rhobs/syncbot) automatically rebases the OpenShift fork onto the new upstream release
3. **CMO version bump** — syncbot also creates a PR to update `jsonnet/versions.yaml` in CMO
4. **Test in CMO** — Verify the change works in the OpenShift monitoring stack

## Testing an Upstream Change with CMO Locally

Before your upstream change is merged and released, you can test it against CMO:

1. Build a custom image of the component from your upstream branch
2. Override the image in CMO's `jsonnet/versions.yaml` or use `SWITCH_TO_CMO=false make run-local` with a modified image reference
3. Run `make generate` to regenerate assets
4. Deploy and test with `make run-local` or on a test cluster

## Upstream Contributing Guides

| Component | Contributing Guide |
|---|---|
| Prometheus | [prometheus/prometheus CONTRIBUTING.md](https://github.com/prometheus/prometheus/blob/main/CONTRIBUTING.md) |
| Alertmanager | [prometheus/alertmanager CONTRIBUTING.md](https://github.com/prometheus/alertmanager/blob/main/CONTRIBUTING.md) |
| Prometheus Operator | [prometheus-operator/prometheus-operator CONTRIBUTING.md](https://github.com/prometheus-operator/prometheus-operator/blob/main/CONTRIBUTING.md) |
| kube-state-metrics | [kubernetes/kube-state-metrics CONTRIBUTING.md](https://github.com/kubernetes/kube-state-metrics/blob/main/CONTRIBUTING.md) |
| node-exporter | [prometheus/node_exporter CONTRIBUTING.md](https://github.com/prometheus/node_exporter/blob/main/CONTRIBUTING.md) |
| Thanos | [thanos-io/thanos CONTRIBUTING.md](https://github.com/thanos-io/thanos/blob/main/CONTRIBUTING.md) |
| kube-rbac-proxy | [brancz/kube-rbac-proxy](https://github.com/brancz/kube-rbac-proxy) |
| metrics-server | [kubernetes-sigs/metrics-server](https://github.com/kubernetes-sigs/metrics-server) |
| prom-label-proxy | [prometheus-community/prom-label-proxy](https://github.com/prometheus-community/prom-label-proxy) |

## Upstream Build and Test

Each upstream repo has its own build/test/lint commands — check the repo's `Makefile` or `CONTRIBUTING.md` (linked above) for current instructions.
