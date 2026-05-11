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
    passmgr-vaultwarden = {
      image = "vaultwarden/server:1.35.3";
      ports = [ "127.0.0.1:8808:80" ];
      volumes = [ "/mnt/state/vaultwarden:/data" ];
      environment = {
        TZ="Europe/Moscow";
        LOG_LEVEL="error";
        EXTENDED_LOGGING="true";
        ADMIN_TOKEN=ENV.TOKENS.VAULTWARDEN_ADMIN_TOKEN;
      };
    };

    metrics-prometheus = {
      image = "prom/prometheus";
      ports = [ "127.0.0.1:9090:9090" ];
      cmd = [
        "--config.file=/etc/prometheus/prometheus.yml"
        "--storage.tsdb.path=/prometheus"
        "--storage.tsdb.retention.time=1y"
        "--log.level=warn"
        "--enable-feature=exemplar-storage"
      ];
      volumes = [
        "${./metrics/prometheus.yml}:/etc/prometheus/prometheus.yml:ro"
        "${./metrics/prometheus.rules.yml}:/etc/prometheus/rules.yml:ro"
        "/mnt/state/prometheus:/prometheus"
      ];
      environment = {
        TZ="Europe/Moscow";
      };
      extraOptions = [ "--user=root" "--dns=10.100.0.1" ];
    };

    metrics-alertmanager = let
      alertmanagerYml = pkgs.writeText "alertmanager.yml" (builtins.replaceStrings
        [
          "@PUSHY_DEV_TEAM_WEBHOOK_URL@"
        ]
        [
          ENV.TOKENS.PUSHY_DEV_TEAM_ALERTS_URL
        ]
        (builtins.readFile ./metrics/alertmanager.yml)
      );
    in {
      image = "prom/alertmanager";
      ports = [ "127.0.0.1:9093:9093" ];
      cmd = [
        "--config.file=/etc/alertmanager/alertmanager.yml"
        "--storage.path=/alertmanager"
        "--log.level=warn"
      ];
      volumes = [
        "${alertmanagerYml}:/etc/alertmanager/alertmanager.yml:ro"
        "/mnt/state/alertmanager:/alertmanager"
      ];
      environment = {
        TZ="Europe/Moscow";
      };
      extraOptions = [ "--user=root" "--dns=10.100.0.1" ];
    };

    metrics-grafana = {
      image = "grafana/grafana";
      ports = [ "127.0.0.1:3000:3000" ];
      volumes = [
        "/mnt/state/grafana:/var/lib/grafana"
      ];
      environment = {
        TZ="Europe/Moscow";
      };
      extraOptions = [ "--user=root" "--dns=10.100.0.1" ];
    };
  };
}
