# 09 – Karpenter Spot Capacity / Service-Linked Role Failure

**Project:** CloudHustler Commerce Platform  
**Phase:** Platform Services (Karpenter)  
**Category:** Karpenter / EC2 Spot / AWS IAM  
**Severity:** Medium  
**Status:** Resolved  
**Date:** July 2026

---

# Incident Summary

After successfully deploying Karpenter and validating the EC2NodeClass and NodePool, the controller attempted to provision replacement worker nodes using Amazon EC2 Spot Instances.

Instead of launching a new node, Karpenter repeatedly failed due to a combination of insufficient Spot capacity and an AWS service-linked role permission issue.

The failure prevented Karpenter from provisioning replacement capacity, causing pending workloads to remain unscheduled.

---

# Environment

- Amazon EKS 1.33
- Terraform
- Karpenter v1.x
- EC2NodeClass
- NodePool
- Amazon EC2 Spot
- AWS IAM

---

# Symptoms

Karpenter generated provisioning failures similar to:

```text
UnfulfillableCapacity
```

followed by:

```text
AuthFailure.ServiceLinkedRoleCreationNotPermitted
```

No new worker nodes were launched even though the NodePool was healthy.

Pending workloads remained unscheduled.

---

# Impact

Because Karpenter could not provision Spot Instances:

- Pending workloads could not obtain compute capacity.
- Automatic scaling failed.
- Cluster elasticity was unavailable.
- Workloads depended entirely on the existing managed node group.

Although the Karpenter controller remained healthy, dynamic node provisioning was unsuccessful.

---

# Investigation

The investigation focused on determining whether the failure originated within Kubernetes or AWS.

The Karpenter controller was first verified.

```bash
kubectl get deployment -n kube-system karpenter
```

Result:

```text
READY   UP-TO-DATE   AVAILABLE

2/2     2            2
```

Next, the controller logs were reviewed.

```bash
kubectl logs -n kube-system deployment/karpenter
```

The logs consistently reported Spot provisioning failures.

AWS EC2 events indicated insufficient Spot capacity in the selected availability zones, followed by an authorization error when attempting to create the required EC2 Spot service-linked role.

---

# Root Cause

Two independent AWS conditions combined to prevent node provisioning.

First, AWS could not satisfy the requested Spot capacity.

```text
UnfulfillableCapacity
```

Second, AWS attempted to create the required EC2 Spot service-linked role automatically but the executing credentials did not have permission.

```text
AuthFailure.ServiceLinkedRoleCreationNotPermitted
```

Because no Spot capacity could be launched, Karpenter was unable to provision replacement worker nodes.

---

# Resolution

Rather than continuing to troubleshoot Spot capacity in the development environment, the NodePool configuration was modified to use On-Demand instances only.

Example requirement:

```yaml
requirements:
  - key: karpenter.sh/capacity-type
    operator: In
    values:
      - on-demand
```

Terraform was re-applied after updating the NodePool configuration.

With On-Demand capacity selected, Karpenter successfully provisioned worker nodes without requiring Spot capacity or automatic service-linked role creation.

---

# Validation

Verify the NodePool:

```bash
kubectl get nodepool
```

Verify Karpenter logs:

```bash
kubectl logs -n kube-system deployment/karpenter
```

No additional Spot provisioning errors should appear.

Verify nodes:

```bash
kubectl get nodes
```

Verify the launched instances:

```bash
aws ec2 describe-instances
```

Confirm that new worker nodes were successfully provisioned and joined the cluster.

---

# Lessons Learned

- Spot capacity is not guaranteed and can vary by region and Availability Zone.
- AWS automatically creates a service-linked role for EC2 Spot only when the caller has sufficient IAM permissions.
- A healthy Karpenter controller does not guarantee successful node provisioning.
- Development environments often benefit from using On-Demand instances to reduce operational complexity while validating platform functionality.

---

# Preventive Recommendations

- Use On-Demand capacity for development and testing environments.
- Enable Spot capacity only after validating Karpenter functionality.
- Ensure IAM permissions allow creation of required AWS service-linked roles when Spot Instances are planned.
- Monitor Karpenter controller logs for provisioning failures during autoscaling validation.

---

# Final Validation

✔ Terraform Apply: Successful

✔ NodePool Healthy

✔ EC2NodeClass Ready

✔ Karpenter Controller Running

✔ On-Demand Worker Nodes Successfully Provisioned

✔ Automatic Node Provisioning Validated