
# 1. S3 Bucket
#-------------------------------------------
resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = var.tags
}

# Ownership Controls
#--------------------------------------------------------
resource "aws_s3_bucket_ownership_controls" "s3_ownership" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Public Access Block
#---------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "s3_public_access_block" {
  count  = var.enable_public_access_block ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Server Side Encryption
#--------------------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sse_config" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }

    bucket_key_enabled = var.enable_bucket_key
  }

}

# Versioning
#----------------------------------------------------
resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# Lifecycle Rules
#-------------------------------------------------------
resource "aws_s3_bucket_lifecycle_configuration" "s3_lifecycle_config" {
  count  = var.lifecycle_enabled ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    id     = "lifecycle-rule"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }
}

# Server Access Logging
#---------------------------------------------------------
resource "aws_s3_bucket_logging" "s3_logging" {
  count         = var.enable_logging ? 1 : 0
  bucket        = aws_s3_bucket.s3_bucket.id
  target_bucket = var.logging_bucket
  target_prefix = var.logging_prefix
}

# Bucket Policy
#----------------------------------------------------------
resource "aws_s3_bucket_policy" "this" {
  count  = var.bucket_policy == null ? 0 : 1
  bucket = aws_s3_bucket.s3_bucket.id
  policy = var.bucket_policy
}