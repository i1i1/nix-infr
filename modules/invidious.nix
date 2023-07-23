{ config, lib, ... }:
let
  cfg = config.features.service.invidious;
in
{
  options.features.service.invidious = with lib; {
    enable = mkEnableOption "enable invidious";
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
        locations."/" = with config.services.invidious; {
          proxyPass = "http://${settings.host_binding}:${toString port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_ssl_server_name on;
            proxy_pass_header Authorization;
          '';
        };
      };
    };

    services.invidious = {
      enable = true;
      port = 3006;
      settings.host_binding = "127.0.0.1";
    };
  };
}
