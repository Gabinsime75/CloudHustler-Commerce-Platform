# 28 – CloudFront Custom Aliases Missing from Distribution Plan

**Project:** CloudHustler Commerce Platform  
**Phase:** 7 – Edge & Security  
**Category:** CloudFront / Terraform Module  
**Severity:** Medium  
**Status:** Resolved  
**Date:** August 2026

---

## Incident Summary

Terraform planned the ACM certificate and Route 53 cutover, but the CloudFront plan did not show:

```text
cloudhusller.com
www.cloudhusller.com
```

as aliases.

State showed:

```hcl
aliases = []
```

## Root Cause

The root module passed `aliases`, and the child module declared the variable, but `aws_cloudfront_distribution` did not consume it.

## Resolution

We added:

```hcl
aliases = var.aliases
```

inside `modules/cloudfront/main.tf`.

## Validation

The next plan showed:

```text
~ aliases = [
    + "cloudhusller.com",
    + "www.cloudhusller.com",
  ]
```

After apply, both aliases appeared on the distribution.

## Lesson Learned

A Terraform variable must be declared, passed, and actually referenced by the child resource.
