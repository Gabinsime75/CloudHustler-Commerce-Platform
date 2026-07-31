# 07 – AWS WAF Deployment Validation

**Project:** CloudHustler Commerce Platform  
**Phase:** Security  
**Category:** AWS WAF / Application Load Balancer / Terraform  
**Severity:** Informational (Deployment Validation)  
**Status:** Successfully Validated  
**Date:** July 2026

---

# Overview

After deploying the AWS Web Application Firewall (WAF) for the CloudHustler Commerce Platform, a comprehensive validation was performed to ensure the Web ACL was correctly created, associated with the Application Load Balancer (ALB), logging was enabled, managed rule groups were active, and traffic inspection was functioning as expected.

Unlike previous troubleshooting incidents, no deployment defect was identified. This validation confirmed that the security layer was operating as designed before progressing to the Kubernetes platform deployment.

---

# Objective

Validate that:

- AWS WAF Web ACL was successfully created.
- Web ACL was associated with the Application Load Balancer.
- AWS Managed Rule Groups were active.
- WAF logging was enabled.
- Metrics were being published to CloudWatch.
- Terraform state accurately reflected deployed resources.

---

# Validation Process

## 1. Verify Terraform Deployment

The deployment was first validated through Terraform.

```bash
terraform plan
```

Expected:

```text
No changes.
Infrastructure is up-to-date.
```

This confirmed that the deployed infrastructure matched the Terraform configuration.

---

## 2. Verify Web ACL

```bash
aws wafv2 list-web-acls \
  --scope REGIONAL
```

Expected:

- Web ACL exists.
- Status is available.

Example:

```text
cloudhusller-commerce-platform-dev-alb-waf
```

---

## 3. Verify Web ACL Association

```bash
aws wafv2 get-web-acl-for-resource \
  --resource-arn <alb-arn>
```

Expected:

```text
WebACL:
```

The returned Web ACL ARN matches the deployed WAF.

This confirms that all traffic entering the Application Load Balancer is inspected before reaching backend services.

---

## 4. Verify Managed Rule Groups

```bash
aws wafv2 get-web-acl \
  --scope REGIONAL \
  --id <web-acl-id> \
  --name cloudhusller-commerce-platform-dev-alb-waf
```

Expected managed rule groups include:

- AWSManagedRulesCommonRuleSet
- AWSManagedRulesKnownBadInputsRuleSet
- AWSManagedRulesAmazonIpReputationList
- AWSManagedRulesAnonymousIpList

Each rule group should report a healthy configuration.

---

## 5. Verify WAF Logging

```bash
aws logs describe-log-groups
```

Expected log group:

```text
aws-waf-logs-cloudhusller-commerce-platform-dev-alb
```

This confirms that WAF logging is enabled for security analysis and incident investigations.

---

## 6. Verify CloudWatch Metrics

```bash
aws cloudwatch list-metrics \
  --namespace AWS/WAFV2
```

Expected metrics include:

- AllowedRequests
- BlockedRequests
- CountedRequests

Metrics confirm that WAF is actively evaluating incoming traffic.

---

## 7. Verify Terraform State

```bash
terraform state list
```

Expected resources include:

```text
module.waf.aws_wafv2_web_acl.this
module.waf.aws_wafv2_web_acl_association.this
module.waf.aws_cloudwatch_log_group.this
module.waf.aws_wafv2_web_acl_logging_configuration.this
```

This confirms Terraform maintains full ownership of the deployed security resources.

---

# Validation Results

| Component | Status |
|-----------|--------|
| Web ACL Created | ✅ Passed |
| ALB Association | ✅ Passed |
| Managed Rule Groups | ✅ Passed |
| Logging Enabled | ✅ Passed |
| CloudWatch Metrics | ✅ Passed |
| Terraform State | ✅ Passed |

Overall Result:

**AWS WAF deployment successfully validated.**

---

# Security Controls Verified

The deployment confirmed protection against common web application threats, including:

- SQL Injection (SQLi)
- Cross-Site Scripting (XSS)
- Known malicious request patterns
- Anonymous proxy and VPN traffic
- Poor reputation IP addresses
- Excessive request rates (rate limiting, if enabled)

These protections provide a strong baseline security posture for internet-facing workloads.

---

# Lessons Learned

- Infrastructure deployment is only one part of a successful implementation; operational validation is equally important.
- Associating a Web ACL with the ALB is critical—an unassociated Web ACL provides no protection.
- Enabling WAF logging significantly improves troubleshooting and forensic investigations.
- CloudWatch metrics provide immediate visibility into WAF activity and should be included in ongoing operational monitoring.

---

# Operational Best Practices

To maintain a secure deployment:

- Regularly review WAF logs for blocked and suspicious requests.
- Monitor CloudWatch metrics for unusual traffic patterns.
- Keep AWS Managed Rule Groups enabled and up to date.
- Periodically evaluate rule exclusions to reduce false positives.
- Configure CloudWatch alarms for spikes in blocked requests or abnormal traffic volumes.

---

# Key Takeaways

| Area | Result |
|-------|--------|
| Deployment | Successful |
| ALB Protection | Active |
| Logging | Enabled |
| CloudWatch Metrics | Active |
| Managed Rules | Operational |
| Terraform State | Healthy |
| Final Status | AWS WAF fully deployed and validated |

---

# Interview Story (STAR Format)

## Situation

As part of the security layer for the CloudHustler Commerce Platform, I deployed AWS WAF to protect the public-facing Application Load Balancer from common web application attacks before exposing any workloads to the internet.

## Task

My responsibility was to verify that the Web ACL was not only deployed successfully through Terraform, but also actively protecting the Application Load Balancer, publishing logs, and generating operational metrics.

## Action

I validated the deployment by confirming Terraform state consistency, verifying the Web ACL existed and was associated with the ALB, ensuring AWS Managed Rule Groups were active, checking that WAF logging was configured to CloudWatch Logs, and confirming that CloudWatch metrics were being generated for allowed and blocked requests. I also reviewed the deployed rule set to ensure it provided protection against common threats such as SQL injection, cross-site scripting, and known malicious IP addresses.

## Result

The validation confirmed that AWS WAF was fully operational and protecting the CloudHustler Commerce Platform as designed. Logging and metrics were functioning correctly, providing the operational visibility needed for monitoring, incident response, and future security tuning without requiring any changes to the Terraform configuration.