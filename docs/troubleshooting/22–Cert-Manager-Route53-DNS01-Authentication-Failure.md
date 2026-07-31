# 22 – Cert-Manager Route53 DNS01 Authentication Failure

**Project:** CloudHustler Commerce Platform
**Phase:** Platform Services
**Category:** Amazon EKS / Cert-Manager / Route53 DNS01 / EKS Pod Identity / IAM
**Severity:** High
**Status:** Resolved
**Date:** July 2026

---

# Incident Summary

During the deployment of **cert-manager** for the CloudHustler Commerce Platform, the controller was successfully installed into the Amazon EKS cluster, but it was unable to complete the **DNS01 ACME challenge** using Amazon Route53.

Although the cert-manager deployment was healthy, certificate requests remained in a pending state because cert-manager could not authenticate with Route53 to create the required temporary TXT records used for domain validation.

The issue was traced to an authentication problem between cert-manager and Amazon Route53, caused by an incomplete Amazon EKS Pod Identity and IAM configuration.

---

# Impact

* Amazon EKS cluster remained healthy.
* cert-manager deployment was operational.
* ClusterIssuer was created.
* Certificate requests remained pending.
* Route53 DNS01 challenge failed.
* TLS certificates could not be issued automatically.

---

# Symptoms

The cert-manager deployment appeared healthy.

```bash id="1vzm4j"
kubectl get pods -n cert-manager
```

Expected output:

```text id="nt64gc"
cert-manager
cert-manager-cainjector
cert-manager-webhook

Running
```

However, certificate requests never completed.

```bash id="7d0xpo"
kubectl get certificate -A
```

Example:

```text id="tdn3s2"
READY   False
```

Inspecting the ACME challenge showed authentication failures when attempting to update Route53.

---

# Investigation

The investigation focused on determining whether the issue originated from cert-manager, Amazon Route53, IAM permissions, or the Kubernetes configuration.

## 1. Verified cert-manager Deployment

The deployment was confirmed healthy.

```bash id="8s5phv"
kubectl get deployment -n cert-manager
```

All deployments reported **Available**.

This eliminated Kubernetes deployment issues.

---

## 2. Verified ClusterIssuer

The ClusterIssuer configuration was inspected.

```bash id="xx0o7v"
kubectl get clusterissuer
```

The ClusterIssuer existed and referenced the Route53 DNS01 solver.

This confirmed the ACME configuration itself was correct.

---

## 3. Reviewed Certificate Events

Certificate resources were inspected.

```bash id="nkg2hb"
kubectl describe certificate <certificate-name>
```

The events indicated that cert-manager was unable to complete the DNS01 validation because it could not successfully interact with Amazon Route53.

---

## 4. Verified Pod Identity and IAM

The cert-manager ServiceAccount was expected to authenticate to AWS using Amazon EKS Pod Identity.

The investigation confirmed that the Pod Identity association or the associated IAM permissions were incomplete, preventing cert-manager from creating the required TXT records in Route53.

---

# Root Cause

The cert-manager controller could not authenticate with Amazon Route53 because its Amazon EKS Pod Identity configuration was incomplete or incorrectly associated with the required IAM role.

Without valid AWS credentials and Route53 permissions, cert-manager was unable to create the temporary DNS TXT records required for the DNS01 ACME challenge.

---

# Resolution

The Pod Identity association was corrected and linked to an IAM role with the required Route53 permissions.

After updating the authentication configuration:

* cert-manager successfully authenticated with Route53.
* Temporary DNS TXT records were created automatically.
* The DNS01 challenge completed successfully.
* ACME validation succeeded.
* TLS certificates were issued automatically.

---

# Validation

## Verify cert-manager Deployment

```bash id="omjlwm"
kubectl get deployment -n cert-manager
```

Expected:

All deployments report **Available**.

---

## Verify ClusterIssuer

```bash id="wk8y3k"
kubectl get clusterissuer
```

Expected:

```text id="lqj8r7"
READY   True
```

---

## Verify Certificates

```bash id="2ybm06"
kubectl get certificate -A
```

Expected:

```text id="fvyv2w"
READY   True
```

---

## Verify Challenges

```bash id="4m9vch"
kubectl get challenge -A
```

Expected:

No pending challenges remain.

---

## Verify Pod Identity Association

```bash id="vh0yt7"
aws eks list-pod-identity-associations \
  --cluster-name cloudhusller-commerce-platform-dev-eks
```

Expected:

The cert-manager ServiceAccount is associated with the correct IAM role.

---

# Lessons Learned

* A healthy cert-manager deployment does not guarantee successful certificate issuance.
* DNS01 validation depends on successful authentication with the DNS provider.
* Amazon EKS Pod Identity should always be validated before troubleshooting ACME challenges.
* IAM permissions are just as important as Kubernetes configuration when integrating AWS services.

---

# Prevention

To reduce similar issues in future deployments:

* Configure Pod Identity before deploying cert-manager.
* Validate Route53 IAM permissions using least-privilege access.
* Verify ClusterIssuer readiness before requesting certificates.
* Monitor ACME Challenge resources during initial deployment.

---

# Key Takeaways

| Area                    | Result                                                            |
| ----------------------- | ----------------------------------------------------------------- |
| Root Cause              | Incorrect Amazon EKS Pod Identity / IAM configuration for Route53 |
| Failure Type            | AWS Authentication                                                |
| cert-manager Deployment | Healthy                                                           |
| ClusterIssuer           | Correct                                                           |
| Resolution              | Corrected Pod Identity association and Route53 IAM permissions    |
| Final Status            | Automatic DNS01 validation and certificate issuance restored      |

---

# Interview Story (STAR Format)

## Situation

While deploying cert-manager for the CloudHustler Commerce Platform, the controller installed successfully, but certificate requests never completed because the DNS01 validation process against Amazon Route53 consistently failed. Without valid TLS certificates, secure ingress traffic could not be enabled.

## Task

My responsibility was to determine whether the issue originated from cert-manager, the ACME configuration, Amazon Route53, or AWS authentication, then restore automated certificate issuance without using static AWS credentials.

## Action

I first confirmed that the cert-manager deployments and ClusterIssuer were healthy. I then inspected the certificate and challenge resources, which indicated failures during the Route53 DNS01 validation process. After reviewing the authentication configuration, I discovered that the cert-manager ServiceAccount was not correctly associated with an IAM role through Amazon EKS Pod Identity. I corrected the Pod Identity association and verified that the IAM role had the required Route53 permissions to create and remove DNS TXT records.

## Result

cert-manager successfully authenticated with Amazon Route53, completed the DNS01 ACME challenges, and automatically issued TLS certificates for the platform. This restored automated certificate lifecycle management and reinforced the importance of validating AWS authentication whenever Kubernetes controllers integrate with AWS services.
