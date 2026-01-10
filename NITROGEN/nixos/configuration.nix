{ config, lib, pkgs, ... }:

let
  ENV = (import ./environment.nix) { pkgs = pkgs; };
in

{
  system.stateVersion = "25.05";

  imports = [
    ./hardware.nix
    ./systemd.nix
    ./containers.nix
    ./vpn/configuration.nix
  ];

  networking = {
    hostName = "NITROGEN";
    domain = "avevad.com";
    fqdn = "nitrogen.avevad.com";

    networkmanager.enable = true;
    firewall.enable = false;
  };

  time.timeZone = "Europe/Moscow";

  programs.fish.enable = true;

  users.groups.admin = {};
  users.users.admin = {
    isNormalUser = true;
    group = "admin";
    homeMode = "770";
    extraGroups = [ "wheel" ];
  };

  users.users.avevad = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "admin" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      vim
    ];
  };

  environment.systemPackages = with pkgs; [
    htop
    neofetch
    git
    slirp4netns
    python311Full
    python311Packages.pip
  ];

  services = {
    openssh.enable = true;
    openssh.listenAddresses = [ { addr = "10.100.100.10"; port = 22; } ];
    openssh.settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };

    haproxy.enable = true;
    haproxy.config = (builtins.replaceStrings
      [
        "@CERT_FILE@"
        "@CERT_FILE_PUSHY@"
        "@CERT_FILE_TONSBP@"
        "@CERT_FILE_PRO@"
        "@DEPLOY_TOKEN@"
      ]
      [
        "${ pkgs.writeText "haproxy.pem" ENV.HAPROXY_CERT }"
        "${ pkgs.writeText "haproxy.pem" ENV.HAPROXY_CERT_PUSHY }"
        "${ pkgs.writeText "haproxy.pem" ENV.HAPROXY_CERT_TONSBP }"
        "${ pkgs.writeText "haproxy.pem" ENV.HAPROXY_CERT_PRO }"
        ENV.TOKENS.HAPROXY_DEPLOY
      ]
      (builtins.readFile ./etc/haproxy.cfg)
    );

    dnsmasq.enable = true;
    dnsmasq.resolveLocalQueries = false;
    dnsmasq.settings = {
      server = [ "1.1.1.1" "1.0.0.1" ];
      no-resolv = true;
      no-hosts = true;
      log-queries = true;
      auth-server = "nitrogen.avevad.com";
      auth-zone = "avedus.pro";
      host-record = [
        # Servers
        "nitrogen.avedus.pro,10.100.100.10" "nitrogen.avedus.pro,10.100.0.1"
        "helium.avedus.pro,10.100.100.20"
        "carbon.avedus.pro,10.100.100.30" "carbon.avedus.pro,10.10.10.10"

        # Important hosts
        "netlink.avedus.pro,10.10.0.1"
        "speedster.avedus.pro,10.10.10.1"
        "actinium-ipmi.avedus.pro,10.10.10.101"
        "actinium.avedus.pro,10.10.10.100"
      ];
      cname = [
        # Service subdomains
        "*.nitrogen.avedus.pro,nitrogen.avedus.pro"
        "*.helium.avedus.pro,helium.avedus.pro"

        # Service aliases
        "balancer.avedus.pro,nitrogen.avedus.pro"
        "cinema.avedus.pro,carbon.avedus.pro"
        "proxmox.avedus.pro,balancer.avedus.pro"
      ];
    };
  };
}
