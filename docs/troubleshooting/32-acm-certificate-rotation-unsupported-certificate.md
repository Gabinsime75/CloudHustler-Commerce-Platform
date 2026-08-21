# 26 – ALB Certificate Rotation Failed with UnsupportedCertificate

**Project:** CloudHustler Commerce Platform  
**Phase:** 7 – Edge & Security  
**Category:** ACM / ALB / Terraform  
**Severity:** High  
**Status:** Resolved  
**Date:** August 2026

---

## Incident Summary

After adding `origin.cloudhusller.com` to the ALB certificate SAN list, Terraform failed while updating the HTTPS listener:

```text
UnsupportedCertificate:
The certificate ... must have a fully-qualified domain name,
a supported signature, and a supported key size.
```

## Investigation

The new certificate was checked:

```bash
aws acm describe-certificate   --region us-east-2   --certificate-arn <new-certificate-arn>
```

It showed:

```text
Status: ISSUED
Key: RSA-2048
SANs:
- cloudhusller.com
- www.cloudhusller.com
- origin.cloudhusller.com
```

## Root Cause

The replacement partially completed. The new certificate existed and became valid, but the listener update failed during the same apply.

## Resolution

The ACM resource already used:

```hcl
lifecycle {
  create_before_destroy = true
}
```

We regenerated the Terraform plan after the new certificate was `ISSUED`. The new plan updated the ALB listener to the new certificate and removed the old certificate.

## Validation

```bash
aws elbv2 describe-listeners   --region us-east-2   --load-balancer-arn <alb-arn>
```

Port 443 showed the new certificate ARN.

## Lesson Learned

For ACM rotation, use `create_before_destroy`, verify the new certificate is `ISSUED`, then rerun the plan after a partially failed replacement.
