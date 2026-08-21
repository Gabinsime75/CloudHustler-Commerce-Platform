# 27 – Route 53 Terraform Ownership Conflict During CloudFront Cutover

**Project:** CloudHustler Commerce Platform  
**Phase:** 7 – Edge & Security  
**Category:** Route 53 / Terraform State / CloudFront  
**Severity:** High  
**Status:** Resolved  
**Date:** August 2026

---

## Incident Summary

Before Phase 7, the networking root managed:

```text
cloudhusller.com → ALB
```

Phase 7 required:

```text
cloudhusller.com → CloudFront
www.cloudhusller.com → CloudFront
```

while networking needed to retain:

```text
origin.cloudhusller.com → ALB
```

## Root Cause

The apex record could not safely be managed by both `networking` and `edge-security`.

A second issue appeared because `origin` was nested inside the same `create_app_record` conditional, so disabling the app record also caused Terraform to propose destroying `origin.cloudhusller.com`.

## Resolution

We removed the apex record from networking state without deleting it:

```bash
terraform state rm 'module.route53.aws_route53_record.this["app"]'
```

Then separated the locals so `origin` remained unconditional.

Final ownership:

```text
networking/
└── origin.cloudhusller.com → ALB

edge-security/
├── cloudhusller.com → CloudFront
└── www.cloudhusller.com → CloudFront
```

## Validation

The networking plan showed no real infrastructure changes, and `origin.cloudhusller.com` remained managed.

## Lesson Learned

Each DNS record should have a single Terraform owner. Separate origin-side and viewer-side DNS ownership by root module responsibility.
