# Conventions

## CMO Conventions

For CMO-specific coding standards (Go, Jsonnet, YAML), naming conventions, commit messages, PR titles, config patterns, testing, dependency management, and CI expectations, see:

- [CMO AGENTS.md](https://github.com/openshift/cluster-monitoring-operator/blob/main/AGENTS.md)
- [CMO Documentation](https://github.com/openshift/cluster-monitoring-operator/tree/main/Documentation)
- [OpenShift enhancements CONVENTIONS.md](https://github.com/openshift/enhancements/blob/master/CONVENTIONS.md)

## Harness Conventions

When updating this harness repository:

- Keep component READMEs factual — reference upstream documentation rather than duplicating it
- For operational PromQL, use CMO alert rules in `projects/cluster-monitoring-operator/assets/*/prometheus-rule.yaml` (generated from jsonnet) rather than duplicating queries in the harness
- For alert definitions, refer to the Jsonnet source in `projects/cluster-monitoring-operator/jsonnet/components/`
- After implementing in `projects/` submodules, run `make reset-projects` to restore clean upstream SHAs (push to your fork first)
- Cursor rules (`.mdc` files) should be concise — detailed content goes in the referenced docs
- Do not hardcode component versions anywhere in the harness — the source of truth is `projects/cluster-monitoring-operator/jsonnet/versions.yaml`
- Keep submodules up to date with `make submodule-update`
