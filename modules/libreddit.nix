{ config, lib, ... }:
let
  cfg = config.features.service.libreddit;
in
{
  options.features.service.libreddit = with lib; {
    enable = mkEnableOption "enable libreddit";
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
        locations."/" = with config.services.libreddit; {
          proxyPass = "http://${address}:${toString port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_ssl_server_name on;
            proxy_pass_header Authorization;
          '';
        };
      };
    };

    services.libreddit = {
      enable = true;
      port = 13235;
      address = "127.0.0.1";
    };
  };
}
