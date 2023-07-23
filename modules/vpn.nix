{ pkgs, config, lib, ... }:

let
  cfg = config.features.vpn.wireguard;
in
{
  options.features.vpn.wireguard = with lib; {
    enable = mkEnableOption "enable wireguard";
    serverKeyCommand = mkOption { type = types.listOf types.str; };
    pubkeys = mkOption { type = types.listOf types.str; };
  };

  config = lib.mkIf cfg.enable {
    deployment.keys."server".keyCommand = cfg.serverKeyCommand;

    networking.nat = {
      enable = true;
      externalInterface = "ens3";
      internalInterfaces = [ "wg0" ];
    };
    networking.firewall = with config.networking.wg-quick.interfaces.wg0; {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 listenPort ];
    };

    services.dnsmasq = {
      enable = true;
      settings.interface = "wg0";
    };

    networking.wg-quick.interfaces.wg0 = {
      address = [ "10.0.103.1/24" ];
      listenPort = 51820;

      privateKeyFile = "/run/keys/server";

      postUp =
        let
          # This allows wireguard server to set keep alive for each peer
          persistentKeepAlive =
            lib.lists.fold
              (peer: acc: acc + "wg set wg0 peer ${peer.publicKey} persistent-keepalive ${toString peer.persistentKeepalive}\n")
              ""
              config.networking.wg-quick.interfaces.wg0.peers;
        in
        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
          ${pkgs.iptables}/bin/iptables -A FORWARD -o wg0 -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.103.1/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
          ${persistentKeepAlive}
        '';

      # Undo the above
      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -D FORWARD -o wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.103.1/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
      '';

      peers =
        lib.lists.imap1
          (i: publicKey: {
            inherit publicKey;
            allowedIPs = [ "10.0.103.${toString (i + 1)}/32" ];
            persistentKeepalive = 25;
          })
          cfg.pubkeys;
    };
  };
}
