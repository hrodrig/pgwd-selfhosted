# pgwd-selfhosted — optional automation targets (no Go build).
# Primary validation: Helm workflow (CI), Compose on real hosts.

.DEFAULT_GOAL := help

# Limit to one inventory host: make test-compose-platforms LIMIT=vps-ubuntu
LIMIT ?=

.PHONY: help test-compose-platforms

help:
	@echo "pgwd-selfhosted — make targets"
	@echo ""
	@echo "  make test-compose-platforms   Run Ansible full-cycle on hosts (testing/platforms/)."
	@echo "                                Requires inventory: testing/platforms/inventory/hosts.yml"
	@echo "                                Optional: LIMIT=hostname for --limit"
	@echo ""
	@echo "Examples:"
	@echo "  make test-compose-platforms"
	@echo "  make test-compose-platforms LIMIT=vps-ubuntu"
	@echo ""
	@echo "Or: cd testing/platforms && ansible-playbook playbooks/full-cycle.yml"

test-compose-platforms:
	@command -v ansible-playbook >/dev/null 2>&1 || { echo "ansible-playbook not found; install Ansible 2.14+ (e.g. pip install ansible)"; exit 1; }
	@test -f testing/platforms/inventory/hosts.yml || { echo "Missing testing/platforms/inventory/hosts.yml — copy hosts.yml.example and edit."; exit 1; }
	cd testing/platforms && ansible-playbook playbooks/full-cycle.yml $(if $(LIMIT),--limit $(LIMIT),)
