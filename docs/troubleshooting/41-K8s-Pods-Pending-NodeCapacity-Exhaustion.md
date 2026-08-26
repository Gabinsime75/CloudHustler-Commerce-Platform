# Phase 8 – GitOps & Continuous Delivery Troubleshooting Guide

**Project:** CloudHustler Commerce Platform  
**Phase:** 8 – GitOps & Continuous Delivery  
**Environment:** dev  
**Region:** us-east-2  
**Platform:** AWS EKS, Argo CD, GitHub Actions, Amazon ECR, Kustomize, Helm, Istio and Karpenter

---

## Troubleshooting Incident 1 – Kubernetes Pods Pending Because of Node Capacity Exhaustion

### Problem

Argo CD pods and other platform workloads remained in the `Pending` state. Terraform and Helm deployments subsequently failed with timeout errors.

### Symptoms

```text
0/2 nodes are available: 2 Too many pods.
preemption: 0/2 nodes are available:
2 No preemption victims found for incoming pod.
```

Related Helm and Terraform errors included:

```text
context deadline exceeded
```

```text
timed out waiting for the condition
```

### Root Cause

The EKS cluster only had two worker nodes, and both nodes had reached their maximum pod capacity.

This was not an Argo CD or Helm configuration problem. The Kubernetes scheduler could not place additional workloads because no pod slots were available.

Preemption could not help because there were no lower-priority pods that Kubernetes could safely evict.

### Diagnostic Commands

Check pending pods across the cluster:

```bash
kubectl get pods -A --field-selector=status.phase=Pending
```

Check recent scheduling events:

```bash
kubectl get events -A \
  --sort-by='.lastTimestamp' | tail -50
```

Inspect a specific pending pod:

```bash
kubectl describe pod <POD_NAME> -n <NAMESPACE>
```

Check node capacity and pod allocation:

```bash
kubectl describe nodes
```

Count the pods scheduled on each node:

```bash
kubectl get pods -A \
  -o custom-columns='NODE:.spec.nodeName,POD:.metadata.namespace/.metadata.name' \
  --sort-by='.spec.nodeName'
```

Check the managed node groups:

```bash
aws eks list-nodegroups \
  --cluster-name cloudhusller-commerce-platform-dev-eks \
  --region us-east-2
```

Check Karpenter status:

```bash
kubectl get pods -n kube-system | grep karpenter
```

```bash
kubectl get ec2nodeclass
kubectl get nodepool
```

### Resolution

Restore scheduling capacity using one or more of the following methods:

1. Scale the existing EKS managed node group.
2. Repair the Karpenter `EC2NodeClass` and `NodePool`.
3. Reduce unnecessary workload replicas in the dev environment.
4. Review the VPC CNI configuration and maximum pod limits.
5. Separate system workloads from application workloads using dedicated node groups.

Example managed node group scaling command:

```bash
aws eks update-nodegroup-config \
  --cluster-name cloudhusller-commerce-platform-dev-eks \
  --nodegroup-name cloudhusller-commerce-platform-dev-eks-system \
  --scaling-config minSize=2,maxSize=5,desiredSize=3 \
  --region us-east-2
```

### Validation

```bash
kubectl get nodes
```

```bash
kubectl get pods -A --field-selector=status.phase=Pending
```

```bash
kubectl get pods -n argocd
```

Expected result:

- Additional worker capacity is available.
- Pending pods transition to `Running`.
- Argo CD components become healthy.
- Helm deployments complete without scheduling-related timeouts.

### Senior DevOps Lesson

A Helm timeout is often a downstream symptom rather than the primary failure. Always inspect Kubernetes scheduling events before changing Helm timeout values or repeatedly rerunning Terraform.

---

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