#############################################
# AWS CloudTrail
#############################################

resource "aws_cloudtrail" "this" {

  count = var.enable_cloudtrail ? 1 : 0

  name = "cloudhustler-organization-trail"

  ###########################################
  # Organization Trail
  ###########################################

  is_organization_trail = true
  is_multi_region_trail = true

  ###########################################
  # Logging
  ###########################################

  enable_logging                = true
  include_global_service_events = true

  ###########################################
  # Log File Validation
  ###########################################

  enable_log_file_validation = true

  ###########################################
  # Event Selection
  ###########################################

  event_selector {

    read_write_type           = "All"
    include_management_events = true

  }

  ###########################################
  # Storage
  ###########################################

  s3_bucket_name = var.cloudtrail_bucket_name

  kms_key_id = var.cloudtrail_kms_key_arn

  ###########################################
  # Tags
  ###########################################

  tags = merge(

    local.common_tags,

    var.tags,

    {

      Name    = "cloudhustler-organization-trail"
      Service = "CloudTrail"

    }

  )

}

