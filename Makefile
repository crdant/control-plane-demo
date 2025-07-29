# Project Makefile
# Common targets for development workflow
PROJECTDIR := $(shell pwd)

.PHONY: help setup clean build release test lint app patch minor major alpha beta rc encrypt decrypt update

# Default target
.DEFAULT_GOAL := help

# Colors for output
RED    := \033[31m
GREEN  := \033[32m
YELLOW := \033[33m
BLUE   := \033[34m
RESET  := \033[0m

# Commands
SOPS    := sops
SEMVER  := semver

HELM       := helm
KUBECTL     := kubectl
REPLICATED := replicated

# sources
CHARTDIR    := $(PROJECTDIR)/charts
CHARTS      := $(shell find $(CHARTDIR) -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

MANIFESTDIR := $(PROJECTDIR)/replicated
MANIFESTS   := $(shell find $(MANIFESTDIR) -name '*.yaml' -o -name '*.yml')

VERSION     ?= $(semver get release) 
CHANNEL     := $(shell git branch --show-current)
ifeq ($(CHANNEL), main)
	CHANNEL=Unstable
endif

BUILDDIR      := $(PROJECTDIR)/build
RELEASE_FILES := 

define make-manifest-target
$(BUILDDIR)/$(notdir $1): $1 | $$(BUILDDIR)
	cp $1 $$(BUILDDIR)/$$(notdir $1)
RELEASE_FILES := $(RELEASE_FILES) $(BUILDDIR)/$(notdir $1)
manifests:: $(BUILDDIR)/$(notdir $1)
endef
$(foreach element,$(MANIFESTS),$(eval $(call make-manifest-target,$(element))))

define make-chart-target
$(eval VER := $(shell yq .version $(CHARTDIR)/$1/Chart.yaml))
$(BUILDDIR)/$1-$(VER).tgz : $(CHARTDIR)/$1 $(shell find $(CHARTDIR)/$1 -name '*.yaml' -o -name '*.yml' -o -name "*.tpl" -o -name "NOTES.txt" -o -name "values.schema.json") | $$(BUILDDIR)
ifeq ($1,openhands)
	# Special handling for openhands chart to patch litellm-helm
	helm dependency update $(CHARTDIR)/$1
	$(MAKE) patch-litellm-helm OPENHANDS_CHARTDIR=$(CHARTDIR)/$1
	helm package $(CHARTDIR)/$1 -d $(BUILDDIR)/
else
	helm package -u $(CHARTDIR)/$1 -d $(BUILDDIR)/
endif
RELEASE_FILES := $(RELEASE_FILES) $(BUILDDIR)/$1-$(VER).tgz
charts:: $(BUILDDIR)/$1-$(VER).tgz
test:: 
	@helm test $(CHARTDIR)/$1
lint:: 
	@helm lint $(CHARTDIR)/$1
endef
$(foreach element,$(CHARTS),$(eval $(call make-chart-target,$(element))))

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

## help: Show this help message
help:
	@echo -e "$(BLUE)Available targets:$(RESET)"
	@awk 'BEGIN {FS = ":.*##"; printf ""} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[32m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

## setup: Initial project setup
setup:
	@echo -e "$(YELLOW)Setting up project...$(RESET)"
	@direnv allow
	@if [ ! -f .env ]; then cp .env.example .env 2>/dev/null || echo "# Project environment variables" > .env; fi
	@git config core.hooksPath .githooks
	@if [ ! -f .semver.yaml ]; then semver init --release 0.1.0 ; fi
	@echo -e "$(GREEN)Setup complete! Git hooks activated.$(RESET)"

## app: Create Replicated application
app: setup
	@echo -e "$(YELLOW)Creating Replicated application 'Grafana'...$(RESET)"
	@APP_SLUG=$$($(REPLLICATED) app create Grafana --output json | jq -r '.[].app.slug'); \
	if [ "$$APP_SLUG" != "null" ] && [ -n "$$APP_SLUG" ]; then \
		sed -i.bak "s/REPLICATED_APP=.*/REPLICATED_APP=$$APP_SLUG/" .env && rm .env.bak; \
		echo -e "$(GREEN)Application created with slug: $$APP_SLUG$(RESET)"; \
		echo -e "$(GREEN)Updated .env with app slug$(RESET)"; \
	else \
		echo -e "$(RED)Failed to create application$(RESET)"; \
		exit 1; \
	fi

## clean: Clean temporary files and build artifacts
clean:
	@echo -e "$(YELLOW)Cleaning up...$(RESET)"
	@rm -rf tmp/ .tmp/ *.log build/*
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@echo -e "$(GREEN)Cleanup complete!$(RESET)"

## build: Build the project
build: $(RELEASE_FILES)
	@echo -e "$(YELLOW)Building project...$(RESET)"

release: build

## test: Run tests
test:: $(RELEASE_FILES)
	@echo -e "$(YELLOW)Running tests...$(RESET)"

## lint: Run linting
lint:: $(RELEASE_FILES)
	@echo -e "$(YELLOW)Running linter...$(RESET)"
	@$(REPLICATED) release lint --yaml-dir $(BUILDDIR)

## patch: Bump patch version
patch:
	@echo -e "$(YELLOW)Bumping patch version...$(RESET)"
	@semver-cli bump patch

## minor: Bump minor version
minor:
	@echo -e "$(YELLOW)Bumping minor version...$(RESET)"
	@semver-cli bump minor

## major: Bump major version
major:
	@echo -e "$(YELLOW)Bumping major version...$(RESET)"
	@semver-cli bump major

## alpha: Create alpha pre-release
alpha:
	@echo -e "$(YELLOW)Creating alpha pre-release...$(RESET)"
	@semver-cli bump prerelease --identifier alpha

## beta: Create beta pre-release
beta:
	@echo -e "$(YELLOW)Creating beta pre-release...$(RESET)"
	@semver-cli bump prerelease --identifier beta

## rc: Create release candidate
rc:
	@echo -e "$(YELLOW)Creating release candidate...$(RESET)"
	@semver-cli bump prerelease --identifier rc

## encrypt: Encrypt secrets with SOPS
encrypt:
	@echo -e "$(YELLOW)Encrypting secrets...$(RESET)"
	@if [ -f secrets.yaml ]; then sops -e -i secrets.yaml; else echo -e "$(RED)secrets.yaml not found$(RESET)"; fi

## decrypt: Decrypt secrets with SOPS
decrypt:
	@echo -e "$(YELLOW)Decrypting secrets...$(RESET)"
	@if [ -f secrets.yaml ]; then sops -d secrets.yaml; else echo -e "$(RED)secrets.yaml not found$(RESET)"; fi

## update: Update Nix flake inputs
update:
	@echo -e "$(YELLOW)Updating Nix flake inputs...$(RESET)"
	@nix flake update
	@echo -e "$(GREEN)Flake inputs updated!$(RESET)"
