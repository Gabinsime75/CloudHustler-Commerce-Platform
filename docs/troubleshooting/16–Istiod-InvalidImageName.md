# 16 – Istiod InvalidImageName

**Project:** CloudHustler Commerce Platform
**Phase:** Service Mesh (Istio)
**Category:** Terraform / Helm / Istiod Deployment
**Severity:** High
**Status:** Resolved
**Date:** July 2026

---

# Incident Summary

During the deployment of the Istio control plane for the CloudHustler Commerce Platform, the **Istiod** deployment failed to start after Terraform successfully installed the Helm release.

Although Kubernetes successfully created the deployment and scheduled the pods, every Istiod pod immediately failed with an **InvalidImageName** error. As a result, the Istio control plane never became available, causing the Helm release to remain in a pending state until Terraform eventually timed out.

The issue was traced to empty image override values that caused Helm to render an invalid container image reference.

---

# Impact

* Amazon EKS cluster remained healthy.
* Istio Base installed successfully.
* Istiod deployment failed.
* No control plane was available.
* Sidecar injection was unavailable.
* Service discovery, traffic management, mTLS, and telemetry could not function.
* Terraform deployment timed out.

---

# Symptoms

Terraform eventually failed while waiting for the Helm release.

Example:

```text id="v8s2wn"
Error: release istiod failed

context deadline exceeded
```

Inspecting the Istiod pods showed:

```bash id="ylbdy6"
kubectl get pods -n istio-system
```

Example output:

```text id="b6n2d6"
istiod-xxxxxxxxxx    InvalidImageName
```

Viewing the pod events revealed:

```bash id="7v86f8"
kubectl describe pod <istiod-pod> -n istio-system
```

Example event:

```text id="k9g3br"
Failed to apply default image tag "/pilot:"

invalid reference format
```

---

# Investigation

The investigation focused on determining whether the issue originated from Amazon EKS, Kubernetes, Helm, or the Istio configuration.

## 1. Verified Cluster Health

The Amazon EKS cluster was healthy.

```bash id="txibif"
kubectl get nodes
```

Validation confirmed:

* Worker nodes were **Ready**.
* Kubernetes scheduling was functioning correctly.

This eliminated cluster health as the cause.

---

## 2. Verified Pod Scheduling

The Istiod pods were successfully scheduled.

```bash id="dhb3pd"
kubectl get pods -n istio-system -o wide
```

The pods were assigned to worker nodes, confirming that compute resources were available.

This ruled out CPU, memory, and scheduling issues.

---

## 3. Reviewed Pod Events

The pod events were inspected.

```bash id="g7ppc0"
kubectl describe pod <istiod-pod> -n istio-system
```

The events consistently reported:

```text id="5a7gk9"
Failed to apply default image tag "/pilot:"

invalid reference format
```

This indicated Kubernetes could not construct a valid container image name.

---

## 4. Reviewed Helm Values

The Terraform Helm values were inspected.

The deployment defined optional image override variables similar to:

```yaml id="mwnlj8"
global:
  hub: ""
  tag: ""
```

Because both values were empty, Helm rendered the image as:

```text id="4g9u3x"
/pilot:
```

This is not a valid OCI image reference, causing Kubernetes to reject the container before it could start.

---

# Root Cause

The Terraform configuration supplied empty values for the optional Istio image overrides (`global.hub` and `global.tag`).

Helm interpreted these empty strings as explicit values and generated the invalid image reference:

```text id="qmdh98"
/pilot:
```

Since the image name was invalid, Kubernetes immediately rejected every Istiod container with the **InvalidImageName** error.

---

# Resolution

The empty image override values were removed from the Helm configuration.

Rather than explicitly setting empty values, the deployment allowed Istio to use its default image repository and version.

After removing the empty overrides and redeploying:

* Helm rendered a valid image reference.
* Istiod pods started successfully.
* The Helm release completed.
* Terraform finished successfully.
* The Istio control plane became operational.

---

# Validation

## Verify Istiod Pods

```bash id="jhmkji"
kubectl get pods -n istio-system
```

Expected:

All Istiod pods report:

```text id="qgpf0m"
Running
```

---

## Verify Deployment

```bash id="9t6ux8"
kubectl get deployment -n istio-system
```

Expected:

```text id="3vhmdj"
istiod

AVAILABLE: 1+
```

---

## Verify Helm Release

```bash id="l5npww"
helm list -n istio-system
```

Expected:

The Istiod release reports **deployed**.

---

## Verify Terraform

```bash id="5ajy4q"
terraform apply
```

Expected:

Terraform completes without timeout or Helm errors.

---

# Lessons Learned

* Empty configuration values can be just as dangerous as incorrect values.
* Optional Helm values should be omitted entirely when they are not required.
* Kubernetes pod events often provide the fastest path to identifying container image problems.
* An **InvalidImageName** error usually indicates a configuration issue rather than a Kubernetes infrastructure problem.

---

# Prevention

To reduce similar issues in future deployments:

* Do not set optional Helm image values unless customization is required.
* Validate rendered Helm manifests before deployment.
* Review Kubernetes events whenever containers fail before startup.
* Prefer Helm defaults over empty override values.

---

# Key Takeaways

| Area                  | Result                                                                                      |
| --------------------- | ------------------------------------------------------------------------------------------- |
| Root Cause            | Empty `global.hub` and `global.tag` values generated an invalid image reference (`/pilot:`) |
| Failure Type          | Helm Configuration Error                                                                    |
| Amazon EKS Cluster    | Healthy                                                                                     |
| Kubernetes Scheduling | Healthy                                                                                     |
| Resolution            | Remove empty image overrides and use the default Istio image values                         |
| Final Status          | Istiod deployed successfully and the Istio control plane became operational                 |

---

# Interview Story (STAR Format)

## Situation

While deploying the Istio control plane for the CloudHustler Commerce Platform, the Helm release installed successfully, but every Istiod pod immediately failed with an **InvalidImageName** error. Because the control plane never started, Terraform eventually timed out waiting for the deployment to complete.

## Task

My responsibility was to determine whether the failure was caused by Kubernetes, Amazon EKS, or the Helm configuration, restore the Istio control plane, and complete the deployment without introducing manual changes.

## Action

I first verified that the Amazon EKS cluster and worker nodes were healthy, then confirmed the Istiod pods were successfully scheduled, eliminating infrastructure and scheduling issues. Next, I reviewed the pod events and discovered Kubernetes was attempting to pull an invalid image named `/pilot:`. I inspected the Helm values and found that the optional `global.hub` and `global.tag` variables had been set to empty strings, causing Helm to render an invalid image reference. I removed the empty overrides, allowed Istio to use its default image settings, and redeployed the release.

## Result

The Istiod pods started successfully, the Helm release completed, Terraform finished without errors, and the Istio control plane became fully operational. The incident reinforced the importance of omitting optional Helm values when they are not required and demonstrated how Kubernetes events can quickly identify configuration-related container startup failures.
