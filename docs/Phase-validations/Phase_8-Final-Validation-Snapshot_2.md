# Phase 8 – Final Validation Snapshot

**Project:** CloudHustler Commerce Platform  
**Phase:** 8 – GitOps & Continuous Delivery  
**Environment:** dev  
**AWS Region:** us-east-2  
**Validation Date:** September 2–3, 2026  
**Status:** **COMPLETE – PASS**

## Executive Summary

Phase 8 implemented and validated a GitOps-driven continuous delivery platform using GitHub Actions, Amazon ECR, Kustomize, Argo CD, and Amazon EKS.

Full CI/ECR validation was intentionally limited to the following six services:

1. frontend
2. checkoutservice
3. productcatalogservice
4. shippingservice
5. currencyservice
6. paymentservice

Redis and Istio routing were also managed and validated through GitOps.

The environment was successfully restored from an intentional cost-saving hibernation. The EKS control plane and Kubernetes objects were preserved while managed-node capacity, Karpenter controllers, Karpenter NodePool capacity, and Argo CD reconciliation controllers were reduced to zero.

Restoration followed this dependency order:

`EKS managed capacity → core platform pods → Karpenter controllers → NodePool limits → dynamic nodes → observability → Argo CD controllers → GitOps reconciliation → edge validation`

The final result was a healthy platform with automated reconciliation, drift correction, rollback capability, immutable image traceability, persistent observability data, and a working public CloudFront endpoint.

## Validation Results

| Area | Evidence | Result |
| --- | --- | --- |
| Repository | `main` synchronized with `origin/main`; working tree clean | PASS |
| EKS control plane | Cluster `cloudhusller-commerce-platform-dev-eks` ACTIVE on Kubernetes 1.33 | PASS |
| Managed capacity | Three `t3.medium` system nodes Ready | PASS |
| Karpenter | Two controllers running; NodePool and EC2NodeClass Ready | PASS |
| Dynamic capacity | Two `c6a.large` on-demand NodeClaims Ready across `us-east-2a` and `us-east-2b` | PASS |
| Core add-ons | VPC CNI, kube-proxy, Pod Identity Agent, CoreDNS, and EBS CSI healthy | PASS |
| Application workloads | Six scoped services at 2/2; Redis at 1/1; no non-running pods | PASS |
| Argo CD platform | All deployments healthy; Application and ApplicationSet controllers restored | PASS |
| Argo CD applications | Parent and nine child Applications Synced and Healthy; operations Succeeded | PASS |
| Persistent storage | Loki 20 Gi, Alertmanager 10 Gi, Grafana 10 Gi, and Prometheus 50 Gi; all gp3 PVCs and PVs Bound | PASS |
| Observability | Prometheus, Alertmanager, Grafana, kube-state-metrics, operator, node exporters, Loki, and Fluent Bit running | PASS |
| Istio | Gateway and VirtualService present; two ingress replicas running | PASS |
| DNS | ExternalDNS repeatedly reported `All records are already up to date` | PASS |
| TLS | Apex and `www` returned HTTPS 200; HSTS present; ClusterIssuers Ready | PASS |
| CloudFront | `Via`, `X-Amz-Cf-*`, and `X-Cache` headers confirmed | PASS |
| Caching | AVIF asset returned `X-Cache: Hit from cloudfront` and `Age: 224` | PASS |
| Security headers | HSTS, X-Frame-Options, Referrer-Policy, and X-Content-Type-Options present | PASS |
| Kustomize | Nine overlays passed standalone build, kubectl rendering, and server-side dry-run | PASS |
| CI | Latest workflow for each of the six scoped services succeeded | PASS |
| ECR | Every deployed immutable tag was found in its corresponding ECR repository | PASS |
| Drift correction | Manual frontend replica drift was automatically restored by Argo CD self-healing | PASS |
| Rollback | Missing-image Git release failed safely; Git revert restored the known-good version | PASS |

## Deployed Immutable Images

| Service | Tag | Image Digest |
| --- | --- | --- |
| frontend | `e7da48086cfd` | `sha256:a7bb855b9230dc6b114cc0d2a844684ec37c2744ad306d9eab22d5344beee4cd` |
| checkoutservice | `cba99ed13039` | `sha256:eeff1d8096a5c0b239ce75facf3bff8d340af7b00f68ded5cceb86a3b3f31699` |
| productcatalogservice | `d72c6b514c8d` | `sha256:14e23e20c49a9b81fef98d670c5b76e4995cead4fe99210227a1559ab2aacd2a` |
| shippingservice | `0a292fcb9a2c` | `sha256:a69d82d569a36aa0bbf5633bb0456070d1814363eb21fe95becca653fd82299b` |
| currencyservice | `6dfc622b3847` | `sha256:05e13e56730d3cb34d9cba76abdc17d41d9f4aa42ab018c09ee76a35170547b2` |
| paymentservice | `6dfc622b3847` | `sha256:20ce32a367a0c4b6ec5a40bc4a6008739f68b7102bd6e301de565744cf152d8a` |

Currencyservice and paymentservice share a commit-derived tag but have different image digests because each service is built independently and stored in its own ECR repository.

## GitOps Topology

The root Application, `cloudhusller-dev-apps`, implements the App-of-Apps pattern. It manages child Applications for:

1. cartservice
2. checkoutservice
3. currencyservice
4. frontend
5. paymentservice
6. productcatalogservice
7. shippingservice
8. redis-cart
9. istio-routing

The child Applications use Kustomize overlays under:

`gitops/overlays/dev`

Automated synchronization, pruning, and self-healing enforce Git as the desired-state source.

## Drift Test

The live frontend Deployment was manually scaled from two replicas to one without changing Git.

Argo CD detected the divergence and automatically restored the Git-declared replica count of two. The Application returned to `Synced` and `Healthy` without manual synchronization.

**Result:** Automated drift detection and self-healing validated.

## Failed Release and Rollback Test

A deliberately nonexistent frontend image tag was committed to the dev overlay and pushed to `main`.

Argo CD synchronized the desired state, Kubernetes created a new ReplicaSet, and the new pods could not pull the missing image. The rolling-update strategy retained the existing healthy frontend replicas, preserving availability.

The failed commit was reversed with `git revert`, preserving an auditable history. Argo CD detected the revert and restored the known-good immutable image.

The Deployment returned to 2/2 available, and the Application returned to `Synced` and `Healthy`.

This test also demonstrated that `Synced` and `Healthy` are separate signals: an Application can match Git while the desired release itself is unhealthy.

**Result:** Controlled failure detection, availability preservation, and Git-based rollback validated.

## Hibernation Recovery Findings

The initial recovery state contained an active EKS control plane, no registered nodes, and Pending workloads.

The system managed node group was ACTIVE with:

- Minimum capacity: `0`
- Desired capacity: `0`
- Maximum capacity: `5`

CoreDNS and EBS CSI correctly reported degraded health because their pods could not be scheduled.

Three managed nodes restored the system layer, but several workloads remained Pending because the `t3.medium` nodes had exhausted their pod, CPU, and memory capacity.

Karpenter was then restored to two controller replicas. It initially could not provision new nodes because the live NodePool retained its hibernation resource limit, producing:

`Failed to schedule pod, all available instance types exceed limits for nodepool (NodePool=default)`

Restoring the declared NodePool limits to 100 vCPU and 400 Gi enabled Karpenter to create two `c6a.large` NodeClaims.

All remaining workloads scheduled successfully. The Argo CD reconciliation controllers were restored only after platform and storage health were confirmed.

## Kustomize Validation

The following overlays passed all three validation layers:

- cartservice
- checkoutservice
- currencyservice
- frontend
- paymentservice
- productcatalogservice
- shippingservice
- redis-cart
- istio-routing

The validation layers were:

1. `kustomize build` – standalone manifest rendering
2. `kubectl kustomize` – Kubernetes-integrated rendering
3. `kubectl apply --dry-run=server -k` – API schema and admission validation without mutation

The Istio overlay's deprecated `commonLabels` field was migrated to the current `labels` syntax and successfully reconciled by Argo CD.

## Security and CI Notes

- GitHub Actions uses OIDC instead of long-lived AWS credentials.
- Caller workflows explicitly grant `contents: read` and `id-token: write` to the reusable workflow.
- Amazon ECR uses immutable, commit-derived image tags.
- The reusable CI workflow checks whether a tag already exists before attempting to push an image, preventing immutable-tag overwrite failures.
- Trivy reduced the frontend finding count from 40 findings—38 HIGH and 2 CRITICAL—to 7 HIGH and 0 CRITICAL.
- A later Trivy scan identified `CVE-2026-56854` in `golang.org/x/crypto` version `v0.51.0`.
- The affected Go services were upgraded to `golang.org/x/crypto v0.55.0`, eliminating the fixable CRITICAL vulnerability.
- Remaining findings were associated with the Go standard library and recorded as time-bound residual risk pending an upstream fix.
- Product Catalog tests were validated in a Linux container because the service uses Unix signals that are unavailable in the native Windows Go environment.

## Product Catalog and Frontend Asset Validation

The Product Catalog was updated with new products and AVIF image assets.

Initial validation showed that the product records appeared in the user interface, but their images returned HTTP `404` responses. The root cause was a mismatch between the `.jpg` paths declared in `products.json` and the actual `.avif` files stored in the frontend.

The remediation included:

1. Renaming image files with lowercase, URL-safe filenames.
2. Updating `products.json` to reference the correct `.avif` paths.
3. Committing the AVIF files under `applications/frontend/static/img/products`.
4. Building and pushing new frontend and Product Catalog images.
5. Updating both GitOps overlays with the new immutable image tags.
6. Allowing Argo CD to reconcile both Deployments.

Final validation confirmed:

- Product records rendered correctly.
- AVIF assets returned HTTP `200 OK`.
- The response used `Content-Type: image/avif`.
- CloudFront returned `X-Cache: Hit from cloudfront`.
- The Product Catalog and frontend Deployments used the intended immutable images.

**Result:** Product Catalog content and frontend static asset delivery validated successfully.

## Troubleshooting Lessons

### Immutable ECR Tag Collision

A retried GitHub Actions workflow attempted to push an image using a commit-derived tag that already existed in an immutable ECR repository.

**Resolution:** The reusable CI workflow was updated to query ECR before pushing. Existing tags are now reused instead of overwritten.

### Windows and Linux Go Test Differences

Native Windows tests failed because `server.go` referenced Unix-specific signals:

- `syscall.SIGUSR1`
- `syscall.SIGUSR2`

**Resolution:** Tests were run in a Linux-based Go container, matching the production EKS runtime environment.

### Product Images Returned 404

The Product Catalog successfully returned new products, but the frontend returned `404` for their images.

**Root causes:**

- JSON referenced `.jpg` files while the actual files used `.avif`.
- Image filenames and JSON paths required exact Linux case-sensitive matching.
- Product Catalog and frontend containers needed independent rebuilds and GitOps deployments.

**Resolution:** The image files and JSON paths were aligned, both container images were rebuilt, and both GitOps overlays were updated.

### Argo CD Reconciliation Delay

Immediately running `kubectl rollout status` after pushing a GitOps commit reported that the existing Deployment was healthy, while the old image was still running.

**Explanation:** `kubectl rollout status` observed the current Kubernetes rollout; it did not wait for Argo CD to detect the new Git commit.

**Resolution:** The Argo CD Application was refreshed, its synchronization status was monitored, and the Deployment image was verified after reconciliation.

## Final Definition of Done

- Argo CD foundation healthy
- AppProject and App-of-Apps operational
- Dev Kustomize overlays validated
- Six-service CI/ECR scope validated
- Immutable image traceability confirmed
- Kubernetes workloads healthy
- Persistent storage recovered
- Observability stack healthy
- Istio routing healthy
- DNS, TLS, CloudFront, and cache behavior validated
- Automated synchronization, pruning, and self-healing configured
- Controlled drift correction demonstrated
- Failed release and rollback demonstrated
- Hibernation recovery demonstrated
- Product Catalog and AVIF asset delivery validated
- Fixable CRITICAL Go dependency vulnerabilities remediated
- Troubleshooting evidence consolidated
- Senior-level implementation explanations completed

## Sign-Off

**Phase 8 – GitOps & Continuous Delivery is formally complete.**

Phase 9 may begin using the restored and validated platform baseline.