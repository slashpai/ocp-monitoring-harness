---
name: mon-implement
description: >-
  Parse a plan.md into execution.md and execute phases in dependency order.
  Works for CMO, downstream components, and upstream contributions. Dispatches
  parallel agents for multi-repo work, enforces TDD for Go changes, handles
  jsonnet regeneration (CMO), and verifies fork push safety before pushing.
  Use when the user says /mon:implement or asks to execute a plan.
disable-model-invocation: true
---

# Monitoring Implement

Parse `plan.md` into `execution.md`, then execute phases with progress tracking. Works for CMO and component repos.

## Input

The user provides a task folder name containing `plan.md`. **Validate:** task name must match `^[a-z0-9][a-z0-9-]*$` — reject names containing `/`, `..`, or special characters.

```
/mon:implement <task-name>
```

## Steps

### 1. Validate and load context

Read these files:

```
tasks/<task>/plan.md        (required — stop if missing)
tasks/<task>/spec.md        (optional — for acceptance criteria)
CLAUDE.md                   (for project context)
```

For each project in the plan's Files Modified tables, read if they exist:

- `projects/<project>/CLAUDE.md` or `AGENTS.md`

Extract and hold:

- Phase list with dependencies and parallel annotations
- Projects touched per phase (from file paths)
- Per-project build/test commands from CLAUDE.md
- Spec acceptance criteria

### 2. Generate execution.md

Parse each phase from the plan and create `tasks/<task>/execution.md` using `templates/execution.md`.

**For each phase:**

1. Extract phase name, dependency, parallel annotations, and type verbatim
2. From Files Modified table: one checkbox per row — `- [ ] [Change] — \`file/path\``
3. From Details section: extract investigation/decision items as checkboxes
4. From Phase N Verification: create verification checkboxes under sub-heading
5. Derive project list from file paths

**Phase type determines execution approach:**

| Type | TDD Required | Post-edit steps |
|------|-------------|-----------------|
| `implementation` | Yes (Red-Green-Refactor) | `make test-unit`, `go vet ./...` |
| `configuration` | No | Build/lint verification |
| `jsonnet` | No | `make jsonnet-fmt generate`, verify asset diff, commit sources + assets together |
| `investigation` | No | Annotate findings inline |

**Parallel group separators:** When consecutive phases can run in parallel, insert:

```
---
_Phases N and M can run in parallel after Phase K_
---
```

Save `tasks/<task>/execution.md`.

### 3. Present execution strategy

Before executing, present a summary and wait for confirmation:

```
## Execution Summary

**Total phases:** N
**Parallel groups:** [which phases run in parallel]
**Projects touched:** [list]

### Git strategy
- projects/<repo>: branch `<branch>` from `<base>`

### Push safety
- Fork URL: <from PR Strategy>
- Push target: fork only (never origin/openshift)

### Phases requiring human action
- Phase N: [what user needs to do]

Proceed?
```

Wait for user approval before executing.

### 4. Execute phases

Process phases in dependency order.

**a. Check dependencies** — verify prerequisite phases are marked complete.

**b. Determine execution mode:**

- **Direct execution** — 1-2 files, mechanical changes. Execute yourself.
- **Single agent** — complex but one repo. Dispatch one agent via Task tool.
- **Parallel agents** — multiple phases touch different repos. Dispatch agents in a single message.

**c. Phase handling by target:**

**For `jsonnet` phases (CMO only):**

1. Edit the `.libsonnet` file(s)
2. Run `make jsonnet-fmt generate` in `projects/cluster-monitoring-operator/`
3. Verify the asset diff matches the jsonnet change
4. Stage and commit sources + regenerated assets together
5. Never edit `assets/*.yaml` directly

**For `implementation` phases (Go — any repo):**

1. **RED** — Write a failing test. Run it. Confirm it fails for the right reason.
2. **GREEN** — Write minimal code to pass. Run it. Confirm all tests pass.
3. **REFACTOR** — Clean up. Keep tests green.
4. Run the project's test command:
   - **CMO:** `make test-unit`. If modifying `go.mod`, run `go mod tidy && go mod vendor` in all affected modules (`./`, `test/monitoring/`, `hack/tools/`)
   - **Components:** Read `Makefile` for the test target (e.g., `make test`, `go test ./...`). Run `go mod tidy` if `go.mod` was modified.

**For component repos (not CMO):**

Read `projects/<component>/Makefile`, `CLAUDE.md`, or `AGENTS.md` for:
- Build command (e.g., `make build`, `go build ./...`)
- Test command (e.g., `make test`, `go test ./...`)
- Lint/format command (e.g., `make lint`, `make format`)
- Any pre-commit hooks or CI checks

**d. Annotate results inline** in execution.md:

```
- [x] Check latest release tag -- **v0.78.1**
- [x] Run make test-unit -- **passes**
- [x] Run make jsonnet-fmt generate -- **no additional diff**
- [ ] Deploy on test cluster -- [HUMAN]
```

**e. Handle human-action phases** — present what needs to happen and wait for confirmation.

### 5. Push safety (before any push)

**Rule: always push to the user's personal fork. Never push directly to any upstream or OpenShift repo.**

Before pushing to any remote:

1. Read fork URL and PR target from plan's PR Strategy section
2. Run `git remote -v` in the submodule
3. If `fork` remote is missing, add it: `git remote add fork <url-from-plan>`
4. If `fork` exists but URL does not match the plan, **stop and ask**
5. Confirm the push target URL contains the **user's GitHub username** (e.g., `github.com/<user>/<repo>`). If it doesn't, **stop and ask** — it's not their fork. Cross-check against `architecture/repo-mapping.md`: if the URL matches any upstream or downstream org listed there, reject it.
6. Push with `git push fork <branch>` only
7. **Never** `git push origin` — `origin` in submodules points to the OpenShift fork
8. PR target (from plan): `openshift/<repo>` for downstream, community repo for upstream (see `architecture/repo-mapping.md`)

### 6. Handle failures

| Failure | Action | Limit |
|---------|--------|-------|
| Build/compilation error | Read error, attempt fix, re-verify | 2 attempts then stop |
| Test failure | Diagnose real bug vs test issue | 2 attempts then stop |
| Environment issue (tools, permissions) | Stop, present to user | — |
| Plan is wrong (assumption fails) | Mark BLOCKED, suggest amendment | — |

**Emergent phases:** When execution reveals unanticipated work:

1. Add Phase N.5 to execution.md with a note: `> Added during execution: [reason]`
2. Update dependency annotations for subsequent phases
3. Execute before continuing with dependent phases

### 7. Final verification and summary

After all phases:

1. Run end-to-end verification from the plan's Verification section
2. Cross-reference against spec acceptance criteria
3. Append summary to execution.md:

```
## Summary

**Status:** Complete | Partial (N of M phases done)

### Outstanding items
- [ ] [Items requiring human action]

### Decisions and Notes
- [Deviations from plan]
- [Issues for future work]

### Commits and PRs
| Repo | PR/Commit | Branch | Description |
|------|-----------|--------|-------------|
```

4. Present git state per project and suggest next steps (create PR, push to fork)
