#############################################
# AWS CloudTrail
#############################################

output "cloudtrail_arn" {

  description = "ARN of the AWS CloudTrail."

  value = var.enable_cloudtrail ? aws_cloudtrail.this[0].arn : null

}

output "cloudtrail_home_region" {

  description = "Home region of the AWS CloudTrail."

  value = var.enable_cloudtrail ? aws_cloudtrail.this[0].home_region : null

}

output "cloudtrail_s3_bucket_name" {

  description = "Amazon S3 bucket used by AWS CloudTrail."

  value = var.cloudtrail_bucket_name

}

#############################################
# AWS Config
#############################################

output "config_recorder_name" {

  description = "AWS Config configuration recorder name."

  value = var.enable_config ? aws_config_configuration_recorder.this[0].name : null

}

output "config_delivery_channel_name" {

  description = "AWS Config delivery channel name."

  value = var.enable_config ? aws_config_delivery_channel.this[0].name : null

}

#############################################
# Amazon GuardDuty
#############################################

output "guardduty_detector_id" {

  description = "Amazon GuardDuty detector ID."

  value = var.enable_guardduty ? aws_guardduty_detector.this[0].id : null

}

#############################################
# AWS Security Hub
#############################################

output "securityhub_account_id" {

  description = "AWS Security Hub account ID."

  value = var.enable_securityhub ? aws_securityhub_account.this[0].id : null

}

#############################################
# IAM Access Analyzer
#############################################

output "access_analyzer_arn" {

  description = "IAM Access Analyzer ARN."

  value = var.enable_access_analyzer ? aws_accessanalyzer_analyzer.this[0].arn : null

}

output "access_analyzer_name" {

  description = "IAM Access Analyzer name."

  value = var.enable_access_analyzer ? aws_accessanalyzer_analyzer.this[0].analyzer_name : null

}

#############################################
# Amazon Detective
#############################################

output "detective_graph_arn" {

  description = "Amazon Detective behavior graph ARN."

  value = var.enable_detective ? aws_detective_graph.this[0].graph_arn : null

}

#############################################
# Governance Summary
#############################################

output "governance_services" {

  description = "Summary of enabled governance services."

  value = {

    cloudtrail       = var.enable_cloudtrail
    config           = var.enable_config
    guardduty        = var.enable_guardduty
    securityhub      = var.enable_securityhub
    access_analyzer  = var.enable_access_analyzer
    detective        = var.enable_detective

  }

}

# Why these outputs?

# These outputs expose the key identifiers that other root configurations or automation workflows may need.

# Service	Output
# CloudTrail	Trail ARN, Home Region
# AWS Config	Recorder Name, Delivery Channel
# GuardDuty	Detector ID
# Security Hub	Account ID
# IAM Access Analyzer	Analyzer ARN, Analyzer Name
# Amazon Detective	Behavior Graph ARN

# These outputs will become especially useful in later phases when integrating:

# EventBridge for event routing
# Lambda for automated remediation
# SNS for notifications
# Amazon Bedrock for AI-powered incident analysis
# OpenSearch for centralized search and analytics
# CloudWatch for observability
# AI Ops workflows that consume governance and security data