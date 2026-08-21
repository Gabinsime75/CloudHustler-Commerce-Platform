# 26 – OpenTelemetry Collector Deployment Failures

**Project:** CloudHustler Commerce Platform  
**Phase:** Platform Services (Observability)  
**Category:** OpenTelemetry Collector / Helm / Kubernetes / Terraform  
**Severity:** High  
**Status:** Resolved  
**Date:** August 2026

---

# Incident Summary

During deployment of the OpenTelemetry Collector through Terraform and Helm, several independent configuration errors prevented the Collector from reaching a healthy state.

The Helm release was created, but the Deployment repeatedly failed or timed out because Kubernetes rejected invalid port names and the Collector rejected unsupported or outdated configuration fields.

The deployment was ultimately completed after correcting the Helm values, cleaning stale failed releases, and updating the Collector configuration for version `0.157.0`.

---

# Environment

- Amazon EKS
- Terraform
- Helm
- OpenTelemetry Collector Helm chart `0.166.0`
- OpenTelemetry Collector Contrib `0.157.0`
- Prometheus Operator
- Kubernetes Deployment mode
- Namespace: `observability`

---

# Error 1 – Kubernetes Port Name Too Long

## Symptom

Terraform failed with:

```text
Deployment.apps "opentelemetry-collector" is invalid:

spec.template.spec.containers[0].ports[6].name:
Invalid value: "prometheus-exporter":
must be no more than 15 characters
```

## Root Cause

Kubernetes container port names are limited to 15 characters.

The configured port name:

```hcl
"prometheus-exporter"
```

exceeded that limit.

## Resolution

The port name was shortened:

```hcl
prometheus = {
  enabled       = true
  containerPort = var.prometheus_exporter_port
  servicePort   = var.prometheus_exporter_port
  protocol      = "TCP"
}
```

Any ServiceMonitor reference was also updated to use:

```hcl
port = "prometheus"
```

---

# Error 2 – Helm Release Name Already in Use

## Symptom

A subsequent Terraform apply failed with:

```text
cannot re-use a name that is still in use
```

## Root Cause

The previous failed Helm installation remained recorded in the cluster because the module used:

```hcl
atomic          = false
cleanup_on_fail = false
```

These settings intentionally preserved failed resources for troubleshooting, but the failed Helm release blocked Terraform from creating a new release with the same name.

## Resolution

The failed release was removed:

```bash
helm uninstall opentelemetry-collector -n observability
```

Verification:

```bash
helm list -n observability
```

The `observability` namespace remained because Terraform managed it separately.

---

# Error 3 – Helm Context Deadline Exceeded

## Symptom

Terraform failed with:

```text
context deadline exceeded
```

Helm reported:

```text
STATUS: failed
```

The Collector Deployment remained:

```text
READY   0/1
```

The pod entered:

```text
CrashLoopBackOff
```

## Root Cause

Helm waited for the Collector Deployment to become Ready, but the Collector process exited during startup because its configuration was invalid.

The timeout was a secondary symptom. The actual cause was visible in the pod logs.

## Investigation

```bash
kubectl get pods -n observability -o wide

kubectl describe pod \
  -n observability \
  -l app.kubernetes.io/instance=opentelemetry-collector

kubectl logs \
  -n observability \
  deployment/opentelemetry-collector \
  --tail=100
```

---

# Error 4 – Obsolete `service.telemetry.metrics.address`

## Symptom

Collector logs showed:

```text
failed to get config:
cannot unmarshal the configuration

'service.telemetry.metrics' decoding failed

'migration.MetricsConfigV030' has invalid keys: address
```

## Root Cause

The configuration used:

```hcl
service = {
  telemetry = {
    metrics = {
      level   = "normal"
      address = "0.0.0.0:8888"
    }
  }
}
```

The `address` field is no longer supported under `service.telemetry.metrics` in Collector version `0.157.0`.

The Collector rejected the entire configuration and exited with code `1`.

## Resolution

The unsupported field was removed:

```hcl
service = {
  telemetry = {
    logs = {
      level = var.collector_log_level
    }

    metrics = {}
  }
}
```

Collector application metrics continued to be exposed through the configured Prometheus exporter on port `8889`.

---

# Error 5 – Deprecated `k8sattributes` Processor Name

## Symptom

Helm displayed warnings:

```text
Processor 'k8sattributes' has been renamed to 'k8s_attributes'
```

The pipelines were automatically rewritten, but the chart warned that this compatibility behavior would be removed in a future release.

## Root Cause

The configuration used the older processor name:

```hcl
k8sattributes = {
  ...
}
```

and referenced it in the pipelines as:

```hcl
"k8sattributes"
```

## Resolution

The processor was renamed:

```hcl
k8s_attributes = {
  ...
}
```

Pipeline references were updated:

```hcl
processors = [
  "memory_limiter",
  "k8s_attributes",
  "resource",
  "batch"
]
```

This removed the deprecation warning and aligned the configuration with the current Collector schema.

---

# Error 6 – Unsupported `container.name` Metadata Field

## Symptom

Collector logs showed:

```text
invalid configuration:

processors::k8s_attributes:
"container.name" is not a supported metadata field
```

## Root Cause

The Kubernetes attributes processor was configured to extract:

```hcl
metadata = [
  "k8s.namespace.name",
  "k8s.pod.name",
  "k8s.pod.uid",
  "k8s.deployment.name",
  "k8s.statefulset.name",
  "k8s.daemonset.name",
  "k8s.node.name",
  "container.name"
]
```

The `k8s_attributes` processor in Collector version `0.157.0` did not support `container.name` in the metadata extraction list.

Because Collector configuration validation is strict, one unsupported field caused the entire process to exit.

## Resolution

The unsupported field was removed:

```hcl
metadata = [
  "k8s.namespace.name",
  "k8s.pod.name",
  "k8s.pod.uid",
  "k8s.deployment.name",
  "k8s.statefulset.name",
  "k8s.daemonset.name",
  "k8s.node.name"
]
```

The remaining metadata still provides the Kubernetes context required for metrics and traces.

---

# Final Resolution

After correcting all configuration errors, the failed Helm release was removed and Terraform was reapplied:

```bash
helm uninstall opentelemetry-collector -n observability

terraform fmt -recursive
terraform validate
terraform apply --auto-approve
```

Terraform completed successfully:

```text
Apply complete!

Resources: 1 added, 0 changed, 0 destroyed.
```

The final release status was:

```text
opentelemetry_release_status = "deployed"
```

---

# Final Configuration

The Collector was successfully deployed with:

```text
Deployment mode: Deployment
Replicas: 1
OTLP gRPC: 4317
OTLP HTTP: 4318
Prometheus exporter: 8889
Health endpoint: 13133
zPages: 55679
Trace exporter: debug
AWS X-Ray: disabled
```

---

# Validation Commands

Verify Helm:

```bash
helm list -n observability
```

Verify the Deployment:

```bash
kubectl get deployment -n observability
```

Verify the pod:

```bash
kubectl get pods -n observability -o wide
```

Verify the Service:

```bash
kubectl get svc -n observability
```

Verify the ServiceMonitor:

```bash
kubectl get servicemonitor -n observability
```

Check Collector logs:

```bash
kubectl logs \
  -n observability \
  deployment/opentelemetry-collector \
  --tail=100
```

Verify health:

```bash
kubectl port-forward \
  -n observability \
  service/opentelemetry-collector \
  13133:13133
```

```bash
curl http://localhost:13133/
```

Verify Prometheus metrics:

```bash
kubectl port-forward \
  -n observability \
  service/opentelemetry-collector \
  8889:8889
```

```bash
curl http://localhost:8889/metrics
```

---

# Lessons Learned

- Kubernetes port names must not exceed 15 characters.
- A Helm timeout usually reflects an unhealthy workload rather than a Helm-specific problem.
- Collector configuration validation is strict; one unsupported field prevents startup.
- OpenTelemetry configuration fields can change between Collector versions.
- Helm chart and Collector image versions should be validated together.
- Always inspect pod logs before changing Kubernetes scheduling, resources, or Helm timeouts.
- `atomic = false` and `cleanup_on_fail = false` are useful during troubleshooting but may leave stale failed releases.
- Deprecated processor names should be updated before compatibility rewrites are removed.

---

# Preventive Recommendations

- Pin both the Helm chart and Collector image versions.
- Compare the Collector configuration with the release-specific schema before deployment.
- Render Helm values before applying:

```bash
helm template \
  opentelemetry-collector \
  open-telemetry/opentelemetry-collector \
  --version 0.166.0 \
  -n observability
```

- Validate all container port names against Kubernetes naming limits.
- Keep OpenTelemetry processor and exporter names current.
- Add Collector configuration validation to CI.
- Monitor `CrashLoopBackOff`, failed exports, dropped telemetry, and receiver errors.
- Keep zPages and health endpoints internal.
- Enable AWS X-Ray only after the base Collector deployment is healthy.

---

# Final Validation

✔ Helm release deployed

✔ Collector Deployment healthy

✔ OTLP gRPC endpoint available

✔ OTLP HTTP endpoint available

✔ Prometheus exporter available

✔ Health endpoint available

✔ zPages enabled

✔ Kubernetes metadata enrichment configured

✔ Terraform state synchronized

✔ Phase 6 observability implementation resumed