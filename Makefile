CONTAINER_ENGINE ?= podman
MDOX ?= $(shell command -v mdox 2>/dev/null)

.PHONY: submodule-init submodule-update submodule-status reset-projects lint lint-fix check-links validate

submodule-init:
	git submodule update --init

submodule-update:
	git submodule update --remote --merge

submodule-status:
	git submodule status

reset-projects:
	@./scripts/reset-projects.sh

lint:
	$(CONTAINER_ENGINE) run --rm -v $(CURDIR):/workdir:Z davidanson/markdownlint-cli2:v0.23.2 "**/*.md"

lint-fix:
	$(CONTAINER_ENGINE) run --rm -v $(CURDIR):/workdir:Z davidanson/markdownlint-cli2:v0.23.2 --fix "**/*.md"

check-links:
ifndef MDOX
	$(error mdox not found — install with: go install github.com/bwplotka/mdox@latest)
endif
	$(MDOX) fmt --links.validate --links.validate.config-file=.mdox.validate.yaml --check *.md components/**/*.md development/**/*.md

validate: lint check-links
