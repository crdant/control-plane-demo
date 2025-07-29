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
          version = "1.1.1";
          
          src = pkgs.fetchFromGitHub {
            owner = "maykonlsf";
            repo = "semver-cli";
            rev = "v${version}";
            sha256 = "sha256-Qj9RV2wW0i0hL5CDL4WCa7yKUIvmL2kkId1K8qNIfsw=";
          };
          
          vendorHash = "sha256-o87+Y0m2pmjijlEXQDFFekshCgWR+lYt83nU4w5faV0=";
          
          meta = with pkgs.lib; {
            description = "A command line tool for semantic versioning";
            homepage = "https://github.com/maykonlsf/semver-cli";
            license = licenses.mit;
          };
        };
        
        # Build replicated CLI from source
        replicated = pkgs.buildGoModule rec {
          pname = "replicated";
          version = "0.109.1";
          
          src = pkgs.fetchFromGitHub {
            owner = "replicatedhq";
            repo = "replicated";
            rev = "v${version}";
            sha256 = "sha256-wECaQiqzPVdbRacFLZnNef4jeVXygw9qbSkI67OXSD0=";
          };
          
          vendorHash = "sha256-/OKkyV6x/7wgk8kbNLVq0Swr/QRD0dqfOXHuoW1S2aY=";
          
          subPackages = [ "cli/cmd/" ];
          
          ldflags = [
            "-X github.com/replicatedhq/replicated/pkg/version.version=${version}"
            "-X github.com/replicatedhq/replicated/pkg/version.gitCommit=${src.rev}"
          ];

          ldflagsStr = pkgs.lib.strings.concatStringsSep " " ldflags;

          # Override build phase to use make
          buildPhase = ''
            export HOME=$(pwd)
            runHook preBuild
            make LDFLAGS='-ldflags "${ldflagsStr}"' build
            runHook postBuild
          '';

          # Install the binary
          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            cp bin/replicated $out/bin/
            runHook postInstall
          '';

          nativeBuildInputs = [ pkgs.installShellFiles ];

          postInstall = ''
            $out/bin/replicated completion bash > replicated.bash
            $out/bin/replicated completion zsh > replicated.zsh
            $out/bin/replicated completion fish > replicated.fish
            installShellCompletion replicated.{bash,zsh,fish}
          '';
          
          # Skip tests that might be problematic
          doCheck = false;
          
          meta = with pkgs.lib; {
            homepage = "https://github.com/replicatedhq/replicated";
            description = "A CLI to create, edit and promote releases for the Replicated platform";
            mainProgram = "replicated";
            license = licenses.mit;
          };
        };
      in
      {
        devShells.default = pkgs.devshell.mkShell {
          imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
          
          packages = with pkgs; [
            # Custom packages built in this flake
            semver-cli
            replicated
            
            # Helm and Kubernetes tooling
            kubernetes-helm
            kubectl
          ];
        };
      });
}