# Jsonnet Manifest Generation Workflow

## Overview

CMO uses [Jsonnet](https://jsonnet.org/) to generate the Kubernetes manifests that define each monitoring component. This is a critical part of the codebase — most feature work involves modifying Jsonnet sources.

## File Structure

```text
jsonnet/
  main.jsonnet              Top-level entrypoint (assembles all components)
  components/
    alertmanager.libsonnet   Alertmanager resources
    prometheus.libsonnet     Prometheus resources
    node-exporter.libsonnet  node-exporter resources
    ...                      One file per component
  jsonnetfile.json           Dependency manifest (managed by jb)
  jsonnetfile.lock.json      Locked versions
  versions.yaml              Component versions → app.kubernetes.io/version labels
```

## Workflow

### Making a Change

1. Edit the relevant `jsonnet/components/<component>.libsonnet` file
2. Format Jsonnet sources:

   ```bash
   make jsonnet-fmt
   ```

3. Regenerate assets:

   ```bash
   make generate
   ```

4. Verify the generated YAML in `assets/` reflects your changes
5. Commit both the Jsonnet source changes AND the regenerated assets

### Full Regeneration (Clean Build)

If the generated output looks stale or incorrect:

```bash
make clean
make generate
```

### Managing Dependencies

Jsonnet dependencies are managed by `jsonnet-bundler` (`jb`):

```bash
# Install jsonnet-bundler
go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest

# Update a dependency
cd jsonnet
jb update <package>

# Install all dependencies
cd jsonnet
jb install
```

## Key Patterns

### Component Structure

Each component libsonnet typically defines:

```jsonnet
{
  // ServiceAccount, ClusterRole, ClusterRoleBinding
  serviceAccount: ...,
  clusterRole: ...,
  clusterRoleBinding: ...,

  // The main workload (Deployment, StatefulSet, DaemonSet)
  deployment: ...,  // or statefulSet or daemonSet

  // Service and ServiceMonitor for metrics scraping
  service: ...,
  serviceMonitor: ...,

  // PrometheusRules for alerting
  prometheusRule: ...,
}
```

### Version Labels

Component versions from `jsonnet/versions.yaml` are applied as `app.kubernetes.io/version` labels on all generated manifests. The versions file is managed by `hack/go/generate_versions.go`.

## Common Mistakes

1. **Editing `assets/` directly** — These files are generated and will be overwritten by `make generate`
2. **Forgetting to regenerate** — CI will fail if Jsonnet sources and assets are out of sync
3. **Not formatting** — `make jsonnet-fmt` must be run before committing Jsonnet changes
4. **Stale vendor** — If dependencies changed, run `jb install` before `make generate`
