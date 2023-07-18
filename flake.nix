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
            actionlint.enable = true;
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
            terraform-format.enable = true;
            tflint.enable = true;
          };
        };

        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;

          packages = with pkgs; [
            colmena
            wireguard-tools
            terraform
            terraform-providers.vultr
            vultr-cli
          ];
        };

        apps.qr-code =
          let
            qr_code_shell_app = with pkgs; writeShellApplication {
              name = "generate-qr-code";
              checkPhase = ":";
              runtimeInputs = [ colmena jq qrencode rbw ];
              text = builtins.readFile ./generate-qr-code.sh;
            };
          in
          {
            type = "app";
            program = "${qr_code_shell_app}/bin/generate-qr-code";
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
