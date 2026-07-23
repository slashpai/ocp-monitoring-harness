---
name: mon-diagnostic
description: >-
  Diagnose bugs and issues in the OpenShift monitoring stack. Maps symptoms to
  components, queries metrics via obs-mcp when available, provides oc commands
  and PromQL for manual investigation when not. Follows the alerts-component-
  metrics-logs-config troubleshooting methodology. Use when the user says
  /mon:diagnostic or asks to diagnose a monitoring issue.
disable-model-invocation: true
---

# Monitoring Diagnostic

Structured bug diagnosis for the OpenShift monitoring stack.

## Input

Either a task folder name containing `spec.md` with a bug description, or an inline symptom description. **If a task name is given, validate:** must match `^[a-z0-9][a-z0-9-]*$` — reject names containing `/`, `..`, or special characters.

```
/mon:diagnostic <task-name>
/mon:diagnostic "kube-state-metrics pods crashing after 4.21 upgrade"
```

## Steps

### 1. Gather symptom details

**From spec:** Read `tasks/<task>/spec.md`, extract the symptom, affected component(s), cluster version, and any error messages.

**From inline:** Parse the symptom description. Ask for missing context:

- Cluster version (OCP x.y)
- When the issue started (upgrade, config change, new workload?)
- Affected namespace (`openshift-monitoring` or `openshift-user-workload-monitoring`?)
- Any error messages or pod states observed

### 2. Map symptoms to components

Use the symptom-component table to narrow scope:

| Symptom | Likely Components |
|---------|-------------------|
| Missing metrics | Prometheus, kube-state-metrics, node-exporter, scrape targets |
| Alerts not firing | Prometheus (rules), Alertmanager (routing/silences) |
| Alerts not delivered | Alertmanager (receivers, routes) |
| Console monitoring broken | monitoring-plugin, Thanos Querier |
| High memory / OOM | Prometheus (cardinality, retention), Thanos |
| Pod CrashLoopBackOff | Component-specific — check logs and resource limits |
| RBAC / auth errors | kube-rbac-proxy, prom-label-proxy |
| HPA not scaling | metrics-server |
| Query errors / slow queries | Thanos Querier, Prometheus |
| UWM metrics missing | UWM Prometheus, Thanos Ruler, prom-label-proxy |

Read `components/<component>/README.md` for each suspected component to understand its architecture and common failure modes.

### 3. Check alert rules

Read the relevant alert rules to understand what the monitoring stack itself checks:

```
projects/cluster-monitoring-operator/assets/<component>/prometheus-rule.yaml
```

Match the symptom against existing alerts. If an alert exists for this condition:

- Note the alert name, PromQL expression, and thresholds
- These expressions are maintained per release and are reliable starting points

### 4. Live investigation (obs-mcp available)

When the `user-obs-mcp` MCP server is connected, use it for live queries. Check connection by attempting a metric listing.

**Investigation sequence:**

a. **List relevant metrics:**

```
CallMcpTool: user-obs-mcp / list_metrics
```

b. **Check if alerts are firing:**

```
PromQL: ALERTS{alertstate="firing"}
```

Filter to the suspected component's namespace/job.

c. **Component health:**

```
PromQL: up{namespace="openshift-monitoring", job="<component>"}
```

d. **Resource pressure:**

```
PromQL: container_memory_working_set_bytes{namespace="openshift-monitoring", container="<component>"}
PromQL: container_cpu_usage_seconds_total{namespace="openshift-monitoring", container="<component>"}
```

e. **Component-specific queries** — use expressions from the alert rules found in step 3.

f. **Cardinality checks** (for OOM/high-memory issues):

```
PromQL: prometheus_tsdb_head_series
PromQL: topk(10, count by (__name__)({__name__=~".+"}))
```

### 5. Offline investigation (obs-mcp NOT available)

When obs-mcp is not connected, provide the user with commands to run manually.

**Cluster health commands:**

```bash
# Pod status
oc get pods -n openshift-monitoring
oc get pods -n openshift-user-workload-monitoring

# Recent events
oc get events -n openshift-monitoring --sort-by='.lastTimestamp' | tail -20

# Component logs
oc logs -n openshift-monitoring deployment/cluster-monitoring-operator --tail=100
oc logs -n openshift-monitoring prometheus-k8s-0 -c prometheus --tail=100
oc logs -n openshift-monitoring alertmanager-main-0 -c alertmanager --tail=100

# Configuration
oc get configmap cluster-monitoring-config -n openshift-monitoring -o yaml
oc get configmap user-workload-monitoring-config -n openshift-user-workload-monitoring -o yaml

# Resource usage
oc adm top pods -n openshift-monitoring
```

**PromQL queries to run in console:**

Provide the same queries from step 4, formatted for the user to paste into the OCP console or `oc exec` into Prometheus.

### 6. Analyze and correlate

Follow the troubleshooting methodology: **alerts → component → metrics → logs → configuration**

For each piece of evidence:

1. Note what it confirms or rules out
2. Build a causal chain: trigger → intermediate effect → observed symptom
3. Check for known issues in the component version (`jsonnet/versions.yaml`)

### 7. Produce structured diagnosis

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

### 8. Optionally generate a fix spec

If the root cause points to a code or configuration change, offer to generate `tasks/<task>/spec.md` (or update the existing one) with:

- Problem statement derived from the diagnosis
- Acceptance criteria derived from the verification steps
- Related projects identified from the root cause
- References to the alert rules, metrics, and evidence gathered
