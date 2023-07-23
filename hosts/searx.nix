{ pkgs, config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "vanyarybin1@live.ru";

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."sx.thatsverys.us" = {
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
}
