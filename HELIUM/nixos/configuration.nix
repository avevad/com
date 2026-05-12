{ config, lib, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  networking.hostName = "HELIUM";
  networking.firewall.enable = false;
  networking.networkmanager.enable = true; # TODO: replace with static config

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
