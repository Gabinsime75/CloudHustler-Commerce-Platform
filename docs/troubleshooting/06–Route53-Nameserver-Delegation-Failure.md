# 06 – Route53 Nameserver Delegation Failure

**Project:** CloudHustler Commerce Platform  
**Phase:** Networking  
**Category:** Amazon Route53 / DNS Delegation / ACM Validation  
**Severity:** High  
**Status:** Resolved  
**Date:** July 2026

---

# Incident Summary

During the Networking phase of the CloudHustler Commerce Platform deployment, Amazon Route53 successfully created the hosted zone and all required DNS records through Terraform. However, the domain continued resolving through the previous DNS provider, preventing Route53 records from becoming publicly authoritative.

As a result, DNS lookups did not return the newly created Route53 records, ACM certificate validation remained pending, and external services relying on the domain could not function correctly.

The issue was ultimately traced to the domain registrar still pointing to the old authoritative name servers instead of the Route53 hosted zone.

---

# Impact

- Route53 DNS records were not publicly authoritative.
- ACM certificate validation failed.
- Domain resolution continued using the previous DNS provider.
- HTTPS deployment was blocked.
- External DNS records created by Terraform were ignored by the Internet.

---

# Symptoms

DNS queries returned unexpected results.

Example:

```bash
nslookup cloudhusller.com
```

or

```bash
dig NS cloudhusller.com
```

returned name servers that were **not** the Route53 assigned name servers.

ACM remained in:

```text
Pending Validation
```

Even though the required validation records existed inside Route53.

---

# Investigation

The troubleshooting process focused on determining whether the issue originated from Terraform, Route53, or the domain registrar.

---

## 1. Verified Route53 Hosted Zone

Terraform successfully created:

- Public Hosted Zone
- A Records
- CNAME Validation Records
- Alias Records

Terraform state confirmed all Route53 resources existed.

---

## 2. Verified DNS Records

The validation CNAME records were visible inside Route53.

Example:

```text
_acbd123.cloudhusller.com
```

However, public DNS lookups did not return these records.

This indicated Route53 was not serving authoritative DNS.

---

## 3. Compared Authoritative Name Servers

The hosted zone assigned four Route53 name servers similar to:

```text
ns-123.awsdns-xx.com
ns-456.awsdns-yy.net
ns-789.awsdns-zz.org
ns-111.awsdns-aa.co.uk
```

A public DNS lookup showed different authoritative name servers.

This confirmed the domain registrar was still delegating the domain to another DNS provider.

---

## 4. Verified Registrar Configuration

The registrar's DNS configuration was reviewed.

The domain was still configured with the previous provider's name servers rather than the Route53 name servers assigned to the hosted zone.

This prevented Route53 from becoming authoritative.

---

# Root Cause

Although Terraform successfully created the Route53 hosted zone and DNS records, the domain registrar had not been updated to delegate the domain to Route53.

Because DNS delegation had not changed, Internet DNS resolvers continued querying the previous authoritative name servers instead of Route53.

---

# Resolution

The registrar's name server configuration was updated to the four authoritative Route53 name servers assigned to the hosted zone.

After DNS delegation propagated:

- Route53 became authoritative.
- Public DNS queries returned Route53 records.
- ACM automatically completed DNS validation.
- HTTPS deployment completed successfully.

---

# Validation

Deployment success was verified using the following commands.

## Verify Hosted Zone Name Servers

```bash
aws route53 get-hosted-zone \
  --id <hosted-zone-id>
```

Expected:

```text
DelegationSet:
NameServers:
```

The returned name servers matched those configured at the registrar.

---

## Verify Public Delegation

```bash
dig NS cloudhusller.com
```

Expected:

The same four Route53 name servers returned by the hosted zone.

---

## Verify DNS Resolution

```bash
nslookup cloudhusller.com
```

Expected:

The domain resolves using Route53 records.

---

## Verify ACM Certificate

```bash
aws acm describe-certificate \
  --certificate-arn <certificate-arn>
```

Expected:

```text
ValidationStatus: SUCCESS
Status: ISSUED
```

---

## Verify Terraform State

```bash
terraform state list
```

Expected resources:

```text
module.route53.aws_route53_zone.this
module.route53.aws_route53_record.validation
module.route53.aws_route53_record.apex
```

---

# Lessons Learned

- Creating a Route53 hosted zone does **not** automatically make Route53 authoritative.
- DNS delegation must always be updated at the domain registrar.
- Missing name server delegation can appear as ACM or Route53 failures even when Terraform is correct.
- Public DNS tools should always be used to verify authoritative name servers.

---

# Prevention

To avoid similar issues in future deployments:

- Update registrar name servers immediately after creating a new Route53 hosted zone.
- Verify DNS delegation before troubleshooting ACM validation.
- Compare the hosted zone's assigned name servers with the registrar configuration.
- Allow sufficient time for global DNS delegation to propagate.

---

# Key Takeaways

| Area | Result |
|-------|--------|
| Root Cause | Domain registrar still pointed to previous name servers |
| Failure Type | DNS Delegation |
| Terraform Configuration | Correct |
| Route53 Configuration | Correct |
| Resolution | Update registrar to use Route53 name servers |
| Final Status | Route53 became authoritative and services deployed successfully |

---

# Interview Story (STAR Format)

## Situation

While deploying the networking layer of the CloudHustler Commerce Platform, Terraform successfully created the Route53 hosted zone and DNS records, but ACM certificate validation never completed because the domain continued resolving through a previous DNS provider.

## Task

My responsibility was to determine whether the issue was caused by Terraform, Route53, ACM, or external DNS configuration, and restore authoritative DNS without modifying the infrastructure code.

## Action

I confirmed that Terraform had created the hosted zone and all required DNS records correctly. I compared the Route53 assigned name servers with the authoritative name servers returned by public DNS queries and discovered they did not match. I then reviewed the domain registrar configuration and found it was still delegating the domain to the previous DNS provider. After updating the registrar to use the Route53 name servers, I monitored DNS propagation until Route53 became authoritative.

## Result

Once DNS delegation propagated, Route53 became the authoritative DNS provider, ACM automatically validated the certificate, HTTPS deployment completed successfully, and all public DNS records resolved correctly. The incident reinforced that DNS delegation at the registrar is just as important as creating DNS records within Route53.