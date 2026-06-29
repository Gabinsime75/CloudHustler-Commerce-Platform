#############################################
# AWS Config
#############################################

resource "aws_config_configuration_recorder" "this" {

  count = var.enable_config ? 1 : 0

  name = "cloudhustler-config-recorder"

  role_arn = var.config_service_role_arn

  recording_group {

    all_supported                 = true
    include_global_resource_types = true

  }

}

#############################################
# AWS Config Delivery Channel
#############################################

resource "aws_config_delivery_channel" "this" {

  count = var.enable_config ? 1 : 0

  name = "cloudhustler-config-delivery-channel"

  s3_bucket_name = var.config_bucket_name

  s3_kms_key_arn = var.config_kms_key_arn

  depends_on = [

    aws_config_configuration_recorder.this

  ]

}

#############################################
# AWS Config Configuration Recorder Status
#############################################

resource "aws_config_configuration_recorder_status" "this" {

  count = var.enable_config ? 1 : 0

  name = aws_config_configuration_recorder.this[0].name

  is_enabled = true

  depends_on = [

    aws_config_delivery_channel.this

  ]

}

###########################################################
# Explanation
###########################################################
#
# This configuration enables AWS Config for the
# CloudHustler Commerce Platform.
#
# AWS Config continuously records AWS resource
# configurations, tracks configuration changes,
# and provides the foundation for governance,
# compliance monitoring, auditing, and security
# posture management.
#
###########################################################
# Features
###########################################################
#
# • Configuration Recorder
#   Records the configuration of supported AWS
#   resources across the account.
#
# • Global Resource Recording
#   Includes global resource types such as IAM
#   users, groups, roles, and policies.
#
# • Delivery Channel
#   Delivers configuration snapshots and change
#   notifications to a centralized Amazon S3 bucket.
#
# • AWS KMS Encryption
#   Encrypts configuration snapshots using a
#   customer-managed AWS KMS key.
#
# • Automatic Recording
#   Automatically enables the configuration
#   recorder after the delivery channel is created.
#
###########################################################
# Architecture
###########################################################
#
# This configuration only enables and configures
# AWS Config.
#
# It intentionally does NOT create:
#
# • Amazon S3 Bucket
# • AWS KMS Key
# • IAM Service Role
#
# These resources are provisioned by earlier
# platform layers and supplied to Governance
# through Terraform variables.
#
###########################################################
# Dependencies
###########################################################
#
# Bootstrap Layer
#
# • KMS Module
#   Provides the customer-managed KMS key used
#   to encrypt AWS Config snapshots.
#
# • S3 Module
#   Provides the centralized AWS Config bucket.
#
# Identity Layer
#
# • Config Service Role Module
#   Provides the IAM role required by AWS Config
#   to record and deliver configuration data.
#
# This keeps the Governance layer focused solely
# on configuring governance services while
# reusing the foundational infrastructure built
# during earlier phases of the CloudHustler
# Commerce Platform.
#