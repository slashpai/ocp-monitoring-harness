# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Monitoring skill pipeline (`.cursor/skills/`) — five Cursor skills automating the full spec-plan-execution-review workflow for CMO, downstream components, and upstream contributions:
  - `mon-spec` — create structured spec from Jira/description with verified current behavior
  - `mon-plan` — spec to phased plan with impact map, jsonnet awareness, push safety
  - `mon-implement` — plan to implementation with parallel agents, TDD, fork verification
  - `mon-review` — multi-domain PR review (Go, jsonnet, config API, tests)
  - `mon-diagnostic` — bug diagnosis with obs-mcp integration and troubleshooting methodology
- Input validation in all skills — task name regex (`^[a-z0-9][a-z0-9-]*$`), PR URL format check
- Security rule (`.cursor/rules/06-security.mdc`) — prevents secret exposure and documents `.cursor/` directory layout
- Claude Code limitation note in `README.md`
- Rules vs Skills explanation in `USAGE.md`
- Skills documentation in `USAGE.md`, `README.md`, and `CLAUDE.md`

### Changed

- `.gitignore` — ignore all `.cursor/` paths except `.cursor/rules/` and `.cursor/skills/`
- `06-security.mdc` — updated to reflect `.cursor/skills/` is committed (not local-only), warn against storing secrets there
- `templates/plan.md` — enriched with phased structure, file tables, verification steps, PR strategy, risk matrix, CMO-specific phase types
- `templates/execution.md` — enriched with phase structure, dependency annotations, inline result format, summary section
- Merged secret review checklist into `06-security.mdc` — single security rule with prevention + review
- Demoted `00-harness-overview.mdc` from always-on to on-demand (triggers on `README.md`, `USAGE.md`) — content covered by `CLAUDE.md`
- Slimmed `05-planning-workflow.mdc` — removed duplicated submodule list and compacted impact map template
- Slimmed `07-commit-conventions.mdc` — removed examples, kept type table and essential rules

## [v0.1.0] - 2026-07-10

### Added

- Git submodules for CMO and all 12 component repos under `projects/`
- CMO architecture documentation (`architecture/`)
- Per-component references and development guides (`components/`)
- Development and upstream contribution guides (`development/`)
- Cursor agent context rules (`01` through `05`) for harness overview, CMO architecture, development workflow, troubleshooting, PromQL patterns, and planning workflow
- Task workflow structure with spec/plan/execution templates (`templates/`)
- `USAGE.md` — workflow guide, example prompts, and implementation guidance
- `Makefile` with `reset-projects` target for submodule cleanup
- Markdownlint configuration

[Unreleased]: https://github.com/slashpai/ocp-monitoring-harness/compare/v0.1.0...HEAD
[v0.1.0]: https://github.com/slashpai/ocp-monitoring-harness/releases/tag/v0.1.0
