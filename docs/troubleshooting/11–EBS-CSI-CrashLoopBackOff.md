# 11 – EBS CSI CrashLoopBackOff

**Project:** CloudHustler Commerce Platform
**Phase:** Container Platform (Amazon EKS)
**Category:** Amazon EKS / Amazon EBS CSI Driver / Kubernetes
**Severity:** High
**Status:** Resolved
**Date:** July 2026

---

# Incident Summary

During deployment of the Amazon EKS platform for the CloudHustler Commerce Platform, the Amazon EBS CSI Driver add-on entered a **CrashLoopBackOff** state shortly after installation.

Although the managed add-on had been created successfully, the CSI controller pods repeatedly crashed and restarted, preventing the driver from becoming healthy. As a result, Terraform was unable to complete the deployment because the add-on never transitioned to the **ACTIVE** state.

Without a functioning Amazon EBS CSI Driver, Kubernetes could not dynamically provision Persistent Volumes (PVs), preventing stateful workloads from using Amazon EBS storage.

---

# Impact

* Amazon EKS cluster remained operational.
* Worker nodes were healthy.
* Amazon EBS CSI Driver controller pods continuously restarted.
* Dynamic Persistent Volume provisioning failed.
* Stateful Kubernetes workloads could not be deployed.
* Terraform deployment timed out waiting for the add-on to become active.

---

# Symptoms

Terraform eventually failed with a timeout while waiting for the managed add-on.

Example:

```text
Error: waiting for EBS CSI Driver add-on to become ACTIVE:

context deadline exceeded
```

The add-on status reported:

```bash
aws eks describe-addon \
  --cluster-name cloudhusller-commerce-platform-dev-eks \
  --addon-name aws-ebs-csi-driver
```

Example output:

```text
Status: DEGRADED
```

Inspecting the Kubernetes pods revealed:

```bash
kubectl get pods -n kube-system
```

Example:

```text
ebs-csi-controller-xxxxxxxxxx    CrashLoopBackOff
```

---

# Investigation

The investigation focused on determining whether the failures originated from Terraform, the managed add-on, or Kubernetes.

## 1. Verified Cluster Health

The EKS cluster itself was healthy.

Validation:

```bash
aws eks describe-cluster \
  --name cloudhusller-commerce-platform-dev-eks
```

Result:

* Cluster status: **ACTIVE**
* Worker nodes: **Ready**
* Kubernetes API reachable

This confirmed the issue was isolated to the CSI Driver.

---

## 2. Verified Add-on Status

The managed add-on status was inspected.

```bash
aws eks describe-addon \
  --cluster-name cloudhusller-commerce-platform-dev-eks \
  --addon-name aws-ebs-csi-driver
```

Result:

```text
Status: DEGRADED
```

This indicated the AWS resource existed, but Kubernetes components were unhealthy.

---

## 3. Inspected Controller Pods

The controller deployment was reviewed.

```bash
kubectl get pods -n kube-system
```

Multiple controller pods were repeatedly restarting.

This confirmed Kubernetes was unable to keep the CSI controller running.

---

## 4. Reviewed Controller Logs

The controller logs were examined.

```bash
kubectl logs -n kube-system <ebs-csi-controller-pod>
```

The logs showed repeated startup failures, causing Kubernetes to restart the containers continuously.

Because the controller never stabilized, Amazon EKS could not mark the managed add-on as **ACTIVE**.

---

# Root Cause

The Amazon EBS CSI Driver controller pods repeatedly crashed during startup, causing a **CrashLoopBackOff** condition.

Since the controller deployment never became healthy, the managed add-on remained in the **DEGRADED** state and Terraform eventually timed out waiting for the installation to complete.

---

# Resolution

The underlying controller startup issue was resolved, allowing the CSI controller pods to initialize successfully.

Once the controller pods stabilized:

* CrashLoopBackOff stopped.
* Controller replicas became healthy.
* Amazon EKS marked the add-on as **ACTIVE**.
* Terraform completed successfully.
* Dynamic Amazon EBS volume provisioning became available.

---

# Validation

## Verify Add-on Status

```bash
aws eks describe-addon \
  --cluster-name cloudhusller-commerce-platform-dev-eks \
  --addon-name aws-ebs-csi-driver
```

Expected:

```text
Status: ACTIVE
```

---

## Verify Controller Pods

```bash
kubectl get pods -n kube-system
```

Expected:

* All EBS CSI Driver pods are **Running**.
* No pods report **CrashLoopBackOff**.

---

## Verify CSI Driver

```bash
kubectl get csidrivers
```

Expected:

```text
ebs.csi.aws.com
```

---

## Verify Storage Class

```bash
kubectl get storageclass
```

Expected:

```text
gp3 (default)
```

---

## Verify Terraform State

```bash
terraform state list
```

Expected resource:

```text
module.eks.aws_eks_addon.ebs_csi[0]
```

---

# Lessons Learned

* A managed add-on can exist in AWS while its Kubernetes components remain unhealthy.
* CrashLoopBackOff errors should always be investigated from the Kubernetes layer rather than Terraform alone.
* Reviewing pod logs is often the fastest way to identify why a managed add-on cannot become healthy.
* Terraform timeout errors frequently indicate an underlying Kubernetes issue rather than an Infrastructure-as-Code problem.

---

# Prevention

To reduce similar issues in future deployments:

* Validate managed add-on health immediately after installation.
* Monitor Kubernetes pods for restart loops during add-on deployment.
* Review controller logs whenever an add-on reports a **DEGRADED** status.
* Verify the add-on reaches the **ACTIVE** state before deploying stateful applications.

---

# Key Takeaways

| Area                    | Result                                                    |
| ----------------------- | --------------------------------------------------------- |
| Root Cause              | EBS CSI controller pods entered CrashLoopBackOff          |
| Failure Type            | Kubernetes Controller Failure                             |
| Terraform Configuration | Correct                                                   |
| Amazon EKS Cluster      | Healthy                                                   |
| Resolution              | Restored controller health until the add-on became ACTIVE |
| Final Status            | Amazon EBS CSI Driver fully operational                   |

---

# Interview Story (STAR Format)

## Situation

While deploying the CloudHustler Commerce Platform on Amazon EKS, the Amazon EBS CSI Driver managed add-on failed to initialize because the controller pods repeatedly entered a CrashLoopBackOff state. Without the storage driver, Kubernetes could not dynamically provision persistent volumes for stateful workloads.

## Task

My responsibility was to identify why the controller pods were crashing, restore the managed add-on to a healthy state, and complete the infrastructure deployment without introducing manual configuration drift.

## Action

I first verified that the Amazon EKS cluster and worker nodes were healthy, confirming the issue was isolated to the storage driver. I then inspected the managed add-on status, reviewed the controller pod health, and analyzed the pod logs to identify the repeated startup failures. After resolving the controller issue, I monitored the deployment until all controller replicas became healthy and the managed add-on transitioned to the **ACTIVE** state.

## Result

The controller pods stabilized, the CrashLoopBackOff condition was eliminated, Terraform completed successfully, and Kubernetes regained the ability to dynamically provision Amazon EBS volumes for stateful workloads. The incident reinforced the importance of combining AWS managed add-on diagnostics with Kubernetes pod-level troubleshooting when deploying Amazon EKS.
