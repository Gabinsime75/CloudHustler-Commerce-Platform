## Troubleshooting Incident 8 – Argo CD Application Is OutOfSync or Does Not Self-Heal

### Problem

A Kubernetes resource was manually modified, but Argo CD did not automatically return it to the Git-defined state.

### Symptoms

The application displayed:

```text
Sync Status: OutOfSync
```

A manually changed deployment remained different from the Git repository.

### Root Cause

One or more automated synchronization settings were missing or disabled:

- `automated` synchronization
- `selfHeal`
- `prune`

Another possibility was that the resource was excluded, ignored or managed by a different controller.

### Diagnostic Commands

Check application status:

```bash
kubectl get applications -n argocd
```

Inspect the application configuration:

```bash
kubectl get application <APPLICATION_NAME> \
  -n argocd \
  -o yaml
```

Check synchronization policy:

```bash
kubectl get application <APPLICATION_NAME> \
  -n argocd \
  -o jsonpath='{.spec.syncPolicy}'
```

View the Argo CD diff:

```bash
argocd app diff <APPLICATION_NAME>
```

Inspect application-managed resources:

```bash
argocd app resources <APPLICATION_NAME>
```

### Resolution

Configure automated synchronization with pruning and self-healing:

```yaml
spec:
  syncPolicy:
    automated:
      enabled: true
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Commit and push the change:

```bash
git add gitops/
git commit -m "Configure Argo CD automated synchronization and self-healing"
git push origin main
```

Refresh the application:

```bash
argocd app get <APPLICATION_NAME> --refresh
```

Synchronize if required:

```bash
argocd app sync <APPLICATION_NAME>
```

### Controlled Drift Test

Change the deployment replica count manually:

```bash
kubectl scale deployment frontend \
  -n cloudhusller-dev \
  --replicas=3
```

Observe the resource:

```bash
kubectl get deployment frontend \
  -n cloudhusller-dev \
  --watch
```

Expected result:

```text
Argo CD detects the drift and restores the Git-defined replica count.
```

### Pruning Test

Add a temporary resource to Git, synchronize it, remove it from Git and push the deletion.

Confirm that Argo CD removes the resource from the cluster when pruning is enabled.

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

### Senior DevOps Lesson

GitOps is not validated merely because Argo CD successfully deployed an application once.

A complete functional test must demonstrate:

- Git-driven deployment
- Automatic synchronization
- Drift detection
- Self-healing
- Pruning
- Rollback
- App of Apps ownership
- Immutable image deployment
