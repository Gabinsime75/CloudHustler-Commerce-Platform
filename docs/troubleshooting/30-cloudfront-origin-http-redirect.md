# 24 – CloudFront Origin HTTP Redirect to ALB Hostname

**Project:** CloudHustler Commerce Platform  
**Phase:** 7 – Edge & Security  
**Category:** CloudFront / ALB / Origin Protocol  
**Severity:** Medium  
**Status:** Resolved  
**Date:** August 2026

---

## Incident Summary

During Phase 7.1 validation, CloudFront successfully reached the ALB, but requests returned:

```text
HTTP/1.1 301 Moved Permanently
Server: awselb/2.0
Location: https://<alb-dns-name>:443/
X-Cache: Miss from cloudfront
Via: ...cloudfront.net
```

## Root Cause

CloudFront used:

```hcl
origin_protocol_policy = "http-only"
```

while the ALB port 80 listener redirected HTTP to HTTPS. The redirect exposed the raw ALB hostname to the viewer.

## Resolution

We created:

```text
origin.cloudhusller.com
```

and configured:

```text
origin.cloudhusller.com → Route 53 Alias → ALB
```

CloudFront was then changed to:

```hcl
domain_name            = "origin.cloudhusller.com"
origin_protocol_policy = "https-only"
origin_ssl_protocols   = ["TLSv1.2"]
```

## Validation

```bash
curl -I https://<cloudfront-domain>
```

The old `301` redirect to the raw ALB hostname disappeared.

## Lesson Learned

For a CloudFront-to-ALB production path, use a dedicated origin hostname and HTTPS rather than relying on an ALB HTTP redirect.
