{ config, lib, pkgs, ... }:

let
  ENV = (import ./environment.nix) { pkgs = pkgs; };
in

{
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = let
    ghcrAuth = {
      username = "avevad";
      passwordFile = "${pkgs.writeText "ghcr-token.txt" ENV.TOKENS.GITHUB_DEPLOY}";
      registry = "https://ghcr.io";
    };
  in {
  };
}
