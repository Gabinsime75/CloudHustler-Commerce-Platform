# 29 – Validation Used a Stale CloudFront Distribution

**Project:** CloudHustler Commerce Platform  
**Phase:** 7 – Edge & Security  
**Category:** CloudFront / DNS / Validation  
**Severity:** Medium  
**Status:** Resolved  
**Date:** August 2026

---

## Incident Summary

Validation was performed against an old CloudFront hostname:

```text
d2nrhr3xv1564c.cloudfront.net
```

and failed with:

```text
curl: (6) Could not resolve host
```

The old distribution ID also returned:

```text
NoSuchDistribution
```

Terraform outputs showed the current distribution:

```text
ID: E3KZRVPZLIVY98
Domain: d3cvfhjad2hhxv.cloudfront.net
Status: Deployed
```

## Root Cause

The validation commands used stale identifiers from a previous deployment.

## Resolution

We used Terraform outputs/state and AWS CLI to identify the active distribution.

## Validation

```bash
curl -I https://d3cvfhjad2hhxv.cloudfront.net
```

returned through CloudFront and reached the ALB.

## Lesson Learned

After infrastructure recreation or replacement, always retrieve current IDs and DNS names from Terraform or AWS before validation.
