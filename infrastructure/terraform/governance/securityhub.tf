#############################################
# AWS Security Hub
#############################################

resource "aws_securityhub_account" "this" {

  count = var.enable_securityhub ? 1 : 0

  enable_default_standards = true

}

#############################################
# AWS Foundational Security Best Practices
#############################################

resource "aws_securityhub_standards_subscription" "aws_foundational" {

  count = var.enable_securityhub ? 1 : 0

  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"

  depends_on = [

    aws_securityhub_account.this

  ]

}

#############################################
# CIS AWS Foundations Benchmark
#############################################

resource "aws_securityhub_standards_subscription" "cis" {

  count = var.enable_securityhub ? 1 : 0

  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/cis-aws-foundations-benchmark/v/1.2.0"

  depends_on = [

    aws_securityhub_account.this

  ]

}

###########################################################
# Explanation
###########################################################
#
# This configuration enables AWS Security Hub
# for the CloudHustler Commerce Platform.
#
# AWS Security Hub provides a centralized
# security posture management service by
# aggregating findings from AWS security
# services and continuously evaluating the
# environment against security best practices
# and compliance frameworks.
#
###########################################################
# Features
###########################################################
#
# • Security Hub
#   Centralizes security findings across
#   AWS accounts and supported services.
#
# • AWS Foundational Security Best Practices
#   Enables AWS-recommended security controls
#   for continuous posture assessment.
#
# • CIS AWS Foundations Benchmark
#   Enables the CIS benchmark to measure
#   compliance against industry-recognized
#   AWS security standards.
#
# • Centralized Findings
#   Aggregates findings from GuardDuty,
#   IAM Access Analyzer, Amazon Inspector,
#   AWS Config, and other supported services.
#
# • Continuous Compliance
#   Continuously evaluates resources for
#   security misconfigurations and compliance
#   violations.
#
###########################################################
# Architecture
###########################################################
#
# This configuration only enables and configures
# AWS Security Hub.
#
# It intentionally does NOT create:
#
# • IAM Roles
# • AWS Organizations
# • Amazon S3 Buckets
# • AWS KMS Keys
#
# Those resources are provisioned by earlier
# platform layers and consumed by Governance
# where required.
#
###########################################################
# Dependencies
###########################################################
#
# Bootstrap Layer
#
# • None
#
# Organization Layer
#
# • AWS Organization
#   Enables centralized governance across
#   multiple AWS accounts.
#
# Identity Layer
#
# • None
#
# Governance Integrations
#
# • AWS Config
#   Supplies configuration and compliance data.
#
# • Amazon GuardDuty
#   Contributes threat detection findings.
#
# • IAM Access Analyzer
#   Contributes external access findings.
#
# • Amazon Inspector
#   Will contribute vulnerability findings
#   when introduced in the Security layer.
#
# Future Integrations
#
# • Amazon Detective
#   Investigates Security Hub findings.
#
# • Amazon EventBridge
#   Routes findings to downstream services.
#
# • AWS Lambda
#   Automates remediation workflows.
#
# • Amazon Bedrock
#   Generates AI-powered incident summaries,
#   compliance reports, and remediation
#   recommendations.
#
# AWS Security Hub serves as the central
# security aggregation service for the
# CloudHustler Commerce Platform, providing
# a single pane of glass for security posture,
# compliance, and threat visibility.
#