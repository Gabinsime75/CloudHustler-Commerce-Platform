###############################################################
# AWS Load Balancer Controller IAM Outputs
###############################################################

output "aws_load_balancer_controller_iam_policy_arn" {
  description = "IAM policy ARN used by the AWS Load Balancer Controller."
  value       = module.aws_load_balancer_controller.iam_policy_arn
}

output "aws_load_balancer_controller_pod_identity_role_arn" {
  description = "Pod Identity IAM role ARN used by the controller."
  value       = module.aws_load_balancer_controller.pod_identity_role_arn
}

output "aws_load_balancer_controller_pod_identity_association_id" {
  description = "EKS Pod Identity association ID for the controller."
  value       = module.aws_load_balancer_controller.pod_identity_association_id
}

###############################################################
# AWS Load Balancer Controller Helm Outputs
###############################################################

output "aws_load_balancer_controller_release_name" {
  description = "AWS Load Balancer Controller Helm release name."
  value       = module.aws_load_balancer_controller.release_name
}

output "aws_load_balancer_controller_release_namespace" {
  description = "Namespace containing the AWS Load Balancer Controller."
  value       = module.aws_load_balancer_controller.release_namespace
}

output "aws_load_balancer_controller_release_status" {
  description = "Status of the AWS Load Balancer Controller Helm release."
  value       = module.aws_load_balancer_controller.release_status
}

output "aws_load_balancer_controller_service_account_name" {
  description = "Service account used by the AWS Load Balancer Controller."
  value       = module.aws_load_balancer_controller.service_account_name
}

output "managed_target_group_arns" {
  description = "Target groups the AWS Load Balancer Controller may manage."
  value       = module.aws_load_balancer_controller.managed_target_group_arns
}

output "metrics_server_release_name" {
  description = "Metrics Server Helm release name."
  value       = module.metrics_server.release_name
}

output "metrics_server_release_namespace" {
  description = "Metrics Server namespace."
  value       = module.metrics_server.release_namespace
}

output "metrics_server_release_status" {
  description = "Metrics Server Helm release status."
  value       = module.metrics_server.release_status
}

output "metrics_server_chart_version" {
  description = "Installed Metrics Server chart version."
  value       = module.metrics_server.chart_version
}

###############################################################
# Istio Control Plane Outputs
###############################################################

output "istio_base_release_name" {
  description = "Istio base Helm release name."
  value       = module.istio_control_plane.base_release_name
}

output "istio_base_release_status" {
  description = "Istio base Helm release status."
  value       = module.istio_control_plane.base_release_status
}

output "istiod_release_name" {
  description = "Istiod Helm release name."
  value       = module.istio_control_plane.istiod_release_name
}

output "istiod_release_namespace" {
  description = "Namespace containing Istiod."
  value       = module.istio_control_plane.istiod_release_namespace
}

output "istiod_release_status" {
  description = "Istiod Helm release status."
  value       = module.istio_control_plane.istiod_release_status
}

output "istio_chart_version" {
  description = "Installed Istio chart version."
  value       = module.istio_control_plane.chart_version
}

###############################################################
# Istio Ingress Gateway Outputs
###############################################################

output "istio_ingress_gateway_release_name" {
  description = "Istio ingress gateway Helm release name."
  value       = module.istio_ingress_gateway.release_name
}

output "istio_ingress_gateway_namespace" {
  description = "Namespace containing the ingress gateway."
  value       = module.istio_ingress_gateway.release_namespace
}

output "istio_ingress_gateway_release_status" {
  description = "Istio ingress gateway Helm release status."
  value       = module.istio_ingress_gateway.release_status
}

output "istio_ingress_gateway_service_name" {
  description = "Ingress gateway Kubernetes Service name."
  value       = module.istio_ingress_gateway.service_name
}

output "istio_ingress_gateway_service_type" {
  description = "Ingress gateway Kubernetes Service type."
  value       = module.istio_ingress_gateway.service_type
}

################################################################################
# Istio Ingress TargetGroupBinding
################################################################################

output "istio_ingress_target_group_binding_name" {
  description = "Name of the Istio ingress TargetGroupBinding."
  value       = module.istio_ingress_target_group_binding.name
}

output "istio_ingress_target_group_binding_namespace" {
  description = "Namespace containing the Istio ingress TargetGroupBinding."
  value       = module.istio_ingress_target_group_binding.namespace
}

output "istio_ingress_target_group_binding_resource_id" {
  description = "Fully qualified identifier of the Istio ingress TargetGroupBinding."
  value       = module.istio_ingress_target_group_binding.resource_id
}

output "istio_ingress_target_group_arn" {
  description = "ARN of the AWS target group bound to the Istio ingress gateway."
  value       = module.istio_ingress_target_group_binding.target_group_arn
}


################################################################################
# ExternalDNS IAM Role Outputs
################################################################################

output "external_dns_iam_role_name" {
  description = "Name of the IAM role used by ExternalDNS through EKS Pod Identity."
  value       = module.external_dns.iam_role_name
}

output "external_dns_iam_role_arn" {
  description = "ARN of the IAM role used by ExternalDNS through EKS Pod Identity."
  value       = module.external_dns.iam_role_arn
}


################################################################################
# ExternalDNS IAM Policy Outputs
################################################################################

output "external_dns_iam_policy_name" {
  description = "Name of the IAM policy granting ExternalDNS access to Route 53."
  value       = module.external_dns.iam_policy_name
}

output "external_dns_iam_policy_arn" {
  description = "ARN of the IAM policy granting ExternalDNS access to Route 53."
  value       = module.external_dns.iam_policy_arn
}


################################################################################
# ExternalDNS EKS Pod Identity Outputs
################################################################################

output "external_dns_pod_identity_association_id" {
  description = "Identifier of the EKS Pod Identity association created for ExternalDNS."
  value       = module.external_dns.pod_identity_association_id
}

output "external_dns_pod_identity_association_arn" {
  description = "ARN of the EKS Pod Identity association created for ExternalDNS."
  value       = module.external_dns.pod_identity_association_arn
}


################################################################################
# ExternalDNS Kubernetes Outputs
################################################################################

output "external_dns_namespace" {
  description = "Kubernetes namespace in which ExternalDNS is deployed."
  value       = module.external_dns.namespace
}

output "external_dns_service_account_name" {
  description = "Kubernetes service account used by ExternalDNS."
  value       = module.external_dns.service_account_name
}


################################################################################
# ExternalDNS Helm Release Outputs
################################################################################

output "external_dns_helm_release_name" {
  description = "Name of the ExternalDNS Helm release."
  value       = module.external_dns.helm_release_name
}

output "external_dns_helm_release_namespace" {
  description = "Namespace containing the ExternalDNS Helm release."
  value       = module.external_dns.helm_release_namespace
}

output "external_dns_helm_release_chart" {
  description = "Name of the ExternalDNS Helm chart deployed by Terraform."
  value       = module.external_dns.helm_release_chart
}

output "external_dns_helm_release_version" {
  description = "Version of the ExternalDNS Helm chart deployed by Terraform."
  value       = module.external_dns.helm_release_version
}

output "external_dns_helm_release_status" {
  description = "Current status of the ExternalDNS Helm release."
  value       = module.external_dns.helm_release_status
}


################################################################################
# ExternalDNS Route 53 Configuration Outputs
################################################################################

output "external_dns_hosted_zone_id" {
  description = "Route 53 hosted zone managed by ExternalDNS."
  value       = module.external_dns.hosted_zone_id
}

output "external_dns_domain_filters" {
  description = "DNS domains that ExternalDNS is permitted to manage."
  value       = module.external_dns.domain_filters
}

output "external_dns_sources" {
  description = "Kubernetes and Istio resources watched by ExternalDNS."
  value       = module.external_dns.sources
}

output "external_dns_registry" {
  description = "Ownership registry used by ExternalDNS."
  value       = module.external_dns.registry
}

output "external_dns_txt_owner_id" {
  description = "TXT record ownership identifier used by ExternalDNS."
  value       = module.external_dns.txt_owner_id
}

# =============================================================================
# Karpenter Outputs
# =============================================================================
# Exposes the Karpenter Helm release, IAM roles, namespace, and interruption
# queue created through the reusable Karpenter module.
# =============================================================================

# -----------------------------------------------------------------------------
# Helm Deployment
# -----------------------------------------------------------------------------

output "karpenter_helm_release_name" {
  description = "Name of the Karpenter Helm release."
  value       = module.karpenter.helm_release_name
}

output "karpenter_namespace" {
  description = "Kubernetes namespace where Karpenter is installed."
  value       = module.karpenter.namespace
}

output "karpenter_chart_version" {
  description = "Installed Karpenter Helm chart version."
  value       = module.karpenter.chart_version
}

# -----------------------------------------------------------------------------
# Controller IAM
# -----------------------------------------------------------------------------

output "karpenter_controller_iam_role_arn" {
  description = "ARN of the IAM role used by the Karpenter controller."
  value       = module.karpenter.controller_iam_role_arn
}

output "karpenter_controller_iam_role_name" {
  description = "Name of the IAM role used by the Karpenter controller."
  value       = module.karpenter.controller_iam_role_name
}

# -----------------------------------------------------------------------------
# Worker-Node IAM
# -----------------------------------------------------------------------------

output "karpenter_node_iam_role_arn" {
  description = "ARN of the IAM role used by Karpenter-managed EC2 nodes."
  value       = module.karpenter.node_iam_role_arn
}

output "karpenter_node_iam_role_name" {
  description = "Name of the IAM role used by Karpenter-managed EC2 nodes."
  value       = module.karpenter.node_iam_role_name
}

# -----------------------------------------------------------------------------
# Interruption Handling
# -----------------------------------------------------------------------------

output "karpenter_interruption_queue_name" {
  description = "Name of the SQS queue used by Karpenter for interruption handling."
  value       = module.karpenter.interruption_queue_name
}

output "karpenter_interruption_queue_arn" {
  description = "ARN of the SQS queue used by Karpenter for interruption handling."
  value       = module.karpenter.interruption_queue_arn
}

# =============================================================================
# Karpenter EC2NodeClass Outputs
# =============================================================================

output "karpenter_ec2_node_class_name" {
  description = "Name of the Karpenter EC2NodeClass."
  value       = kubernetes_manifest.karpenter_ec2_node_class.manifest.metadata.name
}

output "karpenter_ec2_node_class_api_version" {
  description = "API version used by the Karpenter EC2NodeClass."
  value       = kubernetes_manifest.karpenter_ec2_node_class.manifest.apiVersion
}

output "karpenter_ec2_node_class_ami_family" {
  description = "AMI family configured for Karpenter-managed nodes."
  value       = var.karpenter_ami_family
}

output "karpenter_ec2_node_class_ami_alias" {
  description = "AMI alias configured for Karpenter-managed nodes."
  value       = var.karpenter_ami_alias
}

# =============================================================================
# Karpenter NodePool Outputs
# =============================================================================

output "karpenter_node_pool_name" {
  description = "Name of the default Karpenter NodePool."
  value       = kubernetes_manifest.karpenter_node_pool.manifest.metadata.name
}

output "karpenter_node_pool_capacity_types" {
  description = "Capacity types allowed by the default Karpenter NodePool."
  value       = var.karpenter_capacity_types
}

output "karpenter_node_pool_instance_categories" {
  description = "EC2 instance categories allowed by the default Karpenter NodePool."
  value       = var.karpenter_instance_categories
}

output "karpenter_node_pool_cpu_limit" {
  description = "Maximum total vCPU capacity permitted for the default Karpenter NodePool."
  value       = var.karpenter_node_pool_cpu_limit
}

output "karpenter_node_pool_memory_limit" {
  description = "Maximum total memory capacity permitted for the default Karpenter NodePool."
  value       = var.karpenter_node_pool_memory_limit
}

# =============================================================================
# Prometheus Monitoring Foundation Outputs
# =============================================================================
# These outputs expose the status and configuration of the Phase 1 Prometheus
# monitoring foundation.
# =============================================================================

# -----------------------------------------------------------------------------
# Prometheus Namespace
# -----------------------------------------------------------------------------

output "prometheus_namespace" {
  description = "Namespace where the Prometheus monitoring stack is deployed."
  value       = module.prometheus.namespace
}

# -----------------------------------------------------------------------------
# Prometheus Helm Release
# -----------------------------------------------------------------------------

output "prometheus_helm_release_name" {
  description = "Name of the Prometheus Helm release."
  value       = module.prometheus.helm_release_name
}

output "prometheus_helm_release_namespace" {
  description = "Namespace of the Prometheus Helm release."
  value       = module.prometheus.helm_release_namespace
}

output "prometheus_helm_chart" {
  description = "Name of the deployed Prometheus Helm chart."
  value       = module.prometheus.helm_chart
}

output "prometheus_helm_chart_version" {
  description = "Version of the deployed Prometheus Helm chart."
  value       = module.prometheus.helm_chart_version
}

output "prometheus_helm_release_status" {
  description = "Current status of the Prometheus Helm release."
  value       = module.prometheus.helm_release_status
}

output "prometheus_helm_release_revision" {
  description = "Current revision of the Prometheus Helm release."
  value       = module.prometheus.helm_release_revision
}

# -----------------------------------------------------------------------------
# Prometheus Server
# -----------------------------------------------------------------------------

output "prometheus_enabled" {
  description = "Indicates whether the Prometheus server is enabled."
  value       = module.prometheus.prometheus_enabled
}

output "prometheus_retention" {
  description = "Configured Prometheus metric retention period."
  value       = module.prometheus.prometheus_retention
}

output "prometheus_storage_size" {
  description = "Configured Prometheus persistent storage size."
  value       = module.prometheus.prometheus_storage_size
}

# -----------------------------------------------------------------------------
# Alertmanager
# -----------------------------------------------------------------------------

output "prometheus_alertmanager_enabled" {
  description = "Indicates whether Alertmanager is enabled."
  value       = module.prometheus.alertmanager_enabled
}

output "prometheus_alertmanager_replicas" {
  description = "Configured number of Alertmanager replicas."
  value       = module.prometheus.alertmanager_replicas
}

# -----------------------------------------------------------------------------
# Kubernetes Monitoring Components
# -----------------------------------------------------------------------------

output "prometheus_kube_state_metrics_enabled" {
  description = "Indicates whether kube-state-metrics is enabled."
  value       = module.prometheus.kube_state_metrics_enabled
}

output "prometheus_node_exporter_enabled" {
  description = "Indicates whether Prometheus Node Exporter is enabled."
  value       = module.prometheus.node_exporter_enabled
}

output "prometheus_default_rules_enabled" {
  description = "Indicates whether default Kubernetes monitoring rules are enabled."
  value       = module.prometheus.default_rules_enabled
}

