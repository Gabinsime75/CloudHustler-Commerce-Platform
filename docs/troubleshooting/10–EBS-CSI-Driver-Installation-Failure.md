# 10 – EBS CSI Driver Installation Failure

**Project:** CloudHustler Commerce Platform
**Phase:** Container Platform (Amazon EKS)
**Category:** Amazon EKS / EBS CSI Driver / Terraform
**Severity:** High
**Status:** Resolved
**Date:** July 2026

---

# Incident Summary

During the deployment of the Amazon EKS platform for the CloudHustler Commerce Platform, Terraform failed while installing the Amazon EBS CSI Driver managed add-on.

Although the EKS cluster and managed node group deployed successfully, the EBS CSI Driver remained in a failed state and Terraform eventually timed out waiting for the add-on to become active.

Without the EBS CSI Driver, Kubernetes could not dynamically provision Amazon EBS volumes, preventing stateful workloads from using Persistent Volumes (PVs) and Persistent Volume Claims (PVCs).

---

# Impact

* Amazon EKS cluster deployed successfully.
* Managed node group was operational.
* Amazon EBS CSI Driver installation failed.
* Dynamic volume provisioning was unavailable.
* Stateful Kubernetes workloads could not be deployed.
* Terraform deployment could not complete successfully.

---

# Symptoms

Terraform eventually failed while waiting for the add-on to become active.

Example error:

```text
Error: waiting for EBS CSI Driver add-on to become ACTIVE:

context deadline exceeded
```

Checking the add-on status showed:

```bash
aws eks describe-addon \
  --cluster-name cloudhusller-commerce-platform-dev-eks \
  --addon-name aws-ebs-csi-driver
```

Result:

```text
Status: DEGRADED
```

Further inspection revealed insufficient healthy CSI controller replicas.

---

# Investigation

The investigation focused on determining whether the issue originated from Terraform, Amazon EKS, or the Kubernetes deployment.

## 1. Verified the EKS Cluster

The cluster was confirmed to be healthy.

```bash
aws eks describe-cluster \
  --name cloudhusller-commerce-platform-dev-eks
```

Validation confirmed:

* Cluster status was **ACTIVE**
* Worker nodes were **Ready**
* Kubernetes API was accessible

This isolated the issue to the EBS CSI Driver add-on.

---

## 2. Verified Add-on Status

The add-on status was inspected.

```bash
aws eks describe-addon \
  --cluster-name cloudhusller-commerce-platform-dev-eks \
  --addon-name aws-ebs-csi-driver
```

Result:

```text
Status: DEGRADED
```

The add-on was installed but unable to become healthy.

---

## 3. Investigated Kubernetes Pods

The CSI Driver pods were inspected.

```bash
kubectl get pods -n kube-system
```

Several controller pods were not reaching the **Running** state.

Further investigation showed the controller deployment did not have enough healthy replicas to satisfy the managed add-on health requirements.

---

## 4. Reviewed Controller Logs

Controller logs and deployment status indicated that the add-on was repeatedly attempting to start but could not achieve the minimum number of healthy replicas.

Amazon EKS therefore kept the add-on in a degraded state, causing Terraform to continue waiting until the operation timed out.

---

# Root Cause

The Amazon EBS CSI Driver could not reach the required number of healthy controller replicas.

Because the managed add-on never transitioned to the **ACTIVE** state, Terraform eventually exceeded its timeout while waiting for the deployment to complete.

---

# Resolution

The underlying health issue affecting the CSI controller deployment was resolved, allowing the controller pods to become healthy.

Once the required replicas were available:

* The add-on status changed to **ACTIVE**.
* Terraform completed successfully.
* Kubernetes regained the ability to dynamically provision Amazon EBS volumes.

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

## Verify CSI Pods

```bash
kubectl get pods -n kube-system
```

Expected:

* All EBS CSI Driver pods report **Running**.
* All controller pods are **Ready**.

---

## Verify Storage Classes

```bash
kubectl get storageclass
```

Expected:

```text
gp3 (default)
```

---

## Verify Dynamic Volume Provisioning

```bash
kubectl get csidrivers
```

Expected:

```text
ebs.csi.aws.com
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

* A successful add-on installation depends on the Kubernetes deployment becoming healthy, not just the AWS API accepting the request.
* Terraform timeouts often indicate an underlying Kubernetes health issue rather than a Terraform configuration problem.
* Managed add-ons should always be validated from both the AWS and Kubernetes perspectives.
* Reviewing pod health is an essential part of troubleshooting Amazon EKS managed add-ons.

---

# Prevention

To reduce similar issues in future deployments:

* Verify worker nodes are healthy before installing managed add-ons.
* Monitor add-on health using both the AWS CLI and Kubernetes.
* Inspect controller pods whenever an add-on remains in the **DEGRADED** state.
* Validate add-on status before deploying workloads that depend on persistent storage.

---

# Key Takeaways

| Area                    | Result                                                    |
| ----------------------- | --------------------------------------------------------- |
| Root Cause              | EBS CSI Driver controller failed to reach a healthy state |
| Failure Type            | Amazon EKS Managed Add-on Health                          |
| Terraform Configuration | Correct                                                   |
| Kubernetes Cluster      | Healthy                                                   |
| Resolution              | Restored controller health until the add-on became ACTIVE |
| Final Status            | Amazon EBS CSI Driver installed successfully              |

---

# Interview Story (STAR Format)

## Situation

While deploying the Amazon EKS platform for the CloudHustler Commerce Platform, the EBS CSI Driver managed add-on failed to become active. Although the cluster and worker nodes were healthy, Terraform timed out waiting for the storage driver to finish installing.

## Task

My responsibility was to identify why the managed add-on remained in a degraded state, restore dynamic storage provisioning, and complete the infrastructure deployment without introducing manual configuration drift.

## Action

I first confirmed that the EKS cluster and worker nodes were healthy, then inspected the managed add-on status using the AWS CLI. After confirming the add-on was stuck in a **DEGRADED** state, I investigated the Kubernetes controller pods and verified they had not reached the required healthy replica count. Once the controller deployment became healthy, I confirmed that the add-on transitioned to the **ACTIVE** state and Terraform completed successfully.

## Result

The EBS CSI Driver became fully operational, dynamic Amazon EBS volume provisioning was restored, and the platform could successfully deploy stateful Kubernetes workloads. The incident reinforced the importance of validating both AWS managed add-on status and Kubernetes pod health when troubleshooting EKS deployments.
