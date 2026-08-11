# OCP Monitoring Harness

This repository is a **structured workspace** for the OpenShift Cluster Monitoring Operator (CMO) and all components it deploys. It provides structured context, workflows, and code to help with development, architecture understanding, and troubleshooting.

## Repository Layout

- `.agents/skills/` — Portable Agent Skills (`/mon:spec`, `/mon:plan`, etc.); `.cursor/skills` and `.claude/skills` are compatibility symlinks
- `.cursor/rules/` — Cursor rules — auto-loaded context (Cursor-enhanced; optional for other agents)
- `ARCHITECTURE.md` — CMO component catalog, repo mapping, and syncbot workflow
- `components/<name>/` — Per-component references (role, key metrics, jsonnet paths)
- `development/` — Cross-component contributing guides (upstream vs downstream)
- `projects/` — Git submodules for CMO and all component repos (source of truth for code and versions)
- `scripts/` — `reset-projects.sh` and other harness scripts
- `tasks/` — Active tasks (spec → plan → execution) — local, gitignored; see [tasks/README.md](tasks/README.md)
- `completed/` — Archived completed tasks — local, gitignored
- `templates/` — Templates for spec, plan, and execution documents
- `USAGE.md` — Workflow, example prompts, and where to implement changes; see [USAGE.md](USAGE.md)

## Components and Architecture

Component catalog, upstream/downstream mapping, and syncbot workflow: [ARCHITECTURE.md](ARCHITECTURE.md).

CMO internals (jsonnet pipeline, config API, reconciliation, namespaces): [`projects/cluster-monitoring-operator/AGENTS.md`](projects/cluster-monitoring-operator/AGENTS.md).

## Development

For CMO-specific development (build, test, PR conventions, code organization), see the [CMO Documentation](https://github.com/openshift/cluster-monitoring-operator/tree/main/Documentation) and [CMO AGENTS.md](https://github.com/openshift/cluster-monitoring-operator/blob/main/AGENTS.md).

For cross-component contributing guidance (upstream vs downstream, syncbot workflow), see [development/contributing.md](development/contributing.md).

## Troubleshooting

When troubleshooting, follow this order:

1. **Check firing alerts** — Alert labels provide exact identifiers for targeted queries
2. **Identify the component** — Map symptoms to components (see `components/` for per-component details)
3. **Query relevant metrics** — Use CMO alert rules in `projects/cluster-monitoring-operator/assets/<component>/prometheus-rule.yaml`, generic patterns in `.cursor/rules/04-promql-patterns.mdc`, and live MCP metric discovery when available
4. **Check logs** — `oc logs -n openshift-monitoring <pod>`
5. **Check configuration** — `oc get configmap cluster-monitoring-config -n openshift-monitoring -o yaml`

## Task Workflow

For non-trivial changes, follow the spec → plan → execution workflow. Task directories under `tasks/` are **local working documents** (gitignored); Jira and GitHub are the system of record.

1. **Spec** (`tasks/<name>/spec.md`) — Problem statement, acceptance criteria
2. **Plan** (`tasks/<name>/plan.md`) — Repository impact map from `projects/`, plus structured tasks per `templates/plan.md`
3. **Execution** (`tasks/<name>/execution.md`) — Progress tracking

Each phase requires an explicit prompt and a human review gate before the next phase.

**Implementation** — edit in `projects/<repo>/`, push only to `fork`, then `make reset-projects`.

**Push safety:** submodules fetch from openshift/\* (`origin`). **Never push to OpenShift directly** — not `origin`, not `upstream`, not any remote with a `github.com/openshift/*` URL, and not a bare push to an openshift URL. Use `Push remote: fork (<url>)` from the Phase 3 prompt; add or verify `fork` before pushing. If the URL is missing or `fork` does not match the prompt, stop and ask. Push with `git push fork <branch>` only; open PRs to the repo in `PR target:`.

**Always search `projects/` submodules for real file paths and symbols** before creating impact maps or plans. Never guess.

**Stop and present the plan for human review before proceeding.** If the plan is wrong, the code will be wrong too.

## Skills

Custom skills automate the spec-plan-execution pipeline:

| Skill            | Command                            | Purpose                                                                     |
|------------------|------------------------------------|-----------------------------------------------------------------------------|
| `mon-spec`       | `/mon:spec <task> "<description>"` | Create structured spec from Jira/description with verified current behavior |
| `mon-plan`       | `/mon:plan <task>`                 | Spec → phased plan with impact map, jsonnet awareness, push safety          |
| `mon-implement`  | `/mon:implement <task>`            | Executes plan with 4 human gates (start, commit, push, PR); resume-aware    |
| `mon-review`     | `/mon:review <PR>`                 | Multi-domain PR review (Go, jsonnet, config API, tests)                     |
| `mon-diagnostic` | `/mon:diagnostic "symptom"`        | Bug diagnosis with per-command consent before any cluster query             |
| `harness-commit` | `/harness:commit [--auto]`         | Atomic harness commits with security scan, changelog; `--auto` auto-approves |

Skill definitions live in `.agents/skills/` ([Agent Skills](https://agentskills.io) standard). Invoke with `/mon:*` where supported, or by skill name / natural language.

Source code for CMO and all components lives under `projects/` — see [ARCHITECTURE.md](ARCHITECTURE.md) for the submodule map.
