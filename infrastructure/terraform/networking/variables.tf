###############################################################
# General
###############################################################

variable "aws_region" {
  description = "AWS region where networking resources will be deployed."
  type        = string
}

variable "project_name" {
  description = "Project name used for naming and tagging resources."
  type        = string
}

variable "environment" {
  description = "Environment name such as dev, staging, or prod."
  type        = string

  validation {
    condition = contains(
      ["dev", "staging", "prod", "shared"],
      var.environment
    )

    error_message = "environment must be one of: dev, staging, prod, shared."
  }
}

variable "tags" {
  description = "Additional tags applied to all supported resources."
  type        = map(string)
  default     = {}
}

###############################################################
# VPC
###############################################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

# variable "availability_zones" {
#   description = "Availability Zones used for subnet placement."
#   type        = list(string)
# }

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets."
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateways for private subnet egress."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT Gateway instead of one NAT Gateway per AZ."
  type        = bool
  default     = false
}

# variable "enable_vpc_flow_logs" {
#   description = "Whether to enable VPC Flow Logs."
#   type        = bool
#   default     = true
# }

###############################################################
# Security Groups
###############################################################

variable "alb_ingress_cidrs" {
  description = "CIDR blocks allowed to access the public ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_https_ingress" {
  description = "Whether to allow HTTPS ingress to the ALB security group."
  type        = bool
  default     = true
}

variable "enable_http_ingress" {
  description = "Whether to allow HTTP ingress to the ALB security group."
  type        = bool
  default     = true
}

###############################################################
# Domain / DNS
###############################################################

variable "domain_name" {
  description = "Root domain name used for ACM and Route53."
  type        = string
}

variable "hosted_zone_id" {
  description = "Existing Route53 Hosted Zone ID."
  type        = string
}

variable "app_domain_name" {
  description = "Application domain name that points to the ALB."
  type        = string
}

variable "create_app_record" {
  description = "Whether to create the application Route53 alias record."
  type        = bool
  default     = true
}

variable "create_www_record" {
  description = "Whether to create a www Route53 alias record."
  type        = bool
  default     = false
}

###############################################################
# ACM
###############################################################

variable "enable_https" {
  description = "Whether to create an HTTPS listener and ACM certificate."
  type        = bool
  default     = true
}

variable "acm_subject_alternative_names" {
  description = "Subject Alternative Names for the ACM certificate."
  type        = list(string)
  default     = []
}

variable "acm_key_algorithm" {
  description = "Key algorithm for the ACM certificate."
  type        = string
  default     = "RSA_2048"

  validation {
    condition = contains(
      [
        "RSA_2048",
        "EC_prime256v1",
        "EC_secp384r1"
      ],
      var.acm_key_algorithm
    )

    error_message = "acm_key_algorithm must be RSA_2048, EC_prime256v1, or EC_secp384r1."
  }
}

variable "certificate_transparency_logging_preference" {
  description = "Certificate Transparency logging preference."
  type        = string
  default     = "ENABLED"

  validation {
    condition = contains(
      ["ENABLED", "DISABLED"],
      upper(var.certificate_transparency_logging_preference)
    )

    error_message = "certificate_transparency_logging_preference must be ENABLED or DISABLED."
  }
}

###############################################################
# ALB
###############################################################

variable "alb_internal" {
  description = "Whether the ALB is internal."
  type        = bool
  default     = false
}

variable "alb_ip_address_type" {
  description = "ALB IP address type."
  type        = string
  default     = "ipv4"

  validation {
    condition = contains(
      ["ipv4", "dualstack"],
      var.alb_ip_address_type
    )

    error_message = "alb_ip_address_type must be ipv4 or dualstack."
  }
}

variable "enable_alb_deletion_protection" {
  description = "Whether to enable ALB deletion protection."
  type        = bool
  default     = true
}

variable "enable_alb_cross_zone_load_balancing" {
  description = "Whether to enable ALB cross-zone load balancing."
  type        = bool
  default     = true
}

variable "enable_alb_http2" {
  description = "Whether to enable HTTP/2 on the ALB."
  type        = bool
  default     = true
}

variable "alb_idle_timeout" {
  description = "ALB idle timeout in seconds."
  type        = number
  default     = 60
}

variable "alb_drop_invalid_header_fields" {
  description = "Whether the ALB should drop invalid HTTP header fields."
  type        = bool
  default     = true
}

variable "alb_desync_mitigation_mode" {
  description = "ALB desync mitigation mode."
  type        = string
  default     = "defensive"

  validation {
    condition = contains(
      ["monitor", "defensive", "strictest"],
      var.alb_desync_mitigation_mode
    )

    error_message = "alb_desync_mitigation_mode must be monitor, defensive, or strictest."
  }
}

variable "ssl_policy" {
  description = "SSL policy for the HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

###############################################################
# ALB Access Logs
###############################################################

variable "enable_alb_access_logs" {
  description = "Whether to enable ALB access logs."
  type        = bool
  default     = false
}

variable "alb_access_logs_bucket" {
  description = "S3 bucket for ALB access logs."
  type        = string
  default     = null
}

variable "alb_access_logs_prefix" {
  description = "S3 prefix for ALB access logs."
  type        = string
  default     = null
}

###############################################################
# ALB Target Group
###############################################################

variable "app_target_group_port" {
  description = "Application target group port."
  type        = number
  default     = 80
}

variable "app_target_group_protocol" {
  description = "Application target group protocol."
  type        = string
  default     = "HTTP"
}

variable "app_target_type" {
  description = "Application target type."
  type        = string
  default     = "instance"

  validation {
    condition = contains(
      ["instance", "ip", "lambda"],
      var.app_target_type
    )

    error_message = "app_target_type must be instance, ip, or lambda."
  }
}

variable "app_deregistration_delay" {
  description = "Target group deregistration delay in seconds."
  type        = number
  default     = 300
}

variable "app_slow_start" {
  description = "Target group slow start duration in seconds."
  type        = number
  default     = 0
}

variable "app_load_balancing_algorithm_type" {
  description = "Target group load balancing algorithm."
  type        = string
  default     = "round_robin"

  validation {
    condition = contains(
      ["round_robin", "least_outstanding_requests", "weighted_random"],
      var.app_load_balancing_algorithm_type
    )

    error_message = "app_load_balancing_algorithm_type must be round_robin, least_outstanding_requests, or weighted_random."
  }
}

###############################################################
# ALB Target Group Health Check
###############################################################

variable "app_health_check_protocol" {
  description = "Application target group health check protocol."
  type        = string
  default     = "HTTP"
}

variable "app_health_check_path" {
  description = "Application target group health check path."
  type        = string
  default     = "/health"
}

variable "app_health_check_port" {
  description = "Application target group health check port."
  type        = string
  default     = "traffic-port"
}

variable "app_health_check_matcher" {
  description = "Application target group health check matcher."
  type        = string
  default     = "200-399"
}

variable "app_health_check_interval" {
  description = "Application target group health check interval in seconds."
  type        = number
  default     = 30
}

variable "app_health_check_timeout" {
  description = "Application target group health check timeout in seconds."
  type        = number
  default     = 5
}

variable "app_healthy_threshold" {
  description = "Application target group healthy threshold."
  type        = number
  default     = 5
}

variable "app_unhealthy_threshold" {
  description = "Application target group unhealthy threshold."
  type        = number
  default     = 2
}

###############################################################
# ALB Stickiness
###############################################################

variable "enable_alb_stickiness" {
  description = "Whether to enable ALB target group stickiness in the HTTPS listener forward action."
  type        = bool
  default     = false
}

variable "alb_stickiness_duration" {
  description = "ALB stickiness duration in seconds."
  type        = number
  default     = 3600
}