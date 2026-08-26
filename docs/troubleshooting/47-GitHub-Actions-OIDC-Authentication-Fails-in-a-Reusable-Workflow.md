## Troubleshooting Incident 5 – GitHub Actions OIDC Authentication Fails in a Reusable Workflow

### Problem

A reusable GitHub Actions workflow attempted to authenticate to AWS through OIDC but could not obtain an identity token.

### Symptoms

The AWS credential step reported errors similar to:

```text
Could not load credentials from any providers
```

or:

```text
Unable to get ACTIONS_ID_TOKEN_REQUEST_URL environment variable
```

### Root Cause

The called reusable workflow requested:

```yaml
permissions:
  id-token: write
  contents: read
```

However, the calling workflow did not grant `id-token: write`.

A reusable workflow cannot elevate the permissions granted by its caller. The permission chain must allow OIDC token creation from the top-level calling workflow.

### Calling Workflow Fix

```yaml
name: Frontend CI

on:
  push:
    branches:
      - main
    paths:
      - "applications/frontend/**"
      - ".github/workflows/frontend-ci.yml"

  pull_request:
    branches:
      - main
    paths:
      - "applications/frontend/**"
      - ".github/workflows/frontend-ci.yml"

permissions:
  contents: read
  id-token: write

jobs:
  frontend-ci:
    uses: ./.github/workflows/reusable-service-ci.yml
    with:
      service_name: frontend
      ecr_repository: cloudhusller-commerce-platform-dev/frontend
    secrets: inherit
```

### Called Reusable Workflow

```yaml
name: Reusable Service CI

on:
  workflow_call:
    inputs:
      service_name:
        required: true
        type: string
      ecr_repository:
        required: true
        type: string

permissions:
  contents: read
  id-token: write
```

### AWS Authentication Step

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v5
  with:
    role-to-assume: ${{ secrets.AWS_GITHUB_ACTIONS_ROLE_ARN }}
    aws-region: us-east-2
```

### IAM Trust Policy Validation

Confirm that the IAM role trusts the GitHub OIDC provider and restricts access to the intended repository and branch.

```json
{
  "Effect": "Allow",
  "Principal": {
    "Federated": "arn:aws:iam::396913735153:oidc-provider/token.actions.githubusercontent.com"
  },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
    "StringEquals": {
      "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
    },
    "StringLike": {
      "token.actions.githubusercontent.com:sub": "repo:<GITHUB_ORG>/<GITHUB_REPOSITORY>:*"
    }
  }
}
```

### Validation

Add a temporary identity check after configuring AWS credentials:

```yaml
- name: Verify AWS identity
  shell: bash
  run: aws sts get-caller-identity
```

Expected result:

```json
{
  "Account": "396913735153",
  "Arn": "arn:aws:sts::396913735153:assumed-role/<ROLE_NAME>/<SESSION_NAME>"
}
```

### Senior DevOps Lesson

OIDC authentication depends on a complete trust chain:

```text
Calling workflow permissions
        ↓
Reusable workflow permissions
        ↓
GitHub OIDC provider
        ↓
IAM role trust policy
        ↓
AWS role permissions
```

The called workflow cannot grant itself permissions that the caller did not provide.