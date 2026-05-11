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
    ./balancer/configuration.nix
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
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "copyfail.avevad.com" = {
        root = ./www/copyfail.avevad.com;
        listen = [ { addr = "127.0.0.1"; port = 8080; } ];
      };
    };
  };
}
