###############################################################
# Local Values
###############################################################

locals {

  #############################################################
  # Naming
  #############################################################

  name_prefix = "${var.project_name}-${var.environment}"

  vpc_name = "${local.name_prefix}-vpc"

  alb_name = "${local.name_prefix}-alb"

  #############################################################
  # Common Tags
  #############################################################

  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Layer       = "Networking"
    }
  )

  #############################################################
  # ACM Domains
  #############################################################

  acm_subject_alternative_names = concat(
    var.acm_subject_alternative_names,
    var.create_www_record ? ["www.${var.domain_name}"] : []
  )

  #############################################################
  # ALB Listener Configuration
  #############################################################

  alb_listeners = {

    http = {
      port     = 80
      protocol = "HTTP"

      ssl_policy      = null
      certificate_arn = null
      alpn_policy     = null

      default_action = {
        type = var.enable_https ? "redirect" : "forward"

        #########################################################
        # Forward
        #########################################################

        target_groups = var.enable_https ? null : [
          {
            name   = "app"
            weight = 100
          }
        ]

        stickiness = null

        #########################################################
        # Redirect
        #########################################################

        protocol    = var.enable_https ? "HTTPS" : null
        port        = var.enable_https ? "443" : null
        host        = null
        path        = null
        query       = null
        status_code = var.enable_https ? "HTTP_301" : null

        #########################################################
        # Fixed Response
        #########################################################

        content_type = null
        message_body = null
      }
    }

    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm[0].certificate_arn
      ssl_policy      = var.ssl_policy
      alpn_policy     = null

      default_action = {
        type = "forward"

        #########################################################
        # Forward
        #########################################################

        target_groups = [
          {
            name   = "app"
            weight = 100
          }
        ]

        stickiness = var.enable_alb_stickiness ? {
          enabled  = true
          duration = var.alb_stickiness_duration
        } : null

        #########################################################
        # Redirect
        #########################################################

        protocol    = null
        port        = null
        host        = null
        path        = null
        query       = null
        status_code = null

        #########################################################
        # Fixed Response
        #########################################################

        content_type = null
        message_body = null
      }
    }

  }

  #############################################################
  # Active ALB Listeners
  #############################################################

  active_alb_listeners = merge(
    {
      http = local.alb_listeners.http
    },
    var.enable_https ? {
      https = local.alb_listeners.https
    } : {}
  )

  #############################################################
  # ALB Target Groups
  #############################################################

  alb_target_groups = {

    app = {
      port        = var.app_target_group_port
      protocol    = var.app_target_group_protocol
      target_type = var.app_target_type

      deregistration_delay          = var.app_deregistration_delay
      slow_start                    = var.app_slow_start
      load_balancing_algorithm_type = var.app_load_balancing_algorithm_type

      health_check = {
        enabled             = true
        protocol            = var.app_health_check_protocol
        path                = var.app_health_check_path
        port                = var.app_health_check_port
        matcher             = var.app_health_check_matcher
        interval            = var.app_health_check_interval
        timeout             = var.app_health_check_timeout
        healthy_threshold   = var.app_healthy_threshold
        unhealthy_threshold = var.app_unhealthy_threshold
      }
    }

  }
  #############################################################
  # Route53 Records
  #############################################################

  route53_records = merge(
    var.create_app_record ? {
      app = {
        name = var.app_domain_name
        type = "A"

        alias = {
          name                   = module.alb.dns_name
          zone_id                = module.alb.zone_id
          evaluate_target_health = true
        }
      }
    } : {},

    var.create_www_record ? {
      www = {
        name = "www.${var.domain_name}"
        type = "A"

        alias = {
          name                   = module.alb.dns_name
          zone_id                = module.alb.zone_id
          evaluate_target_health = true
        }
      }
    } : {}
  )

}