variable "aws_region" {
  description = "AWS Region for the bootstrap deployment."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
}