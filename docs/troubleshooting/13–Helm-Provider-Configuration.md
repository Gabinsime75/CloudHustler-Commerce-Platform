# 13 – Helm Provider Configuration Failure

**Project:** CloudHustler Commerce Platform
**Phase:** Service Mesh (Istio)
**Category:** Terraform / Helm Provider / Amazon EKS
**Severity:** High
**Status:** Resolved
**Date:** July 2026

---

# Incident Summary

During the Service Mesh phase of the CloudHustler Commerce Platform, Terraform failed while attempting to deploy Istio using the Terraform Helm Provider.

Although the Amazon EKS cluster was healthy and kubectl could communicate with the Kubernetes API server, Terraform could not establish a connection to the cluster through the Helm provider. As a result, none of the Helm releases could be installed.

The issue was traced to an incomplete Helm provider configuration that prevented Terraform from authenticating with the Kubernetes cluster.

---

# Impact

* Amazon EKS cluster remained fully operational.
* Kubernetes API was accessible through kubectl.
* Terraform could not deploy Helm charts.
* Istio installation could not begin.
* Platform deployment was blocked until Helm connectivity was restored.

---

# Symptoms

Terraform failed during the Helm release deployment.

Example error:

```text
Error: Kubernetes cluster unreachable
```

or

```text
Error: failed to configure Kubernetes client
```

Although kubectl commands worked successfully, every Helm release managed by Terraform failed during initialization.

---

# Investigation

The investigation focused on determining whether the issue originated from Terraform, the Helm provider, Kubernetes, or Amazon EKS.

## 1. Verified Amazon EKS Cluster

The cluster was confirmed to be healthy.

```bash
aws eks describe-cluster \
  --name cloudhusller-commerce-platform-dev-eks
```

Validation confirmed:

* Cluster status: **ACTIVE**
* Worker nodes operational
* Kubernetes API endpoint available

This eliminated Amazon EKS as the source of the issue.

---

## 2. Verified kubectl Connectivity

Cluster connectivity was validated.

```bash
kubectl get nodes
```

Expected output:

* All worker nodes reported **Ready**.

This confirmed Kubernetes authentication was functioning correctly outside of Terraform.

---

## 3. Reviewed Helm Provider Configuration

The Terraform Helm provider configuration was inspected.

The provider was not correctly configured to authenticate with the Amazon EKS cluster.

Specifically, the provider required:

* Kubernetes API endpoint
* Cluster certificate authority
* AWS authentication token

Without these values, Terraform could not create a Kubernetes client for Helm operations.

---

## 4. Updated the Helm Provider

The provider was configured to retrieve the required connection information directly from the Amazon EKS cluster.

Example:

```hcl
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"

      command = "aws"

      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name
      ]
    }
  }
}
```

After updating the provider, Terraform successfully authenticated with Kubernetes.

---

# Root Cause

The Terraform Helm provider was missing the required Kubernetes authentication configuration.

Although the Amazon EKS cluster and kubeconfig were correctly configured for kubectl, Terraform maintains its own Kubernetes client configuration and therefore required explicit provider authentication.

---

# Resolution

The Helm provider configuration was updated to use:

* Amazon EKS cluster endpoint
* Cluster certificate authority
* AWS CLI authentication (`aws eks get-token`)

Once configured, Terraform successfully established a Kubernetes client and deployed Helm releases.

---

# Validation

## Verify Kubernetes Connectivity

```bash
kubectl get nodes
```

Expected:

* All worker nodes report **Ready**.

---

## Verify Terraform Initialization

```bash
terraform init
```

Expected:

```text
Terraform has been successfully initialized!
```

---

## Verify Helm Deployment

```bash
terraform apply
```

Expected:

Helm releases are created successfully without authentication errors.

---

## Verify Installed Helm Releases

```bash
helm list -A
```

Expected:

Installed Helm releases are displayed successfully.

---

# Lessons Learned

* kubectl and the Terraform Helm provider use separate authentication mechanisms.
* A working kubeconfig does not automatically configure the Helm provider.
* Terraform providers should always be validated independently before deploying Kubernetes applications.
* Amazon EKS authentication should be centralized across Kubernetes and Helm providers whenever possible.

---

# Prevention

To avoid similar issues in future deployments:

* Configure the Kubernetes and Helm providers from the same Amazon EKS outputs.
* Use the AWS CLI token authentication mechanism (`aws eks get-token`) for both providers.
* Validate Terraform provider connectivity before deploying Helm releases.
* Test Helm deployments immediately after cluster creation.

---

# Key Takeaways

| Area                 | Result                                                      |
| -------------------- | ----------------------------------------------------------- |
| Root Cause           | Incomplete Helm provider authentication configuration       |
| Failure Type         | Terraform Provider Configuration                            |
| Amazon EKS Cluster   | Healthy                                                     |
| kubectl Connectivity | Healthy                                                     |
| Resolution           | Configure the Helm provider to authenticate with Amazon EKS |
| Final Status         | Terraform successfully deployed Helm releases               |

---

# Interview Story (STAR Format)

## Situation

While deploying Istio for the CloudHustler Commerce Platform, Terraform consistently failed to install Helm charts even though the Amazon EKS cluster was healthy and kubectl could communicate with Kubernetes successfully.

## Task

My responsibility was to determine why Terraform could not deploy Helm releases, restore connectivity between the Helm provider and the Kubernetes cluster, and continue the Istio installation without introducing manual deployments.

## Action

I first confirmed that the Amazon EKS cluster and worker nodes were healthy and verified that kubectl authenticated successfully. This isolated the issue to Terraform rather than Kubernetes itself. I reviewed the Helm provider configuration and discovered it lacked the required Kubernetes authentication settings. I updated the provider to use the EKS cluster endpoint, cluster certificate authority, and AWS CLI token authentication, allowing Terraform to create its own authenticated Kubernetes client.

## Result

Terraform successfully connected to the Kubernetes cluster, Helm releases deployed without errors, and the Istio installation proceeded as planned. The incident reinforced the importance of understanding that Terraform providers maintain independent authentication configurations, even when kubectl is already functioning correctly.
