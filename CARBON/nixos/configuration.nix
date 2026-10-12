{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware.nix
      ./balancer/configuration.nix
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
  };

  programs.wireshark.enable = true;
  programs.wireshark.dumpcap.enable = true;
  programs.tmux.enable = true;

  time.timeZone = "Europe/Moscow";

  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings.features.cdi = true;

  users.groups.media = {};
  users.users.avevad = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "admin" "media" "wireshark" ];
    packages = with pkgs; [ vim htop git wireshark python312Packages.pip python312 ];
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
  services.qdrant.enable = true;
  services.opensearch.enable = true;

  services.minio = {
    enable = true;
    dataDir = [ "/mnt/store/minio" ];
    consoleAddress = "127.0.0.1:9001";
    listenAddress = "127.0.0.1:9000";
  };

  services.mongodb = {
    enable = true;
    dbpath = "/mnt/store/mongodb";
    enableAuth = true;
    initialRootPasswordFile = "/root/mongopasswd";
  };

  networking.firewall.enable = false;

  system.copySystemConfiguration = true;
  system.stateVersion = "25.05";
}
