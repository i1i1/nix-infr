{ pkgs, config, ... }:
{
  deployment.keys."root" = {
    keyCommand = [ "rbw" "get" "nextcloud-admin-pass" ];
    user = "nextcloud";
    group = "nextcloud";
    permissions = "0640";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud27;

    # Apps
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit contacts calendar bookmarks tasks files_markdown onlyoffice;
    };
    extraAppsEnable = true;

    # HTTPS
    hostName = "nc.thatsverys.us";
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

  users.users.nextcloud.extraGroups = [ "keys" ];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "vanyarybin1@live.ru";

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    enableACME = true;
  };
}
