BIN_DIR ?= $(CURDIR)/bin
MDOX ?= $(BIN_DIR)/mdox

.PHONY: help submodule-init submodule-update submodule-status reset-projects lint lint-fix install-mdox validate clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

submodule-init: ## Initialize git submodules
	git submodule update --init

submodule-update: ## Pull latest upstream commits into submodules
	git submodule update --remote --merge

submodule-status: ## Show pinned submodule commits
	git submodule status

reset-projects: ## Reset all submodules to .gitmodules branches (push first)
	@./scripts/reset-projects.sh

install-mdox: ## Install mdox
	mkdir -p $(BIN_DIR)
	GOBIN=$(BIN_DIR) go install github.com/bwplotka/mdox@latest

$(MDOX):
	$(MAKE) install-mdox

lint: $(MDOX) ## Check markdown formatting and links
	find . -name '*.md' -not -path './projects/*' -not -path './tasks/*' -not -path './completed/*' -not -path './tmp/*' -not -path './bin/*' -not -name 'README.md' -print0 | xargs -0 $(MDOX) fmt --links.validate --links.validate.config-file=.mdox.validate.yaml --check
	$(MDOX) fmt --links.validate --links.validate.config-file=.mdox.validate.yaml --check --soft-wraps README.md

lint-fix: $(MDOX) ## Fix markdown formatting and validate links
	find . -name '*.md' -not -path './projects/*' -not -path './tasks/*' -not -path './completed/*' -not -path './tmp/*' -not -path './bin/*' -not -name 'README.md' -print0 | xargs -0 $(MDOX) fmt --links.validate --links.validate.config-file=.mdox.validate.yaml
	$(MDOX) fmt --links.validate --links.validate.config-file=.mdox.validate.yaml --soft-wraps README.md

validate: lint ## Run all checks

clean: ## Remove local tool binaries
	rm -rf $(BIN_DIR)
