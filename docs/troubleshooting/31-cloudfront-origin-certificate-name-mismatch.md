# 25 – CloudFront Origin TLS Certificate Name Mismatch

**Project:** CloudHustler Commerce Platform  
**Phase:** 7 – Edge & Security  
**Category:** CloudFront / ACM / TLS  
**Severity:** High  
**Status:** Resolved  
**Date:** August 2026

---

## Incident Summary

The CloudFront origin initially used the AWS-generated ALB hostname, while the ALB certificate covered only:

```text
cloudhusller.com
www.cloudhusller.com
```

Using HTTPS to the raw ALB hostname would create a certificate-name mismatch.

## Root Cause

The certificate presented by the ALB did not match the CloudFront origin hostname.

## Resolution

We introduced:

```text
origin.cloudhusller.com
```

and replaced the ALB certificate so it covered:

```text
cloudhusller.com
www.cloudhusller.com
origin.cloudhusller.com
```

Then CloudFront used:

```hcl
alb_dns_name           = "origin.cloudhusller.com"
origin_protocol_policy = "https-only"
```

## Validation

```bash
curl -I https://origin.cloudhusller.com
```

TLS succeeded and the request reached the ALB.

## Lesson Learned

Use a dedicated DNS name that is covered by the ALB certificate for secure CloudFront-to-origin HTTPS.
