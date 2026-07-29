# Troubleshooting: AWS Config Delivery Channel Permission Failure

## Overview

During the Governance phase of the CloudHustler Commerce Platform, AWS Config was deployed using Terraform to continuously record AWS resource configurations and deliver configuration snapshots and compliance history to Amazon S3.

Although the Configuration Recorder deployed successfully, Terraform consistently failed while creating the AWS Config Delivery Channel. Without the Delivery Channel, AWS Config could not deliver snapshots or configuration history, preventing the service from becoming fully operational.

The issue was ultimately traced to insufficient permissions on the destination Amazon S3 bucket rather than a problem with Terraform or AWS Config itself.

---

## Environment

| Component | Value |
|-----------|------|
| Project | CloudHustler Commerce Platform |
| Phase | Governance |
| Service | AWS Config |
| Destination | Amazon S3 |
| IaC | Terraform |
| Region | us-east-2 |

---

## Objective

Deploy AWS Config to provide continuous resource inventory and compliance monitoring by:

- Recording supported AWS resources
- Delivering configuration snapshots to Amazon S3
- Enabling future compliance rules
- Maintaining the deployment entirely through Terraform

---

## Symptoms

Terraform failed while creating the AWS Config Delivery Channel.

As a result:

- Configuration Recorder existed.
- Delivery Channel was not created.
- AWS Config could not start recording resources.
- Governance deployment could not complete successfully.

---

## Investigation Timeline

### Step 1 – Verify Configuration Recorder

Confirmed that the AWS Config Configuration Recorder had been created successfully.

Result:

The recorder itself was healthy.

---

### Step 2 – Verify Amazon S3 Bucket

Confirmed that the destination S3 bucket existed and was accessible.

Verified:

- Bucket name
- Region
- Terraform outputs

Result:

The bucket existed as expected.

---

### Step 3 – Review Terraform Dependencies

Verified that Terraform correctly established dependencies between:

- S3 bucket
- IAM Role
- Configuration Recorder
- Delivery Channel

No dependency issues were identified.

---

### Step 4 – Review Bucket Policy

Attention shifted to the Amazon S3 bucket policy.

The bucket policy was compared against the permissions required by AWS Config.

The investigation revealed that AWS Config did not have sufficient permissions to write configuration snapshots into the bucket.

---

### Step 5 – Update Bucket Policy

The bucket policy was updated to grant AWS Config the required permissions for:

- GetBucketAcl
- ListBucket (where applicable)
- PutObject

The Terraform deployment was rerun after updating the policy.

---

## Failed Assumptions

### Assumption 1

Terraform dependency ordering was incorrect.

Result:

Incorrect.

Terraform created resources in the proper sequence.

---

### Assumption 2

AWS Config itself failed to deploy.

Result:

Incorrect.

The Configuration Recorder deployed successfully.

---

### Assumption 3

The S3 bucket was missing.

Result:

Incorrect.

The bucket existed, but AWS Config was not authorized to write to it.

---

## Root Cause

The Amazon S3 bucket policy did not grant AWS Config the permissions required to deliver configuration snapshots.

Although all infrastructure resources existed, AWS Config could not complete Delivery Channel creation because it was denied access to the destination bucket.

---

## Resolution

The S3 bucket policy was updated to include the permissions required by AWS Config.

After applying the updated Terraform configuration:

- Delivery Channel was created successfully.
- AWS Config started successfully.
- Configuration snapshots were delivered to Amazon S3.
- Terraform completed without errors.

---

## Alternative Solution

An alternative troubleshooting approach would have been to manually test AWS Config through the AWS Console.

However, resolving the issue directly within Terraform preserved Infrastructure as Code as the single source of truth and eliminated configuration drift.

---

## Validation

The implementation was validated by confirming:

- Configuration Recorder was active.
- Delivery Channel existed.
- AWS Config entered a recording state.
- Configuration snapshots appeared in Amazon S3.
- Terraform completed successfully without errors.

---

## Lessons Learned

- AWS Config depends on both IAM permissions and Amazon S3 bucket policies.
- Resource existence does not guarantee service functionality.
- Bucket policies should always be validated when AWS services write to Amazon S3.
- Resolving permission issues through Terraform prevents long-term configuration drift.
- Validating each dependency individually reduces troubleshooting time.

---

## Resolution Summary

**Issue**

AWS Config Delivery Channel failed during Terraform deployment.

**Root Cause**

Amazon S3 bucket policy did not grant AWS Config permission to write configuration snapshots.

**Resolution**

Updated the S3 bucket policy with the required AWS Config permissions.

**Outcome**

AWS Config successfully created the Delivery Channel, began recording resources, and delivered configuration snapshots to Amazon S3.