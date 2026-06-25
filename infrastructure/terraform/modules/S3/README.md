# Amazon S3 Module

## Overview

This Terraform module provisions a secure, production-ready Amazon S3 bucket following AWS security best practices. It is designed to serve as a reusable building block for Terraform remote state, application storage, centralized logging, backups, static website assets, and data lake storage.

The module supports encryption using customer-managed AWS KMS keys, versioning, lifecycle management, server access logging, public access protection, and optional bucket policies.

---

# Features

- Creates an Amazon S3 bucket
- Supports AWS KMS server-side encryption (SSE-KMS)
- Supports S3 Bucket Keys to reduce KMS costs
- Enforces bucket ownership controls
- Blocks all public access
- Supports bucket versioning
- Supports lifecycle management
- Supports server access logging
- Supports optional bucket policies
- Supports resource tagging
- Reusable across multiple environments

---

# Resources Created

This module provisions the following AWS resources:

- `aws_s3_bucket`
- `aws_s3_bucket_ownership_controls`
- `aws_s3_bucket_public_access_block`
- `aws_s3_bucket_server_side_encryption_configuration`
- `aws_s3_bucket_versioning`
- `aws_s3_bucket_lifecycle_configuration`
- `aws_s3_bucket_logging`
- `aws_s3_bucket_policy`

---

# Module Structure

```text
s3/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── providers.tf
└── README.md
```

---

# Input Variables

| Variable | Description | Type |
|----------|-------------|------|
| `bucket_name` | Name of the S3 bucket | `string` |
| `versioning_enabled` | Enable bucket versioning | `bool` |
| `kms_key_arn` | ARN of the KMS key used for encryption | `string` |
| `force_destroy` | Allow deletion of non-empty buckets | `bool` |
| `enable_logging` | Enable server access logging | `bool` |
| `logging_bucket` | Destination bucket for access logs | `string` |
| `logging_prefix` | Prefix for server access logs | `string` |
| `lifecycle_enabled` | Enable lifecycle rules | `bool` |
| `noncurrent_version_expiration_days` | Days before deleting previous object versions | `number` |
| `enable_public_access_block` | Enable S3 Block Public Access | `bool` |
| `enable_bucket_key` | Enable S3 Bucket Keys | `bool` |
| `bucket_policy` | Optional JSON bucket policy | `string` |
| `tags` | Resource tags | `map(string)` |

---

# Outputs

| Output | Description |
|---------|-------------|
| `bucket_id` | ID of the S3 bucket |
| `bucket_arn` | ARN of the S3 bucket |
| `bucket_name` | Name of the S3 bucket |
| `bucket_domain_name` | DNS name of the S3 bucket |
| `regional_domain_name` | Regional DNS name of the S3 bucket |

---

# Security Features

- Customer-managed AWS KMS encryption (SSE-KMS)
- S3 Bucket Keys enabled
- Bucket Ownership Controls
- Block Public Access enabled
- Bucket Versioning
- Lifecycle management
- Optional bucket policies
- Server access logging
- Resource tagging

---

# Example Usage

```hcl
module "s3" {

  source = "../modules/s3"

  bucket_name                            = "cloudhustler-app-storage"
  kms_key_arn                            = module.kms.kms_key_arn

  versioning_enabled                     = true
  enable_bucket_key                      = true
  enable_public_access_block             = true

  lifecycle_enabled                      = true
  noncurrent_version_expiration_days     = 90

  enable_logging                         = false
  logging_bucket                         = null
  logging_prefix                         = "logs/"

  force_destroy                          = false

  tags = {
    Environment = "Production"
    Project     = "CloudHustler"
    ManagedBy   = "Terraform"
  }

}
```

---

# Best Practices

- Use customer-managed KMS keys instead of SSE-S3 whenever possible.
- Enable versioning to protect against accidental object deletion.
- Keep Block Public Access enabled unless public access is explicitly required.
- Enable lifecycle rules to reduce storage costs.
- Enable server access logging for audit and compliance requirements.
- Use consistent resource tags across all AWS infrastructure.
- Grant access using IAM roles and bucket policies instead of ACLs.

---

# Notes

- This module follows AWS Well-Architected Framework recommendations.
- Suitable for production, staging, and development environments.
- Can be used for Terraform remote state, application storage, centralized logging, backup storage, and data lake workloads.
- Designed as a reusable module for enterprise-scale infrastructure.