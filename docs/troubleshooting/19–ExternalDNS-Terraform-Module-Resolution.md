# 19 – ExternalDNS Terraform Module Resolution

**Project:** CloudHustler Commerce Platform
**Phase:** Platform Services
**Category:** Terraform / Module Structure / ExternalDNS
**Severity:** Medium
**Status:** Resolved
**Date:** July 2026

---

# Incident Summary

While implementing **ExternalDNS** for the CloudHustler Commerce Platform, Terraform failed because it could not locate the ExternalDNS module referenced by the root configuration.

The infrastructure code had been organized into reusable Terraform modules, but the module path referenced by the root configuration did not match the actual repository structure. As a result, Terraform could not initialize the module dependency and the deployment was blocked before any AWS or Kubernetes resources could be created.

The issue was resolved by correcting the module directory structure and updating the module source path so Terraform could successfully discover and load the ExternalDNS module.

---

# Impact

* Terraform initialization failed.
* ExternalDNS could not be deployed.
* Platform Services deployment was blocked.
* No AWS resources were modified.
* No Kubernetes resources were created.

---

# Symptoms

Terraform failed during initialization with a module resolution error.

Example:

```text id="j4n6vk"
Error: Unreadable module directory

Unable to evaluate directory symlink
or module source path.
```

While validating the repository structure, an incorrect directory was also identified.

Example:

```bash id="4ztgk6"
ls ../../module
```

Output:

```text id="zrgh2x"
ls: cannot access '../../module': No such file or directory
```

This indicated the module path being referenced did not exist.

---

# Investigation

The investigation focused on determining whether the issue originated from Terraform, the repository layout, or the module configuration.

## 1. Verified Repository Structure

The repository layout was inspected.

```bash id="u6a31g"
ls
```

The Platform Services root contained the expected Terraform files but the referenced module path did not align with the actual directory structure.

---

## 2. Verified Module Directory

The modules directory was inspected.

```bash id="a6jkzb"
ls ../modules
```

The ExternalDNS module either did not exist yet or was not located where the root configuration expected it.

---

## 3. Reviewed Module Source

The Terraform configuration was reviewed.

The module source path referenced an incorrect relative location.

Because Terraform resolves modules relative to the calling module, even a small directory mismatch prevented initialization.

---

## 4. Corrected Repository Structure

The ExternalDNS module was created and placed under the project's shared modules directory.

Example structure:

```text id="hl0z7w"
modules/
└── external-dns/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

The Platform Services root was then updated to reference the correct module path.

---

# Root Cause

The Terraform root configuration referenced an incorrect relative module path.

Because the module directory did not match the repository structure, Terraform could not locate the ExternalDNS module during initialization.

---

# Resolution

The repository structure was standardized and the ExternalDNS module was moved to the shared `modules` directory.

The Terraform module source was updated to reference the correct relative path.

After correcting the module reference:

* Terraform initialized successfully.
* Module dependencies loaded correctly.
* ExternalDNS deployment proceeded normally.

---

# Validation

## Verify Repository Structure

```bash id="n7r3l5"
tree modules
```

Expected:

```text id="z4b8mf"
modules/
└── external-dns/
```

---

## Verify Terraform Initialization

```bash id="rj9m4x"
terraform init
```

Expected:

```text id="xj6vsz"
Terraform has been successfully initialized!
```

---

## Verify Terraform Validation

```bash id="9n9wwq"
terraform validate
```

Expected:

```text id="grc81o"
Success! The configuration is valid.
```

---

## Verify Deployment

```bash id="r1ezci"
terraform apply
```

Expected:

ExternalDNS resources deploy successfully without module errors.

---

# Lessons Learned

* Repository organization is critical for reusable Terraform modules.
* Relative module paths should be validated whenever directories are reorganized.
* Terraform initialization errors often indicate structural issues before any infrastructure changes occur.
* A consistent module layout simplifies maintenance and reuse across environments.

---

# Prevention

To avoid similar issues in future deployments:

* Maintain a consistent repository structure for all reusable modules.
* Validate module paths after moving or renaming directories.
* Run `terraform init` immediately after adding new modules.
* Standardize module locations across all Terraform roots.

---

# Key Takeaways

| Area               | Result                                                   |
| ------------------ | -------------------------------------------------------- |
| Root Cause         | Incorrect Terraform module source path                   |
| Failure Type       | Terraform Module Resolution                              |
| AWS Infrastructure | Unaffected                                               |
| Kubernetes Cluster | Unaffected                                               |
| Resolution         | Corrected the module directory structure and source path |
| Final Status       | ExternalDNS module initialized and deployed successfully |

---

# Interview Story (STAR Format)

## Situation

While implementing ExternalDNS for the CloudHustler Commerce Platform, Terraform failed before deployment because it could not locate the ExternalDNS module referenced by the Platform Services configuration. This prevented the deployment from progressing beyond the initialization phase.

## Task

My responsibility was to identify why Terraform could not resolve the module, correct the repository structure, and restore a reusable module layout without introducing changes to the infrastructure itself.

## Action

I inspected the repository layout, compared the configured module source with the actual directory structure, and discovered that the relative module path did not point to a valid location. I standardized the repository structure by placing the ExternalDNS implementation in the shared `modules` directory, updated the Terraform module source, and re-ran initialization to verify that Terraform could successfully resolve all dependencies.

## Result

Terraform initialized successfully, the ExternalDNS module loaded correctly, and the deployment proceeded without further module resolution errors. The incident reinforced the value of maintaining a consistent Terraform module hierarchy and validating repository structure before deploying infrastructure.
