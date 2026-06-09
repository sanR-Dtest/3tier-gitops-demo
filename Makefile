.PHONY: help install-argocd deploy-app verify-deployment logs cleanup helm-lint validate-chart

help:
	@echo "3-Tier GitOps Demo - Available Commands"
	@echo "========================================"
	@echo "make install-argocd          - Install ArgoCD on the cluster"
	@echo "make deploy-app              - Deploy the application via ArgoCD"
	@echo "make verify-deployment       - Verify the deployment status"
	@echo "make logs                    - Stream logs from application pods"
	@echo "make helm-lint               - Lint the Helm chart"
	@echo "make validate-chart          - Validate the Helm chart"
	@echo "make cleanup                 - Remove ArgoCD and application"
	@echo "make help                    - Show this help message"
	@echo "make argocd-deploy-dev       - Deploy ArgoCD application for development environment"
	@echo "make argocd-deploy-qa        - Deploy ArgoCD application for QA environment"
	@echo "make argocd-deploy-prod      - Deploy ArgoCD application for production environment"

install-argocd:
	@echo "Installing ArgoCD..."
	kubectl create namespace argocd || true
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "ArgoCD installation initiated. Waiting for pods to be ready..."
	kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

deploy-app:
	@echo "Deploying application via ArgoCD..."
	kubectl apply -f argocd/application.yaml
	@echo "Application deployment initiated."
	@echo "Check status with: make verify-deployment"

verify-deployment:
	@echo "Verifying deployment status..."
	@echo "\n--- ArgoCD App Status ---"
	argocd app get ecommerce
	@echo "\n--- Kubernetes Resources ---"
	kubectl get all -n ecommerce
	@echo "\n--- Ingress Status ---"
	kubectl get ingress -n ecommerce

# ArgoCD deployment targets
argocd-deploy-dev:
	@echo "Applying ArgoCD application for dev..."
	kubectl apply -f argocd/application-dev.yaml
	@echo "Applied argocd/application-dev.yaml"

argocd-deploy-qa:
	@echo "Applying ArgoCD application for qa..."
	kubectl apply -f argocd/application-qa.yaml
	@echo "Applied argocd/application-qa.yaml"

argocd-deploy-prod:
	@echo "Applying ArgoCD application for prod..."
	kubectl apply -f argocd/application-prod.yaml
	@echo "Applied argocd/application-prod.yaml"

argocd-delete-dev:
	@echo "Deleting ArgoCD application for dev..."
	kubectl delete -f argocd/application-dev.yaml || true

argocd-delete-qa:
	@echo "Deleting ArgoCD application for qa..."
	kubectl delete -f argocd/application-qa.yaml || true

argocd-delete-prod:
	@echo "Deleting ArgoCD application for prod..."
	kubectl delete -f argocd/application-prod.yaml || true

logs:
	@echo "Streaming application logs..."
	@echo "Press Ctrl+C to stop."
	kubectl logs -n ecommerce -f -l app.kubernetes.io/name=ecommerce --all-containers=true

helm-lint:
	@echo "Linting Helm chart..."
	helm lint charts/ecommerce/

validate-chart:
	@echo "Validating Helm chart..."
	helm template ecommerce charts/ecommerce/ > /dev/null && echo "Chart validation successful!"

cleanup:
	@echo "WARNING: This will remove ArgoCD and the application."
	@read -p "Are you sure? (y/N) " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "Removing application..."; \
		kubectl delete -f argocd/application.yaml || true; \
		echo "Removing ArgoCD..."; \
		kubectl delete namespace argocd || true; \
		echo "Cleanup complete."; \
	else \
		echo "Cleanup cancelled."; \
	fi

# Development targets
dev-deploy:
	@echo "Deploying development environment..."
	helm install ecommerce charts/ecommerce/ -n ecommerce --create-namespace -f environments/dev-values.yaml

qa-deploy:
	@echo "Deploying QA environment..."
	helm install ecommerce charts/ecommerce/ -n ecommerce --create-namespace -f environments/qa-values.yaml

prod-deploy:
	@echo "Deploying production environment..."
	helm install ecommerce charts/ecommerce/ -n ecommerce --create-namespace -f environments/prod-values.yaml

# Upgrade targets
dev-upgrade:
	@echo "Upgrading development environment..."
	helm upgrade ecommerce charts/ecommerce/ -n ecommerce -f environments/dev-values.yaml

qa-upgrade:
	@echo "Upgrading QA environment..."
	helm upgrade ecommerce charts/ecommerce/ -n ecommerce -f environments/qa-values.yaml

prod-upgrade:
	@echo "Upgrading production environment..."
	helm upgrade ecommerce charts/ecommerce/ -n ecommerce -f environments/prod-values.yaml
