.PHONY: help init plan apply destroy bootstrap clean

# Colors
BLUE := \033[0;34m
NC := \033[0m

help: ## Show this help
	@echo "$(BLUE)budabuda-k8s Homelab$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ===== SOPS =====
generate-age-key: ## Generate age key for SOPS
	@mkdir -p ~/.config/sops/age
	age-keygen -o ~/.config/sops/age/age.agekey
	@echo "Public key:"
	@grep "public key" ~/.config/sops/age/age.agekey
	@echo "Update .sops.yaml with this public key"

encrypt-secrets: ## Encrypt all secrets with SOPS
	sops -e secrets/blocky-env.yaml > secrets/blocky-env.enc.yaml
	sops -e secrets/authelia-env.yaml > secrets/authelia-env.enc.yaml

# ===== OpenTofu =====
tofu-init: ## Initialize OpenTofu
	cd tofu/providers && tofu init

tofu-plan: ## Plan OpenTofu changes
	cd tofu/providers && tofu plan -out=tfplan

tofu-apply: ## Apply OpenTofu changes
	cd tofu/providers && tofu apply tfplan

tofu-destroy: ## Destroy OpenTofu resources (DANGEROUS)
	cd tofu/providers && tofu destroy

# ===== Talos =====
talos-gen-config: ## Generate Talos machine configs
	@echo "Generate schematic at: https://factory.talos.dev/schematics"
	@echo "Then run: talosctl gen config budabuda-k8s https://192.168.1.200:6443"

talos-apply: ## Apply Talos machine configs
	talosctl apply-config --talosconfig=talosconfig --nodes=192.168.1.210 -f controlplane.yaml
	talosctl apply-config --talosconfig=talosconfig --nodes=192.168.1.211 -f worker.yaml

talos-bootstrap: ## Bootstrap etcd (single-node CP)
	talosctl bootstrap --talosconfig=talosconfig --nodes=192.168.1.210

talos-kubeconfig: ## Get kubeconfig
	talosctl kubeconfig --talosconfig=talosconfig --nodes=192.168.1.210 --endpoint=192.168.1.200

# ===== Kubectl =====
kubectl-apply-base: ## Apply base cluster manifests
	kubectl apply -f cluster/base/

kubectl-apply-apps: ## Apply application manifests
	kubectl apply -f cluster/apps/

# ===== Bootstrap =====
bootstrap: ## Full bootstrap sequence
	@echo "$(BLUE)Phase 1: Initialize OpenTofu$(NC)"
	$(MAKE) tofu-init
	@echo "$(BLUE)Phase 2: Apply OpenTofu (create VMs)$(NC)"
	$(MAKE) tofu-apply
	@echo "$(BLUE)Phase 3: Apply Talos configs$(NC)"
	$(MAKE) talos-apply
	@echo "$(BLUE)Phase 4: Bootstrap etcd$(NC)"
	$(MAKE) talos-bootstrap
	@echo "$(BLUE)Phase 5: Get kubeconfig$(NC)"
	$(MAKE) talos-kubeconfig
	@echo "$(BLUE)Phase 6: Apply Cilium + Longhorn$(NC)"
	$(MAKE) kubectl-apply-base
	@echo "$(BLUE)Bootstrap complete!$(NC)"
	@echo "Access ArgoCD at: https://argocd.budabuda-k8s.duckdns.org"

clean: ## Clean generated files
	rm -f tofu/providers/.terraform -rf
	rm -f tofu/providers/tfplan
