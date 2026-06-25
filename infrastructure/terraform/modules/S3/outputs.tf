output "bucket_id" {
  description = "ID of the S3 bucket."
  value       = aws_s3_bucket.s3_bucket.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.s3_bucket.arn
}

output "bucket_name" {
  description = "Name of the S3 bucket."
  value       = aws_s3_bucket.s3_bucket.bucket
}


output "bucket_domain_name" {
  description = "DNS domain name of the S3 bucket."
  value       = aws_s3_bucket.s3_bucket.bucket_domain_name
}


output "regional_domain_name" {
  description = "Regional DNS name of the S3 bucket."
  value       = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
}