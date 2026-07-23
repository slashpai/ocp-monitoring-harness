---
name: mon-review
description: >-
  Multi-domain PR review for CMO and monitoring stack components. For CMO PRs,
  classifies files by domain (Go, jsonnet, config API, tests, YAML assets) and
  checks for CMO anti-patterns. For component PRs, adapts to the project's own
  build system and conventions. Use when the user says /mon:review or asks
  to review a PR.
disable-model-invocation: true
---

# Monitoring Reviewer

Multi-angle PR review for CMO and monitoring stack components.

## Input

A PR number or GitHub PR URL.

```
/mon:review 1234
/mon:review https://github.com/openshift/cluster-monitoring-operator/pull/1234
```

**Validate input:**
- **PR number** — must be a positive integer
- **URL** — must match `https://github.com/<org>/<repo>/pull/<number>`. Reject URLs that don't point to `github.com` or don't follow this pattern.

## Steps

### 1. Gather PR context

**Prerequisite:** Run `gh auth status > /dev/null 2>&1` and check the exit code. If non-zero, stop and instruct the user to run `gh auth login` first.

Use `gh` CLI to collect:

```bash
gh pr view <number> --json title,body,baseRefName,headRefName,files,additions,deletions
gh pr diff <number>
```

**Fallback:** If `gh` is unavailable or auth fails and the branch exists locally in `projects/<repo>/`, offer to review the local branch diff instead using `git diff <base>...<branch>`.

`CLAUDE.md` is already in context (loaded as a workspace rule) — do not re-read it.

### 2. Determine repo type and classify changed files

**Identify the target repo** from the PR URL. This determines which review domains apply.

**For CMO PRs** (`cluster-monitoring-operator`), sort files into:

| Domain | File patterns |
|--------|---------------|
| Go (operator logic) | `pkg/**/*.go`, `cmd/**/*.go` (excluding `_test.go`) |
| Go (tests) | `*_test.go`, `test/**/*.go` |
| Jsonnet | `jsonnet/**/*.libsonnet`, `jsonnet/**/*.jsonnet` |
| YAML assets | `assets/**/*.yaml`, `manifests/**/*.yaml` |
| Config API | `pkg/manifests/types.go`, `pkg/manifests/config.go` |
| Build/CI | `Makefile`, `Dockerfile*`, `.github/**`, `Containerfile*` |
| Dependencies | `go.mod`, `go.sum`, `vendor/**`, `jsonnet/versions.yaml` |
| Documentation | `*.md`, `docs/**` |

**For component PRs** (Prometheus, Thanos, etc.), sort files into:

| Domain | File patterns |
|--------|---------------|
| Go (logic) | `**/*.go` (excluding `_test.go` and `vendor/`) |
| Go (tests) | `*_test.go` |
| Build/CI | `Makefile`, `Dockerfile*`, `.github/**`, `Containerfile*` |
| Dependencies | `go.mod`, `go.sum`, `vendor/**` |
| Documentation | `*.md`, `docs/**` |

For component PRs, read the project's `CLAUDE.md`, `AGENTS.md`, or `CONTRIBUTING.md` for project-specific conventions before reviewing.

### 3. Review by domain

#### Go — logic

- [ ] **Correctness** — logic follows intent, edge cases handled
- [ ] **Error handling** — errors wrapped with context, not silently ignored
- [ ] **Concurrency** — goroutines have proper lifecycle, no data races
- [ ] **CMO patterns** (CMO only) — reconciliation follows task ordering (PO first → components → config sharing last), new tasks registered in `pkg/operator/operator.go`
- [ ] **Resource management** — no resource leaks (file handles, HTTP clients, informers)
- [ ] **Logging** — structured logging with appropriate levels
- [ ] **Backward compatibility** — API and config changes are additive
- [ ] **Component conventions** (component PRs) — follows the project's own patterns (read `CONTRIBUTING.md` or `AGENTS.md`)

#### Jsonnet — manifest generation

- [ ] **Formatting** — `jsonnetfmt` compliant (consistent indentation, trailing commas)
- [ ] **Template reuse** — uses existing helper functions, no copy-paste from other components
- [ ] **Label conventions** — standard OpenShift labels present (`app.kubernetes.io/*`)
- [ ] **`make generate` consistency** — assets match jsonnet sources. If jsonnet files changed but assets did not, flag as incomplete.
- [ ] **Anti-patterns** — no hardcoded namespaces (use variables), no inline YAML strings

#### Config API — types.go / config.go

- [ ] **Field naming** — follows existing conventions in `types.go`
- [ ] **CEL validation** — constraints defined where appropriate
- [ ] **Default values** — set in `config.go`, documented in field comments
- [ ] **Backward compatibility** — new fields are optional, existing defaults unchanged
- [ ] **Both files** — `types.go` changes accompanied by `config.go` handling (and vice versa)

#### Tests

- [ ] **Coverage** — new code has corresponding tests
- [ ] **Assertion quality** — tests verify behavior, not implementation details
- [ ] **E2E patterns** — follows existing patterns in `test/e2e/`
- [ ] **Test naming** — descriptive, follows `Test<Component>_<Behavior>` convention
- [ ] **Flakiness risk** — no hardcoded timeouts, uses polling/retry helpers

#### YAML assets

- [ ] **Generated, not hand-edited** — if assets changed, corresponding jsonnet changes must exist
- [ ] **No secrets or real values** — placeholder values only

#### Dependencies

- [ ] **Vendor sync** — `vendor/` matches `go.mod` + `go.sum`
- [ ] **Version bumps** — changelog/release notes referenced

### 4. Cross-domain checks

**All repos:**

- [ ] **Commit message format** — follows project conventions (CMO: `<subsystem>: <description>`, references Jira; upstream: check `CONTRIBUTING.md`)
- [ ] **PR description** — explains what and why, links to issue tracker
- [ ] **No secrets** — no hardcoded tokens, passwords, or credentials in the diff
- [ ] **go.mod consistency** — `vendor/` matches `go.mod` + `go.sum`

**CMO-specific (skip for component PRs):**

- [ ] **Asset-jsonnet consistency** — if assets changed, jsonnet changed too (unless a legitimate manual override exists with a comment explaining why)
- [ ] **go.mod multi-module** — all three modules (`./`, `test/monitoring/`, `hack/tools/`) are consistent

### 5. Synthesize findings

Present findings grouped by severity:

```
## PR Review: <title>

### 🔴 Critical (must fix before merge)
- [file:line] Description of issue

### 🟡 Important (should fix)
- [file:line] Description of concern

### 🟢 Nit (optional improvement)
- [file:line] Suggestion

### ✅ Looks good
- [domain] Brief positive note on what's done well
```

Include:

- Total changed files and lines
- Domains covered
- Summary recommendation: **Approve**, **Request Changes**, or **Comment**
