{ config, lib, pkgs, ... }:

{
  security.acme = {
    acceptTerms = true;
    defaults.email = "vadim@avevad.com";

    certs."avedus.pro" = {
      domain = "*.carbon.avedus.pro";
      extraDomainNames = [ "*.at.avedus.pro" ];

      dnsProvider = "porkbun";
      environmentFile = "/var/acme/porkbun.env";

      group = config.services.haproxy.group;
      reloadServices = [ "haproxy.service" ];
    };
  };

  services.haproxy = {
    enable = true;
    config = (builtins.readFile ./haproxy.cfg);
  };

  systemd.services.haproxy = {
    wants = [ "acme-avedus.pro.service" ];
    after = [ "acme-avedus.pro.service" ];
  };
}
