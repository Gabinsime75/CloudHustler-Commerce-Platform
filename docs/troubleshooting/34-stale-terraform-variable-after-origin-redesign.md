# 31 – Stale Terraform Variable Prompt After Origin Redesign

**Project:** CloudHustler Commerce Platform  
**Phase:** 7 – Edge & Security  
**Category:** Terraform / CloudFront Inputs  
**Severity:** Low  
**Status:** Resolved  
**Date:** August 2026

---

## Incident Summary

Terraform unexpectedly prompted:

```text
var.alb_dns_name
Enter a value:
```

after CloudFront had already been redesigned to use:

```text
origin.cloudhusller.com
```

## Root Cause

The root module still declared the old required variable, and `terraform.tfvars` still contained a stale `alb_dns_name`.

## Resolution

We removed the obsolete root variable and stale tfvars entry while keeping the child module input:

```hcl
alb_dns_name = "origin.${var.domain_name}"
```

## Validation

`terraform plan` ran without interactive prompts or undeclared-variable warnings.

## Lesson Learned

After Terraform input refactoring, clean up both variable declarations and `.tfvars` entries.
