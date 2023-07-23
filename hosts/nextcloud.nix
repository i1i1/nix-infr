{ pkgs, config, lib, ... }:

let
  cfg = config.features.service.nextcloud;
in
{
  options.features.service.nextcloud = with lib; {
    enable = mkEnableOption "enable nextcloud";
    serverKeyCommand = mkOption { type = types.listOf types.str; };
    hostName = mkOption { type = types.str; };
  };

  config = lib.mkIf cfg.enable {
    deployment.keys."root" = {
      keyCommand = cfg.serverKeyCommand;
      user = "nextcloud";
      group = "nextcloud";
      permissions = "0640";
    };

    users.users.nextcloud.extraGroups = [ "keys" ];

    services.nextcloud = {
      inherit (cfg) hostName;

      enable = true;
      package = pkgs.nextcloud27;

      # Apps
      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit
          bookmarks
          calendar
          contacts
          files_markdown
          onlyoffice
          tasks;
      };
      extraAppsEnable = true;

      # HTTPS
      https = true;

      # caching
      configureRedis = true;
      caching.apcu = false;

      # Admin password
      config.adminpassFile = "/run/keys/root";

      phpOptions = {
        upload_max_filesize = "2G";
        post_max_size = "2G";
      };
    };

    services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
      forceSSL = true;
      enableACME = true;
    };
  };
}
