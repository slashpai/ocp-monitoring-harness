# telemeter-client — Useful PromQL Queries

## Health

```promql
# telemeter-client pod health
up{job="telemeter-client", namespace="openshift-monitoring"}

# Check if telemeter-client is running
kube_deployment_status_replicas_available{namespace="openshift-monitoring", deployment="telemeter-client"}
```

## Telemetry Forwarding

```promql
# Total telemetry requests sent
metricsclient_request_send_total

# Failed telemetry requests
metricsclient_request_send_errors_total

# Error rate over 5 minutes
rate(metricsclient_request_send_errors_total[5m])
```

## Resource Usage

```promql
# Memory usage
container_memory_working_set_bytes{namespace="openshift-monitoring", pod=~"telemeter-client-.*", container!=""}

# CPU usage
rate(container_cpu_usage_seconds_total{namespace="openshift-monitoring", pod=~"telemeter-client-.*", container!=""}[5m])
```
