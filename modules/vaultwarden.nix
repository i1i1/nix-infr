{ config, lib, ... }:
let
  cfg = config.features.service.vaultwarden;
in
{
  options.features.service.vaultwarden = with lib; {
    enable = mkEnableOption "enable vaultwarden";
    hostName = mkOption { type = types.str; };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."${cfg.hostName}" = with config.services.vaultwarden.config; {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${ROCKET_ADDRESS}:${toString ROCKET_PORT}";
          proxyWebsockets = true;
        };
        locations."/notifications/hub" = {
          proxyPass = "http://${WEBSOCKET_ADDRESS}:${toString WEBSOCKET_PORT}";
          proxyWebsockets = true;
        };
        locations."/notifications/hub/negotiate" = {
          proxyPass = "http://${ROCKET_ADDRESS}:${toString ROCKET_PORT}";
          proxyWebsockets = true;
        };
      };
    };

    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8822;
        WEBSOCKET_ADDRESS = "127.0.0.1";
        WEBSOCKET_PORT = 8823;
      };
    };
  };
}

