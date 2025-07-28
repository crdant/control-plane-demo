# Project Makefile
# Common targets for development workflow

.PHONY: help setup clean build test lint format install dev patch minor major alpha beta rc encrypt decrypt update

# Default target
.DEFAULT_GOAL := help

# Colors for output
RED    := \033[31m
GREEN  := \033[32m
YELLOW := \033[33m
BLUE   := \033[34m
RESET  := \033[0m

## help: Show this help message
help:
	@echo "$(BLUE)Available targets:$(RESET)"
	@awk 'BEGIN {FS = ":.*##"; printf ""} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-15s$(RESET) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

## setup: Initial project setup
setup:
	@echo "$(YELLOW)Setting up project...$(RESET)"
	@direnv allow
	@if [ ! -f .env ]; then cp .env.example .env 2>/dev/null || echo "# Project environment variables" > .env; fi
	@git config core.hooksPath .githooks
	@echo "$(GREEN)Setup complete! Git hooks activated.$(RESET)"

## clean: Clean temporary files and build artifacts
clean:
	@echo "$(YELLOW)Cleaning up...$(RESET)"
	@rm -rf tmp/ .tmp/ *.log
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@echo "$(GREEN)Cleanup complete!$(RESET)"

## build: Build the project
build:
	@echo "$(YELLOW)Building project...$(RESET)"
	@echo "$(RED)Build target not implemented - customize for your project$(RESET)"

## test: Run tests
test:
	@echo "$(YELLOW)Running tests...$(RESET)"
	@echo "$(RED)Test target not implemented - customize for your project$(RESET)"

## lint: Run linting
lint:
	@echo "$(YELLOW)Running linter...$(RESET)"
	@echo "$(RED)Lint target not implemented - customize for your project$(RESET)"

## format: Format code
format:
	@echo "$(YELLOW)Formatting code...$(RESET)"
	@if command -v prettier >/dev/null 2>&1; then \
		prettier --write "**/*.{js,ts,jsx,tsx,json,yaml,yml,md}" 2>/dev/null || true; \
	fi
	@if command -v black >/dev/null 2>&1; then \
		black . 2>/dev/null || true; \
	fi
	@if command -v rustfmt >/dev/null 2>&1; then \
		find . -name "*.rs" -exec rustfmt {} \; 2>/dev/null || true; \
	fi
	@if command -v gofmt >/dev/null 2>&1; then \
		gofmt -w . 2>/dev/null || true; \
	fi
	@echo "$(GREEN)Code formatting complete!$(RESET)"

## install: Install dependencies
install:
	@echo "$(YELLOW)Installing dependencies...$(RESET)"
	@echo "$(RED)Install target not implemented - customize for your project$(RESET)"

## dev: Start development server
dev:
	@echo "$(YELLOW)Starting development server...$(RESET)"
	@echo "$(RED)Dev target not implemented - customize for your project$(RESET)"

## patch: Bump patch version
patch:
	@echo "$(YELLOW)Bumping patch version...$(RESET)"
	@semver-cli bump patch

## minor: Bump minor version
minor:
	@echo "$(YELLOW)Bumping minor version...$(RESET)"
	@semver-cli bump minor

## major: Bump major version
major:
	@echo "$(YELLOW)Bumping major version...$(RESET)"
	@semver-cli bump major

## alpha: Create alpha pre-release
alpha:
	@echo "$(YELLOW)Creating alpha pre-release...$(RESET)"
	@semver-cli bump prerelease --identifier alpha

## beta: Create beta pre-release
beta:
	@echo "$(YELLOW)Creating beta pre-release...$(RESET)"
	@semver-cli bump prerelease --identifier beta

## rc: Create release candidate
rc:
	@echo "$(YELLOW)Creating release candidate...$(RESET)"
	@semver-cli bump prerelease --identifier rc

## encrypt: Encrypt secrets with SOPS
encrypt:
	@echo "$(YELLOW)Encrypting secrets...$(RESET)"
	@if [ -f secrets.yaml ]; then sops -e -i secrets.yaml; else echo "$(RED)secrets.yaml not found$(RESET)"; fi

## decrypt: Decrypt secrets with SOPS
decrypt:
	@echo "$(YELLOW)Decrypting secrets...$(RESET)"
	@if [ -f secrets.yaml ]; then sops -d secrets.yaml; else echo "$(RED)secrets.yaml not found$(RESET)"; fi

## update: Update Nix flake inputs
update:
	@echo "$(YELLOW)Updating Nix flake inputs...$(RESET)"
	@nix flake update
	@echo "$(GREEN)Flake inputs updated!$(RESET)"