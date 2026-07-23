# Plan: [Task Name]


## Problem

_Why this change is needed. Link upstream issues if relevant. Explain the business or technical motivation._

## Current State

| Component | File / Location | Current Behavior |
|-----------|-----------------|------------------|
| [name] | `projects/<repo>/path/to/file.ext` | [What it does now] |

## Changes

### Phase 1: [Name]

**Dependency:** None
**Parallel with:** None | Phase N (when touching different repos/files)
**Type:** implementation | configuration | jsonnet | investigation

#### Files Modified

| File | Change |
|------|--------|
| `projects/<repo>/path/to/file.ext` | [Brief description of what changes] |

#### Details

_Detailed description of the changes. Include code snippets for type changes and non-obvious logic. Include line references when the exact point matters._

#### Phase 1 Verification

- [ ] [Specific command and expected output]

### Phase 2: [Name]

**Dependency:** Phase 1
**Parallel with:** Phase 3 (different repo)
**Type:** implementation | configuration | jsonnet | investigation

#### Files Modified

| File | Change |
|------|--------|
| `projects/<repo>/path/to/file.ext` | [Brief description] |

#### Details

_Details of the changes._

#### Phase 2 Verification

- [ ] [Specific command and expected output]

## PR Strategy

| PR | Repository | Branch | Fork URL | PR Target | Description | Dependencies |
|----|------------|--------|----------|-----------|-------------|--------------|
| 1 | [repo] | [branch] | `https://github.com/<you>/repo` | `openshift/repo` | [what this PR contains] | None |
| 2 | [repo] | [branch] | `https://github.com/<you>/repo` | `openshift/repo` | [what this PR contains] | PR 1 merged |

**Push safety:** Always push to your personal fork. Never push directly to `openshift/*` repos or community upstream repos.

## Verification

_End-to-end verification mapped to the spec's acceptance criteria._

- [ ] [Acceptance criterion] — [how to verify]

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| [What could go wrong] | [What breaks] | [How to prevent or recover] |

---

## CMO-Specific Notes

### Phase types

| Type | When to use | Post-edit steps |
|------|-------------|-----------------|
| `implementation` | New functions, API changes, refactoring | TDD (Red-Green-Refactor). Run `make test-unit` |
| `configuration` | Version bumps, import updates, config values | No TDD. Verify with build/lint |
| `jsonnet` | Editing `.libsonnet` files or jsonnet config | Run `make jsonnet-fmt generate`. Commit sources + regenerated `assets/` together. Never edit `assets/` directly |
| `investigation` | Research, compatibility checks, decisions | No code changes. Annotate findings inline |

### Common CMO file patterns

| Change Type | Files Typically Involved |
|-------------|--------------------------|
| New/modified K8s resources | `jsonnet/components/<component>.libsonnet` → `make jsonnet-fmt generate` → `assets/<component>/` |
| New config option | `pkg/manifests/types.go` → `pkg/manifests/config.go` → `pkg/manifests/<component>.go` |
| New alerting rule | `jsonnet/components/<component>.libsonnet` (PrometheusRule section) |
| New scrape target | `jsonnet/components/<component>.libsonnet` (ServiceMonitor section) |
| Version bump | `jsonnet/versions.yaml` → `make generate` |
| E2E test | `test/e2e/<component>_test.go` |
