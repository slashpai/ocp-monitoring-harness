CONTAINER_ENGINE ?= podman

.PHONY: submodule-init submodule-update submodule-status reset-projects lint lint-fix

submodule-init:
	git submodule update --init

submodule-update:
	git submodule update --remote --merge

submodule-status:
	git submodule status

reset-projects:
	@./scripts/reset-projects.sh

lint:
	$(CONTAINER_ENGINE) run --rm -v $(CURDIR):/workdir:Z davidanson/markdownlint-cli2:latest "**/*.md"

lint-fix:
	$(CONTAINER_ENGINE) run --rm -v $(CURDIR):/workdir:Z davidanson/markdownlint-cli2:latest --fix "**/*.md"
