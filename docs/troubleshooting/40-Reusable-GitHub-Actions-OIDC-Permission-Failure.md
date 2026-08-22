# 34 – Reusable GitHub Actions OIDC Permission Failure

**Project:** CloudHustler Commerce Platform

**Phase:** 8 – GitOps & Continuous Delivery

**Category:** GitHub Actions / AWS IAM / OIDC

**Severity:** High

**Status:** Resolved

**Date:** August 2026

---

# Incident Summary

While converting service pipelines to use a reusable GitHub Actions workflow, the workflow failed before AWS authentication.

The reusable workflow requested:

```yaml

permissions:

contents: read

id-token: write

```

but the calling workflow had not granted `id-token: write`.

As a result, GitHub could not issue the OIDC token required to assume the AWS CI role.

---

# Root Cause

Reusable workflows cannot elevate permissions beyond those granted by the caller.

The effective flow was:

```text

Calling Workflow

id-token: none

    |

    v

Reusable Workflow

id-token: write

    |

    v

Permission denied

```

The failure was therefore in GitHub Actions permissions, not in the AWS IAM trust policy.

---

# Resolution

The calling workflow was updated with:

```yaml

permissions:

contents: read

id-token: write

```

Useful troubleshooting commands included:

```bash

gh workflow list

gh run list

gh run view <RUN_ID>

gh run view <RUN_ID> --log-failed

```

---

# Validation

After adding the permission block:

```text

GitHub Actions

  |

  v

OIDC Token

  |

  v

AWS STS AssumeRole

  |

  v

Amazon ECR Authentication

  |

  v

CI Continued Successfully

```

The reusable workflow executed successfully and AWS authentication completed without static credentials.

---

# Lesson Learned

Reusable GitHub Actions workflows inherit the permission ceiling of their caller.

OIDC failures should be troubleshot in order:

```text

GitHub Permissions

  |

  v

OIDC Token

  |

  v

AWS STS

  |

  v

IAM Authorization

```

This prevents unnecessary IAM changes when the actual problem exists in the GitHub Actions permission model.