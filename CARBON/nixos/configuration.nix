{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware.nix
    ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.swraid.enable = true;
  boot.swraid.mdadmConf = "PROGRAM /run/current-system/sw/bin/true";

  networking = {
    hostName = "CARBON";
    domain = "avevad.com";
    fqdn = "carbon.avevad.com";
    useDHCP = false;
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    interfaces.enp7s0.ipv4 = {
      addresses = [ { address = "10.10.10.10"; prefixLength = 24; } ];
      routes = [
        { address = "0.0.0.0"; prefixLength = 0; via = "10.10.10.1"; }
        { address = "10.10.10.0"; prefixLength = 24; }
      ];
    };

    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.100.100.30/32" ];
        privateKeyFile = "/root/nixos/wg0.txt";
        listenPort = 51339;
        peers = [
          {
            publicKey = "jD9IEOpc2ZcoOTZ2bUHexmns1/OBKPl6PeApovWcJSs=";
            allowedIPs = [ "10.100.0.0/16" ];
            endpoint = "77.233.223.179:51339"; # hub.avevad.com:51339
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  programs.wireshark.enable = true;
  programs.wireshark.dumpcap.enable = true;

  time.timeZone = "Europe/Moscow";

  virtualisation.docker.enable = true;

  users.groups.media = {};
  users.users.avevad = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "admin" "media" "wireshark" ];
    packages = with pkgs; [ vim htop git wireshark ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];

  services.openssh = {
    enable = true;
    listenAddresses = [ { addr = "10.10.10.10"; port = 22;  } ];
    settings.X11Forwarding = true;
  };
  services.jellyfin.enable = true;

  networking.firewall.enable = false;

  system.copySystemConfiguration = true;
  system.stateVersion = "25.05";
}
