{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # simple-nixos-mailserver = {
    #   url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.utils.follows = "flake-utils";
    # };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , pre-commit-hooks
    , ...
    }:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        checks.pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            # Github actions
            actionlint.enable = true;

            # nix
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;

            # terraform
            terraform-format.enable = true;
            tflint.enable = true;

            # Shell
            shellcheck.enable = true;
            shfmt.enable = true;
          };
        };

        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;

          packages = with pkgs; with  self.packages.${system}; [
            colmena
            wireguard-tools
            terraform
            terraform-providers.vultr
            vultr-cli
            deploy-configuration
            generate-qr-code
          ];
        };

        packages = with pkgs; {
          deploy-configuration = writeShellApplication {
            name = "deploy-configuration";
            checkPhase = ":";
            runtimeInputs = [ colmena rbw ];
            text = ''
              set -ex
              colmena apply "$@"
              colmena exec "$@" -- sudo nix-collect-garbage -dv
              colmena exec "$@" -- sudo nix-store --optimise -v
            '';
          };

          generate-qr-code = writeShellApplication {
            name = "generate-qr-code";
            checkPhase = ":";
            runtimeInputs = [ colmena jq qrencode rbw ];
            text = builtins.readFile ./generate-qr-code.sh;
          };
        };

        apps = {
          deploy-configuration = {
            type = "app";
            program = "${self.packages.${system}.deploy-configuration}/bin/deploy-configuration";
          };
          generate-qr-code = {
            type = "app";
            program = "${self.packages.${system}.generate-qr-code}/bin/generate-qr-code";
          };
        };

      }) // {
      colmena = {
        meta.nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ ];
        };
        defaults = {
          imports = [
            "${nixpkgs}/nixos/modules/profiles/headless.nix"
            "${nixpkgs}/nixos/modules/profiles/minimal.nix"
            ./hosts/defaults.nix
          ];
        };

        vpn = {
          deployment.targetUser = "nixos";
          deployment.targetHost = "vpn.thatsverys.us";
          imports = [
            ./hosts/vpn.nix
          ];
        };

        nextcloud = {
          deployment.targetUser = "nixos";
          deployment.targetHost = "nc.thatsverys.us";
          imports = [
            ./hosts/nextcloud.nix
          ];
        };

        # mail = {
        #   deployment.targetUser = "nixos";
        #   deployment.targetHost = "mail.thatsverys.us";
        #   imports = [
        #     simple-nixos-mailserver.nixosModule
        #     ./hosts/mail.nix
        #   ];
        # };
      };
    }
  ;
}
