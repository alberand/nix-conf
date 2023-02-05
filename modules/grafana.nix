{ pkgs, ... }:

{
	services.grafana = {
		enable = true;
		settings.server = {
			http_port = 3000;
			http_addr = "127.0.0.1";
		};
	};
}
