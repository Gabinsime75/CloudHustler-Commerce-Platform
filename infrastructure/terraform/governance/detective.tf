#############################################
# Amazon Detective
#############################################

resource "aws_detective_graph" "this" {

  count = var.enable_detective ? 1 : 0

  tags = merge(

    local.common_tags,

    var.tags,

    {

      Name    = "cloudhustler-detective"
      Service = "Amazon Detective"

    }

  )

}

# Explanation

# This configuration enables Amazon Detective, AWS's security investigation service.
# Unlike GuardDuty, which detects threats, Amazon Detective helps you investigate and understand those threats by analyzing relationships between AWS resources, users, and activities.

# Resource
# Amazon Detective Graph
# Creates a Detective behavior graph for the AWS account.
# Once enabled, Detective automatically ingests data from supported AWS services to help security teams investigate incidents.

# CloudHustler Security Workflow
# CloudTrail
#       │
# AWS Config
#       │
# GuardDuty
#       │
# Security Hub
#       │
#       ▼
# Amazon Detective
#       │
#       ├── Investigation
#       ├── Timeline Analysis
#       ├── User Activity
#       ├── API Analysis
#       ├── EC2 Behavior
#       └── EKS Investigation

# CloudHustler Architecture: Amazon Detective complements the other governance services:
# CloudTrail – Records API activity.
# AWS Config – Tracks configuration changes.
# GuardDuty – Detects suspicious behavior.
# Security Hub – Aggregates security findings.
# Amazon Detective – Investigates and correlates findings to accelerate incident response.

# This gives the CloudHustler Commerce Platform a complete detection-and-investigation workflow suitable for an enterprise security posture.