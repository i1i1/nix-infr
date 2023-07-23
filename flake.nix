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
            ./modules/defaults.nix
          ];
        };

        server = {
          deployment.targetUser = "nixos";
          deployment.targetHost = "sx.thatsverys.us";
          imports = [
            ./modules/nextcloud.nix
            ./modules/vpn.nix
            ./modules/searx.nix
            ./modules/invidious.nix
            ./modules/libreddit.nix
            {
              networking.firewall.allowedTCPPorts = [ 80 443 ];

              security.acme.acceptTerms = true;
              security.acme.defaults.email = "vanyarybin1@live.ru";

              features = {
                service = {
                  nextcloud = {
                    enable = true;
                    serverKeyCommand = [ "rbw" "get" "nextcloud-admin-pass" ];
                    hostName = "nc.thatsverys.us";
                  };
                  searx = {
                    enable = true;
                    hostName = "sx.thatsverys.us";
                  };
                  invidious = {
                    enable = true;
                    hostName = "in.thatsverys.us";
                  };
                  libreddit = {
                    enable = true;
                    hostName = "lr.thatsverys.us";
                  };
                };

                vpn.wireguard = {
                  enable = true;
                  serverKeyCommand = [ "rbw" "get" "--folder" "wireguard" "server" ];
                  pubkeys = [
                    "u6OpMKjB89S25tYjIsUZnGB9Jabu0L0/vQzObTk28HA="
                    "9s/ZsJg1SIqQmEl0CmyLZs/yGcg/YUwMBbIcCwFRt0g="
                    "E27NpaVSoPnQ4otoKSz6Yv8c3TQ9vADZPUtuhrprdVg="
                    "Y5UxdQH5cBPjAbnZ3trCKSLLeB7ubYYWohgKhNM5ukI="
                  ];
                };

              };
            }
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
