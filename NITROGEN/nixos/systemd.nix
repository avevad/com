{ config, lib, pkgs, ... }:

let
  ENV = (import ./environment.nix) { pkgs = pkgs; };
in

{
  systemd.services.pushy-error-logs = {
    enable = true;
    description = "Export Error Journal to Pushy";
    after = [ "network.target" ];
    serviceConfig = {
      Type = "exec";
      ExecStart = "${ pkgs.bash }/bin/bash -c '${ pkgs.systemd }/bin/journalctl -perr -f -n0 | /root/.local/bin/pushy send -c -m code'";
      StandardOutput = "null";
      StandardError = "journal";
      Environment = "PUSHY_API_KEY=${ ENV.TOKENS.ERR_LOGS_API_KEY }";
      Restart = "on-failure";
    };
    wantedBy = [ "multi-user.target" ];
  };
}

