# Usage Guide

This harness is a **domain knowledge and workflow layer** for AI-assisted CMO work. It is not the SDLC itself — Jira, GitHub, and CI still own tracking and delivery. The harness gives the agent structured context so its output is grounded in real code and reviewable by humans.

## Workflow

Each task follows a three-document workflow (inspired by [observability-ui/harness](https://github.com/observability-ui/harness) and [harness engineering](https://developers.redhat.com/articles/2026/04/07/harness-engineering-structured-workflows-ai-assisted-development)):

1. **Spec** ([`templates/spec.md`](templates/spec.md)) — Problem statement, related projects, acceptance criteria
2. **Plan** (`tasks/<name>/plan.md`) — Phased plan with impact map, verification steps, and PR strategy per [templates/plan.md](templates/plan.md). **Human reviews before execution.**
3. **Execution** ([`templates/execution.md`](templates/execution.md)) — Progress tracking with checkboxes and notes

The principle: **structure in, structure out**. The more you constrain the solution space, the more predictable the output.

Task directories under `tasks/` are **local working documents** and are gitignored. See [tasks/README.md](tasks/README.md).

## Prerequisites

- An [Agent Skills](https://agentskills.io)–compatible coding agent ([Cursor](https://cursor.com), [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Codex, Gemini CLI, etc.)
- `git` with submodule support (enable `core.symlinks=true` on Windows if skill symlinks fail)
- Go (for `make lint` — auto-installs [mdox](https://github.com/bwplotka/mdox) to `bin/`)
- A GitHub fork of each **component** repo you will change (e.g. `cluster-monitoring-operator`) — for opening PRs

## Getting Started

1. Clone this harness with submodules (your fork of `ocp-monitoring-harness`, or upstream if you are not contributing harness docs):

   ```bash
   git clone --recurse-submodules https://github.com/<you>/ocp-monitoring-harness.git
   cd ocp-monitoring-harness
   make submodule-init   # if submodules were not cloned recursively
   ```

2. Open the repo in your agent:
   - **Skills** — `.agents/skills/` (portable); `.cursor/skills` and `.claude/skills` are compatibility symlinks — see [Skills](#skills)
   - **Cursor rules** (`.cursor/rules/`) — Cursor-only auto-loaded guardrails; other agents use [`CLAUDE.md`](CLAUDE.md) and harness docs for domain context

   > **Rules vs Skills:** Rules are always-on guardrails (push safety, commit conventions, security) — loaded automatically in Cursor. Skills are structured workflows (`/mon:spec`, `/mon:plan`) — invoked explicitly when needed. Skills are committed under `.agents/skills/` so every team member and agent gets the same commands.

3. Start with a prompt. The agent uses harness content plus `projects/` submodules to ground responses.

## Where User Input Goes

Unstructured input (chat, Jira, alerts) becomes structured task documents before code changes:

```text
Your prompt / Jira ticket
        ↓
Agent creates tasks/<name>/spec.md     ← you review
        ↓
Agent creates tasks/<name>/plan.md      ← you review (required gate)
        ↓
Agent implements in projects/<repo>/     ← see "Where Code Changes Go"
        ↓
Agent updates tasks/<name>/execution.md ← audit trail (local)
        ↓
PR opened in target repo                ← Jira/GitHub are system of record
        ↓
make reset-projects                     ← reset submodules after PR is pushed
```

**Default:** you prompt → agent drafts `spec.md` → you review → you prompt again → agent drafts `plan.md` → you review → you prompt again → agent implements.

**Optional:** write `spec.md` yourself when the Jira ticket is already clear, then ask the agent to produce the plan.

## Workflows by Task Type

### Develop or fix a monitoring component (non-trivial)

Use the spec → plan → implement workflow. Each phase produces a document that feeds the next, with a **human review gate** between phases. Works for CMO, downstream component forks, and upstream contributions.

#### With skills (recommended)

Skills automate each phase. You review between phases and approve before the next one starts.

**Example: OCPBUGS-85522 — disable kubelet Endpoints reconciliation**

**Step 1 — Create the spec.** Give the skill a task name and description (Jira ID, bug report, or feature request):

```text
/mon:spec disable-kubelet-endpoints "OCPBUGS-85522: prometheus-operator logs v1 Endpoints deprecation warnings for kube-system/kubelet, causing log noise. Kubelet scraping already uses EndpointSlice (CMO PR #2696)."
```

The agent will:

- Create `tasks/disable-kubelet-endpoints/`
- Explore `projects/` to find relevant files and verify current behavior
- Look up `ARCHITECTURE.md` to determine contribution target
- Generate `tasks/disable-kubelet-endpoints/spec.md` with problem statement, current behavior table, acceptance criteria, and open questions (or if `spec.md` already exists, show what's there and ask whether to update or regenerate)
- **Stop and wait for your review**

**Step 2 — Review `spec.md`, then generate the plan:**

```text
/mon:plan disable-kubelet-endpoints
```

The agent will:

- Read the spec and system context (`CLAUDE.md`, component docs)
- Ask 5-10 clarifying questions (scope, testing, target branch)
- After your answers, explore the codebase for real file paths
- Generate `tasks/disable-kubelet-endpoints/plan.md` with phased changes, verification steps, PR strategy, and risks (or if `plan.md` already exists, show what's there and ask whether to update or regenerate)
- **Stop and wait for your review**

**Step 3 — Review `plan.md`, then implement:**

```text
/mon:implement disable-kubelet-endpoints
```

The agent will:

- Parse the plan into `execution.md` with checkboxes and **wait for your confirmation** before executing
- If `execution.md` already exists: detect whether the plan has changed — if so, ask how to handle it (regenerate, keep, or merge); if unchanged, resume from the first incomplete phase with a summary of what was already done
- Execute phases in dependency order — handles jsonnet regeneration, TDD for Go
- **Stop before every commit** — presents `git diff`, summary, and proposed message; waits for approval
- **Stop before every push** — presents the exact `git push` command, remote URL, and branch; waits for approval
- **Stop before creating a PR** — asks whether to create it for you, prepare details for manual creation, or skip
- Track progress with inline annotations (`-- **passes**`, `-- **FAILED: reason**`)
- Push only to your fork (never to `openshift/*` or upstream orgs)

**Resuming a partially completed task:**

```text
/mon:implement disable-kubelet-endpoints
```

If `execution.md` already exists with completed phases, the agent preserves all prior work, shows what was done, and picks up from the next incomplete phase. If the plan was revised since the last run, the agent detects the divergence and asks before proceeding.

**Step 4 (optional) — Review the resulting PR:**

```text
/mon:review https://github.com/openshift/cluster-monitoring-operator/pull/<number>
```

**Troubleshooting — no task folder needed:**

```text
/mon:diagnostic "kube-state-metrics pod in openshift-monitoring panics and enters CrashLoopBackOff when it encounters a CronJob that uses the .spec.timeZone field (or the legacy CRON_TZ= prefix in .spec.schedule)"
```

#### With manual prompts

If you prefer manual prompts instead of skills, copy the fenced `text` blocks below. Each phase gives the agent **intent**; it fills `spec.md` / `plan.md` from `templates/` and `projects/`.

<details>
<summary>Phase 1 — spec only (OCPBUGS-85522)</summary>

```text
New task: disable-kubelet-endpoints

Jira: OCPBUGS-85522 — platform prometheus-operator logs v1 Endpoints
deprecation warnings for kube-system/kubelet. This is causing unnecessary load 
on the logging system and producing excessive unwanted logs. Kubelet scraping 
already uses EndpointSlice (CMO PR #2696).

We want to stop managing kubelet Endpoints without breaking kubelet scrapes.

Stop after spec.md. Do not write plan.md or change code until I review.
```

</details>

<details>
<summary>Phase 2 — plan only (after you approve the spec)</summary>

```text
For tasks/disable-kubelet-endpoints (OCPBUGS-85522), write plan.md:

1. Repository impact map — scan projects/ for real file paths and symbols;
   do not guess. Include dependencies and risks.
2. Phased plan per templates/plan.md.

Stop before any implementation or execution.md updates so I can review the plan.
```

</details>

<details>
<summary>Phase 3 — implement (after you approve the plan)</summary>

```text
Plan approved for disable-kubelet-endpoints (OCPBUGS-85522).

Implement per tasks/disable-kubelet-endpoints/plan.md in
projects/cluster-monitoring-operator/ (submodule in this harness).
Branch: OCPBUGS-85522
PR target: openshift/cluster-monitoring-operator
Push remote: fork (https://github.com/<you>/cluster-monitoring-operator)

Track progress in tasks/disable-kubelet-endpoints/execution.md.
Open the PR when ready. I will run make reset-projects after the PR is pushed.
```

</details>

### Troubleshoot a live cluster

No task folder required. Use `/mon:diagnostic` for structured diagnosis (or invoke the skill by name). Otherwise, provide symptoms, alert names, or pod/namespace details in chat.

If a Prometheus/Alertmanager MCP server (e.g. [obs-mcp](https://github.com/rhobs/obs-mcp)) is configured, the agent combines harness knowledge (expected metrics, alerts, architecture) with live cluster data.

### Learn architecture or design

Ask in chat. The agent reads `ARCHITECTURE.md`, `components/`, and `projects/` as needed. No task folder unless the question becomes a code change.

## What You Can Ask

**Architecture and design:**

- "How does Thanos Querier aggregate metrics from multiple Prometheus instances?"
- "What happens when User Workload Monitoring is enabled?"
- "How does config flow from cluster-monitoring-config to component manifests?"

**Troubleshooting:**

- "Prometheus pods are in CrashLoopBackOff — what should I check?"
- "Alertmanager is not sending notifications — help me debug"

**Development:**

- "Add a new config option to CMO for Prometheus retention size"
- "How do I bump the Thanos version in CMO?"
- "Where do I change kubelet ServiceMonitor discovery?"

## Where Code Changes Go

| Change                                   | Where to implement                                 | Where to open PR                        |
|------------------------------------------|----------------------------------------------------|-----------------------------------------|
| CMO manifest, config API, operator logic | `projects/cluster-monitoring-operator`             | `openshift/cluster-monitoring-operator` |
| Upstream component fix                   | `projects/<component>`                             | Community repo or OpenShift fork        |
| Harness docs only                        | This repo (`ARCHITECTURE.md`, `components/`, etc.) | This repo                               |

### How Implementation Works

Implement directly in `projects/<repo>/`. Same paths as the plan impact map; one workspace for the agent.

Submodules clone from `openshift/*` (`origin`) for read. Give your fork URL in the Phase 3 prompt (`Push remote: fork (<url>)` — see example above); the agent branches, commits, pushes to `fork` only, and configures that remote on push. **Never push to openshift remotes directly** (`origin`, `upstream`, or any `github.com/openshift/*` URL) — use fork + PR. No separate remote setup step. `make reset-projects` keeps the `fork` remote; it only resets branches and discards unpushed work.

To resume a branch already on your fork: `git fetch fork`, then `git checkout -b bugfix-1234 fork/bugfix-1234`.

**After the PR is pushed** — reset submodules so planning stays on clean upstream SHAs:

```bash
make reset-projects
```

`reset-projects` discards unpushed commits and uncommitted changes in every `projects/` submodule. Push before resetting.

For Jsonnet changes in CMO: edit `jsonnet/components/*.libsonnet`, run `make jsonnet-fmt generate`, commit sources and regenerated `assets/` together. Never edit `assets/` by hand.

## Skills

Custom skills automate the spec-plan-execution pipeline. They encode monitoring stack domain knowledge (jsonnet phases, push safety, impact maps, obs-mcp, upstream/downstream repo mapping) so the agent follows the right steps without you repeating instructions. See [Workflows by Task Type](#workflows-by-task-type) for a detailed walkthrough.

Invoke with `/mon:*` where the agent supports slash skills; otherwise use the skill name or describe the workflow in natural language.

| Skill      | Command                            | Input                        | Output                                                                              |
|------------|------------------------------------|------------------------------|-------------------------------------------------------------------------------------|
| Spec       | `/mon:spec <task> "<description>"` | Task name + Jira/description | `tasks/<task>/spec.md` with verified current behavior                               |
| Plan       | `/mon:plan <task>`                 | `tasks/<task>/spec.md`       | `tasks/<task>/plan.md` with impact map, phases, PR strategy                         |
| Implement  | `/mon:implement <task>`            | `tasks/<task>/plan.md`       | `tasks/<task>/execution.md` + implemented changes; 4 human gates                    |
| Review     | `/mon:review <PR>`                 | PR number or URL             | Structured review with severity levels                                              |
| Diagnostic | `/mon:diagnostic "symptom"`        | Inline symptom description   | Root cause diagnosis with per-command consent                                       |
| Commit     | `/harness:commit [--auto]`         | Pending harness changes      | Atomic commits with security scan and changelog; `--auto` skips per-commit approval |

Skills work for CMO, downstream component forks (`openshift/*`), and upstream community contributions. They live in [`.agents/skills/`](.agents/skills/) ([Agent Skills](https://agentskills.io) standard). Compatibility symlinks: `.cursor/skills` and `.claude/skills`.

## Agentic SDLC Fit

In a typical agentic SDLC, this harness covers the **context and planning substrate**:

| SDLC phase      | Harness role                                                                                                                       |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------|
| Intake / triage | `ARCHITECTURE.md`, `components/` — map symptoms to components                                                                      |
| Spec            | `tasks/<name>/spec.md` from [templates/spec.md](templates/spec.md)                                                                 |
| Plan            | Impact map from `projects/` submodules — **human review gate**                                                                     |
| Implement       | `projects/<repo>/` submodule — push to fork, PR to upstream                                                                        |
| Test            | [CMO testing docs](https://github.com/openshift/cluster-monitoring-operator/tree/main/Documentation) — `make test-unit`, e2e, etc. |
| Review          | `plan.md` and `execution.md` document intent vs outcome                                                                            |
| Operate         | CMO `assets/*/prometheus-rule.yaml`, `.cursor/rules/04-promql-patterns.mdc`, optional live MCP tools                               |
| Cleanup         | `make reset-projects` after tasks (push first)                                                                                     |

## Submodule Maintenance

```bash
make submodule-init      # first clone
make submodule-update    # pull latest upstream SHAs into submodules (before planning)
make submodule-status    # show pinned commits
make reset-projects      # discard local submodule changes; reset to .gitmodules branches
```

Keep submodules current before planning. After implementation, run `make reset-projects` once the branch is pushed to your fork.

## Validation

```bash
make lint                # check markdown formatting and links (auto-installs mdox)
make lint-fix            # fix markdown formatting and validate links
make validate            # run all checks
make clean               # remove local tool binaries (bin/)
make help                # list all available targets
```

Uses [mdox](https://github.com/bwplotka/mdox) for formatting and link validation. Auto-installed to `bin/` on first run (requires Go).
