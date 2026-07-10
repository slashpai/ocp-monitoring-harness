# Usage Guide

This harness is a **domain knowledge and workflow layer** for AI-assisted CMO work. It is not the SDLC itself — Jira, GitHub, and CI still own tracking and delivery. The harness gives the agent structured context so its output is grounded in real code and reviewable by humans.

## Workflow

Each task follows a three-document workflow (inspired by [observability-ui/harness](https://github.com/observability-ui/harness) and [harness engineering](https://developers.redhat.com/articles/2026/04/07/harness-engineering-structured-workflows-ai-assisted-development)):

1. **Spec** ([`templates/spec.md`](templates/spec.md)) — Problem statement, related projects, acceptance criteria
2. **Plan** (`tasks/<name>/plan.md`) — Repository impact map from `projects/`, plus structured tasks per [templates/plan.md](templates/plan.md). **Human reviews before execution.**
3. **Execution** ([`templates/execution.md`](templates/execution.md)) — Progress tracking with checkboxes and notes

The principle: **structure in, structure out**. The more you constrain the solution space, the more predictable the output.

Task directories under `tasks/` are **local working documents** and are gitignored. See [tasks/README.md](tasks/README.md).

## Prerequisites

- [Cursor](https://cursor.com) or [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- `git` with submodule support
- `podman` or `docker` (for markdown linting only)
- A GitHub fork of each **component** repo you will change (e.g. `cluster-monitoring-operator`) — for opening PRs
- Mode B only: a separate local checkout of that fork (e.g. `~/github.com/<you>/cluster-monitoring-operator`)

## Getting Started

1. Clone this harness with submodules (your fork of `ocp-monitoring-harness`, or upstream if you are not contributing harness docs):

   ```bash
   git clone --recurse-submodules https://github.com/<you>/ocp-monitoring-harness.git
   cd ocp-monitoring-harness
   make submodule-init   # if submodules were not cloned recursively
   ```

2. Open the repo in your AI coding tool:
   - **Cursor** — `.cursor/rules/` automatically feeds the agent context based on what you're working on
   - **Claude Code** — `CLAUDE.md` is automatically read for project context

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
Agent implements (submodule or fork)    ← see "Where Code Changes Go"
        ↓
Agent updates tasks/<name>/execution.md ← audit trail (local)
        ↓
PR opened in target repo                ← Jira/GitHub are system of record
        ↓
make reset-projects (Mode A only)       ← reset submodules after PR is pushed
```

**Default:** you prompt → agent drafts `spec.md` → you review → you prompt again → agent drafts `plan.md` → you review → you prompt again → agent implements.

**Optional:** write `spec.md` yourself when the Jira ticket is already clear, then ask the agent to produce the plan.

## Workflows by Task Type

### Develop or fix CMO (non-trivial)

Use the spec → plan → execution workflow. A full three-phase prompt example for **disable-kubelet-endpoints** / **OCPBUGS-85522** is below.

1. Prompt the agent to create a task from [templates/spec.md](templates/spec.md)
2. Review `tasks/<name>/spec.md`
3. Ask the agent to produce `plan.md` — it must scan `projects/` for real file paths
4. **Review the plan before any implementation**
5. Agent implements using **Mode A** (submodule, default) or **Mode B** (external fork clone) — see [Where Code Changes Go](#where-code-changes-go)
6. Track progress in `execution.md`; open PR in the component repo, not in this harness
7. After the PR is pushed, run `make reset-projects` (Mode A — required; skip for Mode B)

#### Example walkthrough: `disable-kubelet-endpoints` (OCPBUGS-85522)

Copy only the fenced `text` blocks below into your agent — phase headings and this intro are for you, not part of the prompt. Each phase gives the agent **intent**; it fills `spec.md` / `plan.md` from `templates/` and `projects/`. Example: [OCPBUGS-85522](https://issues.redhat.com/browse/OCPBUGS-85522).

##### Phase 1 — spec only (OCPBUGS-85522)

```text
New task: disable-kubelet-endpoints

Jira: OCPBUGS-85522 — platform prometheus-operator logs v1 Endpoints
deprecation warnings for kube-system/kubelet. This is causing unnecessary load 
on the logging system and producing excessive unwanted logs. Kubelet scraping 
already uses EndpointSlice (CMO PR #2696).

We want to stop managing kubelet Endpoints without breaking kubelet scrapes.

Stop after spec.md. Do not write plan.md or change code until I review.
```

##### Phase 2 — plan only (OCPBUGS-85522, after you approve the spec)

```text
For tasks/disable-kubelet-endpoints (OCPBUGS-85522), write plan.md:

1. Repository impact map — scan projects/ for real file paths and symbols;
   do not guess. Include dependencies and risks.
2. Structured tasks per templates/plan.md.

Stop before any implementation or execution.md updates so I can review the plan.
```

##### Phase 3 — implement (OCPBUGS-85522, after you approve the plan), Mode A — submodule (default)

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

##### Phase 3 — implement (OCPBUGS-85522), Mode B — external fork clone

```text
Plan approved for disable-kubelet-endpoints (OCPBUGS-85522).

Implement per tasks/disable-kubelet-endpoints/plan.md.
Implementation repo (local path): ~/github.com/<you>/cluster-monitoring-operator
Branch: OCPBUGS-85522
PR target: openshift/cluster-monitoring-operator

Sync with upstream/main before branching. Use projects/ in this harness only
for reading during planning; edit only in the implementation repo path above.

Track progress in tasks/disable-kubelet-endpoints/execution.md.
Open the PR when ready.
```

### Troubleshoot a live cluster

No task folder required. Provide symptoms, alert names, or pod/namespace details in chat.

If a Prometheus/Alertmanager MCP server (e.g. [obs-mcp](https://github.com/rhobs/obs-mcp)) is configured, the agent combines harness knowledge (expected metrics, alerts, architecture) with live cluster data.

### Learn architecture or design

Ask in chat. The agent reads `architecture/`, `components/`, and `projects/` as needed. No task folder unless the question becomes a code change.

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

| Change | Where to implement | Where to open PR |
|---|---|---|
| CMO manifest, config API, operator logic | `projects/cluster-monitoring-operator` (Mode A) or `~/github.com/<you>/cluster-monitoring-operator` (Mode B) | `openshift/cluster-monitoring-operator` |
| Upstream component fix | `projects/<component>` (Mode A) or `~/github.com/<you>/<component>` (Mode B) | Community repo or OpenShift fork |
| Harness docs only | This repo (`architecture/`, `components/`, etc.) | This repo |

### Choosing a mode

| | Mode A — submodule | Mode B — external fork |
|---|---|---|
| **Best for** | One active task, one workspace; plan paths match edit paths | Parallel tasks on the **same** repo, or fork outside the harness workspace |
| **Same repo, two tasks** | One branch per submodule — finish, push, and `make reset-projects` before the next task, or use `git worktree` / a second harness clone | Separate clone per task (e.g. `~/cmo-bugfix-1234`, `~/cmo-feature-5678`) |
| **Different repos in parallel** | Fine — e.g. CMO in `projects/cluster-monitoring-operator` and Thanos in `projects/thanos` at once | Fine — independent clones |
| **Cleanup** | `make reset-projects` resets **all** submodules (push first) | Harness submodules stay on upstream; no reset needed |
| **Complexity** | Lower — no second path in Phase 3 prompts | Higher — sync fork with upstream; specify local path each time |

**Rule of thumb:** default to Mode A for a single focused task. Switch to Mode B when you need concurrent work on the same component repo, or when the implementation checkout must live outside this workspace.

### Mode A — Submodule (recommended default)

Implement directly in `projects/<repo>/`. Same paths as the plan impact map; one workspace for the agent.

Submodules clone from `openshift/*` (`origin`) for read. Give your fork URL in the Phase 3 prompt (`Push remote: fork (<url>)` — see example above); the agent branches, commits, pushes to `fork` only, and configures that remote on push. **Never push to openshift remotes directly** (`origin`, `upstream`, or any `github.com/openshift/*` URL) — use fork + PR. No separate remote setup step. `make reset-projects` keeps the `fork` remote; it only resets branches and discards unpushed work.

To resume a branch already on your fork: `git fetch fork`, then `git checkout -b bugfix-1234 fork/bugfix-1234`.

**After the PR is pushed** — reset submodules so planning stays on clean upstream SHAs:

```bash
make reset-projects
```

`reset-projects` discards unpushed commits and uncommitted changes in every `projects/` submodule. Push before resetting.

### Mode B — External fork clone

Use when the fork lives outside this workspace or you prefer submodules to stay untouched.

- **Read** source from `projects/` when building impact maps (same as Mode A) — run `make submodule-update` in the harness before planning so submodules match current upstream
- **Edit, commit, test, and push** in a separate checkout — give the agent **local path**, **branch**, and **PR target** in the Phase 3 prompt
- **Sync that checkout with upstream before each task** — plans are built from harness submodules; a stale fork causes wrong baselines and painful merges

**One-time setup** — `upstream` points at the OpenShift repo; `origin` is your fork (typical clone layout):

```bash
cd ~/github.com/<you>/cluster-monitoring-operator
git remote add upstream https://github.com/openshift/cluster-monitoring-operator.git  # if missing
```

**Per task** — update from upstream, then branch:

```bash
cd ~/github.com/<you>/cluster-monitoring-operator
git fetch upstream
git checkout main
git merge upstream/main
git checkout -b bugfix-1234
# edit, test, commit
git push origin bugfix-1234
# open PR: <you>/cluster-monitoring-operator → openshift/cluster-monitoring-operator
```

```text
Implementation repo (local path): ~/github.com/<you>/cluster-monitoring-operator
Branch: bugfix-1234
PR target: openshift/cluster-monitoring-operator
```

For Jsonnet changes in CMO: edit `jsonnet/components/*.libsonnet`, run `make jsonnet-fmt generate`, commit sources and regenerated `assets/` together. Never edit `assets/` by hand.

## Agentic SDLC Fit

In a typical agentic SDLC, this harness covers the **context and planning substrate**:

| SDLC phase | Harness role |
|---|---|
| Intake / triage | `architecture/`, `components/` — map symptoms to components |
| Spec | `tasks/<name>/spec.md` from [templates/spec.md](templates/spec.md) |
| Plan | Impact map from `projects/` submodules — **human review gate** |
| Implement | Mode A: `projects/<repo>/` submodule; Mode B: fork clone path you specify |
| Test | [development/testing.md](development/testing.md) — `make test-unit`, e2e, etc. |
| Review | `plan.md` and `execution.md` document intent vs outcome |
| Operate | CMO `assets/*/prometheus-rule.yaml`, `.cursor/rules/04-promql-patterns.mdc`, optional live MCP tools |
| Cleanup | `make reset-projects` after Mode A tasks (push first) |

## Submodule Maintenance

```bash
make submodule-init      # first clone
make submodule-update    # pull latest upstream SHAs into submodules (before planning)
make submodule-status    # show pinned commits
make reset-projects      # discard local submodule changes; reset to .gitmodules branches
```

Keep submodules current before planning. After Mode A implementation, run `make reset-projects` once the branch is pushed to your fork.
