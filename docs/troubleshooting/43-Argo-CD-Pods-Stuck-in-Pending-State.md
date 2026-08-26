# Phase 8 – GitOps & Continuous Delivery Troubleshooting Guide

**Project:** CloudHustler Commerce Platform  
**Phase:** 8 – GitOps & Continuous Delivery  
**Environment:** dev  
**Region:** us-east-2  
**Platform:** Amazon EKS, Argo CD, GitHub Actions, Amazon ECR, Kustomize, Helm, Istio and Karpenter

---

## Troubleshooting Incident 1 – Argo CD Pods Stuck in Pending State

### Problem

The Argo CD Helm installation timed out, and the Argo CD pods remained in the `Pending` state.

### Symptoms

```text
Error: context deadline exceeded
```

The Kubernetes events showed:

```text
0/2 nodes are available: 2 Too many pods.
preemption: 0/2 nodes are available:
2 No preemption victims found for incoming pod.
```

### Root Cause

The EKS cluster had only two worker nodes, and both nodes had reached their maximum pod capacity.

The Argo CD pods could not be scheduled because:

- The existing nodes had no remaining pod slots.
- No lower-priority pods could be preempted.
- Karpenter was not successfully provisioning additional capacity.
- The Helm timeout was a secondary symptom of the Kubernetes scheduling problem.

### Diagnostic Commands

Check the Argo CD pods:

```bash
kubectl get pods -n argocd -o wide
```

Check recent namespace events:

```bash
kubectl get events -n argocd \
  --sort-by='.lastTimestamp'
```

Describe a pending pod:

```bash
kubectl describe pod <PENDING_POD_NAME> \
  -n argocd
```

Check node capacity:

```bash
kubectl get nodes
```

```bash
kubectl describe nodes
```

Check the number of pods scheduled on each node:

```bash
kubectl get pods -A \
  -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,NODE:.spec.nodeName' \
  --sort-by='.spec.nodeName'
```

Check managed node groups:

```bash
aws eks list-nodegroups \
  --cluster-name cloudhusller-commerce-platform-dev-eks \
  --region us-east-2
```

Check Karpenter resources:

```bash
kubectl get nodepool
```

```bash
kubectl get ec2nodeclass
```

```bash
kubectl get pods -n kube-system \
  -l app.kubernetes.io/name=karpenter
```

### Resolution

Restore scheduling capacity by completing one or more of the following actions:

1. Repair the Karpenter `EC2NodeClass` and `NodePool`.
2. Increase the managed node group desired capacity.
3. Remove completed or unnecessary workloads.
4. Review overly large CPU or memory requests.
5. Confirm that the VPC CNI has enough IP addresses available.

Example node group scaling command:

```bash
aws eks update-nodegroup-config \
  --cluster-name cloudhusller-commerce-platform-dev-eks \
  --nodegroup-name cloudhusller-commerce-platform-dev-eks-system \
  --scaling-config minSize=2,maxSize=5,desiredSize=3 \
  --region us-east-2
```

After capacity becomes available, Kubernetes should schedule the pending Argo CD pods automatically.

### Validation

```bash
kubectl get pods -n argocd
```

Expected result:

```text
All Argo CD pods are Running and Ready.
```

```bash
kubectl get applications -n argocd
```

Expected result:

```text
The root and child applications report Synced and Healthy.
```

### Senior DevOps Lesson

A Helm `context deadline exceeded` error does not necessarily indicate a Helm problem. Helm may be waiting for Kubernetes resources that cannot become ready because of cluster capacity, networking, storage or scheduling constraints.

Always inspect pod events before increasing Helm timeouts.

---