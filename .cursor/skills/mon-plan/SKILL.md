---
name: mon-plan
description: >-
  Create a phased implementation plan from a task spec for CMO or any monitoring
  stack component. Explores projects/ submodules for real file paths, asks
  clarifying questions, and generates plan.md with impact map, phase
  dependencies, verification steps, PR strategy, and risk analysis. Supports
  CMO, downstream (openshift/*), and upstream contributions.
  Use when the user says /mon:plan or asks to plan a monitoring stack task.
disable-model-invocation: true
---

# Monitoring Planner

Generate `plan.md` from a `spec.md` for CMO or any monitoring stack component.

## Input

The user provides a task folder name. The folder must exist under `tasks/` and contain `spec.md`. **Validate:** task name must match `^[a-z0-9][a-z0-9-]*$` — reject names containing `/`, `..`, or special characters.

```
/mon:plan <task-name>
```

## Steps

### 1. Read spec and system context

Read these files in order:

```
tasks/<task>/spec.md
```

Note: `CLAUDE.md` is already in context (loaded as a workspace rule) — do not re-read it.

For each project listed in the spec's "Related Projects" section, read if they exist:

- `projects/<project>/CLAUDE.md`
- `projects/<project>/AGENTS.md`
- `projects/<project>/README.md`

Read relevant harness context:

- `architecture/repo-mapping.md` — always read (upstream/downstream mapping, PR destinations)
- Read only the architecture doc relevant to the change type:
  - Config API changes → `architecture/configuration.md`
  - Scraping / metrics flow → `architecture/data-flow.md`
  - Namespace scoping → `architecture/namespaces.md`
  - General architecture questions → `architecture/overview.md`
  - Do not read all architecture docs — pick the 1-2 most relevant
- `components/<name>/README.md` — ONLY for components listed in the spec's "Related Projects" section (typically 1-3). Do not read all component READMEs.

After reading, identify:

- Which repositories are in scope
- The dependency order between changes
- What the spec is asking for (the change) vs why (the motivation)
- Which acceptance criteria are concrete vs ambiguous

### 2. Ask clarifying questions

Present 5-10 questions in a single message before exploring. Target questions that would change the plan structure. Do not ask questions answerable by reading the codebase.

Good questions target:

- Ambiguous acceptance criteria
- Scope boundaries (CI pipelines in scope? docs?)
- Target branches and release alignment
- Testing expectations (test cluster available?)
- Risk areas the spec does not mention
- PR ordering constraints

Wait for answers before proceeding.

### 3. Explore the codebase

Explore `projects/` with focused intent based on the spec and answers. **Limit exploration to repos listed in the spec's "Related Projects" section** — do not scan all 13 submodules.

**Multi-repo tasks:** Launch parallel explore agents only for the repos in scope (from spec). Each reports: project structure, files to modify, current behavior, relevant patterns.

**Single-repo tasks:** Explore directly.

For each repo in scope, investigate:

- **Files that will change** — grep for symbols, types, function names within `projects/<specific-repo>/`
- **Current behavior** — read files to document the "Current State" table
- **Dependencies and blast radius** — imports, consumers, tests
- **Similar implementations** — patterns to follow
- **File patterns** — for CMO targets, use the CMO-specific patterns:

| Change Type | Files Typically Involved |
|-------------|--------------------------|
| K8s resources | `jsonnet/components/<component>.libsonnet` → `make jsonnet-fmt generate` → `assets/` |
| Config option | `pkg/manifests/types.go` → `config.go` → `<component>.go` |
| Alerting rule | `jsonnet/components/<component>.libsonnet` (PrometheusRule) |
| Version bump | `jsonnet/versions.yaml` → `make generate` |
| E2E test | `test/e2e/<component>_test.go` |

  For **component targets** (not CMO), skip the CMO patterns above. Instead:
  - Read `projects/<component>/Makefile` for build/test/lint commands
  - Read `projects/<component>/CLAUDE.md` or `AGENTS.md` for project conventions
  - Identify the component's own test patterns (e.g., `go test ./...`, `make test`, etc.)
  - Check for component-specific CI requirements (e.g., `make lint`, `make format`)

**Critical:** Every file path MUST exist in `projects/` (verify with glob/grep). Never guess paths.

**Exploration budget:** Aim to read no more than 20 files total from `projects/`. If you need more, present what you've found so far and ask if deeper exploration is needed.

### 4. Classify phases

Assign a type to each phase:

| Type | When | Post-edit steps |
|------|------|-----------------|
| `implementation` | New functions, API changes, refactoring | TDD required. `make test-unit` |
| `configuration` | Version bumps, import updates, config values | No TDD. Build/lint verification |
| `jsonnet` | Editing `.libsonnet` files (CMO only) | `make jsonnet-fmt generate`. Commit sources + assets together. Never edit `assets/` directly |
| `investigation` | Research, compatibility checks | No code. Annotate findings inline |

For **component targets**, use `implementation` or `configuration` — `jsonnet` type only applies to CMO.

### 5. Ensure test and verification phases

Every plan must include phases for testing and verification. Do not assume the implementation phases alone are sufficient.

**Required phases to consider:**

- **Test phase** — Add or extend tests for the change. Search for existing test patterns:
  - `test/e2e/<component>_test.go` — e2e test assertions (e.g., `expectContainerArg()`)
  - `test/monitoring/` — Ginkgo-based extended tests
  - Unit tests alongside the modified Go packages
  - If no test change is needed, include a phase of type `investigation` documenting why

- **Cluster verification phase** — For changes that affect runtime behavior, include a phase with specific `oc` commands and PromQL queries the reviewer or CI should run post-deploy. Reference alert rules from `assets/<component>/prometheus-rule.yaml` for relevant PromQL expressions.

If the user's clarifying-question answers indicate no test cluster is available, mark the verification phase as `[HUMAN]` with the specific commands to run.

### 6. Write plan.md

Use `templates/plan.md` as the base. Every section is required:

- **Problem** — motivation, not just what changes
- **Current State** table — what exists before the change
- **Changes** — phased with dependency/parallel annotations, Files Modified tables, Details, per-phase Verification. Must include test and verification phases (from step 5).
- **PR Strategy** — fork URL, PR target (from spec's Contribution Target and `architecture/repo-mapping.md`), merge ordering. Push safety: "Always push to your personal fork. Never push directly to `openshift/*` repos or community upstream repos (`prometheus/*`, `thanos-io/*`, etc.)."
- **Verification** — mapped to spec acceptance criteria
- **Risks** — impact and mitigation

### 7. Self-review

Before saving, verify:

1. Every spec acceptance criterion is addressed by a phase
2. Phase dependencies are correct — no phase uses output from a later phase
3. Parallel phases do not modify overlapping files
4. Every file path exists in `projects/` (or is marked as new)
5. Jsonnet phases include `make jsonnet-fmt generate` in verification
6. PR Strategy includes fork URL and push safety reminder
7. Config API changes include both `types.go` and `config.go`
8. Plan includes a test phase (or documents why none is needed)
9. Plan includes a verification phase with specific commands for post-deploy validation

### 8. Save and present

Save as `tasks/<task>/plan.md`.

Present a summary to the user: phase count, repos touched, parallel groups, and any risks. **Stop and wait for human review before any implementation.**
