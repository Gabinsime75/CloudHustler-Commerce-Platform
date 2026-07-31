# 06 – Karpenter IAM Policy Size Limit Exceeded

**Project:** CloudHustler Commerce Platform  
**Phase:** Platform Services (Karpenter)  
**Category:** AWS IAM / Terraform / Karpenter  
**Severity:** High  
**Status:** Resolved  
**Date:** July 2026

---

# Incident Summary

During the deployment of Karpenter, Terraform successfully created most AWS resources but failed while provisioning the IAM policy for the Karpenter controller.

The deployment consistently stopped during the creation of the controller policy, preventing the Karpenter controller from being deployed into the Amazon EKS cluster.

---

# Environment

- AWS EKS 1.33
- Terraform
- Karpenter
- AWS IAM
- Amazon EventBridge
- Amazon SQS
- EKS Pod Identity

---

# Symptoms

Terraform failed during deployment with the following error:

```text
Error: creating IAM Policy (cloudhusller-commerce-platform-dev-karpenter-controller):

LimitExceeded: Cannot exceed quota for PolicySize: 6144
```

Terraform stopped before the Helm release for Karpenter could be installed.

---

# Impact

Because the IAM policy could not be created:

- The Karpenter controller IAM role remained incomplete.
- Pod Identity could not be configured.
- The Karpenter Helm chart could not deploy successfully.
- Automatic node provisioning was unavailable.

The remainder of the Platform Services deployment was blocked.

---

# Investigation

The first step was verifying that the failure was isolated to IAM rather than Kubernetes.

The following checks were performed:

- Reviewed the Terraform execution plan.
- Confirmed the EKS cluster was healthy.
- Verified the Pod Identity configuration.
- Reviewed the generated IAM policy.
- Compared the generated policy against AWS IAM service limits.

Terraform consistently failed before any Kubernetes resources were created, indicating the problem originated entirely within AWS IAM.

---

# Root Cause

The Terraform AWS Karpenter module generated a controller IAM policy that exceeded AWS's maximum managed policy size of **6,144 characters**.

AWS therefore rejected the policy during creation.

The failure was not caused by:

- Terraform syntax
- Kubernetes
- Helm
- Pod Identity
- IAM permissions

The generated policy itself exceeded the AWS managed policy size limit.

---

# Resolution

Rather than creating a large managed IAM policy, the deployment was modified to use an inline policy attached directly to the controller IAM role.

Terraform configuration:

```hcl
enable_controller_inline_policy = true
```

This prevented Terraform from creating an oversized managed IAM policy while preserving the required permissions.

After updating the configuration, Terraform successfully created:

- Controller IAM Role
- Inline Controller Policy
- Pod Identity Association

The Karpenter Helm deployment then completed successfully.

---

# Validation

Terraform completed without IAM errors.

Controller resources were verified:

```bash
terraform apply
```

Verify IAM role:

```bash
aws iam get-role \
  --role-name cloudhusller-commerce-platform-dev-karpenter-controller-role
```

Verify Karpenter deployment:

```bash
kubectl get deployment -n kube-system karpenter
```

Expected output:

```text
READY   UP-TO-DATE   AVAILABLE

2/2     2            2
```

Verify controller pods:

```bash
kubectl get pods -n kube-system \
-l app.kubernetes.io/name=karpenter
```

Expected output:

```text
2/2 Running
```

---

# Lessons Learned

- AWS IAM managed policies have a hard size limit of 6 KB.
- Modern Karpenter deployments often require large permission sets that can exceed this limit.
- Inline IAM policies eliminate the managed policy size restriction while maintaining identical functionality.
- Terraform failures occurring before Helm deployment should always be investigated from the AWS infrastructure layer first.

---

# Preventive Recommendations

- Prefer inline controller policies when deploying Karpenter with Terraform.
- Validate IAM policy size before deployment.
- Keep Terraform AWS modules up to date, as newer releases frequently optimize generated IAM policies.
- Separate AWS infrastructure failures from Kubernetes deployment failures during troubleshooting.

---

# Final Validation

✔ Terraform Apply: Successful

✔ Controller IAM Role Created

✔ Inline Policy Attached

✔ Pod Identity Association Created

✔ Karpenter Controller Running

✔ Automatic node provisioning successfully enabled.