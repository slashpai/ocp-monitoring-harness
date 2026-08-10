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
```

Update the `**Status:**` line in `tasks/<task>/plan.md` from `Draft` to `Approved` — invoking `/mon:implement` implies the human has reviewed the plan.

Note: `CLAUDE.md` is already in context (loaded as a workspace rule) — do not re-read it.

For each project in the plan's Files Modified tables, read if they exist:

- `projects/<project>/CLAUDE.md` or `AGENTS.md`

Extract and hold:

- Phase list with dependencies and parallel annotations
- Projects touched per phase (from file paths)
- Per-project build/test commands from CLAUDE.md
- Spec acceptance criteria

### 2. Generate or resume execution.md

**If `tasks/<task>/execution.md` already exists:** This is a **resume**. Read both the existing `execution.md` and the current `plan.md`. Compare the phase structure (phase count, names, file lists) between the two:

- **If phases match:** Standard resume. Scan for the first phase with unchecked items (`- [ ]`). Preserve all existing content and annotations — do not regenerate. Skip to step 3 with a resume summary.
- **If phases diverge** (plan was revised — phases added, removed, renamed, or files changed in incomplete phases): Stop and tell the user what changed. Ask whether to:
  - Regenerate execution.md from the revised plan (completed phases are lost)
  - Keep the current execution.md and ignore plan changes (user takes responsibility)
  - Merge — preserve completed phases, regenerate only the incomplete ones from the revised plan

Do NOT silently resume with a stale execution.md when the plan has changed.

**If `tasks/<task>/execution.md` does not exist:** Generate it from scratch. Parse each phase from the plan and create it using `templates/execution.md`, including the `**Status:** In Progress` line under the title.

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

Before executing, present a summary and wait for confirmation.

**For a fresh run:**

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

**For a resume:**

```
## Resuming Execution

### Completed phases
- Phase 1: [Phase Name] — [key result or commit, from annotations]
- Phase 2: [Phase Name] — [key result]
- ...

### Resuming from
- Phase M: [Phase Name] — [what it will do]

### Remaining
- Phase M+1: [Phase Name]
- ...

**Projects touched (remaining):** [list]

Proceed from Phase M?
```

Stop here. Do NOT execute any phase until the user explicitly approves.

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
4. Present changes for user review (step 4d) — sources + regenerated assets commit together
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

**d. Human review before committing** — after completing a phase's changes, you MUST stop and present the following to the user. Do NOT run `git commit` until the user explicitly approves:

1. The files changed (`git diff --stat`)
2. A summary of what changed and why
3. The proposed commit message

Stop here. Do not proceed until the user says to commit.

**e. Annotate results inline** in execution.md:

```
- [x] Check latest release tag -- **v0.78.1**
- [x] Run make test-unit -- **passes**
- [x] Run make jsonnet-fmt generate -- **no additional diff**
- [ ] Deploy on test cluster -- [HUMAN]
```

**f. Handle human-action phases** — present what needs to happen and wait for confirmation.

### 5. Push safety (before any push)

**Rule: always push to the user's personal fork. Never push directly to any upstream or OpenShift repo.**

Before pushing to any remote:

1. Read fork URL and PR target from plan's PR Strategy section
2. Run `git remote -v` in the submodule
3. If `fork` remote is missing, add it: `git remote add fork <url-from-plan>`
4. If `fork` exists but URL does not match the plan, **stop and ask**
5. Confirm the push target URL contains the **user's GitHub username** (e.g., `github.com/<user>/<repo>`). If it doesn't, **stop and ask** — it's not their fork. Cross-check against `ARCHITECTURE.md`: if the URL matches any upstream or downstream org listed there, reject it.
6. **Stop and present the push to the user.** Show the exact command (`git push fork <branch>`), the remote URL, and the branch name. Do NOT run `git push` until the user explicitly approves. Stop here and wait.
7. After user approval, push with `git push fork <branch>` only
8. **Never** `git push origin` — `origin` in submodules points to the OpenShift fork
9. PR target (from plan): `openshift/<repo>` for downstream, community repo for upstream (see `ARCHITECTURE.md`)

### 6. Handle failures

| Failure | Action | Limit |
|---------|--------|-------|
| Build/compilation error | Read error, attempt fix, re-verify | 2 attempts then stop |
| Test failure | Diagnose real bug vs test issue | 2 attempts then stop |
| Environment issue (tools, permissions) | Stop, present to user | — |
| Plan is wrong (assumption fails) | Mark BLOCKED, update the top `**Status:**` line to `Blocked`, suggest amendment | — |

**Emergent phases:** When execution reveals unanticipated work:

1. Add Phase N.5 to execution.md with a note: `> Added during execution: [reason]`
2. Update dependency annotations for subsequent phases
3. Execute before continuing with dependent phases

### 7. Final verification and summary

After all phases:

1. Run end-to-end verification from the plan's Verification section
2. Cross-reference against spec acceptance criteria
3. Update the top `**Status:**` line to `Complete` (all phases done) or `Partial` (some phases outstanding)
4. Append summary to execution.md:

```
## Summary

_N of M phases done._

### Outstanding items
- [ ] [Items requiring human action]

### Decisions and Notes
- [Deviations from plan]
- [Issues for future work]

### Commits and PRs
| Repo | PR/Commit | Branch | Description |
|------|-----------|--------|-------------|
```

5. Present git state per project, then ask the user how to proceed:

```
How would you like to handle the PR?
- I'll create the PR for you (I'll show the title, body, and target branch for approval first)
- I'll prepare the PR details but you create it manually
- Skip — I'll handle it myself later
```

Stop here. Do NOT create a PR or run `gh pr create` unless the user picks the first option and approves the details.
