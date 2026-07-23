---
name: mon-spec
description: >-
  Create a structured task spec for CMO or any monitoring stack component from
  a Jira ticket, bug report, or feature description. Explores projects/ to
  verify related repos, documents current behavior, identifies open questions,
  and generates spec.md with acceptance criteria. Supports CMO, downstream
  (openshift/*), and upstream contributions.
  Use when the user says /mon:spec or asks to create a task spec.
disable-model-invocation: true
---

# Monitoring Spec

Generate `spec.md` from a Jira ticket, bug description, or feature request. Works for CMO, downstream component forks, and upstream contributions.

## Input

The user provides a task name and a description (inline text, Jira ID, or both).

```
/mon:spec <task-name> "<description or Jira reference>"
```

## Steps

### 1. Parse the input

Extract from the user's description:

- **Task name** — used as folder name under `tasks/`. **Validate:** must match `^[a-z0-9][a-z0-9-]*$` (lowercase, numbers, hyphens only; no `/`, `..`, spaces, or special characters). If invalid, ask the user for a safe name.
- **Problem summary** — what needs to change
- **Motivation** — why (user impact, upstream deprecation, performance, etc.)
- **Jira/issue reference** — if provided
- **Scope hints** — which components or repos are mentioned

If the description is too vague (fewer than 2 sentences, no clear problem), ask the user for more context before proceeding.

### 2. Identify related projects

From the description, determine which `projects/` repos are involved. Verify they exist:

```
projects/cluster-monitoring-operator    # most common
projects/prometheus-operator
projects/prometheus
projects/thanos
# etc.
```

For each related project, do a quick exploration to understand how the change area works today:

- Grep for mentioned symbols, flags, or config options
- Read the relevant files to document current behavior
- Note the file paths that will likely change

### 3. Document current behavior

Create a "Current Behavior" table showing what exists before the change. This is the key improvement over a bare spec — the agent verifies facts in code rather than leaving everything to the planning phase.

For each relevant file, document:

- What it does now
- The specific file path (verified in `projects/`)
- Line numbers for key sections when relevant

### 4. Determine contribution target

Read `architecture/repo-mapping.md` to look up the component's upstream and downstream repos.

Classify the change:

| Target | When | PR destination | Build/test |
|--------|------|----------------|------------|
| **CMO** | Changes to operator logic, jsonnet, config API | `openshift/cluster-monitoring-operator` | `make jsonnet-fmt generate`, `make test-unit` |
| **Downstream component** | OpenShift-specific fix in a component fork | `openshift/<component>` (e.g., `openshift/prometheus`) | Read `projects/<component>/Makefile` for build/test commands |
| **Upstream component** | Bug fix or feature for the community project | Community repo from repo-mapping.md (e.g., `prometheus/prometheus`) | Read `projects/<component>/Makefile`; upstream may have different CI |

**Push safety (all targets):** Always push to the user's personal fork. Never push directly to `openshift/*` repos or community upstream repos.

Include the contribution target in the spec so the planner knows where the PR goes.

For **upstream contributions**: note that `projects/<component>` tracks the OpenShift fork. The upstream repo may have diverged — flag this as an open question. Some components are OpenShift-only with no upstream (see repo-mapping.md).

### 5. Identify open questions

Flag ambiguities that should be resolved during planning, not guessed at during spec writing:

- Scope boundaries (is UWM in scope? Tests? Docs?)
- **Upstream vs downstream** — should this be contributed upstream first and then cherry-picked, or is it OpenShift-specific?
- Backward compatibility concerns
- Whether a test cluster is available for verification
- RBAC or security implications
- Component-specific build/test requirements (if not CMO)

### 6. Write spec.md

Create `tasks/<task>/spec.md` with these sections:

```markdown
# Spec: <task-name>

## Problem Statement

[Clear description of what needs to change and why. Include impact —
log noise, API deprecation, user-facing breakage, etc. Reference upstream
docs or PRs that motivate the change.]

## Contribution Target

Target: CMO | Downstream (<component>) | Upstream (<component>)
PR destination: openshift/<repo> | upstream/<repo>

## Current Behavior (verified in code)

| Component | File | Behavior |
|-----------|------|----------|
| [name] | `projects/<repo>/path/to/file` | [What it does now] |

[Key insights — surprising findings from code exploration.]

## Related Projects

- `projects/<repo>` — [why it's involved]

## Acceptance Criteria

- [ ] [Concrete, verifiable criterion]
- [ ] [Another criterion]
- [ ] Build/test passes (CMO: `make jsonnet-fmt generate`, `make test-unit`;
      components: use project-specific commands from Makefile)

## Open Questions (for plan phase)

1. [Question that could change the plan structure]

## References

- Jira: [ID]
- [Relevant PRs, upstream docs, KEPs]
```

**Key rules:**

- Acceptance criteria as proper markdown checkboxes, not inside code fences
- File paths verified in `projects/` — never guessed
- "Current Behavior" table populated from actual code, not assumed
- Open questions explicitly flagged — do not silently resolve ambiguities
- Build/test acceptance criteria adapted to the target project — read the component's `Makefile` for the right commands instead of assuming CMO's `make test-unit`

### 7. Present and stop

Save as `tasks/<task>/spec.md`.

Present a summary:

- Problem in one sentence
- Repos involved
- Number of acceptance criteria
- Open questions that need answers before planning

**Stop and wait for human review.** Do not proceed to plan.md or any implementation.
