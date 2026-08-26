## Troubleshooting Incident 4 – Immutable ECR Image Tag Already Exists

### Problem

The GitHub Actions workflow successfully uploaded the image layers but failed when publishing the tag.

### Symptoms

```text
tag invalid: The image tag '1826ab5bd3c2' already exists in the
'cloudhusller-commerce-platform-dev/currencyservice' repository and
cannot be overwritten because the tag is immutable.
```

The workflow ended with:

```text
Process completed with exit code 1
```

### Root Cause

Amazon ECR tag immutability was enabled, which correctly prevented an existing image tag from being overwritten.

The workflow attempted to reuse a Git SHA tag that had already been pushed.

Common reasons include:

- Rerunning the same workflow for the same commit.
- Two jobs attempting to push the same service and SHA.
- A workflow trigger firing more than once.
- A build-and-push step executing during both the initial run and a retry.
- Using a shortened SHA that already exists in the repository.

### Diagnostic Commands

Check repository tag mutability:

```bash
aws ecr describe-repositories \
  --repository-names cloudhusller-commerce-platform-dev/currencyservice \
  --region us-east-2 \
  --query 'repositories[0].imageTagMutability'
```

Check whether the tag already exists:

```bash
aws ecr describe-images \
  --repository-name cloudhusller-commerce-platform-dev/currencyservice \
  --image-ids imageTag=1826ab5bd3c2 \
  --region us-east-2
```

Display the current Git commit:

```bash
git rev-parse HEAD
```

Display the shortened commit:

```bash
git rev-parse --short=12 HEAD
```

### Resolution

Keep ECR tag immutability enabled. Do not overwrite the existing SHA tag.

Make the workflow idempotent by checking whether the image exists before building and pushing it.

```yaml
- name: Check whether image already exists
  id: image-check
  shell: bash
  run: |
    if aws ecr describe-images \
      --repository-name "${ECR_REPOSITORY}" \
      --image-ids imageTag="${IMAGE_TAG}" \
      --region "${AWS_REGION}" >/dev/null 2>&1; then
      echo "exists=true" >> "$GITHUB_OUTPUT"
    else
      echo "exists=false" >> "$GITHUB_OUTPUT"
    fi

- name: Build and push image
  if: steps.image-check.outputs.exists == 'false'
  shell: bash
  run: |
    docker build \
      -t "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}" \
      .

    docker push \
      "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
```

If the exact immutable image already exists, the workflow can reuse it and continue with the GitOps manifest update.

### Validation

```bash
aws ecr describe-images \
  --repository-name cloudhusller-commerce-platform-dev/currencyservice \
  --image-ids imageTag=1826ab5bd3c2 \
  --region us-east-2 \
  --query 'imageDetails[0].[imageTags,imageDigest,imagePushedAt]'
```

Confirm that the Kubernetes deployment uses the expected tag:

```bash
kubectl get deployment currencyservice \
  -n cloudhusller-dev \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

### Senior DevOps Lesson

Immutable image tags are a production-grade control, not an error to disable.

A mature CI pipeline must be idempotent. Rerunning a workflow for the same commit should detect and reuse the existing artifact instead of trying to overwrite it.
