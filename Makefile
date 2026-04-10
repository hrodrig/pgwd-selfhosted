# pgwd-selfhosted — optional automation targets (no Go build).
# Primary validation: Helm workflow (CI), Compose on real hosts.

.DEFAULT_GOAL := help

# Limit to one inventory host: make test-compose-platforms LIMIT=vps-ubuntu
LIMIT ?=

# Helm / kubeconform — keep in sync with .github/workflows/helm-lint.yml and CONTRIBUTING.md
CHART_DIR ?= run/kubernetes/helm/pgwd
KUBERNETES_VERSION ?= 1.30.0

.PHONY: help release-check test-compose-platforms test-helm-kind test-kind-postgres

help:
	@echo "pgwd-selfhosted — make targets"
	@echo ""
	@echo "  make release-check             Local gate before tagging: helm lint, helm template +"
	@echo "                                 kubeconform (same scenarios as CI), minimal Compose config."
	@echo "                                 Requires: helm, kubeconform, docker (compose plugin)."
	@echo ""
	@echo "  make test-kind-postgres        kind + postgres-minimal only (testing/kind/)."
	@echo "                                 Requires: Docker, kind, kubectl."
	@echo "  make test-helm-kind            Same cluster + Helm install pgwd + log-based Postgres check."
	@echo "                                 Requires: Docker, kind, kubectl, helm."
	@echo "                                 Optional: PGWD_HELM_E2E_CLUSTER, PGWD_KIND_POSTGRES_ROLLOUT_TIMEOUT,"
	@echo "                                 PGWD_HELM_E2E_ROLLOUT_TIMEOUT, PGWD_HELM_E2E_LOG_WAIT_SECS, PGWD_HELM_E2E_NO_CLEANUP"
	@echo ""
	@echo "  make test-compose-platforms   Run Ansible full-cycle on hosts (testing/platforms/)."
	@echo "                                Requires inventory: testing/platforms/inventory/hosts.yml"
	@echo "                                Optional: LIMIT=hostname for --limit"
	@echo ""
	@echo "Examples:"
	@echo "  make test-kind-postgres"
	@echo "  make test-helm-kind"
	@echo "  make test-compose-platforms"
	@echo "  make test-compose-platforms LIMIT=vps-ubuntu"
	@echo ""
	@echo "Or: cd testing/platforms && ansible-playbook playbooks/full-cycle.yml"

release-check:
	@command -v helm >/dev/null 2>&1 || { echo "helm not found"; exit 1; }
	@command -v kubeconform >/dev/null 2>&1 || { echo "kubeconform not found (brew install kubeconform — see CONTRIBUTING.md)"; exit 1; }
	@command -v docker >/dev/null 2>&1 || { echo "docker not found"; exit 1; }
	@echo "release-check: helm lint $(CHART_DIR) (default values.yaml)..."
	@helm lint "$(CHART_DIR)"
	@echo "release-check: helm lint + values-config-mode.yaml (schema + fixture)..."
	@helm lint "$(CHART_DIR)" -f "$(CHART_DIR)/values-config-mode.yaml"
	@echo "release-check: helm template + kubeconform (default values)..."
	@helm template test-rel "$(CHART_DIR)" --namespace test-ns | \
		kubeconform -strict -kubernetes-version "$(KUBERNETES_VERSION)" -summary -
	@echo "release-check: helm template + kubeconform (config file mode)..."
	@helm template test-rel "$(CHART_DIR)" --namespace test-ns \
		--set config.enabled=true \
		--set secrets.create=false | \
		kubeconform -strict -kubernetes-version "$(KUBERNETES_VERSION)" -summary -
	@echo "release-check: helm template + kubeconform (inline DB URL Secret)..."
	@helm template test-rel "$(CHART_DIR)" --namespace test-ns \
		--set secrets.dbUrl='postgres://ci:ci@postgres.default.svc.cluster.local:5432/db?sslmode=disable' | \
		kubeconform -strict -kubernetes-version "$(KUBERNETES_VERSION)" -summary -
	@echo "release-check: helm template + kubeconform (existing Secret)..."
	@helm template test-rel "$(CHART_DIR)" --namespace test-ns \
		--set secrets.create=false \
		--set secrets.existingSecret=my-imported-secret | \
		kubeconform -strict -kubernetes-version "$(KUBERNETES_VERSION)" -summary -
	@echo "release-check: docker compose config (minimal, dummy PGWD_DB_URL)..."
	@PGWD_DB_URL='postgres://user:pass@localhost:5432/db?sslmode=disable' \
		docker compose --env-file run/common/.env.example -f run/docker-compose/minimal/docker-compose.yml config >/dev/null
	@echo "release-check passed."

test-kind-postgres:
	@command -v docker >/dev/null 2>&1 || { echo "docker not found"; exit 1; }
	@command -v kind >/dev/null 2>&1 || { echo "kind not found (https://kind.sigs.k8s.io/docs/user/quick-start/#installation)"; exit 1; }
	@command -v kubectl >/dev/null 2>&1 || { echo "kubectl not found"; exit 1; }
	@chmod +x testing/scripts/test-helm-kind.sh
	@PGWD_KIND_E2E_PGWD=0 testing/scripts/test-helm-kind.sh

test-helm-kind:
	@command -v docker >/dev/null 2>&1 || { echo "docker not found"; exit 1; }
	@command -v kind >/dev/null 2>&1 || { echo "kind not found (https://kind.sigs.k8s.io/docs/user/quick-start/#installation)"; exit 1; }
	@command -v kubectl >/dev/null 2>&1 || { echo "kubectl not found"; exit 1; }
	@command -v helm >/dev/null 2>&1 || { echo "helm not found"; exit 1; }
	@chmod +x testing/scripts/test-helm-kind.sh
	@PGWD_KIND_E2E_PGWD=1 testing/scripts/test-helm-kind.sh

test-compose-platforms:
	@command -v ansible-playbook >/dev/null 2>&1 || { echo "ansible-playbook not found; install Ansible 2.14+ (e.g. pip install ansible)"; exit 1; }
	@test -f testing/platforms/inventory/hosts.yml || { echo "Missing testing/platforms/inventory/hosts.yml — copy hosts.yml.example and edit."; exit 1; }
	cd testing/platforms && ansible-playbook playbooks/full-cycle.yml $(if $(LIMIT),--limit $(LIMIT),)
