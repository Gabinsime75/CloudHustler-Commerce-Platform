# 09 – Managed Node Group AMI Compatibility

**Project:** CloudHustler Commerce Platform
**Phase:** Container Platform (Amazon EKS)
**Category:** Amazon EKS / Managed Node Groups / AMI Compatibility
**Severity:** High
**Status:** Resolved
**Date:** July 2026

---

# Incident Summary

While deploying the Amazon EKS platform for the CloudHustler Commerce Platform, the Kubernetes control plane was created successfully, but Terraform failed when provisioning the managed node group.

Amazon EKS rejected the worker node configuration because the deployment attempted to use the **Amazon Linux 2 (AL2)** AMI with a **Kubernetes 1.33** cluster. Since Kubernetes 1.33 no longer supports AL2 for new managed node groups, AWS prevented the node group from being created.

The issue prevented worker nodes from joining the cluster until the managed node group configuration was updated to use Amazon Linux 2023 (AL2023).

---

# Impact

* Amazon EKS control plane deployed successfully.
* Managed node group creation failed.
* No worker nodes joined the cluster.
* Kubernetes workloads could not be scheduled.
* Deployment of platform services was blocked.

---

# Symptoms

Terraform failed while creating the managed node group with the following error:

```text
Error: creating EKS Node Group:

InvalidParameterException:
AMI Type AL2_x86_64 is only supported for Kubernetes versions 1.32 or earlier.
```

Although the control plane reported an **ACTIVE** status, the cluster contained no compute nodes.

---

# Investigation

The investigation focused on determining whether the issue originated from Terraform, Amazon EKS, or the managed node group configuration.

## 1. Verified the EKS Control Plane

The first step was confirming that the control plane had deployed successfully.

```bash
aws eks describe-cluster \
  --name cloudhusller-commerce-platform-dev-eks
```

Validation confirmed:

* Cluster status was **ACTIVE**
* Kubernetes API endpoint was available
* OIDC provider was configured correctly

This isolated the problem to the managed node group.

---

## 2. Verified the Kubernetes Version

The cluster version was inspected.

```bash
aws eks describe-cluster \
  --name cloudhusller-commerce-platform-dev-eks \
  --query "cluster.version"
```

Expected output:

```text
"1.33"
```

This indicated that compatibility between the Kubernetes version and the selected AMI should be reviewed.

---

## 3. Reviewed the Managed Node Group Configuration

The Terraform configuration specified the following AMI type:

```hcl
ami_type = "AL2_x86_64"
```

While this configuration was valid for earlier Kubernetes releases, it is no longer supported for managed node groups running Kubernetes 1.33.

---

## 4. Confirmed AWS Compatibility Requirements

The Amazon EKS documentation confirmed:

* Amazon Linux 2 is supported only through Kubernetes 1.32.
* Kubernetes 1.33 requires Amazon Linux 2023 (AL2023) for new managed node groups.
* Existing AL2 node groups may continue operating on supported cluster versions, but new deployments must use AL2023.

---

# Root Cause

The managed node group was configured with an unsupported **Amazon Linux 2 (AL2)** AMI while targeting an Amazon EKS Kubernetes 1.33 cluster.

Amazon EKS rejected the deployment because AL2 is no longer supported for newly created managed node groups running Kubernetes 1.33.

---

# Resolution

The managed node group configuration was updated to use the supported Amazon Linux 2023 AMI.

```hcl
ami_type = "AL2023_x86_64_STANDARD"
```

After updating the configuration:

* Terraform successfully created the managed node group.
* Worker nodes registered with the cluster.
* Kubernetes workloads could be scheduled successfully.
* Platform service deployment resumed.

---

# Validation

## Verify the Kubernetes Version

```bash
aws eks describe-cluster \
  --name cloudhusller-commerce-platform-dev-eks \
  --query "cluster.version"
```

Expected:

```text
"1.33"
```

---

## Verify the Managed Node Group

```bash
aws eks list-nodegroups \
  --cluster-name cloudhusller-commerce-platform-dev-eks
```

Expected:

```text
cloudhusller-commerce-platform-dev-eks-system
```

---

## Verify Worker Nodes

```bash
kubectl get nodes -o wide
```

Expected:

* Worker nodes report **Ready**
* Amazon Linux 2023 instances are registered with the cluster

---

## Verify Terraform State

```bash
terraform state list
```

Expected resource:

```text
module.eks.aws_eks_node_group.this["system"]
```

---

# Lessons Learned

* Kubernetes upgrades often introduce infrastructure compatibility changes.
* Operating system compatibility should always be reviewed before upgrading EKS.
* AWS release notes should be part of every Kubernetes upgrade planning process.
* Validating platform prerequisites early prevents unnecessary troubleshooting later in the deployment.

---

# Prevention

To reduce the likelihood of similar issues:

* Review Amazon EKS release notes before upgrading Kubernetes versions.
* Use Amazon Linux 2023 for all new Kubernetes 1.33 and later managed node groups.
* Validate supported AMI types during Terraform code reviews.
* Test Kubernetes version upgrades in development before promoting them to higher environments.

---

# Key Takeaways

| Area                     | Result                                             |
| ------------------------ | -------------------------------------------------- |
| Root Cause               | Unsupported Amazon Linux 2 AMI for Kubernetes 1.33 |
| Failure Type             | Version Compatibility                              |
| Terraform Configuration  | Required AMI update                                |
| Amazon EKS Control Plane | Healthy                                            |
| Resolution               | Migrated managed node group to Amazon Linux 2023   |
| Final Status             | Managed node group deployed successfully           |

---

# Interview Story (STAR Format)

## Situation

While deploying the Amazon EKS platform for the CloudHustler Commerce Platform, the Kubernetes control plane deployed successfully, but the managed node group failed to provision. Without worker nodes, the cluster could not run any workloads.

## Task

My responsibility was to determine why Amazon EKS rejected the managed node group, restore a functional Kubernetes cluster, and ensure the deployment followed AWS best practices for Kubernetes 1.33.

## Action

I first verified that the EKS control plane was healthy and confirmed the cluster was running Kubernetes 1.33. I then reviewed the managed node group configuration and found it was configured to use the Amazon Linux 2 AMI. After consulting the Amazon EKS compatibility documentation, I confirmed that Kubernetes 1.33 requires Amazon Linux 2023 for new managed node groups. I updated the Terraform configuration to use the AL2023 AMI and redeployed the node group.

## Result

The managed node group was created successfully, worker nodes joined the cluster, and Kubernetes became fully operational. The experience reinforced the importance of validating operating system compatibility whenever upgrading Kubernetes versions and reviewing AWS release notes before implementing new platform releases.
