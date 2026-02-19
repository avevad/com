{ config, lib, pkgs, ... }:

{
  services.haproxy = {
    enable = true;
    config = ./haproxy.cfg;
  };
}
