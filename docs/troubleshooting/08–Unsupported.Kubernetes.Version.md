# 08 – Unsupported Kubernetes Version

**Project:** CloudHustler Commerce Platform  
**Phase:** Container Platform (Amazon EKS)  
**Category:** Amazon EKS / Terraform / Managed Node Groups  
**Severity:** High  
**Status:** Resolved  
**Date:** July 2026

---

# Incident Summary

During deployment of the Amazon EKS cluster for the CloudHustler Commerce Platform, Terraform successfully created the control plane but failed while provisioning the managed node group.

The deployment failed because the node group was configured to use the **Amazon Linux 2 (AL2)** Amazon Machine Image (AMI) while the EKS cluster was running **Kubernetes version 1.33**.

Beginning with Kubernetes 1.33, Amazon EKS no longer supports AL2 as the default managed node group operating system. As a result, AWS rejected the node group creation request.

---

# Impact

- EKS control plane deployed successfully.
- Managed node group creation failed.
- Worker nodes were not registered with the cluster.
- Kubernetes workloads could not be scheduled.
- Terraform deployment stopped before the platform became operational.

---

# Symptoms

Terraform failed while creating the managed node group.

Example error:

```text
Error: creating EKS Node Group:

InvalidParameterException:
AMI Type AL2_x86_64 is only supported for Kubernetes versions 1.32 or earlier.
```

The EKS cluster itself remained active, but no worker nodes joined the cluster.

---

# Investigation

The troubleshooting process focused on determining whether the issue originated from Terraform, Amazon EKS, or the managed node group configuration.

## 1. Verified EKS Cluster

The control plane deployed successfully.

Validation:

```bash
aws eks describe-cluster \
  --name cloudhusller-commerce-platform-dev-eks
```

Result:

- Cluster status: **ACTIVE**
- Endpoint available
- OIDC provider configured

This confirmed the issue was isolated to the worker nodes.

---

## 2. Verified Kubernetes Version

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

This immediately suggested a compatibility issue with the selected node AMI.

---

## 3. Reviewed Managed Node Group Configuration

The Terraform configuration specified:

```hcl
ami_type = "AL2_x86_64"
```

Although this configuration worked for previous EKS versions, AWS no longer supports AL2 for managed node groups running Kubernetes 1.33.

---

## 4. Reviewed AWS Documentation

AWS documentation confirmed:

- Amazon Linux 2 support ends with Kubernetes 1.32.
- Kubernetes 1.33 managed node groups should use Amazon Linux 2023 (AL2023).
- Existing AL2 node groups can continue operating on supported versions, but new 1.33 deployments must use AL2023.

---

# Root Cause

The managed node group was configured to use the deprecated **Amazon Linux 2 (AL2)** AMI while the EKS control plane was running Kubernetes 1.33.

AWS rejected the request because AL2 is only supported through Kubernetes version 1.32.

---

# Resolution

The managed node group configuration was updated to use the supported Amazon Linux 2023 AMI.

Example:

```hcl
ami_type = "AL2023_x86_64_STANDARD"
```

After updating the configuration:

- Terraform successfully created the managed node group.
- Worker nodes joined the cluster.
- Kubernetes became ready to host workloads.

---

# Validation

## Verify Cluster Version

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

## Verify Node Group

```bash
aws eks list-nodegroups \
  --cluster-name cloudhusller-commerce-platform-dev-eks
```

Expected:

```text
cloudhusller-commerce-platform-dev-eks-system
```

---

## Verify Kubernetes Nodes

```bash
kubectl get nodes -o wide
```

Expected:

- Nodes in **Ready** state.
- Amazon Linux 2023 worker nodes registered.

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

- Kubernetes upgrades can introduce operating system compatibility changes.
- Always verify Amazon EKS release notes before selecting a Kubernetes version.
- Managed node group AMIs should be reviewed whenever upgrading the control plane.
- Compatibility issues can occur even when the Terraform configuration is otherwise correct.

---

# Prevention

To prevent similar issues in future deployments:

- Review Amazon EKS release notes before upgrading Kubernetes.
- Use Amazon Linux 2023 for new Kubernetes 1.33+ managed node groups.
- Validate supported AMI types during Terraform code reviews.
- Test cluster upgrades in development before promoting to production.

---

# Key Takeaways

| Area | Result |
|-------|--------|
| Root Cause | Unsupported AL2 AMI for Kubernetes 1.33 |
| Failure Type | Version Compatibility |
| Terraform Configuration | Correct except for AMI selection |
| EKS Control Plane | Healthy |
| Resolution | Migrate managed node group to Amazon Linux 2023 |
| Final Status | Node group deployed successfully |

---

# Interview Story (STAR Format)

## Situation

While deploying the Amazon EKS platform for the CloudHustler Commerce Platform, Terraform successfully provisioned the Kubernetes control plane but failed while creating the managed node group. Without worker nodes, the cluster could not run any workloads.

## Task

My responsibility was to determine why the node group deployment failed, restore a fully operational Kubernetes cluster, and ensure the solution aligned with AWS best practices for Kubernetes 1.33.

## Action

I first confirmed that the EKS control plane was healthy by checking the cluster status and Kubernetes version. I then reviewed the Terraform configuration for the managed node group and identified that it was configured to use the **Amazon Linux 2 (AL2)** AMI. After reviewing the Amazon EKS documentation, I confirmed that AL2 is only supported through Kubernetes version 1.32 and that Kubernetes 1.33 requires Amazon Linux 2023 for new managed node groups. I updated the Terraform configuration to use the **AL2023_x86_64_STANDARD** AMI and redeployed the node group.

## Result

The managed node group was successfully created, the worker nodes joined the cluster, and Kubernetes became fully operational. The incident reinforced the importance of validating operating system compatibility whenever upgrading Kubernetes versions and highlighted the value of reviewing AWS release notes before introducing new platform versions.