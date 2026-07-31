# 08 – Karpenter EC2NodeClass Discovery (NotReady)

**Project:** CloudHustler Commerce Platform  
**Phase:** Platform Services (Karpenter)  
**Category:** Karpenter / EC2NodeClass / Infrastructure Discovery  
**Severity:** High  
**Status:** Resolved  
**Date:** July 2026

---

# Incident Summary

Following the successful deployment of the Karpenter controller and EC2NodeClass, the EC2NodeClass failed to become ready.

Although Terraform completed successfully and the Kubernetes resources existed, Karpenter was unable to discover the required AWS infrastructure. As a result, the EC2NodeClass remained in a **NotReady** state, preventing NodePools from provisioning new worker nodes.

---

# Environment

- Amazon EKS 1.33
- Terraform
- Karpenter v1.x
- EC2NodeClass
- NodePool
- Amazon EC2
- Amazon VPC

---

# Symptoms

The EC2NodeClass was successfully created but reported:

```text
READY   False
```

Checking the resource showed:

```bash
kubectl get ec2nodeclass
```

Output:

```text
NAME      READY

default   False
```

The NodePool also remained unavailable because no valid infrastructure configuration could be resolved.

---

# Impact

Because the EC2NodeClass was not ready:

- Karpenter could not discover eligible subnets.
- Security groups could not be resolved.
- NodePools could not launch EC2 instances.
- Automatic node provisioning was unavailable.

The Karpenter controller remained healthy, but cluster autoscaling was non-functional.

---

# Investigation

The first step was verifying that the controller itself was healthy.

```bash
kubectl get deployment -n kube-system karpenter
```

Result:

```text
READY   UP-TO-DATE   AVAILABLE

2/2     2            2
```

Next, the EC2NodeClass was inspected.

```bash
kubectl describe ec2nodeclass default
```

The resource indicated that infrastructure discovery had failed.

Attention then shifted to the discovery selectors defined in the EC2NodeClass.

The subnet and security group selectors relied on the following discovery tag:

```text
karpenter.sh/discovery=cloudhusller-commerce-platform-dev-eks
```

AWS resources were inspected to verify the presence of this tag.

---

# Root Cause

The required Karpenter discovery tag was missing or incorrectly configured on one or more AWS resources.

Because Karpenter discovers infrastructure dynamically using AWS resource tags, it was unable to locate:

- Private application subnets
- Worker node security group

Without these resources, the EC2NodeClass could not transition to the Ready state.

---

# Resolution

The required discovery tag was applied consistently to the infrastructure resources used by Karpenter.

Private application subnets:

```text
karpenter.sh/discovery=cloudhusller-commerce-platform-dev-eks
```

Worker node security group:

```text
karpenter.sh/discovery=cloudhusller-commerce-platform-dev-eks
```

Terraform was re-applied to update the infrastructure.

Once the discovery tags were present, Karpenter immediately detected the resources and the EC2NodeClass transitioned to the Ready state.

---

# Validation

Verify the EC2NodeClass:

```bash
kubectl get ec2nodeclass
```

Expected output:

```text
NAME      READY

default   True
```

Describe the resource:

```bash
kubectl describe ec2nodeclass default
```

Verify the NodePool:

```bash
kubectl get nodepool
```

Expected output:

```text
READY

True
```

Verify subnet discovery:

```bash
aws ec2 describe-subnets \
  --filters "Name=tag:karpenter.sh/discovery,Values=cloudhusller-commerce-platform-dev-eks"
```

Verify security group discovery:

```bash
aws ec2 describe-security-groups \
  --filters "Name=tag:karpenter.sh/discovery,Values=cloudhusller-commerce-platform-dev-eks"
```

---

# Lessons Learned

- Karpenter discovers AWS infrastructure entirely through resource tags.
- An EC2NodeClass can exist while remaining unusable if discovery fails.
- The Karpenter controller should always be validated separately from the EC2NodeClass.
- Incorrect or missing discovery tags are one of the most common causes of EC2NodeClass readiness failures.

---

# Preventive Recommendations

- Standardize discovery tags across all Karpenter-managed infrastructure.
- Apply discovery tags through Terraform rather than manually.
- Validate subnet and security group tags before deploying the EC2NodeClass.
- Include EC2NodeClass readiness checks in all Karpenter deployment validation procedures.

---

# Final Validation

✔ Terraform Apply: Successful

✔ Discovery Tags Applied

✔ EC2NodeClass Ready

✔ NodePool Ready

✔ Karpenter successfully discovered AWS infrastructure

✔ Automatic node provisioning fully operational