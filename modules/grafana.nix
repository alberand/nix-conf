{ pkgs, ... }:

{
	services.grafana = {
		enable = true;
		port = 3000;
		addr = "127.0.0.1";
		analytics.reporting.enable = false;
	};
}
