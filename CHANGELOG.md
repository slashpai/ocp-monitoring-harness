# Changelog

Notable changes to this harness, newest first. This repo does not publish releases — this file is a historical record only.

- Added `make validate` target — runs `lint` + `check-links` in one command
- Added `make check-links` using [mdox](https://github.com/bwplotka/mdox) for internal and external link validation with `.mdox.validate.yaml` config
- Added GitHub Actions lint workflow (`lint.yaml`) — runs `make lint` on PRs and pushes to `main`
- Slimmed `.cursor/rules/02-development-workflow.mdc` to pointer (same pattern as other Cursor rules)
- Slimmed `components/` READMEs — removed overview tables (duplicated `ARCHITECTURE.md`), config tables, and deployment topology (drift-prone); kept role descriptions, key metrics, and jsonnet paths
- Deleted `components/*/development.md` (12 files) — templated CMO integration steps now covered by CMO's own `Documentation/`
- Moved CMO-specific development guides (`adding-alerts.md`, `adding-metrics.md`, `jsonnet-workflow.md`, `testing.md`) from harness `development/` to CMO's `Documentation/` via [PR branch](https://github.com/slashpai/cluster-monitoring-operator/tree/docs/add-alerts-metrics-guides)
- Slimmed `development/contributing.md` to cross-component guidance only (upstream vs downstream); removed CMO-specific sections
- Slimmed `CLAUDE.md` and `CONVENTIONS.md` to harness-level content; CMO-specific dev workflow and coding standards now point to CMO docs
- Consolidated `architecture/` (5 files) into a single root `ARCHITECTURE.md` — keeps stable content (repo mapping, component catalog, syncbot workflow) and drops drift-prone CMO internals now covered by [`projects/cluster-monitoring-operator/AGENTS.md`](projects/cluster-monitoring-operator/AGENTS.md)
- Made `ARCHITECTURE.md` the single component catalog; README, `CLAUDE.md`, and Cursor overview rule link to it instead of duplicating tables/lists
- Updated skills, Cursor rules, and docs to reference `ARCHITECTURE.md`
- Moved monitoring skills to `.agents/skills/` ([Agent Skills](https://agentskills.io) standard) for agent portability; `.cursor/skills` and `.claude/skills` are compatibility symlinks
- Docs and security rule updated for portable skills; Cursor rules remain Cursor-specific enrichment
- Added weekly GitHub Actions workflow to bump submodules and open a PR (`bump-submodules.yaml`), with SHA-pinned actions and job-scoped permissions
- Added Dependabot config for GitHub Actions updates
- Reframed this file as a historical record (no release versions)
- Monitoring skill pipeline — five skills automating the full spec-plan-execution-review-diagnose workflow (`mon-spec`, `mon-plan`, `mon-implement`, `mon-review`, `mon-diagnostic`)
- Input validation in all skills — task name regex (`^[a-z0-9][a-z0-9-]*$`), PR URL format check
- Status field tracking (`**Status:** Draft | Approved | In Progress | Complete`) across spec, plan, and execution documents
- Security rule (`.cursor/rules/06-security.mdc`) — prevents secret exposure, documents `.cursor/` directory layout, includes secret review checklist for diffs
- Commit conventions rule (`.cursor/rules/07-commit-conventions.mdc`) — DCO sign-off, GPG signatures, conventional commits
- Skills documentation in `USAGE.md`, `README.md`, `CLAUDE.md`, and `tasks/README.md`
- Renamed "knowledge harness" to "structured workspace" across all docs and rules
- Simplified to submodule-only implementation — removed Mode B (external fork clone) from all docs, rules, and templates
- Enriched `templates/plan.md` and `templates/execution.md` with phased structure, verification steps, and PR strategy
- Scoped skill exploration with soft token budgets — skills limit exploration to repos listed in spec
- Slimmed Cursor rules (`00`, `05`, `07`); demoted `00-harness-overview.mdc` to on-demand
- Bumped submodules to latest upstream
- Initial harness: git submodules for CMO and all 12 component repos under `projects/`
- CMO architecture documentation, per-component references, and development guides
- Cursor agent context rules and task workflow (spec → plan → execution templates)
- `USAGE.md`, `Makefile` with `reset-projects`, markdownlint configuration
