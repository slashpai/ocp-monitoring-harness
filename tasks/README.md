# Tasks

Active tasks follow a three-document workflow. Task directories are **local working documents** and are **not committed** to this repository (see `.gitignore`). Use Jira and GitHub PRs as the system of record; keep `tasks/` for agent context and your own audit trail.

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

Code changes go in the target component repository — typically `projects/cluster-monitoring-operator/` or your own fork — not in this harness. Open PRs against `openshift/cluster-monitoring-operator` (or the relevant component repo).

## Completed Tasks

Move finished task directories from `tasks/` to `completed/` locally for archival.
