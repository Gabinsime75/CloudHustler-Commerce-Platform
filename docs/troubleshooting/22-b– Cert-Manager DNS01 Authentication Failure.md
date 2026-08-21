# 22 – Cert-Manager DNS01 Authentication Failure

**Project:** CloudHustler Commerce Platform  
**Phase:** Platform Services  
**Category:** Cert-Manager / Amazon EKS Pod Identity / Route53 / Let's Encrypt  
**Severity:** High  
**Status:** Resolved  
**Date:** July 2026

---

# Incident Summary

During the implementation of Cert-Manager on the CloudHustler Commerce Platform, certificate issuance using the Let's Encrypt DNS01 challenge failed.

The goal was to authenticate Cert-Manager to AWS using Amazon EKS Pod Identity so it could automatically create temporary DNS TXT records in Amazon Route53 during ACME validation.

Although the Kubernetes infrastructure, IAM configuration, and Cert-Manager installation appeared healthy, certificate issuance never completed because the Cert-Manager controller could not authenticate with AWS.

---

# Environment

- **Platform:** CloudHustler Commerce Platform
- **Kubernetes Platform:** Amazon EKS
- **Authentication:** Amazon EKS Pod Identity
- **Certificate Manager:** Cert-Manager
- **Certificate Authority:** Let's Encrypt (Staging)
- **Challenge Type:** DNS01
- **DNS Provider:** Amazon Route53
- **AWS Region:** us-east-2

---

# Initial Symptoms

The Certificate resource was successfully created.

However:

- Certificate remained:

```text
READY=False
```

- The TLS Secret was never created.

The Challenge resource reported:

```text
failed to determine Route53 hosted zone ID
failed to refresh cached credentials
no EC2 IMDS role found
```

At first glance, the error appeared to indicate one of the following:

- Missing IAM permissions
- Incorrect IAM trust relationship
- Route53 configuration problem
- Pod Identity configuration issue

---

# Initial Troubleshooting Hypotheses

The following possible causes were investigated:

1. IAM policy missing Route53 permissions
2. Incorrect IAM trust policy
3. Missing Pod Identity Association
4. Incorrect Cert-Manager ServiceAccount
5. Route53 Hosted Zone configuration
6. ClusterIssuer configuration
7. DNS01 solver configuration
8. Amazon EKS Pod Identity Agent failure
9. AWS SDK credential retrieval issue

Each possibility was validated individually.

---

# Investigation Timeline

## Step 1 — Verify ClusterIssuer

```bash
kubectl describe clusterissuer letsencrypt-staging
```

Result:

```text
Ready=True
Reason=ACMEAccountRegistered
```

**Conclusion**

The ClusterIssuer was healthy and successfully registered with Let's Encrypt.

---

## Step 2 — Verify CertificateRequest

```bash
kubectl get certificaterequest
```

Result:

```text
Approved=True
Ready=True
```

**Conclusion**

Cert-Manager successfully communicated with the ACME server.

---

## Step 3 — Verify Order

```bash
kubectl get order
```

Result:

```text
STATE=Valid
```

**Conclusion**

Communication with Let's Encrypt was functioning correctly.

---

## Step 4 — Verify ServiceAccount

```bash
kubectl get serviceaccount cert-manager -n cert-manager
```

Result:

```text
cert-manager
```

**Conclusion**

The ServiceAccount matched the Terraform configuration.

---

## Step 5 — Verify Pod Identity Association

```bash
aws eks list-pod-identity-associations
```

Result:

Association existed for:

- Namespace: cert-manager
- ServiceAccount: cert-manager

**Conclusion**

The Pod Identity Association had been created successfully.

---

## Step 6 — Verify Pod Identity Agent

```bash
kubectl get pods -n kube-system | grep pod-identity
```

Result:

```text
Running
```

**Conclusion**

The Amazon EKS Pod Identity Agent was healthy.

---

## Step 7 — Verify EKS Pod Identity Add-on

```bash
aws eks describe-addon \
  --addon-name eks-pod-identity-agent
```

Result:

```text
Status = ACTIVE
```

**Conclusion**

The EKS Pod Identity add-on was operating normally.

---

## Step 8 — Verify IAM Trust Policy

```bash
aws iam get-role
```

Result:

```text
Principal:
pods.eks.amazonaws.com
```

**Conclusion**

The IAM trust relationship was configured correctly.

---

## Step 9 — Compare with External Secrets Operator

Since External Secrets Operator was already working with Amazon EKS Pod Identity, it became the reference implementation.

The External Secrets pod contained:

- `AWS_CONTAINER_CREDENTIALS_FULL_URI`
- `AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE`
- `eks-pod-identity-token` projected volume

The Cert-Manager controller pod contained only:

```text
POD_NAMESPACE
```

The following components were completely missing:

- `AWS_CONTAINER_CREDENTIALS_FULL_URI`
- `AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE`
- `eks-pod-identity-token`

This became the turning point of the investigation.

---

# Root Cause Analysis

At this point it became clear that Cert-Manager itself was not the problem.

Instead, the Cert-Manager controller pod had **never been mutated by the Amazon EKS Pod Identity admission webhook.**

Because no AWS credentials were injected into the pod, the AWS SDK attempted its normal credential provider chain.

Eventually the SDK attempted EC2 Instance Metadata Service (IMDS), resulting in:

```text
no EC2 IMDS role found
```

The error message was misleading.

The issue was **not IAM permissions.**

The issue was **the complete absence of injected AWS credentials.**

---

# How the Root Cause Was Discovered

The breakthrough came from comparing a healthy workload with the failing workload.

## External Secrets

Contained:

- Pod Identity token
- AWS credential environment variables
- Injected credential volume

## Cert-Manager

Contained none of the above.

This immediately shifted the investigation away from IAM permissions and toward Pod Identity credential injection.

---

# Why the Pod Was Not Mutated

Further investigation revealed that the original Cert-Manager controller pod had been created **before** the Pod Identity Association existed.

Deployment timeline:

```text
Cert-Manager Deployment
          │
          ▼
Controller Pod Created
          │
          ▼
Pod Identity Association Created
```

Because admission webhooks execute **only during pod creation**, the already-running pod never received AWS credentials.

Amazon EKS does not retroactively mutate existing pods after a Pod Identity Association is created.

---

# Failed Troubleshooting Attempts

The following components were verified and found to be functioning correctly:

## IAM Policy

Verified.

No changes required.

---

## IAM Trust Policy

Verified.

Correct service principal:

```text
pods.eks.amazonaws.com
```

---

## ClusterIssuer

Healthy.

Successfully registered with Let's Encrypt.

---

## Route53

Hosted Zone configuration was correct.

---

## DNS01 Solver

Correct configuration.

---

## Pod Identity Agent

Healthy.

Running normally.

---

## EKS Pod Identity Add-on

```text
ACTIVE
```

No issues reported.

---

# Resolution

The Cert-Manager Deployment was restarted.

```bash
kubectl rollout restart deployment cert-manager -n cert-manager
```

A new controller pod was created.

This time:

- Pod Identity Association already existed.
- Admission webhook injected AWS credentials.
- AWS SDK successfully authenticated to Route53.

The new pod now contained:

- `AWS_CONTAINER_CREDENTIALS_FULL_URI`
- `AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE`
- `eks-pod-identity-token`

It also contained the expected label:

```text
eks.amazonaws.com/pod-identity=enabled
```

---

# Validation

After restarting the deployment:

Certificate:

```text
READY=True
```

CertificateRequest:

```text
READY=True
```

Order:

```text
STATE=Valid
```

TLS Secret:

```text
kubernetes.io/tls
```

Certificate issuance completed successfully.

---

# Permanent Improvement

To eliminate this race condition, infrastructure components should always be deployed in the following order:

1. Kubernetes Namespace
2. Kubernetes ServiceAccount
3. IAM Role
4. IAM Policy Attachment
5. Amazon EKS Pod Identity Association
6. Helm Release (Cert-Manager)

This guarantees every Cert-Manager pod receives AWS credentials immediately when it is created.

---

# Alternative Implementation

A more deterministic deployment strategy is to manage the ServiceAccount with Terraform instead of Helm.

Recommended approach:

- Terraform creates the Namespace.
- Terraform creates the ServiceAccount.
- Terraform creates the IAM Role.
- Terraform creates the Pod Identity Association.
- Helm installs Cert-Manager using the existing ServiceAccount.

```yaml
serviceAccount.create=false
```

Advantages:

- Deterministic deployment order
- No race conditions
- Cleaner separation of infrastructure and applications
- Easier lifecycle management
- Better compatibility with Amazon EKS Pod Identity

---

# Lessons Learned

1. The error **"no EC2 IMDS role found"** does not necessarily indicate an IAM permission issue.
2. When troubleshooting Amazon EKS Pod Identity, always verify that the pod contains:
   - `AWS_CONTAINER_CREDENTIALS_FULL_URI`
   - `AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE`
   - `eks-pod-identity-token`
3. Comparing a working workload with a failing workload can significantly reduce troubleshooting time.
4. Existing pods are **not automatically updated** after a Pod Identity Association is created.
5. Restarting a Deployment forces Kubernetes to create new pods, allowing the Pod Identity admission webhook to inject credentials.
6. Before modifying IAM policies, verify that AWS credentials are actually being injected into the pod.

---

# Final Architecture

```text
Let's Encrypt
      │
      ▼
DNS01 Challenge
      │
      ▼
Amazon Route53
      ▲
      │
AWS SDK
      ▲
      │
IAM Role (Pod Identity)
      ▲
      │
Amazon EKS Pod Identity
      ▲
      │
Cert-Manager Controller
      ▲
      │
Kubernetes ServiceAccount
      ▲
      │
Amazon EKS Cluster
```

---

# Resolution Summary

**Issue**

Cert-Manager failed to authenticate with Amazon Route53 during Let's Encrypt DNS01 certificate issuance.

**Root Cause**

The original Cert-Manager controller pod was created before the Amazon EKS Pod Identity Association existed. As a result, the pod never received injected AWS credentials from the Pod Identity admission webhook.

**Resolution**

Restarting the Cert-Manager Deployment created a new controller pod after the Pod Identity Association was available, allowing AWS credentials to be injected successfully.

**Outcome**

Certificate issuance through Let's Encrypt DNS01 completed successfully, validating the complete integration between Cert-Manager, Amazon Route53, and Amazon EKS Pod Identity for the CloudHustler Commerce Platform.