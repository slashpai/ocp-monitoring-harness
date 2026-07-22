# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Security rule (`.cursor/rules/06-security.mdc`) — prevents secret exposure and documents `.cursor/` directory layout
- Claude Code limitation note in `README.md`

### Changed

- `.gitignore` — ignore all `.cursor/` paths except `.cursor/rules/`
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
