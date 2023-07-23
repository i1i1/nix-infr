{ config, lib, ... }:
let
  cfg = config.features.service.nitter;
in
{
  options.features.service.nitter = with lib; {
    enable = mkEnableOption "enable nitter";
    hostName = mkOption { type = types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."${cfg.hostName}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = with config.services.nitter.server; {
          proxyPass = "http://${address}:${toString port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_ssl_server_name on;
            proxy_pass_header Authorization;
          '';
        };
      };
    };

    services.nitter = {
      enable = true;
      server.address = "127.0.0.1";
      server.port = 9002;
    };
  };
}

