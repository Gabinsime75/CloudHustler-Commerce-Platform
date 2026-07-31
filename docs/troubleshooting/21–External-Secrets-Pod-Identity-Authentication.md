# 21 – External Secrets Pod Identity Authentication Failure

**Project:** CloudHustler Commerce Platform
**Phase:** Platform Services
**Category:** Amazon EKS / External Secrets Operator / EKS Pod Identity / IAM
**Severity:** High
**Status:** Resolved
**Date:** July 2026

---

# Incident Summary

During the deployment of the External Secrets Operator (ESO) for the CloudHustler Commerce Platform, the controller was successfully installed into the Kubernetes cluster, but it was unable to authenticate with AWS Secrets Manager.

Although the deployment itself was healthy, External Secrets could not retrieve secrets because the controller pod did not have a valid AWS identity. As a result, Kubernetes Secrets could not be synchronized from AWS Secrets Manager, preventing applications from accessing the credentials they required.

The issue was traced to the Amazon EKS Pod Identity configuration used by the External Secrets Operator.

---

# Impact

* Amazon EKS cluster remained healthy.
* External Secrets Operator deployment was running.
* Authentication to AWS Secrets Manager failed.
* Kubernetes Secrets could not be synchronized.
* Applications depending on external secrets could not retrieve credentials.

---

# Symptoms

The External Secrets Operator deployment appeared healthy.

```bash id="ikz0rz"
kubectl get pods -n external-secrets
```

Expected output:

```text id="xb7qto"
external-secrets-xxxxxxxxxx    Running
```

However, ExternalSecret resources failed to synchronize and reported authentication errors.

Inspecting the controller logs revealed AWS authentication failures.

```bash id="93h9jo"
kubectl logs -n external-secrets deployment/external-secrets
```

Example symptoms included messages indicating that the controller was unable to obtain AWS credentials or access AWS Secrets Manager.

---

# Investigation

The investigation focused on determining whether the issue originated from Kubernetes, External Secrets Operator, Amazon EKS Pod Identity, or IAM.

## 1. Verified Cluster Health

The Kubernetes cluster was healthy.

```bash id="0dq9gf"
kubectl get nodes
```

All worker nodes reported a **Ready** status.

This eliminated cluster health as the source of the problem.

---

## 2. Verified External Secrets Deployment

The deployment was inspected.

```bash id="sqbbdn"
kubectl get deployment -n external-secrets
```

The deployment was successfully created and available.

This confirmed the controller itself was functioning correctly.

---

## 3. Verified Pod Identity Association

The Amazon EKS Pod Identity association was reviewed.

The controller ServiceAccount was expected to be associated with an IAM role granting access to AWS Secrets Manager.

The investigation confirmed that the Pod Identity configuration was incomplete or incorrect, preventing the controller from receiving AWS credentials.

---

## 4. Reviewed IAM Permissions

The IAM role associated with the controller was inspected.

The required permissions included access to AWS Secrets Manager (and AWS Systems Manager Parameter Store if used).

After correcting the Pod Identity association and IAM permissions, the controller successfully authenticated with AWS.

---

# Root Cause

The External Secrets Operator controller did not receive a valid AWS identity because the Amazon EKS Pod Identity association was not correctly configured.

Without temporary AWS credentials, the controller could not authenticate to AWS Secrets Manager or synchronize Kubernetes Secrets.

---

# Resolution

The Amazon EKS Pod Identity association was corrected and linked to an IAM role with the required permissions.

After updating the association:

* The controller obtained temporary AWS credentials.
* Authentication with AWS Secrets Manager succeeded.
* ExternalSecret resources synchronized successfully.
* Kubernetes Secrets were created automatically.

---

# Validation

## Verify Controller Deployment

```bash id="n9l9hn"
kubectl get deployment -n external-secrets
```

Expected:

The deployment reports **Available**.

---

## Verify Pod Identity Association

```bash id="wjlwm7"
aws eks list-pod-identity-associations \
  --cluster-name cloudhusller-commerce-platform-dev-eks
```

Expected:

The External Secrets ServiceAccount is associated with the correct IAM role.

---

## Verify External Secrets

```bash id="xkbf96"
kubectl get externalsecret -A
```

Expected:

ExternalSecret resources report:

```text id="1w5n31"
Ready: True
```

---

## Verify Kubernetes Secrets

```bash id="l2pjim"
kubectl get secrets
```

Expected:

The synchronized Kubernetes Secrets are present.

---

## Verify Controller Logs

```bash id="2t5cjm"
kubectl logs -n external-secrets deployment/external-secrets
```

Expected:

No AWS authentication or permission errors are present.

---

# Lessons Learned

* A healthy Kubernetes deployment does not guarantee successful AWS authentication.
* External Secrets Operator depends on a correctly configured Pod Identity association and IAM role.
* Verifying AWS identity is just as important as verifying pod health.
* Authentication should always be validated before troubleshooting application-level secret synchronization.

---

# Prevention

To avoid similar issues in future deployments:

* Create the IAM role before deploying External Secrets Operator.
* Configure the Pod Identity association before creating SecretStore or ClusterSecretStore resources.
* Validate IAM permissions using a least-privilege policy.
* Confirm successful synchronization immediately after deployment.

---

# Key Takeaways

| Area                        | Result                                                                                          |
| --------------------------- | ----------------------------------------------------------------------------------------------- |
| Root Cause                  | Incorrect Amazon EKS Pod Identity association                                                   |
| Failure Type                | AWS Authentication                                                                              |
| External Secrets Deployment | Healthy                                                                                         |
| Kubernetes Cluster          | Healthy                                                                                         |
| Resolution                  | Corrected Pod Identity association and IAM permissions                                          |
| Final Status                | External Secrets Operator successfully synchronized Kubernetes Secrets from AWS Secrets Manager |

---

# Interview Story (STAR Format)

## Situation

While deploying the External Secrets Operator for the CloudHustler Commerce Platform, the controller installed successfully but was unable to retrieve secrets from AWS Secrets Manager. Although the Kubernetes deployment was healthy, applications could not access the credentials they depended on because no Kubernetes Secrets were being created.

## Task

My responsibility was to determine whether the issue was related to Kubernetes, the External Secrets Operator, Amazon EKS Pod Identity, or IAM permissions, then restore secure secret synchronization without introducing static credentials into the cluster.

## Action

I first confirmed that the Kubernetes cluster and External Secrets deployment were healthy. I then reviewed the Pod Identity association and discovered that the controller was not receiving a valid AWS identity. After correcting the Pod Identity association and verifying that the associated IAM role had the required Secrets Manager permissions, I confirmed that the controller successfully authenticated with AWS and synchronized the requested secrets into Kubernetes.

## Result

External Secrets Operator began automatically creating Kubernetes Secrets from AWS Secrets Manager, restoring secure secret management for the platform without embedding credentials inside the cluster. The incident reinforced the importance of validating both Pod Identity associations and IAM permissions whenever Kubernetes workloads authenticate to AWS services.
