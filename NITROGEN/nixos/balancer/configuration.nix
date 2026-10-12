{ config, lib, pkgs, ... }:

{
  services.haproxy = {
    enable = true;
    config = builtins.readFile ./haproxy.cfg;
  };
}
