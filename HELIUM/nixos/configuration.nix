{ config, lib, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  networking = {
    useDHCP = false;
    firewall.enable = false;

    hostName = "HELIUM";
    domain = "avedus.pro";
    fqdn = "helium.avedus.pro";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    interfaces.ens3.ipv4 = {
      addresses = [ { address = "146.103.124.240"; prefixLength = 24; } ];
      routes = [
        { address = "0.0.0.0"; prefixLength = 0; via = "146.103.124.1"; }
        { address = "146.103.124.0"; prefixLength = 24; }
      ];
    };

    wireguard.interfaces = {
      wg1 = {
        listenPort = 51340;
        ips = [ "10.254.254.1/30" ];
        privateKeyFile = "/var/wireguard/key1.txt";
        peers = [
          { # NITROGEN
            publicKey = "frYUUl/wWzMUeiIzjjzZeAkWCg7tie4KwtCK3yqCum8=";
            allowedIPs = [ "10.254.254.2" ];
          }
        ];
      };
    };
  };

  time.timeZone = "Europe/Amsterdam";

  programs.fish.enable = true;

  users.users.avevad = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      vim
      git
      htop
      neofetch
    ];
  };

  services.openssh.enable = true;

  system.copySystemConfiguration = true;
  system.stateVersion = "25.11";
}
