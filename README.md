# ocp-monitoring-harness

[![checks](https://github.com/slashpai/ocp-monitoring-harness/actions/workflows/checks.yaml/badge.svg)](https://github.com/slashpai/ocp-monitoring-harness/actions/workflows/checks.yaml)
[![submodule updates](https://github.com/slashpai/ocp-monitoring-harness/actions/workflows/bump-submodules.yaml/badge.svg)](https://github.com/slashpai/ocp-monitoring-harness/actions/workflows/bump-submodules.yaml)

> [!NOTE]
> This project is under active development. Content may be incomplete or change without notice.

A structured workspace for the OpenShift [Cluster Monitoring Operator (CMO)](https://github.com/openshift/cluster-monitoring-operator) and all components it deploys.

This repository gives an AI coding agent deep domain knowledge about the OpenShift monitoring stack — architecture, development workflows, operational troubleshooting, PromQL query patterns, and per-component references — so it can effectively assist with development, debugging, and incident investigation.

## Quick Start

1. Fork and clone with submodules — see [USAGE.md](USAGE.md#getting-started)
2. Open in [Cursor](https://cursor.com), [Claude Code](https://docs.anthropic.com/en/docs/claude-code), or any [Agent Skills](https://agentskills.io)–compatible agent
3. Follow the workflow in [USAGE.md](USAGE.md) — spec → plan → execution with human review gates

> [!IMPORTANT]
> **Skills** live under [`.agents/skills/`](.agents/skills/) ([Agent Skills](https://agentskills.io) standard) and work across compatible agents. Compatibility symlinks: `.cursor/skills` and `.claude/skills`.
>
> **Cursor rules** (`.cursor/rules/`) remain Cursor-specific enrichment (on-demand context, security, commit conventions). Other agents use [`CLAUDE.md`](CLAUDE.md) and the harness docs (`ARCHITECTURE.md`, `development/`, `USAGE.md`) for the same domain knowledge.

## Components and Projects

CMO and every component it deploys are available as git submodules under `projects/`. The full catalog — roles, community upstream, OpenShift forks, and submodule paths — lives in [ARCHITECTURE.md](ARCHITECTURE.md). For current versions, see `projects/cluster-monitoring-operator/jsonnet/versions.yaml`.

## Repository Structure

```text
.agents/skills/         Portable Agent Skills (/mon:spec, /mon:plan, etc.)
.cursor/rules/          Cursor rules — auto-loaded context (Cursor-enhanced)
.cursor/skills          Symlink → .agents/skills (Cursor discovery)
.claude/skills          Symlink → .agents/skills (Claude Code discovery)
ARCHITECTURE.md         CMO component catalog, repo mapping, and syncbot workflow
components/             Per-component references (role, key metrics, jsonnet paths)
development/            Cross-component contributing guides (upstream vs downstream)
projects/               Git submodules for CMO and all component repos (plan + implement)
scripts/                reset-projects.sh and other harness scripts
tasks/                  Active tasks (spec → plan → execution) — local, gitignored
completed/              Archived completed tasks — local, gitignored
templates/              Structured task templates (spec, plan, execution)
CHANGELOG.md            Historical record of notable harness changes (no releases)
CLAUDE.md               Project context summary (CMO architecture, workflow, troubleshooting)
CONVENTIONS.md          Harness conventions and pointers to CMO coding standards
USAGE.md                How to use this harness with an AI agent
```

## Skills

Custom skills automate the spec-plan-execution pipeline. Invoke with `/mon:*` where the agent supports slash skills, or by skill name / natural language:

| Skill            | Command                            | What it does                                                                                         |
|------------------|------------------------------------|------------------------------------------------------------------------------------------------------|
| `mon-spec`       | `/mon:spec <task> "<description>"` | Creates `spec.md` from a Jira ticket or description, explores `projects/` to verify current behavior |
| `mon-plan`       | `/mon:plan <task>`                 | Reads `spec.md`, explores `projects/`, asks clarifying questions, generates a phased `plan.md`       |
| `mon-implement`  | `/mon:implement <task>`            | Executes plan with 4 human gates (start, commit, push, PR); resume-aware                             |
| `mon-review`     | `/mon:review <PR>`                 | Multi-domain PR review: Go, jsonnet, config API, tests, asset consistency                            |
| `mon-diagnostic` | `/mon:diagnostic <symptom>`        | Bug diagnosis with per-command consent before any cluster query                                      |
| `harness-commit` | `/harness:commit [--auto]`         | Atomic harness commits with security scan, changelog update; `--auto` skips per-commit approval     |

Skills work for CMO, downstream component forks (`openshift/*`), and upstream contributions. They live in [`.agents/skills/`](.agents/skills/) ([Agent Skills](https://agentskills.io) standard) and are committed to the repo. See [USAGE.md](USAGE.md#skills) for details.

> [!NOTE]
> On Windows, enable Git symlinks (`git config core.symlinks true`) or Developer Mode so `.cursor/skills` and `.claude/skills` resolve after clone.

## Documentation

| Document                           | Purpose                                                      |
|------------------------------------|--------------------------------------------------------------|
| [USAGE.md](USAGE.md)               | Workflow, example prompts, where code changes go             |
| [tasks/README.md](tasks/README.md) | Local task workflow (spec → plan → execution)                |
| [development/](development/)       | Cross-component contributing guides (upstream vs downstream) |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Component catalog, repo mapping, syncbot workflow            |
| [components/](components/)         | Per-component references (role, key metrics, jsonnet paths)  |

> [!NOTE]
> `tasks/` and `completed/` are gitignored — task documents are currently local working files. For larger features with team-wide adoption, these can be source-controlled and each phase (spec, plan) created as a pull request for discussion and review before proceeding to the next phase.

## Acknowledgments

Initial harness documentation was drafted with AI assistance ([Claude Opus 4.6](https://www.anthropic.com/claude/opus) in [Cursor](https://cursor.com)) and refined with human input. Treat it like any other docs—review and improve via PR.

## References

- [Harness Engineering](https://developers.redhat.com/articles/2026/04/07/harness-engineering-structured-workflows-ai-assisted-development) — the approach behind this project
- [observability-ui/harness](https://github.com/observability-ui/harness) — the original harness that inspired this workflow
- [CMO AGENTS.md](https://github.com/openshift/cluster-monitoring-operator/blob/main/AGENTS.md)
- [OpenShift Monitoring Docs](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/monitoring/)

## License

[Apache-2.0](LICENSE)
