{ config, pkgs, ... }:

{
  # 1. Enable the Node Exporter to gather system metrics
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
  };

  # 2. Enable Prometheus and tell it to scrape the Node Exporter
  services.prometheus = {
    enable = true;
    port = 9090;
    scrapeConfigs = [
      {
        job_name = "nixos-system";
        static_configs = [{
          targets = [ "127.0.0.1:9100" ];
        }];
      }
    ];
  };

  # 3. Enable Grafana and automatically connect it to Prometheus
  services.grafana = {
    enable = true;
    settings.server = {
      http_addr = "127.0.0.1";
      http_port = 3030; # Using 3030 because 3000 is used by todoist-opencode-bridge
    };
    settings.security = {
      secret_key = "SW2YcwTIb9zpOOhoPsMm"; # Hardcoded default for non-secret setups
    };
    
    # Declaratively add Prometheus as the default data source
    provision.enable = true;
    provision.datasources.settings.datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        access = "proxy";
        url = "http://127.0.0.1:9090";
        isDefault = true;
      }
    ];
  };
}