## Architecture diagram

```mermaid
graph LR
  subgraph GitRepo[Git Repository]
    repo["sanR-Dtest/3tier-gitops-demo\n(charts/, environments/, argocd/)"]
  end

  subgraph ArgoCD[Argo CD]
    argocd_app["Application (application.yaml)"]
    argocd_dev["App: dev"]
    argocd_qa["App: qa"]
    argocd_prod["App: prod"]
  end

  repo --> argocd_app
  argocd_app --> argocd_dev
  argocd_app --> argocd_qa
  argocd_app --> argocd_prod

  subgraph HelmChart[Helm Chart: ecommerce]
    chart["charts/ecommerce"]
    values["values: dev/qa/prod values"]
    templates["templates/*"]
  end

  argocd_dev --> chart
  argocd_qa --> chart
  argocd_prod --> chart

  subgraph Cluster[Kubernetes Cluster]
    ns["Namespace"]
    ingress["Ingress"]
    frontend_dep["Frontend Deployment"]
    frontend_svc["Frontend Service"]
    backend_dep["Backend Deployment"]
    backend_svc["Backend Service"]
    mysql_ss["MySQL StatefulSet"]
    mysql_svc["MySQL Service"]
    pvc["PersistentVolumeClaim"]
    hpa["HPA"]
  end

  chart --> ns
  ns --> frontend_dep
  frontend_dep --> frontend_svc
  ns --> backend_dep
  backend_dep --> backend_svc
  ns --> mysql_ss
  mysql_ss --> mysql_svc
  mysql_ss --> pvc
  frontend_dep --> hpa
  backend_dep --> hpa
  ingress --> frontend_svc
  ingress --> backend_svc
  frontend_svc -->|"external"| Internet["Internet"]

  style repo fill:#f8f0ff,stroke:#333,stroke-width:1px
  style ArgoCD fill:#e0f3ff,stroke:#333,stroke-width:1px
  style HelmChart fill:#e8ffe8,stroke:#333,stroke-width:1px
  style Cluster fill:#fff7d9,stroke:#333,stroke-width:1px

```

Brief: Git repo holds the Helm chart and environment values; Argo CD syncs `application.yaml` to create environment-specific apps (dev/qa/prod) which deploy the `ecommerce` chart into namespaces. The chart provisions frontend/backend Deployments + Services, a MySQL StatefulSet + PVC, an Ingress, and HPAs.
