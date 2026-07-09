# Tasks

Active tasks follow a three-document workflow:

```text
tasks/
  <task-name>/
    spec.md          Problem statement, related projects, acceptance criteria
    plan.md          Step-by-step breakdown the AI agent executes against
    execution.md     Progress tracking with checkboxes and notes
```

## Workflow

### 1. Spec (`spec.md`)

Define the problem before solving it. A spec must include:

- **Problem statement** — What needs to change and why
- **Related projects** — Which repos in `projects/` are affected
- **Acceptance criteria** — How you know it's done
- **References** — Links to Jira, PRs, upstream issues, docs

### 2. Plan (`plan.md`)

The agent builds a plan grounded in real code from the `projects/` submodules:

- Produces a **repository impact map** (see `.cursor/rules/05-planning-workflow.mdc`)
- Breaks work into **structured tasks** (see `templates/plan.md`)
- Lists steps in dependency order
- Human reviews the plan before execution

### 3. Execution (`execution.md`)

Track progress during implementation:

- Checkboxes for each step from the plan
- Notes on decisions made, blockers hit, deviations from plan
- Links to commits and PRs created

## Completed Tasks

Once a task is done, move its directory from `tasks/` to `completed/` for archival.

## Creating a New Task

```bash
mkdir tasks/<task-name>
# Then create spec.md, have the agent produce plan.md, review, then execute
```
