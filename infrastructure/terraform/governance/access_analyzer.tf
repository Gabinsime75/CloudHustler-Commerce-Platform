#############################################
# IAM Access Analyzer
#############################################

resource "aws_accessanalyzer_analyzer" "this" {

  count = var.enable_access_analyzer ? 1 : 0

  analyzer_name = "cloudhustler-access-analyzer"

  type = "ORGANIZATION"

  tags = merge(

    local.common_tags,

    var.tags,

    {

      Name    = "cloudhustler-access-analyzer"
      Service = "IAM Access Analyzer"

    }

  )

}

###########################################################
# Explanation
###########################################################
#
# This configuration enables IAM Access Analyzer
# for the CloudHustler Commerce Platform.
#
# IAM Access Analyzer continuously evaluates
# resource-based policies to identify resources
# that are accessible from outside the AWS
# Organization.
#
# It helps enforce the principle of least
# privilege by detecting unintended external
# access to AWS resources.
#
###########################################################
# Features
###########################################################
#
# • Organization Analyzer
#   Continuously analyzes resource policies
#   across the AWS Organization.
#
# • External Access Detection
#   Identifies resources that can be accessed
#   by external AWS accounts, anonymous users,
#   or public principals.
#
# • Continuous Policy Evaluation
#   Evaluates newly created and modified
#   resource policies in near real time.
#
# • Least Privilege Validation
#   Helps identify overly permissive resource
#   policies that should be restricted.
#
# • Security Hub Integration
#   Findings can be aggregated into AWS
#   Security Hub for centralized visibility.
#
###########################################################
# Architecture
###########################################################
#
# This configuration only enables and configures
# IAM Access Analyzer.
#
# It intentionally does NOT create:
#
# • IAM Roles
# • Resource Policies
# • AWS Organizations
# • Amazon S3 Buckets
# • AWS KMS Keys
#
# Those resources are provisioned and managed
# by other platform layers.
#
###########################################################
# Dependencies
###########################################################
#
# Bootstrap Layer
#
# • None
#
# Organization Layer
#
# • AWS Organization
#   Required because the analyzer operates
#   in ORGANIZATION mode.
#
# Identity Layer
#
# • None
#
# Governance Integrations
#
# • AWS Security Hub
#   Aggregates Access Analyzer findings into
#   a centralized security dashboard.
#
# Future Integrations
#
# • Amazon EventBridge
#   Routes findings for automated workflows.
#
# • AWS Lambda
#   Performs automated remediation and
#   policy enforcement.
#
# • Amazon Bedrock
#   Generates AI-powered explanations of
#   external access findings and recommends
#   least-privilege policy improvements.
#
# IAM Access Analyzer complements AWS Config,
# GuardDuty, and Security Hub by providing
# continuous visibility into resource-based
# permissions and helping detect unintended
# external access across the CloudHustler
# Commerce Platform.
#