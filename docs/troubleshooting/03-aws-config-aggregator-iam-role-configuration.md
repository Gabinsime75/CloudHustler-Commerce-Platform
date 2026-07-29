# Troubleshooting: AWS Config Aggregator IAM Role Configuration Failure

## Overview

During the Governance phase of the CloudHustler Commerce Platform, an AWS Config Aggregator was deployed to provide a centralized view of configuration and compliance data across the AWS environment.

Although the AWS Config service and Configuration Recorder had been deployed successfully, Terraform failed while creating the Configuration Aggregator. The deployment was blocked because the Aggregator could not assume the required IAM role.

The issue was traced to an incorrectly configured IAM role rather than a problem with AWS Config or Terraform.

---

## Environment

| Component | Value |
|-----------|------|
| Project | CloudHustler Commerce Platform |
| Phase | Governance |
| Service | AWS Config Aggregator |
| IaC | Terraform |
| Region | us-east-2 |

---

## Objective

Deploy an AWS Config Aggregator capable of:

- Collecting configuration data from AWS Config
- Providing a centralized compliance view
- Supporting future multi-account governance
- Remaining fully managed through Terraform

---

## Symptoms

Terraform failed while creating the AWS Config Aggregator.

As a result:

- AWS Config Recorder was operational.
- Delivery Channel was operational.
- Aggregator creation failed.
- Governance deployment could not complete.

---

## Investigation Timeline

### Step 1 – Verify AWS Config Status

Confirmed that AWS Config was functioning correctly.

Verified:

- Configuration Recorder
- Delivery Channel
- Recording Status

Result:

AWS Config services were healthy.

---

### Step 2 – Review Terraform Dependencies

Reviewed Terraform dependencies to ensure the IAM role was created before the Aggregator.

Result:

Terraform dependency ordering was correct.

---

### Step 3 – Inspect IAM Role

Reviewed the IAM role associated with the Aggregator.

Verified:

- Trust relationship
- AssumeRole policy
- Attached permissions

The IAM role configuration was compared against AWS Config documentation.

---

### Step 4 – Validate Aggregator Configuration

Reviewed the Terraform resource configuration for:

- IAM Role ARN
- Account configuration
- Region configuration

No Terraform syntax issues were identified.

---

### Step 5 – Correct IAM Configuration

The IAM role configuration was updated to satisfy AWS Config Aggregator requirements.

Terraform was executed again after the IAM changes.

---

## Failed Assumptions

### Assumption 1

AWS Config had not deployed correctly.

Result:

Incorrect.

AWS Config services were already operational.

---

### Assumption 2

Terraform dependency ordering was incorrect.

Result:

Incorrect.

Resources were created in the correct order.

---

### Assumption 3

The Aggregator service itself was unavailable.

Result:

Incorrect.

The failure occurred because the required IAM role configuration was incomplete.

---

## Root Cause

The IAM role required by the AWS Config Aggregator was not configured correctly.

Although AWS Config itself was functioning normally, the Aggregator could not assume the required role, preventing Terraform from completing the deployment.

---

## Resolution

The IAM role configuration was corrected in Terraform.

After redeployment:

- AWS Config Aggregator was created successfully.
- Terraform completed without errors.
- Governance deployment finished successfully.

No manual AWS Console changes were required.

---

## Alternative Solution

The Aggregator could have been created manually through the AWS Console to verify the configuration.

However, resolving the issue directly within Terraform ensured the deployment remained reproducible and eliminated configuration drift.

---

## Validation

The implementation was validated by confirming:

- AWS Config Recorder operational.
- Delivery Channel operational.
- Aggregator successfully created.
- Terraform completed successfully.
- Governance deployment fully operational.

---

## Lessons Learned

- AWS managed services often depend on correctly configured IAM trust relationships.
- Successful deployment of prerequisite services does not guarantee dependent services will deploy successfully.
- IAM trust policies should always be validated separately from permission policies.
- Maintaining Infrastructure as Code simplifies long-term governance and auditing.

---

## Resolution Summary

**Issue**

AWS Config Aggregator failed during Terraform deployment.

**Root Cause**

Incorrect IAM role configuration prevented the Aggregator from assuming the required role.

**Resolution**

Updated the IAM role configuration in Terraform and redeployed.

**Outcome**

AWS Config Aggregator deployed successfully, completing centralized governance configuration.