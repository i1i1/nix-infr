{ pkgs, config, lib, ... }:
let
  cfg = config.features.service.searx;
in
{
  options.features.service.searx = with lib; {
    enable = mkEnableOption "enable searx";
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
        locations."/" = with config.services.searx.settings.server; {
          proxyPass = "http://${bind_address}:${port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_ssl_server_name on;
            proxy_pass_header Authorization;
          '';
        };
      };
    };

    services.searx = {
      enable = true;
      package = pkgs.searxng;
      settings = {
        server.port = "13234";
        server.bind_address = "127.0.0.1";
        server.secret_key = "@SEARX_SECRET_KEY@";
      };
    };
  };
}
