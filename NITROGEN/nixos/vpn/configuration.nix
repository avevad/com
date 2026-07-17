{ config, lib, pkgs, ... }:

{
  networking = {
    wireguard.interfaces = {
      wg0 = { # gateway.avevad.com
        listenPort = 51337;
        ips = [ "10.100.0.1/16" ];
        privateKeyFile = "/var/wireguard/key0.txt";
        peers = [
          { # ULTRA
            publicKey = "Bjt3G1nGF1vSq1UWzM/TbmWYBCyjDKlu3ZO7PEvnZlQ=";
            allowedIPs = [ "10.100.10.10/16" "10.10.0.0/16" ];
          }
        ] ++ ( import ./clients.nix );
        allowedIPsAsRoutes = false;
        postSetup = ''
          ip route add 10.100.0.0/16 dev wg0 table 42
          ip route add 10.10.0.0/16 via 10.100.10.10 dev wg0
          ip route add 10.10.0.0/16 via 10.100.10.10 dev wg0 table 42
          ip rule add iif wg0 table 42
        '';
        preShutdown = ''
          ip rule delete iif wg0
          ip route del 10.10.0.0/16 via 10.100.10.10 dev wg0 table 42
          ip route del 10.10.0.0/16 via 10.100.10.10 dev wg0
          ip route del 10.100.0.0/16 dev wg0 table 42
        '';
      };

      wg1 = { # NITROGEN<->dimrem
        listenPort = 51340;
        ips = [ "10.8.0.6/32" ];
        privateKeyFile = "/var/wireguard/key1.txt";
        peers = [
          { # dimrem
            publicKey = "tVh679yQKdxP27Hgzh0+q8nl+4Js8MzoGjtM6pyxcic=";
            presharedKeyFile = "/var/wireguard/pskey1.txt";
            allowedIPs = [ "0.0.0.0/0" ];
            endpoint = "de.vpn.dimrem.com:32554";
            persistentKeepalive = 25;
          }
        ];
        allowedIPsAsRoutes = false;
        postSetup = ''
          ip route add default dev wg1 table 42
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o wg1 -j MASQUERADE
        '';
        preShutdown = ''
          ip route del default dev wg1 table 42
        '';
      };
    };
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      server = [ "1.1.1.1" "1.0.0.1" ];
      no-resolv = true;
      no-hosts = true;
      log-queries = true;
      auth-server = "nitrogen.avevad.com";
      auth-zone = "avedus.pro";
      host-record = [
        # Important hosts
        "netlink.avedus.pro,10.10.0.1"
        "ultra.avedus.pro,10.10.10.1"
        "actinium-ipmi.avedus.pro,10.10.10.101"
        "actinium.avedus.pro,10.10.10.100"
        "carbon.avedus.pro,10.10.10.10"
        "oxygen.avedus.pro,10.10.10.11"
        "nitrogen.avedus.pro,10.100.0.1"
      ];
      cname = [
        # Service subdomains
        "*.nitrogen.avedus.pro,nitrogen.avedus.pro"
        "*.helium.avedus.pro,helium.avedus.pro"
        # Proxy aliases
        "cinema.at.avedus.pro,carbon.avedus.pro"
        "passwords.at.avedus.pro,nitrogen.avedus.pro"
        "metrics.at.avedus.pro,nitrogen.avedus.pro"
        "vectors.at.avedus.pro,carbon.avedus.pro"
        "search.at.avedus.pro,carbon.avedus.pro"
        "proxmox-ac.at.avedus.pro,nitrogen.avedus.pro"
      ];
    };
  };
}

