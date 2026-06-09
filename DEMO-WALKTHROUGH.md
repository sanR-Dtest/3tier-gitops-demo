# 3-Tier GitOps Demo Walkthrough

## Prerequisites

- Kubernetes cluster
- Helm 3+
- ArgoCD installed and configured
- kubectl CLI

## Deployment Steps

### 1. Deploy with ArgoCD

```bash
kubectl apply -f argocd/application.yaml
```

### 2. Verify Deployment

```bash
argocd app get ecommerce
kubectl get all -n ecommerce
```

### 3. Access the Application

Get the ingress endpoint and navigate to the application URL.

## Environments

- **dev**: Development environment with minimal resources
- **qa**: QA environment with moderate resources
- **prod**: Production environment with full HA setup

## Notes

- Each environment uses different `values-*.yaml` configurations
- MySQL uses StatefulSet for persistence
- Frontend and Backend communicate via Service discovery
