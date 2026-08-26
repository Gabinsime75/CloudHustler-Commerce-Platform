## Troubleshooting Incident 2 – Helm Release Name Already in Use

### Problem

A Terraform retry failed while reinstalling Argo CD or another platform component.

### Symptoms

```text
Error: cannot re-use a name that is still in use
```

The problem occurred after an earlier Helm installation timed out or failed.

### Root Cause

The initial Helm installation created a release record before Terraform reported the timeout.

Although Terraform considered the operation unsuccessful, Helm still retained the release in the cluster.

This caused a state mismatch:

- Terraform did not have a successfully managed release.
- Helm still had a release with the requested name.
- The next installation attempted to create the same release again.
- Helm rejected the duplicate release name.

### Diagnostic Commands

List all releases, including failed releases:

```bash
helm list -n argocd --all
```

Inspect the release:

```bash
helm status argocd -n argocd
```

Review the release history:

```bash
helm history argocd -n argocd
```

Check whether Terraform tracks the release:

```bash
terraform state list | grep helm_release
```

Inspect the Terraform resource:

```bash
terraform state show helm_release.argocd
```

### Resolution Option 1 – Import the Existing Release

Use this option when the Helm release is valid and should remain installed.

```bash
terraform import \
  helm_release.argocd \
  argocd/argocd
```

Review the Terraform plan:

```bash
terraform plan
```

### Resolution Option 2 – Remove the Failed Release and Reapply

Use this option when the release is incomplete or unusable.

```bash
helm uninstall argocd -n argocd
```

Confirm that the release is gone:

```bash
helm list -n argocd --all
```

Reapply the Terraform configuration:

```bash
terraform apply
```

### Resolution Option 3 – Reconcile Terraform State

If Terraform contains an invalid or stale resource entry, inspect it carefully before removing only that specific state object:

```bash
terraform state show helm_release.argocd
```

```bash
terraform state rm helm_release.argocd
```

Removing a resource from Terraform state does not delete the real Helm release. It only removes Terraform's tracking relationship.

### Validation

```bash
helm list -n argocd
```

```bash
kubectl get pods -n argocd
```

```bash
terraform plan
```

Expected result:

```text
The release is deployed, the pods are healthy and Terraform no longer
attempts to create a duplicate release.
```

### Senior DevOps Lesson

Terraform state, Helm release state and Kubernetes runtime state are separate sources of truth.

After a timeout, always inspect all three before retrying:

1. Terraform state
2. Helm release state
3. Kubernetes resource state

Blindly rerunning `terraform apply` can make the mismatch harder to diagnose.