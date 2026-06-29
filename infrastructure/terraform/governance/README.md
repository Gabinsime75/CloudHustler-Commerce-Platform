````markdown
# 🛡️ Governance

The **Governance** deployment establishes the security and compliance foundation for the CloudHustler Commerce Platform. It enables AWS governance services that continuously monitor, audit, detect, and report security events across the AWS Organization, ensuring that every AWS account follows enterprise security standards from day one.

## 🎯 Purpose

The Governance deployment provisions the AWS services responsible for organization-wide governance, auditing, compliance, and threat detection.

It creates:

- **AWS CloudTrail**
  - Records AWS API activity.
  - Provides audit logs for every AWS account.
  - Supports compliance and forensic investigations.

- **AWS Config**
  - Tracks resource configuration changes.
  - Evaluates compliance using managed rules.
  - Maintains configuration history.

- **Amazon GuardDuty**
  - Continuously monitors AWS accounts for threats.
  - Detects suspicious activity and malicious behavior.
  - Uses machine learning and threat intelligence.

- **AWS Security Hub**
  - Centralizes security findings.
  - Aggregates findings from AWS security services.
  - Provides compliance dashboards.

- **AWS IAM Access Analyzer**
  - Detects unintended resource sharing.
  - Identifies overly permissive IAM policies.
  - Improves least-privilege access.


## ✨ Features

- Organization-wide governance.
- Centralized audit logging.
- Continuous compliance monitoring.
- Threat detection.
- Security posture management.
- Resource configuration tracking.
- IAM policy analysis.
- Multi-account governance.
- Enterprise-ready security foundation.


## 🏗️ AWS Services Deployed

The Governance deployment provisions and configures:

- AWS CloudTrail
- AWS Config
- Amazon GuardDuty
- AWS Security Hub
- AWS IAM Access Analyzer

These services work together to provide continuous visibility into the security posture of the AWS Organization.


## 📂 Directory Structure

```text
governance/
├── versions.tf
├── providers.tf
├── variables.tf
├── locals.tf
├── cloudtrail.tf
├── config.tf
├── guardduty.tf
├── securityhub.tf
├── access_analyzer.tf
├── outputs.tf
└── README.md
```


## 🏛️ Governance Architecture

```text
AWS Organization
│
├── CloudTrail
│
├── AWS Config
│
├── GuardDuty
│
├── Security Hub
│
└── IAM Access Analyzer
```


## 🚀 Deployment Steps

### 1. Navigate to the Governance Directory

```
cd infrastructure/terraform/governance
```

### 2. Initialize Terraform

```
terraform init
```

Terraform downloads the required providers and configures the remote backend.

### 3. Review the Deployment Plan

```
terraform plan
```

Review the resources before deployment.

### 4. Deploy Governance Services

```
terraform apply
```

Approve the deployment when prompted.

Terraform provisions:

- AWS CloudTrail
- AWS Config
- Amazon GuardDuty
- AWS Security Hub
- AWS IAM Access Analyzer

### 5. Verify the Deployment

```
terraform output
```

Confirm that all governance services have been deployed successfully.


## 📥 Inputs

| Name | Description |
|------|-------------|
| `organization_id` | AWS Organization ID |
| `cloudtrail_bucket_name` | S3 bucket for CloudTrail logs |
| `kms_key_arn` | KMS key used for encryption |
| `enable_guardduty` | Enable GuardDuty |
| `enable_security_hub` | Enable Security Hub |
| `enable_config` | Enable AWS Config |
| `enable_access_analyzer` | Enable IAM Access Analyzer |
| `tags` | Resource tags |


## 📤 Outputs

The deployment exports the following outputs:

- **cloudtrail_arn**
  - ARN of the CloudTrail trail.

- **config_recorder_name**
  - AWS Config recorder name.

- **guardduty_detector_id**
  - GuardDuty detector ID.

- **security_hub_hub_arn**
  - Security Hub ARN.

- **access_analyzer_arn**
  - IAM Access Analyzer ARN.


## 🔍 What Each Service Does

### 📝 AWS CloudTrail

CloudTrail records every API call made within your AWS environment.

It provides:

- Audit logging
- User activity tracking
- Compliance reporting
- Incident investigations


### 📋 AWS Config

AWS Config continuously records resource configurations and evaluates compliance.

It provides:

- Configuration history
- Compliance evaluation
- Drift detection
- Resource inventory


### 🛡️ Amazon GuardDuty

GuardDuty continuously analyzes AWS activity using machine learning and threat intelligence.

It detects:

- Unauthorized access
- Compromised credentials
- Cryptocurrency mining
- Malicious network activity
- Data exfiltration attempts


### 🔒 AWS Security Hub

Security Hub aggregates findings from multiple AWS security services into a centralized dashboard.

It provides:

- Security posture management
- Compliance reporting
- Consolidated findings
- Security scorecards


### 🔎 IAM Access Analyzer

Access Analyzer continuously reviews IAM policies and resource policies to identify unintended public or cross-account access.

It helps identify:

- Public S3 buckets
- Cross-account resource sharing
- Overly permissive IAM policies
- Least-privilege violations


## 🛠️ Common Troubleshooting

### CloudTrail Already Exists

**Cause**

A trail with the same name already exists.

**Solution**

Import the existing trail into Terraform or use a different trail name.


### AWS Config Recorder Already Exists

**Cause**

AWS Config supports only one configuration recorder per account and Region.

**Solution**

Import the existing recorder into Terraform.


### GuardDuty Detector Already Exists

**Cause**

GuardDuty has already been enabled.

**Solution**

Import the existing detector into Terraform state.


### Security Hub Already Enabled

**Cause**

Security Hub has already been activated.

**Solution**

Import the existing Security Hub resource into Terraform.

### Access Analyzer Already Exists

**Cause**

An analyzer with the same name already exists.

**Solution**

Import the existing analyzer into Terraform.


## 🔒 Best Practices

- Enable CloudTrail in all AWS Regions.
- Encrypt CloudTrail logs using a customer-managed KMS key.
- Store audit logs in a dedicated logging account.
- Enable AWS Config organization-wide.
- Enable GuardDuty for every AWS account.
- Aggregate findings into a centralized Security Hub.
- Regularly review IAM Access Analyzer findings.
- Enable automatic remediation where appropriate.
- Protect audit logs from modification or deletion.
- Manage all governance resources through Terraform.


## 🤖 Future AI Operations Integration

The Governance layer provides the security telemetry that will later power the CloudHustler Commerce Platform's AI Operations capabilities.

Future integrations may include:

- Amazon Bedrock for security investigation assistance.
- Amazon SageMaker for anomaly detection.
- Automated incident summarization.
- AI-assisted compliance reporting.
- Intelligent remediation recommendations.


## 🎯 Next Steps

With the Governance layer deployed, the CloudHustler Commerce Platform is ready to continue building its enterprise foundation.

The recommended next deployments are:

1. Identity
2. Networking
3. Security
4. Observability
5. Environments
6. Platform Services
7. Application Infrastructure

The Governance deployment establishes continuous monitoring, auditing, compliance, and threat detection for every AWS account that will host the CloudHustler Commerce Platform.
````
