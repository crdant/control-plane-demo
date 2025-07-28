{
  description = "Development environment template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, devshell }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlays.default ];
        };
        
        # Build semver-cli from source
        semver-cli = pkgs.buildGoModule rec {
          pname = "semver-cli";
          version = "1.1.4";
          
          src = pkgs.fetchFromGitHub {
            owner = "maykonlsf";
            repo = "semver-cli";
            rev = "v${version}";
            sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash
          };
          
          vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash
          
          meta = with pkgs.lib; {
            description = "A command line tool for semantic versioning";
            homepage = "https://github.com/maykonlsf/semver-cli";
            license = licenses.mit;
          };
        };
      in
      {
        devShells.default = pkgs.devshell.mkShell {
          imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
          
          packages = with pkgs; [
            # Core development tools
            git
            gnumake
            
            # Secrets management
            sops
            age
            gnupg
            
            # Version management
            semver-cli
            
            # Common utilities
            curl
            jq
            yq-go
          ];
        };
      });
}