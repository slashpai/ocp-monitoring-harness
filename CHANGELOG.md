# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed

- Moved monitoring skills to `.agents/skills/` ([Agent Skills](https://agentskills.io) standard) for agent portability; `.cursor/skills` and `.claude/skills` are compatibility symlinks
- Docs and security rule updated for portable skills; Cursor rules remain Cursor-specific enrichment

## [v0.2.0] - 2026-07-26

### Added

- Monitoring skill pipeline (`.cursor/skills/`) — five Cursor skills automating the full spec-plan-execution-review-diagnose workflow:
  - `mon-spec` — create structured spec with verified current behavior; revision-aware (re-run offers update or regenerate)
  - `mon-plan` — spec to phased plan with impact map, jsonnet awareness, push safety; revision-aware; never modifies `execution.md`
  - `mon-implement` — plan to implementation with 4 human gates (execution start, every commit, every push, PR creation); resume-aware with plan divergence detection
  - `mon-review` — multi-domain PR review (Go, jsonnet, config API, tests) with gh auth fallback
  - `mon-diagnostic` — bug diagnosis with per-command consent before any cluster query; offers to generate spec from findings
- Input validation in all skills — task name regex (`^[a-z0-9][a-z0-9-]*$`), PR URL format check
- Status field tracking (`**Status:** Draft | Approved | In Progress | Complete`) across spec, plan, and execution documents
- Security rule (`.cursor/rules/06-security.mdc`) — prevents secret exposure, documents `.cursor/` directory layout, includes secret review checklist for diffs
- Commit conventions rule (`.cursor/rules/07-commit-conventions.mdc`) — DCO sign-off, GPG signatures, conventional commits
- Skills documentation in `USAGE.md`, `README.md`, `CLAUDE.md`, and `tasks/README.md`

### Changed

- Renamed "knowledge harness" to "structured workspace" across all docs and rules
- Simplified to Cursor-only — removed untested Claude Code references; added note that Claude Code support is planned
- Simplified to submodule-only implementation — removed Mode B (external fork clone) from all docs, rules, and templates
- `templates/plan.md` — enriched with phased structure, file tables, verification steps, PR strategy, risk matrix, CMO-specific phase types
- `templates/execution.md` — enriched with phase structure, dependency annotations, inline result format, summary section
- Scoped skill exploration with soft token budgets — skills limit exploration to repos listed in spec, not all 13 submodules
- `.gitignore` — ignore all `.cursor/` paths except `.cursor/rules/` and `.cursor/skills/`; ignore `tmp/`
- Merged secret review checklist into `06-security.mdc` — single security rule with prevention + review
- Demoted `00-harness-overview.mdc` from always-on to on-demand (triggers on `README.md`, `USAGE.md`)
- Slimmed `05-planning-workflow.mdc` — removed Mode A/B labels, compacted impact map template
- Slimmed `07-commit-conventions.mdc` — removed examples, kept type table and essential rules
- Bumped submodules to latest upstream

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

[Unreleased]: https://github.com/slashpai/ocp-monitoring-harness/compare/v0.2.0...HEAD
[v0.2.0]: https://github.com/slashpai/ocp-monitoring-harness/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/slashpai/ocp-monitoring-harness/releases/tag/v0.1.0
