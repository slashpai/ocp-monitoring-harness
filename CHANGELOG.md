# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Security rule (`.cursor/rules/06-security.mdc`) — prevents secret exposure and documents `.cursor/` directory layout

### Changed

- `.gitignore` — ignore all `.cursor/` paths except `.cursor/rules/`

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
