# 17 – Multiple Istiod Deployments

**Project:** CloudHustler Commerce Platform
**Phase:** Service Mesh (Istio)
**Category:** Amazon EKS / Istio / Helm / Terraform
**Severity:** High
**Status:** Resolved
**Date:** July 2026

---

# Incident Summary

While migrating the Istio control plane to a Terraform-managed Helm deployment for the CloudHustler Commerce Platform, two separate **Istiod** deployments were discovered running simultaneously in the `istio-system` namespace.

The original Istiod deployment had been created by an earlier installation method, while Terraform successfully deployed a second Istiod instance using the Helm chart. Because the original deployment was never removed, both control planes were running concurrently.

Although the Kubernetes cluster remained operational, running multiple independent Istiod deployments introduced unnecessary complexity and the potential for conflicting control plane behavior. The objective was to identify which deployment was actively managing the mesh and safely remove the obsolete deployment.

---

# Impact

* Amazon EKS cluster remained healthy.
* Two Istiod deployments were running simultaneously.
* Kubernetes workloads continued operating.
* Operational complexity increased.
* Risk of configuration inconsistency and troubleshooting confusion.
* Terraform was not the sole source of truth for the Istio control plane.

---

# Symptoms

Listing the Istiod pods revealed multiple deployments.

```bash
kubectl get pods -n istio-system
```

Example output:

```text
NAME                              READY   STATUS    AGE
istiod-default-6bfb769b8c-bgswz   1/1     Running   15h
istiod-default-6bfb769b8c-mq8d7   1/1     Running   15h
istiod-f796647cf-s7qtf            1/1     Running   3m
```

Inspecting the deployments confirmed multiple control planes.

```bash
kubectl get deployments -n istio-system
```

Example:

```text
istiod-default
istiod
```

---

# Investigation

The investigation focused on determining why multiple Istiod deployments existed and identifying which deployment should remain.

## 1. Verified Cluster Health

The Kubernetes cluster was healthy.

```bash
kubectl get nodes
```

All worker nodes reported a **Ready** status.

This confirmed the issue was limited to the Istio control plane deployment.

---

## 2. Reviewed Istio Deployments

The deployments were inspected.

```bash
kubectl get deployments -n istio-system
```

The output showed two separate Istiod deployments managing the same service mesh.

---

## 3. Reviewed Helm Releases

The Helm releases were examined.

```bash
helm list -n istio-system
```

The Terraform-managed Helm release was present and healthy.

The remaining deployment was traced back to the earlier installation method and was no longer intended to manage the cluster.

---

## 4. Determined Active Management

The deployment history was reviewed to determine why both control planes existed.

It was confirmed that:

* The original Istiod deployment had been created before the migration to Terraform.
* Terraform successfully deployed a new Helm-managed Istiod deployment.
* The original deployment had never been removed after the migration.

This explained why duplicate control planes were running simultaneously.

---

# Root Cause

The Istio control plane was migrated from an earlier installation method to a Terraform-managed Helm deployment.

Although the new deployment succeeded, the previous Istiod deployment remained in the cluster because it was never decommissioned, resulting in two independent Istiod deployments running at the same time.

---

# Resolution

The Terraform-managed Helm deployment was selected as the authoritative control plane.

After confirming that the new deployment was healthy and serving the mesh, the legacy Istiod deployment was safely removed.

This restored a single, fully Terraform-managed Istio control plane.

---

# Validation

## Verify Deployments

```bash
kubectl get deployments -n istio-system
```

Expected:

```text
istiod
```

Only one Istiod deployment should remain.

---

## Verify Pods

```bash
kubectl get pods -n istio-system
```

Expected:

Only the pods belonging to the Terraform-managed deployment are running.

---

## Verify Helm Releases

```bash
helm list -n istio-system
```

Expected:

A single Istiod Helm release is present and reports **deployed**.

---

## Verify Terraform

```bash
terraform plan
```

Expected:

Terraform reports no unexpected infrastructure drift.

---

# Lessons Learned

* Only one Istio control plane should manage a Kubernetes cluster unless a deliberate multi-revision upgrade is being performed.
* Migrating from one deployment method to another requires decommissioning the previous installation.
* Mixing manual, operator-managed, and Terraform-managed deployments creates operational complexity.
* Terraform should remain the single source of truth for platform components.

---

# Prevention

To avoid similar issues in future deployments:

* Remove legacy Istio deployments after a successful migration.
* Verify existing Helm releases and Kubernetes deployments before installing replacement components.
* Perform post-migration validation to confirm only one control plane is active.
* Avoid managing the same application through multiple deployment tools.

---

# Key Takeaways

| Area                 | Result                                                                      |
| -------------------- | --------------------------------------------------------------------------- |
| Root Cause           | Legacy Istiod deployment remained after migrating to Terraform-managed Helm |
| Failure Type         | Duplicate Control Plane Deployment                                          |
| Amazon EKS Cluster   | Healthy                                                                     |
| Kubernetes Workloads | Healthy                                                                     |
| Resolution           | Remove the legacy deployment and retain the Terraform-managed control plane |
| Final Status         | Single Istiod deployment managed entirely by Terraform                      |

---

# Interview Story (STAR Format)

## Situation

While migrating the Istio service mesh for the CloudHustler Commerce Platform to a Terraform-managed Helm deployment, I discovered that two separate Istiod deployments were running simultaneously in the `istio-system` namespace. Although the cluster continued operating normally, having multiple control planes increased operational risk and complicated future maintenance.

## Task

My responsibility was to determine why duplicate Istiod deployments existed, identify which control plane was actively managing the service mesh, and safely eliminate the redundant deployment without disrupting cluster operations.

## Action

I verified the health of the Kubernetes cluster, reviewed the Istiod deployments, and inspected the Helm releases. This confirmed that the new Terraform-managed Helm deployment was healthy while the original deployment had been left behind from an earlier installation method. After validating that the new control plane was functioning correctly, I removed the obsolete deployment and confirmed that Terraform was once again the single source of truth for the Istio control plane.

## Result

The environment was simplified to a single Istiod deployment, operational complexity was reduced, and the entire Istio control plane became fully managed through Terraform. The incident reinforced the importance of cleaning up legacy resources after infrastructure migrations and maintaining a single deployment authority for critical platform components.
