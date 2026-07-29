# Troubleshooting: CloudTrail CloudWatch Logs ARN Configuration Failure

## Overview

During the Governance phase of the CloudHustler Commerce Platform, CloudTrail was configured to deliver management events to both Amazon S3 and Amazon CloudWatch Logs. While the S3 integration completed successfully, Terraform failed when attempting to configure CloudTrail logging to CloudWatch.

The issue was traced to an incorrectly formatted CloudWatch Log Group ARN. Although the ARN appeared valid, CloudTrail requires a very specific ARN format when integrating with CloudWatch Logs.

Resolving this issue established centralized audit logging for the platform and became the first production troubleshooting incident encountered during the project.

---

## Environment

| Component | Value |
|-----------|------|
| Project | CloudHustler Commerce Platform |
| Phase | Governance |
| Service | AWS CloudTrail |
| Destination | Amazon CloudWatch Logs |
| IaC | Terraform |
| Region | us-east-2 |

---

## Objective

Configure CloudTrail to:

- Record management events
- Deliver logs to Amazon S3
- Stream logs to Amazon CloudWatch Logs
- Enable centralized auditing across the AWS account

---

## Symptoms

Terraform failed while creating the CloudTrail resource.

CloudTrail was unable to associate with the configured CloudWatch Log Group.

As a result:

- CloudTrail was not created successfully.
- Audit logs were not being delivered to CloudWatch Logs.
- Terraform apply terminated with an error.

---

## Investigation Timeline

### Step 1 – Verify CloudWatch Log Group

Confirmed that the CloudWatch Log Group already existed and had been successfully created by Terraform.

Result:

The Log Group itself was healthy.

---

### Step 2 – Verify IAM Role

Verified that the IAM Role assigned to CloudTrail contained the required permissions to publish log events.

Result:

IAM permissions were correct.

---

### Step 3 – Inspect CloudTrail Configuration

The CloudTrail resource configuration was reviewed line by line.

Particular attention was given to:

- CloudWatch Log Group ARN
- IAM Role ARN
- Region
- Resource dependencies

---

### Step 4 – Compare ARN Format

The configured ARN was compared against the ARN format required by the CloudTrail API.

The investigation revealed that although the ARN referred to the correct CloudWatch Log Group, it did not match the format expected by CloudTrail.

---

## Failed Assumptions

### Assumption 1

The IAM Role lacked permissions.

Result:

Incorrect.

IAM permissions were valid.

---

### Assumption 2

The CloudWatch Log Group had not been created.

Result:

Incorrect.

The Log Group already existed.

---

### Assumption 3

Terraform generated an invalid CloudWatch Log Group.

Result:

Incorrect.

The issue was not the resource itself but the ARN format supplied to CloudTrail.

---

## Root Cause

CloudTrail requires the CloudWatch Log Group ARN to follow a specific format.

Although the configured ARN referenced the correct Log Group, it did not satisfy the CloudTrail API requirements, causing the resource creation to fail.

The issue was a configuration error rather than an IAM or Terraform problem.

---

## Resolution

The CloudTrail configuration was updated to use the correct CloudWatch Log Group ARN format.

After correcting the ARN:

- Terraform apply completed successfully.
- CloudTrail was created.
- CloudTrail successfully streamed audit logs into CloudWatch Logs.

---

## Alternative Solution

An alternative approach would have been to validate the CloudTrail configuration manually through the AWS Console before applying the Terraform configuration.

Although this can help isolate API-related issues, resolving the problem directly in Terraform ensured the Infrastructure as Code remained the single source of truth.

---

## Validation

The implementation was validated by confirming:

- CloudTrail resource created successfully.
- CloudTrail delivered logs to Amazon S3.
- CloudTrail delivered logs to CloudWatch Logs.
- No further Terraform errors occurred.
- Governance deployment completed successfully.

---

## Lessons Learned

- Similar AWS services often have different ARN format requirements.
- A syntactically valid ARN is not always sufficient; service-specific requirements must also be satisfied.
- IAM permission issues should be verified but not assumed to be the root cause.
- Comparing Terraform configuration against AWS service documentation is often faster than repeatedly modifying IAM policies.
- Resolving configuration issues within Terraform preserves Infrastructure as Code as the authoritative deployment mechanism.

---

## Resolution Summary

**Issue**

CloudTrail failed to configure CloudWatch Logs integration.

**Root Cause**

Incorrect CloudWatch Log Group ARN format supplied to the CloudTrail resource.

**Resolution**

Updated the CloudWatch Log Group ARN to the format required by CloudTrail.

**Outcome**

CloudTrail successfully streamed audit logs to both Amazon S3 and Amazon CloudWatch Logs, completing the governance deployment.