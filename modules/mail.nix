{ config, ... }:
{
  mailserver = {
    enable = true;
    fqdn = "mail.thatsverys.us";
    domains = [ "thatsverys.us" ];

    loginAccounts = {
      "ivan@thatsverys.us" = {
        hashedPassword = "$2b$05$IoFpyQqxUpYicBe9rYsiO.V1kmfOVZMcePANO2O5p/958KaqpSe.i";
        aliases = [ "postmaster@thatsverys.us" ];
      };
    };

    certificateScheme = "acme-nginx";
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "vanyarybin1@live.ru";

  services.roundcube = {
    enable = true;
    hostName = config.mailserver.fqdn;
    extraConfig = ''
      # starttls needed for authentication, so the fqdn required to match
      # the certificate
      $config['smtp_host'] = "tls://${config.mailserver.fqdn}";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
    '';
  };

  services.nginx.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
