# Project Template

A comprehensive development environment template that works across multiple languages and frameworks, providing a consistent baseline for new projects.

## Features

- **Nix Flakes** for reproducible development environments
- **direnv** for automatic environment activation
- **SOPS** for secrets management
- **Make** for common development tasks
- **Homebrew** support for non-Nix users
- Comprehensive `.gitignore` for multiple languages and IDEs

## Quick Start

### Option 1: Nix + direnv (Recommended)

1. **Prerequisites**: Install [Nix](https://nixos.org/download.html) and [direnv](https://direnv.net/docs/installation.html)

2. **Clone and setup**:
   ```bash
   git clone <your-repo>
   cd <your-repo>
   direnv allow  # This will automatically set up the development environment
   ```

3. **Configure secrets** (optional):
   ```bash
   # Replace with your GPG key fingerprint in .sops.yaml
   gpg --list-secret-keys --keyid-format LONG
   # Edit .sops.yaml and replace YOUR_GPG_KEY_FINGERPRINT_HERE
   ```

### Option 2: Homebrew (macOS/Linux)

If you prefer not to use Nix:

1. **Install dependencies**:
   ```bash
   brew bundle
   ```

2. **Manual tool installation**:
   ```bash
   # Install semver-cli (requires Go)
   go install github.com/maykonlsf/semver-cli@latest
   ```

3. **Setup direnv**:
   ```bash
   # Add to your shell profile (.bashrc, .zshrc, etc.)
   eval "$(direnv hook bash)"  # for bash
   eval "$(direnv hook zsh)"   # for zsh
   
   # Allow direnv in the project
   direnv allow
   ```

## Development Environment

### Nix Flake

The `flake.nix` provides a reproducible development environment with:

- **Core tools**: git, make, direnv
- **Secrets management**: sops, age, gnupg
- **Utilities**: curl, jq, yq
- **Version management**: semver-cli

Enter the development shell:
```bash
nix develop
# or if you have direnv set up:
# It activates automatically when you cd into the directory
```

### devshell Configuration

The `devshell.toml` configures the development environment with:

- Categorized package lists
- Startup scripts for environment setup
- Helpful MOTD (message of the day)
- Automatic directory creation

### direnv Integration

The `.envrc` file provides:

- Automatic loading of `.env` files
- Nix flake activation
- Environment variable exports

**Usage**: 
- Create a `.env` file for project-specific environment variables
- The environment activates automatically when entering the directory
- Use `direnv reload` to refresh after changes

## Secrets Management

### SOPS (Secrets OPerationS)

Configure secrets encryption with your GPG key:

1. **Setup GPG key**:
   ```bash
   # List your GPG keys
   gpg --list-secret-keys --keyid-format LONG
   
   # Copy the key fingerprint and update .sops.yaml
   ```

2. **Create and encrypt secrets**:
   ```bash
   # Create a secrets file
   echo "api_key: your-secret-value" > secrets.yaml
   
   # Encrypt it
   sops -e -i secrets.yaml
   ```

3. **Use in development**:
   ```bash
   # Decrypt and view
   sops -d secrets.yaml
   
   # Edit encrypted file
   sops secrets.yaml
   ```

### Make Targets

Common development tasks via `make`:

```bash
make help           # Show available targets
make setup          # Initial project setup
make clean          # Clean temporary files
make build          # Build the project (customize)
make test           # Run tests (customize)
make lint           # Run linting (customize)
make format         # Format code (customize)
make dev            # Start development server (customize)

# Version management
make version-patch  # Bump patch version
make version-minor  # Bump minor version  
make version-major  # Bump major version

# Secrets management
make secrets-encrypt  # Encrypt secrets.yaml
make secrets-decrypt  # Decrypt secrets.yaml

# Nix maintenance
make nix-update     # Update flake inputs
```

## Brewfile Support

For teams or contributors not using Nix, the `Brewfile` provides equivalent tools via Homebrew:

```bash
# Install all dependencies
brew bundle

# Install specific categories
brew bundle --file=Brewfile
```

**Included tools**:
- git, make, direnv
- sops, age, gnupg (secrets)
- jq, yq (data processing)
- curl (networking)

**Note**: `semver-cli` requires manual installation via Go.

## Project Structure

```
.
├── .envrc              # direnv configuration
├── .gitignore          # Comprehensive gitignore
├── .sops.yaml          # SOPS configuration
├── Brewfile            # Homebrew dependencies
├── Makefile            # Development tasks
├── README.md           # This file
├── devshell.toml       # Development shell config
└── flake.nix           # Nix flake definition
```

## Customization

### For Your Project

1. **Update `flake.nix`**: Add language-specific tools and dependencies
2. **Customize `Makefile`**: Implement build, test, lint, and dev targets
3. **Configure `devshell.toml`**: Add project-specific packages and startup scripts
4. **Update `Brewfile`**: Add any additional Homebrew packages needed
5. **Setup secrets**: Configure `.sops.yaml` with your GPG key

### Language-Specific Examples

#### Node.js Project
```nix
# Add to flake.nix packages
nodejs
npm
yarn
```

#### Python Project  
```nix
# Add to flake.nix packages
python3
python3Packages.pip
python3Packages.virtualenv
```

#### Go Project
```nix
# Add to flake.nix packages  
go
gopls
```

#### Rust Project
```nix
# Add to flake.nix packages
rustc
cargo
rust-analyzer
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Test across different environments (Nix + Homebrew)
4. Submit a pull request

## License

[Your License Here]