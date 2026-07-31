# 14 – Istio Base CRD Ownership Conflict

**Project:** CloudHustler Commerce Platform
**Phase:** Service Mesh (Istio)
**Category:** Terraform / Helm / Istio Base CRDs
**Severity:** High
**Status:** Resolved
**Date:** July 2026

---

# Incident Summary

During the deployment of the Istio service mesh for the CloudHustler Commerce Platform, Terraform failed while installing the **Istio Base** Helm chart.

Although the Kubernetes cluster was healthy and the Helm provider was correctly configured, Helm refused to install the chart because several Custom Resource Definitions (CRDs) already existed in the cluster and were owned by a different Helm release.

Since Helm requires exclusive ownership of its managed resources, the installation could not proceed until the ownership conflict was resolved.

---

# Impact

* Amazon EKS cluster remained healthy.
* Terraform successfully connected to Kubernetes.
* Istio Base installation failed.
* Istio CRDs could not be managed by Terraform.
* Istiod installation was blocked because the required CRDs were not under the expected Helm release.

---

# Symptoms

Terraform failed while deploying the Istio Base Helm release.

Example error:

```text
Error: rendered manifests contain a resource that already exists.

Unable to continue with install:
CustomResourceDefinition "trafficextensions.extensions.istio.io"
exists and cannot be imported into the current release.

invalid ownership metadata
```

A similar error occurred for the ServiceAccount:

```text
Error: ServiceAccount "istio-reader-service-account" already exists

invalid ownership metadata
```

---

# Investigation

The investigation focused on determining whether the issue originated from Terraform, Helm, Kubernetes, or a previous Istio installation.

## 1. Verified Cluster Health

The Kubernetes cluster was healthy.

```bash
kubectl get nodes
```

Validation confirmed:

* All worker nodes reported **Ready**.
* Kubernetes API was accessible.

This eliminated the cluster itself as the source of the problem.

---

## 2. Verified Existing Istio Resources

Existing Istio resources were inspected.

```bash
kubectl get crds | grep istio
```

Multiple Istio CRDs were already present in the cluster.

This confirmed Terraform was attempting to install resources that already existed.

---

## 3. Reviewed Helm Releases

The existing Helm releases were inspected.

```bash
helm list -A
```

The output revealed that an earlier Istio installation had already created the CRDs and associated resources.

These resources were owned by a different Helm release than the one Terraform was attempting to deploy.

---

## 4. Reviewed Helm Ownership Metadata

The CRDs were inspected.

```bash
kubectl describe crd trafficextensions.extensions.istio.io
```

The resource contained Helm ownership annotations similar to:

```text
meta.helm.sh/release-name
meta.helm.sh/release-namespace
```

These annotations referenced a different Helm release, preventing Terraform's Helm provider from adopting the existing resources.

---

# Root Cause

The Kubernetes cluster already contained Istio Base resources created by a previous Helm installation.

Because those resources were owned by another Helm release, Helm refused to transfer ownership to the new Terraform-managed release, resulting in an ownership conflict.

---

# Resolution

The conflicting Istio resources were removed so that Terraform could deploy a clean installation.

After removing the previous Helm release and its associated CRDs:

* Terraform successfully installed the Istio Base chart.
* Helm created the required CRDs under the correct release ownership.
* Subsequent Istiod deployment proceeded successfully.

---

# Validation

## Verify Helm Releases

```bash
helm list -A
```

Expected:

The Istio Base release appears only once.

---

## Verify CRDs

```bash
kubectl get crds | grep istio
```

Expected:

All required Istio CRDs are present.

---

## Verify Helm Ownership

```bash
kubectl describe crd trafficextensions.extensions.istio.io
```

Expected:

The Helm ownership annotations reference the Terraform-managed release.

---

## Verify Terraform

```bash
terraform apply
```

Expected:

The Istio Base Helm release deploys successfully without ownership conflicts.

---

# Lessons Learned

* Helm does not automatically adopt existing resources created by another release.
* CRDs retain Helm ownership metadata even after other components are removed.
* Existing Helm releases should always be reviewed before reinstalling software into a Kubernetes cluster.
* Clean ownership is essential for reliable Infrastructure-as-Code management.

---

# Prevention

To avoid similar issues in future deployments:

* Verify existing Helm releases before deploying Istio.
* Avoid mixing manual Helm installations with Terraform-managed deployments.
* Remove previous Helm releases completely before reinstalling the same application.
* Maintain Terraform as the single source of truth for Kubernetes package management.

---

# Key Takeaways

| Area                    | Result                                                 |
| ----------------------- | ------------------------------------------------------ |
| Root Cause              | Existing Istio CRDs owned by a different Helm release  |
| Failure Type            | Helm Resource Ownership Conflict                       |
| Kubernetes Cluster      | Healthy                                                |
| Terraform Configuration | Correct                                                |
| Resolution              | Remove conflicting Helm-managed resources and redeploy |
| Final Status            | Istio Base installed successfully                      |

---

# Interview Story (STAR Format)

## Situation

While deploying the Istio service mesh for the CloudHustler Commerce Platform, Terraform consistently failed during the Istio Base installation because Kubernetes already contained Istio CRDs created by a previous Helm release.

## Task

My responsibility was to determine why Helm refused to install the Istio Base chart, resolve the ownership conflict without introducing configuration drift, and restore a fully Terraform-managed Istio deployment.

## Action

I first confirmed the Kubernetes cluster was healthy, then inspected the existing Istio CRDs and Helm releases. This revealed that the CRDs already existed and were owned by a different Helm release through Helm ownership annotations. Because Helm cannot adopt resources owned by another release, I removed the conflicting resources and redeployed the Istio Base chart using Terraform, allowing Helm to recreate the CRDs under the correct ownership.

## Result

Terraform successfully installed the Istio Base chart, the CRDs were recreated with the correct Helm ownership metadata, and the remaining Istio components deployed successfully. The incident reinforced the importance of maintaining a single source of truth for Helm-managed resources and avoiding mixed manual and Infrastructure-as-Code deployments.
