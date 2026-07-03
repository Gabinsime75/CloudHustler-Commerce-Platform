###############################################################
# S3 Default Encryption
###############################################################

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {

  count = var.enable_encryption ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {

    bucket_key_enabled = local.use_kms ? var.bucket_key_enabled : null

    apply_server_side_encryption_by_default {

      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = local.use_kms ? var.kms_key_arn : null

    }

  }

}