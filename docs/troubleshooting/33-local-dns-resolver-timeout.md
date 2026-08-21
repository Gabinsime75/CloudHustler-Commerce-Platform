# 30 – Local DNS Resolver Timeout During Edge Validation

**Project:** CloudHustler Commerce Platform  
**Phase:** 7 – Edge & Security  
**Category:** DNS / Local Workstation  
**Severity:** Low  
**Status:** Resolved / Workaround  
**Date:** August 2026

---

## Incident Summary

`nslookup origin.cloudhusller.com` repeatedly timed out against the workstation DNS resolver:

```text
Server: Unknown
Address: 172.25.254.20
DNS request timed out.
```

However:

```bash
curl -I https://origin.cloudhusller.com
```

successfully reached the ALB.

## Root Cause

The local DNS resolver was unreliable. The Route 53 record itself was working.

## Resolution

We tested with public resolvers:

```bash
nslookup origin.cloudhusller.com 8.8.8.8
nslookup origin.cloudhusller.com 1.1.1.1
```

and could flush the Windows DNS cache with:

```powershell
ipconfig /flushdns
```

## Lesson Learned

Do not assume Route 53 or CloudFront DNS is broken because a local resolver times out. Cross-check with a public resolver and an HTTPS request.
