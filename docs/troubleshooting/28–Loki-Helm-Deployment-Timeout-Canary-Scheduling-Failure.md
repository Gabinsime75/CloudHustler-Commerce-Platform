# 25 – Loki Helm Deployment Timeout (Canary Scheduling Failure)

**Project:** CloudHustler Commerce Platform  
**Phase:** Platform Services (Observability)  
**Category:** Grafana Loki / Helm / Kubernetes Scheduling  
**Severity:** Medium  
**Status:** Resolved  
**Date:** August 2026

---

# Incident Summary

During deployment of Grafana Loki using the official Helm chart, Terraform failed with a `context deadline exceeded` error after waiting for the Helm release to become healthy.

Although Terraform marked the deployment as failed, most Loki components were successfully deployed and operational.

---

# Symptoms

Terraform apply failed with:

```text
Error: Helm release error

context deadline exceeded
```

Helm reported:

```text
STATUS: failed
```

However, inspection showed:

- Loki StatefulSet running
- Loki Gateway running
- Persistent Volume successfully bound
- ServiceMonitor created

Only the Loki Canary DaemonSet remained partially deployed.

---

# Investigation

The Helm release was inspected:

```bash
helm status loki -n logging
```

The deployment showed:

```text
loki-0                 Running
loki-gateway           Running
loki-canary            2/4 Ready
```

Additional validation confirmed:

```bash
kubectl get pods -n logging
kubectl get pvc,pv -n logging
kubectl get daemonset -n logging
```

The persistent volume was healthy and Loki itself was fully operational.

The only failing component was the optional Loki Canary DaemonSet.

---

# Root Cause

The Loki Canary deploys one pod per Kubernetes node.

Two canary pods could not be scheduled because of cluster scheduling constraints, preventing the DaemonSet from reaching the desired number of ready pods before the Helm timeout expired.

Since Helm waits for all enabled components to become healthy, the release timed out even though the core Loki deployment was functioning correctly.

---

# Resolution

The optional Loki Canary workload was disabled in the Helm values:

```hcl
loki_canary_enabled = false
```

The existing Helm release was imported into Terraform state and updated rather than being recreated.

Terraform then performed an in-place Helm upgrade.

---

# Validation

Verified successful deployment using:

```bash
terraform apply

helm list -n logging

kubectl get pods -n logging

kubectl get daemonset -n logging

kubectl get pvc -n logging
```

Results:

- Helm release status changed to **deployed**
- Loki StatefulSet healthy
- Loki Gateway healthy
- Persistent storage bound
- ServiceMonitor active
- Terraform state synchronized

---

# Lessons Learned

- A Helm release can report **failed** even when the primary application is healthy.
- Optional validation workloads (such as Loki Canary) can prevent Helm from completing successfully.
- Always inspect the individual Kubernetes resources before assuming the application deployment itself has failed.
- For development environments, disabling Loki Canary reduces resource consumption while simplifying deployment.
```