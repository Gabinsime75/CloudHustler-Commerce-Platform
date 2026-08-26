# Phase 8 – GitOps & Continuous Delivery Troubleshooting Guide

**Project:** CloudHustler Commerce Platform  
**Phase:** 8 – GitOps & Continuous Delivery  
**Environment:** dev  
**Region:** us-east-2  
**Platform:** AWS EKS, Argo CD, GitHub Actions, Amazon ECR, Kustomize, Helm, Istio and Karpente

## Troubleshooting Incident 2 – Helm Release Failed and Could Not Reuse the Release Name

### Problem

A Helm deployment timed out, but the failed release remained registered in the cluster.

A subsequent Terraform apply failed because Helm considered the release name to be in use.

### Symptoms

Initial failure:

```text
context deadline exceeded
```

Subsequent failure:

```text
cannot re-use a name that is still in use
```

This affected components such as:

- Argo CD
- Istio Ingress
- Loki
- Prometheus

### Root Cause

The first Helm installation partially created resources and stored a Helm release record in the namespace.

The installation did not complete successfully, but Helm still retained the release metadata. Terraform then attempted to create a new release with the same name instead of successfully reconciling the existing failed release.

### Diagnostic Commands

List releases in the target namespace:

```bash
helm list -n argocd --all
```

Check release history:

```bash
helm history argocd -n argocd
```

Inspect the failed release:

```bash
helm status argocd -n argocd
```

Check Helm release secrets:

```bash
kubectl get secrets