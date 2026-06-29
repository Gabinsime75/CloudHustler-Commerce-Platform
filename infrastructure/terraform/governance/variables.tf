#############################################
# AWS Configuration
#############################################

variable "aws_region" {

  description = "AWS Region."

  type = string

  default = "us-east-2"

}

#############################################
# Organization
#############################################

variable "organization_id" {

  description = "AWS Organization ID."

  type = string

}

#############################################
# AWS Config
#############################################

variable "enable_config" {

  description = "Enable AWS Config."

  type = bool

  default = true

}

variable "config_service_role_arn" {

  description = "AWS Config service role ARN."

  type = string

}

variable "config_bucket_name" {

  description = "AWS Config S3 bucket."

  type = string

}

variable "config_kms_key_arn" {

  description = "AWS Config KMS key ARN."

  type = string

}

#############################################
# CloudTrail
#############################################

variable "enable_cloudtrail" {

  description = "Enable AWS CloudTrail."

  type = bool

  default = true

}

variable "cloudtrail_bucket_name" {

  description = "CloudTrail S3 bucket."

  type = string

}

variable "cloudtrail_kms_key_arn" {

  description = "CloudTrail KMS key ARN."

  type = string

}

#############################################
# GuardDuty
#############################################

variable "enable_guardduty" {

  description = "Enable GuardDuty."

  type = bool

  default = true

}

#############################################
# Security Hub
#############################################

variable "enable_securityhub" {

  description = "Enable Security Hub."

  type = bool

  default = true

}

#############################################
# IAM Access Analyzer
#############################################

variable "enable_access_analyzer" {

  description = "Enable IAM Access Analyzer."

  type = bool

  default = true

}

#############################################
# Amazon Detective
#############################################

variable "enable_detective" {

  description = "Enable Amazon Detective."

  type = bool

  default = true

}

#############################################
# Tags
#############################################

variable "tags" {

  description = "Additional resource tags."

  type = map(string)

  default = {}

}