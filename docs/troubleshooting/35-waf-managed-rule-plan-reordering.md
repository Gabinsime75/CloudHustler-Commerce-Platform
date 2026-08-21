# 32 – WAF Managed Rules Appeared Removed and Re-Added in Terraform Plan

**Project:** CloudHustler Commerce Platform  
**Phase:** 7 – Edge & Security  
**Category:** AWS WAF / Terraform Plan Interpretation  
**Severity:** Low  
**Status:** Resolved / Understood  
**Date:** August 2026

---

## Incident Summary

When adding IP reputation, rate limiting, and rule overrides, Terraform displayed existing WAF rules as removed and re-added.

Example:

```text
- AWSManagedRulesCommonRuleSet
- AWSManagedRulesKnownBadInputsRuleSet

+ AWSManagedRulesAmazonIpReputationList
+ AWSManagedRulesCommonRuleSet
+ AWSManagedRulesKnownBadInputsRuleSet
```

## Root Cause

The WAF `rule` blocks are nested inside the same `aws_wafv2_web_acl` resource. Provider diff rendering can show nested block reordering as remove/re-add even when the parent resource is updated in place.

## Resolution

We focused on the parent resource action and plan summary:

```text
~ update in-place
Plan: 0 to add, 1 to change, 0 to destroy.
```

## Validation

```bash
aws wafv2 get-web-acl   --scope CLOUDFRONT   --region us-east-1   --name cloudhusller-commerce-platform-dev-cloudfront-waf   --id <web-acl-id>   --query 'WebACL.Rules[*].[Name,Priority]'   --output table
```

confirmed:

```text
10  AWSManagedRulesCommonRuleSet
20  AWSManagedRulesKnownBadInputsRuleSet
30  AWSManagedRulesAmazonIpReputationList
40  RateLimitPerIP
```

## Lesson Learned

Distinguish nested block diff noise from actual resource replacement. The parent resource action and add/change/destroy summary are the critical indicators.
