# 12 – kubectl Authentication / kubeconfig Failure

**Project:** CloudHustler Commerce Platform
**Phase:** Container Platform (Amazon EKS)
**Category:** Amazon EKS / kubectl / kubeconfig / AWS CLI
**Severity:** High
**Status:** Resolved
**Date:** July 2026

---

# Incident Summary

After successfully deploying the Amazon EKS cluster for the CloudHustler Commerce Platform, attempts to manage the cluster using **kubectl** failed because the local Kubernetes configuration (kubeconfig) had not been configured for the newly created cluster.

Although the EKS control plane was healthy and accessible through AWS, kubectl could not authenticate with the Kubernetes API server because it did not have the required cluster endpoint, certificate authority, or authentication configuration.

The issue was resolved by generating the kubeconfig file using the AWS CLI, allowing kubectl to authenticate successfully with the EKS cluster.

---

# Impact

* Amazon EKS cluster was successfully deployed.
* Kubernetes API was running.
* kubectl could not communicate with the cluster.
* Cluster validation could not be performed.
* Kubernetes resources could not be deployed or managed.

---

# Symptoms

Running kubectl commands produced connection or authentication errors.

Example:

```text
Unable to connect to the server:
dial tcp: no such host
```

or

```text
The connection to the server localhost:8080 was refused.
```

or

```text
error: You must be logged in to the server (Unauthorized)
```

These errors indicated that kubectl was either pointing to the wrong cluster or had no valid kubeconfig configuration.

---

# Investigation

The troubleshooting process focused on determining whether the issue originated from Amazon EKS, AWS authentication, or the local Kubernetes configuration.

## 1. Verified the EKS Cluster

The cluster status was verified using the AWS CLI.

```bash
aws eks describe-cluster \
  --name cloudhusller-commerce-platform-dev-eks
```

Result:

* Cluster status: **ACTIVE**
* Endpoint available
* Cluster accessible through AWS

This confirmed the cluster itself was healthy.

---

## 2. Verified AWS Authentication

The AWS identity used by the CLI was confirmed.

```bash
aws sts get-caller-identity
```

The command returned the expected AWS account and IAM identity, confirming that AWS authentication was functioning correctly.

---

## 3. Reviewed kubeconfig

The local kubeconfig configuration was inspected.

```bash
kubectl config current-context
```

The expected EKS cluster context was either missing or incorrect.

This explained why kubectl was unable to locate or authenticate with the Kubernetes API server.

---

## 4. Updated kubeconfig

The kubeconfig file was regenerated using the AWS CLI.

```bash
aws eks update-kubeconfig \
  --region us-east-2 \
  --name cloudhusller-commerce-platform-dev-eks
```

The AWS CLI downloaded the cluster endpoint, certificate authority, and authentication configuration, updating the local kubeconfig automatically.

---

# Root Cause

The local kubeconfig file did not contain a valid configuration for the newly created Amazon EKS cluster.

Without the correct cluster context and authentication information, kubectl could not communicate with the Kubernetes API server.

---

# Resolution

The kubeconfig file was regenerated using the AWS CLI.

```bash
aws eks update-kubeconfig \
  --region us-east-2 \
  --name cloudhusller-commerce-platform-dev-eks
```

After updating the kubeconfig:

* The correct cluster context was added.
* kubectl authenticated successfully.
* Kubernetes API communication was restored.
* Cluster administration resumed normally.

---

# Validation

## Verify Current Context

```bash
kubectl config current-context
```

Expected:

```text
arn:aws:eks:us-east-2:<account-id>:cluster/cloudhusller-commerce-platform-dev-eks
```

---

## Verify Cluster Connectivity

```bash
kubectl cluster-info
```

Expected:

```text
Kubernetes control plane is running...
```

---

## Verify Nodes

```bash
kubectl get nodes
```

Expected:

```text
STATUS: Ready
```

All worker nodes should report a **Ready** status.

---

## Verify Namespaces

```bash
kubectl get namespaces
```

Expected:

Default Kubernetes namespaces are returned successfully.

---

# Lessons Learned

* Deploying an Amazon EKS cluster does not automatically configure local kubectl access.
* kubeconfig must be updated whenever connecting to a new EKS cluster.
* AWS CLI authentication and Kubernetes authentication are separate validation steps.
* Most kubectl connection errors are caused by incorrect or outdated kubeconfig files rather than cluster failures.

---

# Prevention

To avoid similar issues in future deployments:

* Run `aws eks update-kubeconfig` immediately after creating a new cluster.
* Verify the current Kubernetes context before deploying workloads.
* Validate AWS authentication before troubleshooting Kubernetes connectivity.
* Use `kubectl cluster-info` as an initial connectivity test.

---

# Key Takeaways

| Area               | Result                                              |
| ------------------ | --------------------------------------------------- |
| Root Cause         | Missing or outdated kubeconfig configuration        |
| Failure Type       | Kubernetes Authentication                           |
| Amazon EKS Cluster | Healthy                                             |
| AWS Authentication | Healthy                                             |
| Resolution         | Regenerated kubeconfig using the AWS CLI            |
| Final Status       | kubectl successfully authenticated with the cluster |

---

# Interview Story (STAR Format)

## Situation

After deploying the Amazon EKS cluster for the CloudHustler Commerce Platform, I attempted to validate the deployment using kubectl, but every command failed because my local workstation could not communicate with the Kubernetes API server.

## Task

My responsibility was to determine whether the issue was caused by the EKS cluster, AWS authentication, or the local Kubernetes configuration, and restore administrative access without modifying the cluster itself.

## Action

I first confirmed that the EKS cluster was healthy using the AWS CLI and verified my AWS credentials with the Security Token Service. After confirming the infrastructure was healthy, I inspected the local kubeconfig and found that it did not contain the newly created cluster context. I regenerated the kubeconfig using the `aws eks update-kubeconfig` command, which downloaded the correct endpoint, certificate authority, and authentication configuration for the cluster.

## Result

kubectl immediately authenticated with the Amazon EKS cluster, allowing me to validate the worker nodes, deploy Kubernetes resources, and continue building the CloudHustler Commerce Platform. The incident reinforced the importance of treating kubeconfig configuration as a required post-deployment step for every new EKS cluster.
