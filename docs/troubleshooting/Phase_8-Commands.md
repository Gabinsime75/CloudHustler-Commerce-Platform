# Phase 8.1 – CI/CD Troubleshooting Command Reference

**Project:** CloudHustler Commerce Platform  
**Phase:** 8 – GitOps & Continuous Delivery  
**Scope:** GitHub Actions / Amazon ECR / Terraform / Docker / Trivy / Go / Node.js  
**Validated Services:** frontend, checkoutservice, productcatalogservice, shippingservice, currencyservice, paymentservice  
**Date:** August 2026

---

# 1 – Git Repository Troubleshooting

## Check Repository Status

```bash
git status
```

**What It Does:**  
Displays the current branch, staged files, unstaged changes, and untracked files.

**How It Was Used:**  
Used throughout Phase 8 before commits to verify workflow, Dockerfile, application, and dependency changes.

**Expected Outcome:**  
Only intentional project changes should appear.

---

## Check Repository Status in Short Format

```bash
git status --short
```

**What It Does:**  
Displays a compact list of modified, staged, deleted, and untracked files.

**How It Was Used:**  
Used while troubleshooting accidental staging of `node_modules`.

**Expected Outcome:**  
Quickly identify exactly which files Git is tracking or preparing to commit.

---

## Review Unstaged Changes

```bash
git diff
```

**What It Does:**  
Shows modifications that have not yet been staged.

**How It Was Used:**  
Used to review Dockerfile, workflow, `package.json`, Go module, and application-code changes.

**Expected Outcome:**  
Only expected local modifications should appear.

---

## Review Staged Changes

```bash
git diff --cached
```

**What It Does:**  
Displays the exact changes staged for the next commit.

**How It Was Used:**  
Used before committing GitHub Actions, IAM, dependency, and Docker changes.

**Expected Outcome:**  
Only intended changes should appear.

To exit the Git pager:

```text
q
```

---

## List Only Staged Filenames

```bash
git diff --cached --name-only
```

**What It Does:**  
Shows only the names of files staged for commit.

**How It Was Used:**  
Used to verify that `node_modules` had not accidentally been staged.

**Expected Outcome:**  
Only source, workflow, lockfile, Dockerfile, or configuration files should be listed.

---

## Stage a Specific File or Directory

```bash
git add <path>
```

Example:

```bash
git add .github/workflows/reusable-service-ci.yml
```

**What It Does:**  
Stages the selected file or directory.

**How It Was Used:**  
Used to stage CI workflow fixes and individual service changes.

**Expected Outcome:**  
The selected files appear as staged in `git status`.

---

## Stage Only Intended Paymentservice Files

```bash
git add .gitignore \
  applications/paymentservice/Dockerfile \
  applications/paymentservice/index.js \
  applications/paymentservice/package.json \
  applications/paymentservice/package-lock.json
```

**What It Does:**  
Stages only the files required for the paymentservice remediation.

**How It Was Used:**  
Used after staging the entire service directory caused Git to inspect `node_modules`.

**Expected Outcome:**  
No `node_modules` content is staged.

---

## Unstage Accidentally Added node_modules

```bash
git reset HEAD -- applications/paymentservice/node_modules
```

**What It Does:**  
Removes `node_modules` from the Git staging area without deleting local files.

**How It Was Used:**  
Used after `git add applications/paymentservice` attempted to stage generated dependencies.

**Expected Outcome:**  
`node_modules` disappears from staged changes.

---

## Check Whether node_modules Is Already Tracked

```bash
git ls-files applications/paymentservice/node_modules | head
```

**What It Does:**  
Searches the Git index for files already tracked under `node_modules`.

**How It Was Used:**  
Used to determine whether dependency files had previously been committed.

**Expected Outcome:**  
No output means `node_modules` is not tracked.

---

## Remove node_modules From Git Tracking

```bash
git rm -r --cached applications/paymentservice/node_modules
```

**What It Does:**  
Removes files from Git tracking while leaving them on the local filesystem.

**How It Was Used:**  
Reserved for the case where generated dependencies were already tracked.

**Expected Outcome:**  
The files are removed from the Git index but remain locally.

---

## Add node_modules to .gitignore

```bash
echo "node_modules/" >> .gitignore
```

**What It Does:**  
Adds the Node.js dependency directory to Git ignore rules.

**How It Was Used:**  
Prevented local Node dependencies from being staged in future commits.

**Expected Outcome:**  
`node_modules` no longer appears during normal `git add` operations.

---

## Commit Changes

```bash
git commit -m "ci: skip push for existing immutable ECR tags"
```

**What It Does:**  
Creates a Git commit containing the staged changes.

**How It Was Used:**  
Used for GitHub Actions and ECR pipeline fixes.

**Expected Outcome:**  
Git creates a new commit on the current branch.

---

## Push Changes to GitHub

```bash
git push origin main
```

**What It Does:**  
Pushes the local `main` branch to GitHub.

**How It Was Used:**  
Used to publish fixes and trigger push-based GitHub Actions workflows.

**Expected Outcome:**  
The commit appears on GitHub and configured workflows start.

---

# 2 – GitHub CLI Troubleshooting

## List GitHub Actions Workflows

```bash
gh workflow list
```

**What It Does:**  
Lists workflows recognized by GitHub Actions.

**How It Was Used:**  
Used to verify workflow names before manual execution.

**Expected Outcome:**  
Workflows such as `All Services CI` are displayed.

---

## Manually Run the All-Services Workflow

```bash
gh workflow run all-services-ci.yml --ref main
```

**What It Does:**  
Triggers `all-services-ci.yml` using the `main` branch.

**How It Was Used:**  
Used to validate all six Phase 8.1 services together.

**Expected Outcome:**  
GitHub creates a new `workflow_dispatch` run.

---

## List All-Services Workflow Runs

```bash
gh run list --workflow=all-services-ci.yml
```

**What It Does:**  
Displays recent executions of the all-services workflow.

**How It Was Used:**  
Used to identify active, successful, and failed runs.

**Expected Outcome:**  
Output contains run status, branch, event, run ID, and duration.

---

## Inspect a Workflow Run

```bash
gh run view <RUN_ID>
```

Example:

```bash
gh run view 32529614301
```

**What It Does:**  
Shows the jobs, annotations, and status for a specific run.

**How It Was Used:**  
Used to verify which services passed validation and which build/push jobs failed or were skipped.

**Expected Outcome:**  
Individual service jobs and their status are displayed.

---

## Watch a Workflow Run

```bash
gh run watch <RUN_ID>
```

**What It Does:**  
Monitors a GitHub Actions run until completion.

**How It Was Used:**  
Used during multi-service CI validation.

**Expected Outcome:**  
Job statuses update until the workflow finishes.

---

## Display Only Failed Job Logs

```bash
gh run view <RUN_ID> --log-failed
```

**What It Does:**  
Returns logs only from failed jobs.

**How It Was Used:**  
Used to isolate Trivy, Docker push, dependency, and CI failures.

**Expected Outcome:**  
Failed-job logs are displayed.

If there are no failed jobs, the command can return no output.

---

# 3 – Go Service Troubleshooting

## Download Go Modules

```bash
go mod download
```

**What It Does:**  
Downloads modules declared in `go.mod`.

**How It Was Used:**  
Used locally, in GitHub Actions, and inside Go Docker builds.

**Expected Outcome:**  
Dependencies download without module-resolution errors.

---

## Run Go Tests

```bash
go test ./...
```

**What It Does:**  
Runs tests for every Go package in the service.

**How It Was Used:**  
Used for frontend, checkoutservice, productcatalogservice, and shippingservice validation.

**Expected Outcome:**  
All tests pass.

---

## Run Go Vet Without copylocks

```bash
go vet -copylocks=false ./...
```

**What It Does:**  
Runs Go static analysis while disabling only the `copylocks` analyzer.

**How It Was Used:**  
Generated protobuf structures contained synchronization fields that triggered copylock warnings.

**Expected Outcome:**  
Other Go vet checks continue while generated protobuf copylock warnings no longer block CI.

---

## Run Go Vulnerability Analysis

```bash
govulncheck ./...
```

**What It Does:**  
Checks Go dependencies and standard-library call paths for reachable vulnerabilities.

**How It Was Used:**  
Used to distinguish actual reachable application risk from simple dependency presence.

**Expected Outcome:**  
Reachable vulnerabilities and affected call paths are reported.

In this project, `govulncheck` was configured as report-only while Trivy CRITICAL findings remained the hard security gate.

---

## Display the Go Dependency Graph

```bash
go list -m all
```

**What It Does:**  
Lists direct and transitive Go modules.

**How It Was Used:**  
Used during Trivy remediation to identify vulnerable gRPC, OpenTelemetry, and `golang.org/x/*` packages.

**Expected Outcome:**  
A complete dependency list is displayed.

---

## Upgrade a Go Dependency

```bash
go get <module>@<version>
```

Example:

```bash
go get google.golang.org/grpc@v1.83.0
```

**What It Does:**  
Updates a Go dependency to a selected version.

**How It Was Used:**  
Used to remediate vulnerable gRPC and supporting dependencies.

**Expected Outcome:**  
`go.mod` and `go.sum` reference the new version.

---

## Clean Go Module Metadata

```bash
go mod tidy
```

**What It Does:**  
Removes unused dependencies and updates `go.mod` and `go.sum`.

**How It Was Used:**  
Executed after dependency upgrades.

**Expected Outcome:**  
The module dependency graph is consistent.

---

## Compile Tests Without Running Them

```bash
go test -c
```

**What It Does:**  
Compiles the package test binary without executing it.

**How It Was Used:**  
Used while troubleshooting Windows-specific execution limitations and Linux-oriented application code.

**Expected Outcome:**  
The package compiles successfully.

---

# 4 – Node.js and npm Troubleshooting

## Check Node.js Version

```bash
node --version
```

**What It Does:**  
Displays the installed Node.js version.

**How It Was Used:**  
Identified that the workstation initially used Node 26 while the project CI was standardized on Node 20.

**Expected Outcome:**  

```text
v20.20.2
```

for the aligned local environment used during remediation.

---

## Check npm Version

```bash
npm --version
```

**What It Does:**  
Displays the npm version.

**How It Was Used:**  
Confirmed the package manager version after switching Node versions.

**Expected Outcome:**  

```text
10.8.2
```

in the validated local environment.

---

## Install Dependencies From package-lock.json

```bash
npm ci
```

**What It Does:**  
Performs a clean deterministic installation using `package-lock.json`.

**How It Was Used:**  
Used by GitHub Actions for currencyservice and paymentservice.

**Expected Outcome:**  
Dependencies install exactly as locked.

---

## Install Production Dependencies Only

```bash
npm ci --omit=dev
```

**What It Does:**  
Installs runtime dependencies without development dependencies.

**How It Was Used:**  
Used inside the currencyservice and paymentservice Dockerfiles.

**Expected Outcome:**  
A smaller production dependency tree is installed.

---

## Audit Node Dependencies

```bash
npm audit
```

**What It Does:**  
Scans installed Node dependencies for known vulnerabilities.

**How It Was Used:**  
Used extensively during currencyservice and paymentservice remediation.

**Expected Outcome:**  
After remediation:

```text
found 0 vulnerabilities
```

---

## Automatically Apply Compatible Vulnerability Fixes

```bash
npm audit fix
```

**What It Does:**  
Updates packages where npm can safely apply compatible security fixes.

**How It Was Used:**  
Used during paymentservice remediation.

**Expected Outcome:**  
Vulnerability count decreases.

Paymentservice ultimately reported:

```text
found 0 vulnerabilities
```

---

## Inspect a Specific Installed Package

```bash
npm ls <package>
```

Examples:

```bash
npm ls uuid
```

```bash
npm ls protobufjs
```

**What It Does:**  
Shows installed versions and where a package appears in the dependency tree.

**How It Was Used:**  
Used to inspect vulnerable `protobufjs` versions and confirm the final `uuid` version.

**Expected Outcome:**  
The resolved package version and dependency path are displayed.

Paymentservice eventually showed:

```text
uuid@13.0.2
```

---

## Inspect Package Information From npm

```bash
npm view <package>
```

or:

```bash
npm view <package> versions
```

**What It Does:**  
Displays package metadata or available versions from the npm registry.

**How It Was Used:**  
Useful during dependency remediation to determine newer compatible versions.

**Expected Outcome:**  
Package metadata or version history is returned.

---

## Install or Upgrade a Package

```bash
npm install <package>@<version>
```

**What It Does:**  
Installs a specific package version and updates package metadata.

**How It Was Used:**  
Used to upgrade gRPC and OpenTelemetry dependencies.

**Expected Outcome:**  
`package.json` and `package-lock.json` reference the selected version.

---

## Remove an Obsolete Dependency

```bash
npm uninstall <package>
```

Examples:

```bash
npm uninstall @google-cloud/profiler
```

```bash
npm uninstall @google-cloud/trace-agent
```

```bash
npm uninstall @opentelemetry/exporter-otlp-grpc
```

**What It Does:**  
Removes a package from the service dependency graph.

**How It Was Used:**  
Removed legacy Google Cloud observability libraries and outdated OpenTelemetry dependencies that were no longer needed in the AWS architecture.

**Expected Outcome:**  
The package disappears from `package.json`, `package-lock.json`, and the installed dependency tree.

---

## Validate JavaScript Syntax

```bash
node --check index.js
```

Other files validated included:

```bash
node --check server.js
node --check client.js
```

**What It Does:**  
Parses JavaScript without executing the application.

**How It Was Used:**  
Used after removing profiler and tracing code from currencyservice and paymentservice.

**Expected Outcome:**  
No output.

No output means the JavaScript syntax is valid.

---

# 5 – Node Version Manager / Windows Troubleshooting

## Install NVM for Windows

```powershell
winget install CoreyButler.NVMforWindows
```

**What It Does:**  
Installs Node Version Manager for Windows.

**How It Was Used:**  
Used to replace the workstation's Node 26 environment with the Node 20 runtime used by CI.

**Expected Outcome:**  
NVM installs successfully and becomes available after restarting the shell.

---

## Check NVM Version

```bash
nvm version
```

**What It Does:**  
Displays the installed NVM version.

**How It Was Used:**  
Confirmed NVM was installed correctly.

**Expected Outcome:**  
An NVM version such as `1.2.2` is returned.

---

## Install Node 20

```bash
nvm install 20
```

**What It Does:**  
Downloads and installs Node.js 20.

**How It Was Used:**  
Aligned the local runtime with GitHub Actions.

**Expected Outcome:**  
Node 20 is installed successfully.

---

## Switch to Node 20

```bash
nvm use 20
```

**What It Does:**  
Changes the active Node.js runtime.

**How It Was Used:**  
Moved the local environment from Node 26 to Node 20.

**Expected Outcome:**  
NVM reports that Node 20 is now active.

---

## Inspect Git Bash PATH

```bash
echo $PATH
```

**What It Does:**  
Shows the executable search paths available to Git Bash.

**How It Was Used:**  
Used when Git Bash could not locate `node` or `npm` after the NVM switch.

**Expected Outcome:**  
The NVM Node symlink directory should appear in the PATH.

---

## Inspect the NVM Node Directory

```bash
ls /c/nvm4w/nodejs
```

**What It Does:**  
Lists files in the NVM-managed Node symlink directory.

**How It Was Used:**  
Confirmed that the Node binaries existed even though Git Bash could not initially locate them.

**Expected Outcome:**  
Node and npm-related executables/files are visible.

---

## Add NVM Node to the Current Git Bash PATH

```bash
export PATH="/c/nvm4w/nodejs:$PATH"
```

**What It Does:**  
Temporarily adds the NVM Node directory to Git Bash's executable search path.

**How It Was Used:**  
Fixed `node: command not found` after switching Node versions.

**Expected Outcome:**  

```bash
node --version
npm --version
```

work correctly.

---

## Reload Bash Configuration

```bash
source ~/.bashrc
```

**What It Does:**  
Reloads the user's Bash configuration without restarting Git Bash.

**How It Was Used:**  
Useful after adding the NVM path permanently to `.bashrc`.

**Expected Outcome:**  
Updated PATH configuration becomes active.

---

# 6 – Source-Code Search Commands

## Search Source Files for Dependencies or References

```bash
grep -R "<pattern>" <path>
```

Example:

```bash
grep -R "@google-cloud/profiler" applications/paymentservice
```

**What It Does:**  
Recursively searches files for a string.

**How It Was Used:**  
Used to determine whether legacy GCP profiler and tracing dependencies were actually referenced in application code before removing them.

**Expected Outcome:**  
Matching filenames and source lines are displayed.

---

## Check Whether node_modules Is Already Ignored

```bash
grep -n "node_modules" .gitignore
```

**What It Does:**  
Searches `.gitignore` for the `node_modules` rule.

**How It Was Used:**  
Used after Git attempted to stage thousands of Node dependency files.

**Expected Outcome:**  

```text
node_modules/
```

should be present.

No output indicated the rule was missing.

---

# 7 – Docker Troubleshooting

## Build a Docker Image

```bash
docker build -t <image>:<tag> <context>
```

**What It Does:**  
Builds a container image from a Dockerfile.

**How It Was Used:**  
Used by GitHub Actions for all six validated services.

**Expected Outcome:**  
Docker completes the build and produces a tagged local image.

---

## Push a Docker Image

```bash
docker push <registry>/<repository>:<tag>
```

**What It Does:**  
Uploads image layers and the image manifest to Amazon ECR.

**How It Was Used:**  
Used after successful Trivy validation.

**Expected Outcome:**  
A new immutable SHA-tagged image appears in ECR.

When the tag already existed, ECR correctly returned:

```text
tag invalid:
The image tag already exists and cannot be overwritten
because the tag is immutable.
```

---

## Configure Go Module Proxy Fallback

```text
GOPROXY=https://proxy.golang.org,direct
```

**What It Does:**  
Uses the official Go proxy first and falls back to the source directly.

**How It Was Used:**  
Added after intermittent HTTP/2 failures occurred during `go mod download` inside Docker builds.

**Expected Outcome:**  
Transient proxy failures no longer prevent dependency resolution.

---

## Update Alpine Packages in Node Images

```dockerfile
RUN apk upgrade --no-cache
```

**What It Does:**  
Updates installed Alpine packages to their latest patched versions.

**How It Was Used:**  
Used in currencyservice and paymentservice after Trivy detected CRITICAL OpenSSL vulnerabilities.

**Expected Outcome:**  
Patched `libcrypto3` and `libssl3` packages are installed.

---

# 8 – Trivy Security Troubleshooting

## Scan a Container Image

```bash
trivy image <image>:<tag>
```

**What It Does:**  
Scans the container operating system and application dependencies for known vulnerabilities.

**How It Was Used:**  
Used to identify Go dependency, `protobufjs`, and Alpine OpenSSL vulnerabilities.

**Expected Outcome:**  
Security findings are listed by severity and package.

---

## CI Trivy CRITICAL Gate

```yaml
severity: CRITICAL
ignore-unfixed: true
exit-code: "1"
```

**What It Does:**  
Makes Trivy return a failure code when a fixable CRITICAL vulnerability is found.

**How It Was Used:**  
Used as the hard security gate before pushing images to ECR.

**Expected Outcome:**  

```text
CRITICAL vulnerability found
        |
        v
CI FAILS
        |
        X
ECR push blocked
```

When no blocking CRITICAL vulnerabilities exist, the pipeline continues.

---

# 9 – Amazon ECR Troubleshooting

## Authenticate Docker to Amazon ECR

```bash
aws ecr get-login-password --region us-east-2 | \
docker login \
  --username AWS \
  --password-stdin \
  396913735153.dkr.ecr.us-east-2.amazonaws.com
```

**What It Does:**  
Retrieves a temporary ECR authentication token and authenticates Docker.

**How It Was Used:**  
Equivalent to the authentication performed by the GitHub Actions ECR login action.

**Expected Outcome:**  

```text
Login Succeeded
```

---

## List ECR Repositories

```bash
aws ecr describe-repositories \
  --region us-east-2
```

**What It Does:**  
Lists ECR repositories and their configuration.

**How It Was Used:**  
Used to verify the repositories created for the validated services.

**Expected Outcome:**  
Repositories such as the following are returned:

```text
cloudhusller-commerce-platform-dev/frontend
cloudhusller-commerce-platform-dev/checkoutservice
cloudhusller-commerce-platform-dev/productcatalogservice
cloudhusller-commerce-platform-dev/shippingservice
cloudhusller-commerce-platform-dev/currencyservice
cloudhusller-commerce-platform-dev/paymentservice
```

---

## List Images in an ECR Repository

```bash
aws ecr list-images \
  --repository-name cloudhusller-commerce-platform-dev/frontend \
  --region us-east-2
```

**What It Does:**  
Lists image tags and digests in a repository.

**How It Was Used:**  
Used to verify whether SHA-based image tags had already been published.

**Expected Outcome:**  
Existing image tags and digests are displayed.

---

## Check Whether a Specific Image Tag Exists

```bash
aws ecr describe-images \
  --repository-name cloudhusller-commerce-platform-dev/frontend \
  --image-ids imageTag=<TAG> \
  --region us-east-2
```

**What It Does:**  
Looks up image metadata for a specific tag.

**How It Was Used:**  
Added to the reusable CI pipeline to determine whether an immutable SHA tag already existed before attempting a push.

**Expected Outcome:**  
If the tag exists, ECR returns image metadata.

If it does not exist, ECR returns `ImageNotFoundException`.

Required IAM permission:

```text
ecr:DescribeImages
```

---

# 10 – Terraform Troubleshooting

## Initialize Terraform

```bash
terraform init
```

**What It Does:**  
Initializes Terraform providers, modules, and backend configuration.

**How It Was Used:**  
Used in the Phase 8 CI infrastructure root before managing ECR and GitHub OIDC resources.

**Expected Outcome:**  

```text
Terraform has been successfully initialized!
```

---

## Format Terraform Files

```bash
terraform fmt -recursive
```

**What It Does:**  
Formats Terraform configuration recursively.

**How It Was Used:**  
Used before validation and commits.

**Expected Outcome:**  
Terraform files are normalized to standard formatting.

---

## Validate Terraform Configuration

```bash
terraform validate
```

**What It Does:**  
Checks Terraform syntax and configuration consistency.

**How It Was Used:**  
Used before planning ECR and IAM changes.

**Expected Outcome:**  

```text
Success! The configuration is valid.
```

---

## Preview Terraform Changes

```bash
terraform plan
```

**What It Does:**  
Shows infrastructure changes Terraform intends to make.

**How It Was Used:**  
Used before:

- creating ECR repositories
- adding repository ARNs to CI permissions
- updating `ecr:DescribeImages`
- investigating unexpected IAM policy replacement

**Expected Outcome:**  
Only expected changes should appear.

Important symbols:

```text
+ create
~ update in-place
- destroy
```

---

## Apply Terraform Changes

```bash
terraform apply
```

**What It Does:**  
Applies approved infrastructure changes.

**How It Was Used:**  
Used to create ECR repositories and update the GitHub Actions CI IAM policy.

**Expected Outcome:**  
Terraform completes successfully with the expected resources added or updated.

---

# 11 – IAM Policy Replacement Troubleshooting

## Inspect Terraform Plan Before Apply

```bash
terraform plan
```

**What It Does:**  
Shows whether a configuration update will modify or replace AWS resources.

**How It Was Used:**  
A change to the AWS managed IAM policy description unexpectedly produced:

```text
8 to add
0 to change
2 to destroy
```

The description change was identified as a force-replacement attribute and reverted.

**Expected Outcome After Correction:**

```text
6 to add
1 to change
0 to destroy
```

**Lesson:**  
Never apply an IAM plan containing unexpected resource destruction without investigating the replacement trigger.

---

# 12 – GitHub OIDC Permission Troubleshooting

The calling workflows required:

```yaml
permissions:
  contents: read
  id-token: write
```

**What It Does:**  
Allows GitHub Actions to request an OIDC token.

**How It Was Used:**  
Added after the reusable workflow failed because the caller did not grant `id-token: write`.

**Expected Outcome:**  

```text
GitHub Actions
      |
      v
OIDC Token
      |
      v
AWS STS
      |
      v
CI IAM Role
      |
      v
Amazon ECR
```

A reusable workflow cannot elevate permissions beyond those granted by its caller.

---

# 13 – npm Placeholder Test Troubleshooting

The original Node workflow used:

```bash
npm test --if-present
```

**What It Does:**  
Runs the npm test script if a `test` script exists.

**How It Was Used:**  
Initially used for Node service validation.

**Problem:**  
The default placeholder also counts as an existing test:

```json
"test": "echo \"Error: no test specified\" && exit 1"
```

This caused CI to fail even though the project contained no real tests.

The reusable workflow was changed to detect:

```text
No test script
Placeholder test script
Real test script
```

**Expected Outcome:**  
Placeholder scripts are skipped, while real tests continue to execute and fail CI when appropriate.

---

# 14 – Git LF / CRLF Warning Troubleshooting

Observed warning:

```text
LF will be replaced by CRLF
```

**What It Does:**  
Git warns that line endings may be converted between Unix LF and Windows CRLF.

**How It Was Used:**  
Seen when `git add applications/paymentservice` began processing files inside `node_modules`.

**Expected Outcome:**  
The warning itself does not indicate a build failure.

The real issue was that `node_modules` was not ignored and was being considered for staging.

Resolution:

```bash
echo "node_modules/" >> .gitignore
```

---

# 15 – Multi-Service Final Validation Commands

## Trigger Validation

```bash
gh workflow run all-services-ci.yml --ref main
```

**What It Does:**  
Starts the six-service CI validation workflow.

**Expected Outcome:**  
All six service pipelines begin.

---

## Monitor Runs

```bash
gh run list --workflow=all-services-ci.yml
```

**What It Does:**  
Shows run status and IDs.

**Expected Outcome:**  
The new run appears as active and eventually successful.

---

## Inspect Final Run

```bash
gh run view <RUN_ID>
```

**What It Does:**  
Shows each service validation and image job.

**Expected Outcome:**  
Successful validation for:

```text
frontend
checkoutservice
productcatalogservice
shippingservice
currencyservice
paymentservice
```

---

## Investigate Failures

```bash
gh run view <RUN_ID> --log-failed
```

**What It Does:**  
Displays only failed-job output.

**Expected Outcome:**  
No output after a fully successful run.

---

# Final Phase 8.1 Command Flow

```text
Developer Change
      |
      v
git status / git diff
      |
      v
Runtime Validation
      |
      +--> go test / go vet / govulncheck
      |
      +--> npm ci / npm audit / node --check
      |
      v
Docker Build
      |
      v
Trivy Image Scan
      |
      v
GitHub OIDC
      |
      v
AWS STS
      |
      v
Amazon ECR Tag Check
      |
      +--> Tag exists ----> Skip Push
      |
      +--> Tag missing ---> Docker Push
      |
      v
Amazon ECR
```

---

# Final Validated Phase 8.1 Scope

The following six services were fully validated:

```text
frontend
checkoutservice
productcatalogservice
shippingservice
currencyservice
paymentservice
```

The remaining application services were intentionally deferred because of project time constraints and are not considered Phase 8.1 blockers.