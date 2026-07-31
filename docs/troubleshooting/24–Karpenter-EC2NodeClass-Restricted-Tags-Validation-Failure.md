# 07 – Karpenter EC2NodeClass Restricted Tags Validation Failure

**Project:** CloudHustler Commerce Platform  
**Phase:** Platform Services (Karpenter)  
**Category:** Karpenter / EC2NodeClass / Terraform  
**Severity:** High  
**Status:** Resolved  
**Date:** July 2026

---

# Incident Summary

After successfully deploying the Karpenter controller, Terraform failed while creating the default EC2NodeClass resource.

Although all AWS infrastructure and Karpenter controller components were healthy, Kubernetes rejected the EC2NodeClass during validation, preventing Karpenter from provisioning worker nodes.

---

# Environment

- Amazon EKS 1.33
- Terraform
- Karpenter v1.x
- EC2NodeClass
- NodePool
- Amazon EC2
- AWS VPC

---

# Symptoms

Terraform failed while applying the Kubernetes manifest.

Error:

```text
Error: EC2NodeClass.karpenter.k8s.aws "default" is invalid
```

Validation message:

```text
spec.tags contains restricted tag matching:

kubernetes.io/cluster/*
```

The EC2NodeClass was not created successfully.

---

# Impact

Because the EC2NodeClass could not be created:

- No valid infrastructure template existed for Karpenter.
- The NodePool could not become Ready.
- Karpenter was unable to launch worker nodes.
- Automatic cluster scaling was unavailable.

Although the controller deployment was healthy, node provisioning was completely blocked.

---

# Investigation

The controller was verified first.

```bash
kubectl get deployment -n kube-system karpenter
```

Result:

```text
READY   UP-TO-DATE   AVAILABLE

2/2     2            2
```

The EC2NodeClass status was then inspected.

```bash
kubectl get ec2nodeclass
```

The resource either failed to create or immediately entered an invalid state.

The Terraform configuration was reviewed to inspect the tags being assigned to EC2 instances.

One of the configured tags matched:

```text
kubernetes.io/cluster/<cluster-name>
```

---

# Root Cause

The EC2NodeClass included Kubernetes-owned cluster tags within the `spec.tags` section.

Beginning with Karpenter v1.x, several tag prefixes are reserved and cannot be specified by users.

These include:

```text
kubernetes.io/cluster/*
```

Karpenter automatically manages these tags internally.

Attempting to define them manually causes Kubernetes validation to reject the entire resource.

---

# Resolution

The restricted Kubernetes cluster tags were removed from the EC2NodeClass configuration.

Only application-specific tags remained.

Infrastructure discovery continued to use:

```text
karpenter.sh/discovery=<cluster-name>
```

on:

- Private application subnets
- Worker node security group

No Kubernetes-managed tags were defined inside the EC2NodeClass.

Terraform was then re-applied successfully.

---

# Validation

Verify the EC2NodeClass:

```bash
kubectl get ec2nodeclass
```

Describe the resource:

```bash
kubectl describe ec2nodeclass default
```

Verify readiness:

```bash
kubectl get ec2nodeclass
```

Expected output:

```text
NAME      READY

default   True
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

---

# Lessons Learned

- Karpenter reserves several Kubernetes tag prefixes.
- Kubernetes-managed tags should never be configured inside an EC2NodeClass.
- Infrastructure discovery relies on the `karpenter.sh/discovery` tag rather than Kubernetes cluster ownership tags.
- Validation errors should always be reviewed carefully before assuming an AWS infrastructure problem.

---

# Preventive Recommendations

- Never include `kubernetes.io/cluster/*` tags inside an EC2NodeClass.
- Use only supported custom tags for launched EC2 instances.
- Apply discovery tags only to subnets and security groups.
- Validate EC2NodeClass resources immediately after deployment before creating NodePools.

---

# Final Validation

✔ Terraform Apply: Successful

✔ EC2NodeClass Created

✔ EC2NodeClass Ready

✔ NodePool Healthy

✔ Karpenter able to provision worker nodes successfully.