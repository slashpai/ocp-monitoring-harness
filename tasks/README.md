# Tasks

Active tasks follow a three-document workflow. Task directories are **local working documents** and are **not committed** to this repository (see `.gitignore`). Use Jira and GitHub PRs as the system of record; keep `tasks/` for agent context and your own audit trail. For the full workflow and example prompts, see [USAGE.md](../USAGE.md).

```text
tasks/
  <task-name>/
    spec.md          Problem statement, related projects, acceptance criteria
    plan.md          Impact map and structured tasks — human reviews before execution
    execution.md     Progress tracking with checkboxes, notes, PR links
```

When a task is done, move its directory to `completed/` locally (also gitignored).

## User Input

**Default flow:** you provide a prompt (or Jira link) → the agent creates `spec.md` → you review → you prompt again → the agent creates `plan.md` → you review → you prompt again → the agent implements.

You do not need to create files manually unless you prefer to write the spec yourself:

```bash
# Option A: prompt the agent
# "Create tasks/my-feature/spec.md from templates/spec.md for MON-1234 ..."

# Option B: create the directory yourself (from repo root)
mkdir -p tasks/my-feature
cp templates/spec.md tasks/my-feature/spec.md   # then edit
```

Always tell the agent to stop after `spec.md` or `plan.md` until you have reviewed it.

## Workflow

### 1. Spec (`spec.md`)

Define the problem before solving it. Use [templates/spec.md](../templates/spec.md).

- **Problem statement** — What needs to change and why
- **Related projects** — Which repos in `projects/` are affected
- **Acceptance criteria** — How you know it's done
- **References** — Links to Jira, PRs, upstream issues

### 2. Plan (`plan.md`)

The agent builds a plan grounded in real code from `projects/` submodules:

- Produces a **repository impact map** (see `.cursor/rules/05-planning-workflow.mdc`)
- Breaks work into **structured tasks** (see [templates/plan.md](../templates/plan.md))
- Lists steps in dependency order

**Human must review the plan before implementation.**

### 3. Execution (`execution.md`)

Track progress during implementation using [templates/execution.md](../templates/execution.md):

- Checkboxes for each step from the plan
- Notes on decisions, blockers, deviations
- Links to commits and PRs in the **target repo** (not this harness)

## Where Implementation Happens

Two supported modes — see [USAGE.md](../USAGE.md#choosing-a-mode) for when to use each. **Mode A** suits one task at a time per repo; **Mode B** suits parallel work on the same component.

### Mode A — Submodule (recommended)

| Step | Location |
|---|---|
| Plan (read) | `projects/<component>/` |
| Implement (edit, commit, test) | Same `projects/<component>/` submodule |
| Push | Your fork remote (e.g. `git push fork <branch>`) |
| Open PR | Upstream repo (e.g. `openshift/cluster-monitoring-operator`) |
| Cleanup | `make reset-projects` from harness root (after push) |

Include your fork URL in the Phase 3 prompt (`Push remote: fork (<url>)`); the agent configures `fork` on push — no separate setup step. See [USAGE.md](../USAGE.md) for the full walkthrough.

Example Phase 3 prompt:

```text
Implement in projects/cluster-monitoring-operator/
Branch: bugfix-1234
Push remote: fork (https://github.com/<you>/cluster-monitoring-operator)
PR target: openshift/cluster-monitoring-operator
```

### Mode B — External fork clone

Use when the fork is outside this workspace or you want submodules untouched.

| Purpose | Location |
|---|---|
| Read source for planning | `projects/<component>/` submodules (`make submodule-update` before planning) |
| Edit, commit, test, and push | Your fork clone — sync with `upstream/main` before each task |
| Open PR | Upstream repo |

```text
Implementation repo: ~/github.com/<you>/cluster-monitoring-operator
Branch: bugfix-1234
PR target: openshift/cluster-monitoring-operator
```

See [USAGE.md](../USAGE.md#where-code-changes-go) for sync commands and full details.

## Completed Tasks

Move finished task directories from `tasks/` to `completed/` locally for archival.
