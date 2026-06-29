#############################################
# Amazon GuardDuty
#############################################

resource "aws_guardduty_detector" "this" {

  count = var.enable_guardduty ? 1 : 0

  enable = true

  finding_publishing_frequency = "FIFTEEN_MINUTES"

  tags = merge(

    local.common_tags,

    var.tags,

    {

      Name    = "cloudhustler-guardduty"
      Service = "GuardDuty"

    }

  )

}

###########################################################
# Explanation
###########################################################
#
# This configuration enables Amazon GuardDuty
# for the CloudHustler Commerce Platform.
#
# GuardDuty is AWS's intelligent threat detection
# service that continuously monitors AWS accounts,
# workloads, and data sources for malicious
# activity and unauthorized behavior.
#
# GuardDuty analyzes AWS CloudTrail events,
# VPC Flow Logs, DNS logs, EKS audit logs,
# S3 data events, and runtime telemetry to
# identify potential security threats.
#
###########################################################
# Features
###########################################################
#
# • Continuous Threat Detection
#   Continuously monitors AWS resources for
#   suspicious activity.
#
# • CloudTrail Analysis
#   Detects unauthorized API calls and
#   anomalous account activity.
#
# • VPC Flow Log Analysis
#   Identifies suspicious network traffic,
#   reconnaissance, and compromised instances.
#
# • DNS Log Analysis
#   Detects communication with known malicious
#   domains and command-and-control servers.
#
# • Finding Publishing
#   Publishes findings every 15 minutes for
#   near real-time security monitoring.
#
# • Security Hub Integration
#   Findings can be aggregated into AWS
#   Security Hub for centralized visibility.
#
###########################################################
# Architecture
###########################################################
#
# This configuration only enables and configures
# Amazon GuardDuty.
#
# It intentionally does NOT create:
#
# • IAM Roles
# • Amazon S3 Buckets
# • AWS KMS Keys
# • Notification Infrastructure
#
# These resources are provisioned by other
# platform layers and integrated separately.
#
###########################################################
# Dependencies
###########################################################
#
# Bootstrap Layer
#
# • None
#
# Identity Layer
#
# • None
#
# Governance Integrations
#
# • AWS CloudTrail
#   Provides API activity analyzed by GuardDuty.
#
# • AWS Security Hub
#   Aggregates GuardDuty findings into a
#   centralized security dashboard.
#
# Future Integrations
#
# • Amazon Detective
#   Investigates GuardDuty findings.
#
# • Amazon EventBridge
#   Routes findings to downstream services.
#
# • AWS Lambda
#   Performs automated remediation.
#
# • Amazon Bedrock
#   Generates AI-powered incident summaries
#   and remediation recommendations.
#
# This keeps the Governance layer focused on
# enabling AWS-native threat detection while
# allowing downstream services to consume
# GuardDuty findings for investigation,
# automation, and AI-assisted operations.
#