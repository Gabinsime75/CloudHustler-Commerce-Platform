## Troubleshooting Incident 3 – Argo CD AppProject Blocks Namespace Resources

### Problem

Argo CD failed to synchronize an application that included a Kubernetes `Namespace` resource.

### Symptoms

The Argo CD sync reported that the resource was not permitted by the project.

A representative error is:

```text
Resource Namespace is not permitted in project cloudhusller-dev
```

### Root Cause

`Namespace` is a cluster-scoped Kubernetes resource.

The Argo CD `AppProject` restricted cluster-scoped resources and did not include `Namespace` in its `clusterResourceWhitelist`.

Even though most application resources were namespace-scoped, the application could not synchronize because it also attempted to manage the namespace itself.

### Diagnostic Commands

Inspect the application:

```bash
kubectl describe application <APPLICATION_NAME> \
  -n argocd
```

Inspect the AppProject:

```bash
kubectl get appproject cloudhusller-dev \
  -n argocd \
  -o yaml
```

Review the resource permission configuration:

```bash
kubectl get appproject cloudhusller-dev \
  -n argocd \
  -o jsonpath='{.spec.clusterResourceWhitelist}'
```

Check application conditions:

```bash
kubectl get application <APPLICATION_NAME> \
  -n argocd \
  -o jsonpath='{.status.conditions}'
```

### Resolution

Allow only the required cluster-scoped resource instead of using an unrestricted wildcard.

```yaml
spec:
  clusterResourceWhitelist:
    - group: ""
      kind: Namespace
```

Apply the updated AppProject:

```bash
kubectl apply -f gitops/argocd/projects/cloudhusller-dev-project.yaml
```

If the application retained a stale failed synchronization or retry state, terminate the old operation before starting a new synchronization:

```bash
argocd app terminate-op <APPLICATION_NAME>
```

Refresh the application:

```bash
argocd app get <APPLICATION_NAME> --refresh
```

Start a fresh synchronization:

```bash
argocd app sync <APPLICATION_NAME>
```

### Validation

```bash
kubectl get application <APPLICATION_NAME> \
  -n argocd
```

Expected result:

```text
SYNC STATUS: Synced
HEALTH STATUS: Healthy
```

Confirm the namespace exists:

```bash
kubectl get namespace cloudhusller-dev
```

### Senior DevOps Lesson

Production Argo CD projects should follow least privilege.

Avoid this broad configuration:

```yaml
clusterResourceWhitelist:
  - group: "*"
    kind: "*"
```

Permit only the cluster-scoped resource types the application must manage. In this case, allowing only `Namespace` fixed the synchronization without weakening the entire project boundary.

---