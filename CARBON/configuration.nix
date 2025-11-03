# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  # boot.initrd.systemd.fido2.enable = true;
  # boot.initrd.luks.devices.secure1.device = "/dev/disk/by-uuid/87fc7191-23f5-41d7-ab84-74c169749d76";
  # boot.initrd.luks.devices.secure1.crypttabExtraOpts = [ "fido2-device=auto" ];
  boot.swraid.enable = true;

  networking = {
    hostName = "CARBON";
    domain = "avevad.com";
    fqdn = "carbon.avevad.com";

    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.100.100.30/32" ];
        privateKeyFile = "/root/nixos/wg0.txt";
        listenPort = 51339;
        peers = [
          {
            publicKey = "jD9IEOpc2ZcoOTZ2bUHexmns1/OBKPl6PeApovWcJSs=";
            allowedIPs = [ "10.100.0.0/16" ];
            endpoint = "hub.avevad.com:51339";
            persistentKeepalive = 25;
          }
        ];
        postSetup = "${pkgs.iptables}/bin/iptables -t nat -I POSTROUTING -o enp9s0 -j MASQUERADE";
        preShutdown = "${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o enp9s0 -j MASQUERADE";
      };
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  
  systemd.services.mdmonitor.enable = false;
  virtualisation.docker.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  users.groups.admin = {};
  users.users.admin = {
    isNormalUser = true;
    group = "admin";
    homeMode = "770";
    extraGroups = [ "wheel" ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.avevad = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "admin" ];
    packages = with pkgs; [ vim htop git ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.nscd.enable = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  system.nssModules = lib.mkForce [];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
