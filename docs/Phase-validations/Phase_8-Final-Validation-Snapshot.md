# Phase 8 – Final Validation Snapshot

**Project:** CloudHustler Commerce Platform  
**Phase:** 8 – GitOps & Continuous Delivery  
**Environment:** dev  
**Region:** us-east-2  
**Status:** Final Validation

---

## 1. Argo CD Application Health

Command:

```bash
kubectl get applications -n argocd
```

Result:

```text
<img width="501" height="236" alt="Screenshot 2026-08-26 000820" src="https://github.com/user-attachments/assets/79cb36ce-5635-4164-99f1-6b29804fd285" />

```

Validation:

- Parent App of Apps: `<Synced / Healthy>`
- Child Applications: `<Synced / Healthy>`
- Overall Argo CD Application Health: `<PASS / FAIL>`

## 2. Application Deployments

Command:

```bash
kubectl get deployments -n cloudhusller-dev
```

Result:

```text
<PASTE OUTPUT HERE>
```

Validation:

- Desired replicas available: `<YES / NO>`
- Unavailable deployments: `<NONE / LIST>`
- Deployment Health: `<PASS / FAIL>`

## 3. Application Pods

Command:

```bash
kubectl get pods -n cloudhusller-dev
```

Result:

```text
<PASTE OUTPUT HERE>
```

Validation:

- Running pods: `<VALUE>`
- Pending pods: `<VALUE>`
- Failed pods: `<VALUE>`
- Unexpected restarts: `<VALUE>`
- Pod Health: `<PASS / FAIL>`

## 4. Kubernetes Services

Command:

```bash
kubectl get svc -n cloudhusller-dev
```

Result:

```text
<PASTE OUTPUT HERE>
```

Validation:

- Frontend Service: `<PRESENT / MISSING>`
- CartService: `<PRESENT / MISSING>`
- Redis Cart: `<PRESENT / MISSING>`
- Other application services: `<PRESENT / MISSING>`
- Service Validation: `<PASS / FAIL>`

## 5. Argo CD Platform Pods

Command:

```bash
kubectl get pods -n argocd
```

Result:

```text
<PASTE OUTPUT HERE>
```

Validation:

- Argo CD components running: `<YES / NO>`
- Platform Health: `<PASS / FAIL>`

## 6. Istio Ingress Health

Command:

```bash
kubectl get pods -n istio-ingress
```

Result:

```text
<PASTE OUTPUT HERE>
```

Validation:

- Istio ingress replicas running: `<VALUE>`
- Unexpected restarts: `<VALUE>`
- Istio Ingress Health: `<PASS / FAIL>`

## 7. Istio Gateway and VirtualService

Command:

```bash
kubectl get gateway,virtualservice -n cloudhusller-dev
```

Result:

```text
<PASTE OUTPUT HERE>
```

Validation:

- Gateway present: `<YES / NO>`
- VirtualService present: `<YES / NO>`
- Routing Configuration: `<PASS / FAIL>`

## 8. Karpenter Validation

Commands:

```bash
kubectl get ec2nodeclass
kubectl get nodepool
```

Result:

```text
<PASTE OUTPUT HERE>
```

Validation:

- EC2NodeClass Ready: `<TRUE / FALSE>`
- NodePool Ready: `<TRUE / FALSE>`
- Dynamic node provisioning available: `<YES / NO>`
- Karpenter Health: `<PASS / FAIL>`

## 9. Frontend Image Validation

Command:

```bash
kubectl get deployment frontend \
  -n cloudhusller-dev \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

Result:

```text
<PASTE OUTPUT HERE>
```

Expected image:

```text
396913735153.dkr.ecr.us-east-2.amazonaws.com/cloudhusller-commerce-platform-dev/frontend:f280c4396897
```

Validation:

- Expected immutable SHA deployed: `<YES / NO>`
- Frontend Image Validation: `<PASS / FAIL>`

## 10. CartService Image Validation

Command:

```bash
kubectl get deployment cartservice \
  -n cloudhusller-dev \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

Result:

```text
<PASTE OUTPUT HERE>
```

Expected image:

```text
396913735153.dkr.ecr.us-east-2.amazonaws.com/cloudhusller-commerce-platform-dev/cartservice:0ee7c36fa3b9
```

Validation:

- Expected immutable SHA deployed: `<YES / NO>`
- CartService Image Validation: `<PASS / FAIL>`

## 11. Public Apex Domain Validation

Command:

```bash
curl -I https://cloudhusller.com
```

Result:

```text
<PASTE OUTPUT HERE>
```

Validation:

- HTTP status: `<VALUE>`
- Istio response observed: `<YES / NO>`
- CloudFront observed: `<YES / NO>`
- Public Endpoint: `<PASS / FAIL>`

## 12. Public WWW Domain Validation

Command:

```bash
curl -I https://www.cloudhusller.com
```

Result:

```text
<PASTE OUTPUT HERE>
```

Validation:

- HTTP status: `<VALUE>`
- WWW endpoint reachable: `<YES / NO>`
- Public WWW Endpoint: `<PASS / FAIL>`

## 13. Static Asset / CloudFront Cache Validation

Command:

```bash
curl -I https://cloudhusller.com/static/img/products/sunglasses.jpg
```

Result:

```text
<PASTE OUTPUT HERE>
```

Expected indicators:

```text
HTTP/1.1 200 OK
Content-Type: image/jpeg
X-Cache: Hit from cloudfront
```

Validation:

- Static asset HTTP status: `<VALUE>`
- Correct MIME type: `<YES / NO>`
- CloudFront caching: `<HIT / MISS / ERROR>`
- Static Asset Delivery: `<PASS / FAIL>`

## 14. App of Apps Ownership

Command:

```bash
kubectl get application cloudhusller-dev-apps \
  -n argocd \
  -o jsonpath='{range .status.resources[*]}{.kind}{"\t"}{.name}{"\n"}{end}'
```

Result:

```text
<PASTE OUTPUT HERE>
```

Expected child applications:

- `cartservice-dev`
- `checkoutservice-dev`
- `currencyservice-dev`
- `frontend-dev`
- `istio-routing-dev`
- `paymentservice-dev`
- `productcatalogservice-dev`
- `redis-cart-dev`
- `shippingservice-dev`

Validation:

- Expected child count: `9`
- Actual child count: `<VALUE>`
- All expected applications managed by root app: `<YES / NO>`
- App of Apps Validation: `<PASS / FAIL>`

## 15. GitOps Functional Validation Summary

| Validation item | Result |
| --- | --- |
| Git-driven deployment | `<PASS / FAIL>` |
| Automatic synchronization | `<PASS / FAIL>` |
| Drift detection | `<PASS / FAIL>` |
| Self-healing | `<PASS / FAIL>` |
| Pruning | `<PASS / FAIL>` |
| Rollback | `<PASS / FAIL>` |
| App of Apps | `<PASS / FAIL>` |
| Immutable image deployment | `<PASS / FAIL>` |
| Public application access | `<PASS / FAIL>` |
| Static asset delivery | `<PASS / FAIL>` |
