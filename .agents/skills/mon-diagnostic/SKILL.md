---
name: mon-diagnostic
disable-model-invocation: true
description: Diagnose bugs and issues in the OpenShift monitoring stack. Maps symptoms to components, confirms with the user before querying a live cluster (via obs-mcp or direct oc access), and falls back to manual oc/PromQL commands when no cluster is available. Follows the alerts-component-metrics-logs- config troubleshooting methodology. Use when the user says /mon:diagnostic or asks to diagnose a monitoring issue.
---

# Monitoring Diagnostic

Structured bug diagnosis for the OpenShift monitoring stack.

## Input

An inline symptom description.

```
/mon:diagnostic "kube-state-metrics pod panics and CrashLoopBackOffs when a CronJob uses .spec.timeZone on 4.22"
```

## Steps

### 1. Gather symptom details

Parse the symptom description. Ask for missing context:

- Cluster version (OCP x.y)
- When the issue started (upgrade, config change, new workload?)
- Affected namespace (`openshift-monitoring` or `openshift-user-workload-monitoring`?)
- Any error messages or pod states observed

### 2. Map symptoms to components

Use the symptom-component table to narrow scope:

| Symptom                     | Likely Components                                             |
|-----------------------------|---------------------------------------------------------------|
| Missing metrics             | Prometheus, kube-state-metrics, node-exporter, scrape targets |
| Alerts not firing           | Prometheus (rules), Alertmanager (routing/silences)           |
| Alerts not delivered        | Alertmanager (receivers, routes)                              |
| Console monitoring broken   | monitoring-plugin, Thanos Querier                             |
| High memory / OOM           | Prometheus (cardinality, retention), Thanos                   |
| Pod CrashLoopBackOff        | Component-specific — check logs and resource limits           |
| RBAC / auth errors          | kube-rbac-proxy, prom-label-proxy                             |
| HPA not scaling             | metrics-server                                                |
| Query errors / slow queries | Thanos Querier, Prometheus                                    |
| UWM metrics missing         | UWM Prometheus, Thanos Ruler, prom-label-proxy                |

Read `components/<component>/README.md` for each suspected component to understand its architecture and common failure modes.

### 3. Check alert rules

Read the relevant alert rules to understand what the monitoring stack itself checks:

```
projects/cluster-monitoring-operator/assets/<component>/prometheus-rule.yaml
```

Match the symptom against existing alerts. If an alert exists for this condition:

- Note the alert name, PromQL expression, and thresholds
- These expressions are maintained per release and are reliable starting points

### 4. Confirm investigation approach with the user

**Priority order for evidence: codebase/harness docs → live cluster (confirmed) → manual commands → external sources (last resort, confirmed).** Do not jump to external searches (GitHub PR/issue lookups, web search) as a default step — they are optional and only worth trying if the steps below are inconclusive or the user explicitly asks.

**Ask before checking anything.** Do not probe for `obs-mcp` or `oc` availability first — even a read-only availability check contacts a live system. Ask the question first, and only check/query after the user opts in:

```
How would you like to investigate this?
- Use obs-mcp if it's configured (I'll check availability first)
- Use oc directly if you have cluster access (I'll check availability first)
- Skip the cluster — I'll give you manual commands to run yourself
- Skip the cluster entirely (static analysis only, using code/docs/alert rules)
```

Wait for the user's answer before doing anything else in this step.

- If the user picks **obs-mcp**: check availability (e.g., `list_metrics`). Report whether it's connected, then proceed to step 5a or fall back to step 6 if not connected.
- If the user picks **oc directly**: check availability (`oc whoami`). If it fails in a sandboxed environment, that may be a permissions/network restriction rather than "no cluster" — ask the user whether to retry with expanded network permissions before concluding no cluster is reachable. Report the result, then proceed to step 5b or fall back to step 6 if not connected.
- If the user picks **manual commands** or **static analysis only**: skip straight to step 6 or step 7.

### 5. Live investigation (cluster access confirmed)

**Human-in-the-loop rule:** Never execute a cluster command or MCP query without showing it to the user first and getting explicit approval. Present the command, explain what it checks, and wait. This applies to every individual command — step 4 approval grants the *approach*, not blanket execution rights.

**a. Via obs-mcp** — present each query one at a time (or in a small logical batch), explain what it checks, and wait for approval before executing:

1. `CallMcpTool: user-obs-mcp / list_metrics` — verify connectivity
2. `ALERTS{alertstate="firing"}` filtered to suspected component — check for existing alerts
3. `up{namespace="openshift-monitoring", job="<component>"}` — is the target up?
4. `container_memory_working_set_bytes{...}` / `container_cpu_usage_seconds_total{...}` — resource usage

Component-specific queries: use expressions from the alert rules found in step 3. For OOM/high-memory issues, also propose cardinality checks:

- `prometheus_tsdb_head_series`
- `topk(10, count by (__name__)({__name__=~".+"}))`

**b. Via direct `oc` access** — present each command, explain its purpose, and wait for approval before running:

1. `oc get pods -n openshift-monitoring` — list pod status
2. `oc get pods -n openshift-user-workload-monitoring` — UWM pod status (if relevant)
3. `oc get events -n openshift-monitoring --sort-by='.lastTimestamp' | tail -20` — recent events
4. `oc logs -n openshift-monitoring <pod> -c <container> --tail=100` — component logs
5. `oc get configmap cluster-monitoring-config -n openshift-monitoring -o yaml` — platform config
6. `oc get configmap user-workload-monitoring-config -n openshift-user-workload-monitoring -o yaml` — UWM config
7. `oc adm top pods -n openshift-monitoring` — resource consumption

Adapt commands to the specific component and symptom (e.g., `oc get cronjob -A -o jsonpath=...` for the KSM CronJob timezone case). Always show the adapted command and wait for approval.

### 6. Manual investigation (no cluster access confirmed)

When the user chose not to grant cluster access, hand them the same commands from step 5 to run themselves:

- The `oc` commands above, adapted to the suspected component
- The PromQL queries from step 5a, formatted for the OCP console or `oc exec` into Prometheus

### 7. Analyze and correlate

Follow the troubleshooting methodology: **alerts → component → metrics → logs → configuration**

For each piece of evidence:

1. Note what it confirms or rules out
2. Build a causal chain: trigger → intermediate effect → observed symptom
3. Check for known issues in the component version (`jsonnet/versions.yaml`)
4. Check `projects/<component>` for existing fix branches or an existing `tasks/<task>/spec.md` covering this symptom — these are authoritative local context. Do not perform live external lookups (`gh pr list`, web search) to check upstream/fork PR status as a default step.

### 8. Produce structured diagnosis

Present findings in this format:

```
## Diagnosis: [Short title]

### Symptom
[What the user reported]

### Root Cause Hypothesis
[Most likely explanation, with confidence level: High/Medium/Low]

### Evidence
1. [Evidence point] — supports/contradicts hypothesis
2. [Evidence point] — supports/contradicts hypothesis

### Alternative Hypotheses
- [Other possible cause] — [why less likely]

### Recommended Fix
1. [Immediate remediation steps]
2. [Permanent fix if different from remediation]

### Verification
- [How to confirm the fix worked]

### Prevention
- [What would prevent recurrence — monitoring, alerts, config]
```

### 9. Optionally generate a fix spec

If the root cause points to a code or configuration change, offer to generate `tasks/<task>/spec.md` (or update the existing one) with:

- Problem statement derived from the diagnosis
- Acceptance criteria derived from the verification steps
- Related projects identified from the root cause
- References to the alert rules, metrics, and evidence gathered
