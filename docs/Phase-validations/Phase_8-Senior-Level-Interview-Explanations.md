# Phase 8 – Senior-Level Interview Explanations

## 1. Walk me through how you implemented CI and secure image delivery

For Phase 8, I separated continuous integration from continuous delivery. GitHub Actions owns CI: it tests the service, builds the container, scans it with Trivy, authenticates to AWS through GitHub OIDC, and publishes the image to a service-specific Amazon ECR repository. Argo CD owns CD: it watches the GitOps manifests and deploys the image declared in Git rather than accepting direct changes from the CI runner.

I implemented a reusable GitHub Actions workflow so the six selected services follow the same security and publishing controls while retaining small service-specific caller workflows. The callers explicitly grant `contents: read` and `id-token: write`. That detail became important during troubleshooting because permissions requested by a reusable workflow are not automatically elevated when the caller grants only the default permissions. Once the caller permission was added, GitHub could mint the OIDC token and assume the AWS role without storing long-lived access keys.

Images are tagged with a shortened Git commit SHA, which creates traceability from the Kubernetes Deployment back to the source revision and workflow run. ECR tag immutability prevents overwriting an existing release. We also adjusted the pipeline behavior to recognize an existing tag instead of treating a safe retry as permission to mutate an immutable artifact.

The final validation correlated the image running in each Kubernetes Deployment with the same tag and digest in ECR. All six latest workflows succeeded, giving us an auditable chain from source commit to CI run, ECR artifact, GitOps declaration, and running workload.

## 2. Walk me through how you configured Argo CD and the App-of-Apps model

I installed Argo CD through Terraform and Helm, keeping the server internal as a ClusterIP service. For the dev environment, the platform uses one application-controller replica and one ApplicationSet-controller replica, while the supporting server, repository, Redis, Dex, and notification components run independently.

For application organization, I used an App-of-Apps model. The root Application, `cloudhusller-dev-apps`, manages the child Applications for the application services, Redis, and Istio routing. Each child Application is restricted through the `cloudhusller-dev` AppProject to the approved repository, destination cluster, namespace, and resource types. During implementation, Argo CD initially rejected Namespace creation because Namespace is cluster-scoped and the AppProject did not permit it. I corrected that with a least-privilege cluster resource whitelist allowing only Namespace rather than opening unrestricted cluster permissions. I also cleared the stale failed operation state before retrying synchronization.

Each Application has automated synchronization with pruning and self-healing. That means Git is the desired-state authority: new commits are applied automatically, deleted manifests can be pruned, and manual drift is corrected. During recovery from hibernation, I deliberately restored the platform and storage layers before scaling the Argo CD controllers back up. Once enabled, the controller refreshed week-old comparisons, pulled the latest repository revision, compared all live resources, and returned all 10 Applications to `Synced/Healthy` with successful operations.

## 3. Walk me through how you structured and validated Kustomize

I used Kustomize to separate reusable Kubernetes definitions from environment-specific configuration. Each service has a base containing its Deployment and Service, using a logical image name and common health, resource, and networking settings. The dev overlay references that base, adds the environment label, and replaces the logical image with the actual ECR repository and immutable commit-SHA tag.

That design avoids copying full manifests for every environment. When staging and production are added, they can reuse the same bases and override only the differences—such as image tags, replica counts, resource sizing, domains, or policy settings. Redis and Istio routing follow the same model, so application and ingress configuration are promoted through Git consistently.

I validated every overlay at three levels. First, `kustomize build` confirmed standalone composition. Second, `kubectl kustomize` confirmed Kubernetes-integrated rendering. Third, `kubectl apply --dry-run=server -k` sent the rendered resources through the live API server's schema and admission checks without persisting changes. All nine overlays passed. I also removed the deprecated `commonLabels` field from the Istio overlay, migrated it to the supported `labels` syntax, compared the rendered output, and confirmed Argo CD reconciled it successfully.

## 4. Walk me through how you implemented drift detection and rollback

I validated drift and rollback as two separate failure modes. For drift, I manually scaled the live frontend Deployment from two replicas to one while Git still declared two. Argo CD detected that the live state no longer matched the repository and self-healed the Deployment back to two replicas without a manual sync. That proved the cluster could not silently diverge from Git.

For rollback, I tested a bad desired state rather than manual drift. I committed a deliberately nonexistent frontend image tag to the dev overlay. Argo CD correctly synchronized it, and Kubernetes created a new ReplicaSet, but the new pods could not pull the image. Because the Deployment used a rolling-update strategy and had two replicas, Kubernetes preserved the existing healthy pods instead of taking the application down.

This test highlighted an important operational distinction: `Synced` means the cluster matches Git, while `Healthy` indicates whether that desired state is actually working. A bad release can therefore be synchronized but degraded or progressing.

I recovered using `git revert`, not a force-push or direct `kubectl set image`. The revert preserved the audit trail and made Git contain the known-good image again. Argo CD detected the new commit, restored the previous immutable image, and returned the Deployment to 2/2 with the Application `Synced/Healthy`. That is our preferred rollback pattern because recovery remains declarative, reviewable, and reproducible.

## 5. Walk me through a significant Phase 8 troubleshooting and recovery scenario

The strongest troubleshooting example was restoring the entire platform after intentional cost-saving hibernation. The EKS control plane and Kubernetes objects were preserved, but the managed node group was at zero, Karpenter and Argo CD reconciliation controllers were scaled down, and the Karpenter NodePool limits were reduced. Initially, every pod was Pending and the EBS CSI and CoreDNS add-ons reported degraded health.

I diagnosed the system in dependency order. AWS confirmed the cluster and node group were ACTIVE, and Kubernetes events showed `no nodes available`, proving this was expected compute removal rather than control-plane failure. I restored three managed `t3.medium` nodes, which brought up networking, DNS, storage, Pod Identity, metrics, cert-manager, Istio, and the load balancer controller. Some pods remained Pending because the nodes reached pod, CPU, and memory limits.

I then restored the two Karpenter controllers. The controllers were healthy, the NodePool and EC2NodeClass were Ready, but no NodeClaim appeared. Events provided the decisive message: all available instance types exceeded the NodePool limits. That ruled out subnet discovery, IAM, and EC2 capacity and pointed to the hibernation limit. I restored the Terraform-declared limits of 100 vCPU and 400 Gi. Karpenter immediately created two on-demand `c6a.large` NodeClaims across two Availability Zones, and the remaining workloads became healthy.

Only after validating Prometheus, Loki, Grafana, Alertmanager, PVC/PV bindings, and all running pods did I restore the Argo CD application and ApplicationSet controllers. Argo CD refreshed the stale comparisons and reconciled the latest Git revision. This recovery demonstrated controlled sequencing, evidence-based diagnosis, cost-aware operations, and the ability to distinguish an intentionally dormant platform from a broken one.
