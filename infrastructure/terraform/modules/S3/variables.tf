variable "bucket_name" {
  description = "Name of the S3 bucket."
  type        = string
}

variable "versioning_enabled" {
  description = "Enable bucket versioning."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the customer-managed KMS key used for bucket encryption."
  type        = string
}

variable "enable_bucket_key" {
  description = "Enable S3 Bucket Keys to reduce KMS request costs."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow Terraform to delete non-empty buckets."
  type        = bool
  default     = false
}

variable "enable_logging" {
  description = "Enable S3 server access logging."
  type        = bool
  default     = false
}

variable "logging_bucket" {
  description = "Destination bucket for server access logs."
  type        = string
  default     = null
}

variable "logging_prefix" {
  description = "Prefix for server access logs"
  type        = string
  default     = "logs/"
}

variable "lifecycle_enabled" {
  description = "value"
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Enable lifecycle management."
  type        = number
  default     = 90
}
variable "enable_public_access_block" {
  description = "Enable S3 Block Public Access."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the bucket."
  type        = map(string)
  default     = {}
}

variable "bucket_policy" {
  description = "JSON bucket policy to attach to the bucket."
  type        = string
  default     = null
}