#!/usr/bin/env sh

vpnInfo() {
	colmena eval -E \
		"{ nodes, lib, ... }:
        with nodes.vpn.config.networking.wg-quick.interfaces.wg0;
        {
          inherit peers address listenPort;
          inherit (nodes.vpn.config.deployment) targetHost;
        }"
}

[ "$#" -ne 1 ] && {
	echo "$0 <peer-number>"
	exit 1
}

PUBKEY=$(rbw get --folder wireguard client"$1" | wg pubkey)
PEER=$(vpnInfo | jq ".peers[] | select(.publicKey == \"$PUBKEY\")")

cat | qrencode -t ansiutf8 <<EOF
[Interface]
PrivateKey = $(rbw get --folder wireguard client"$1")
Address = $(echo "$PEER" | jq -r '.allowedIPs[0]')
DNS = $(vpnInfo | jq -r '.address[0]' | cut -d/ -f1)

[Peer]
PublicKey = $(rbw get --folder wireguard server | wg pubkey)
AllowedIPs = 0.0.0.0/0
Endpoint = $(vpnInfo | jq -r .targetHost):$(vpnInfo | jq -r .listenPort)
PersistentKeepAlive = $(echo "$PEER" | jq -r .persistentKeepalive)
EOF
