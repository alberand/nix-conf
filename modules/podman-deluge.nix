{ pkgs, ... }:

{
    systemd.services.podman-deluge = {
        after = [ "wireguard-wg0.service" ];
    };

    virtualisation.oci-containers.containers = {
        "deluge" = {
            image = "binhex/arch-delugevpn";
            autoStart = true;
            ports = [ 
	            "127.0.0.1:8112:8112" 
	            "8118:8118" 
	            "58846:58846" 
	            "58946:58946" 
            ];
            volumes = [
	            "/media:/media"
	            "/home/alberand/.deluge:/config"
                "/etc/localtime:/etc/localtime:ro"
            ];
            environment = {
                PUID = "0";
                PGID = "8096";
                VPN_ENABLED = "yes";
                VPN_CLIENT = "wireguard";
	            VPN_PROV = "custom";
                STRICT_PORT_FORWARD = "yes";
                ENABLE_PRIVOXY = "yes";
                LAN_NETWORK = "192.168.0.100/32";
                NAME_SERVERS = "84.200.69.80,37.235.1.174,1.1.1.1,37.235.1.177,84.200.70.40,1.0.0.1";
                DELUGE_DAEMON_LOG_LEVEL = "trace";
                DELUGE_WEB_LOG_LEVEL = "trace";
                DEBUG = "true";
                UMASK = "000";
                TZ = "Europe/London";
            };
            extraOptions = [
                "--privileged=true"
	            ''--sysctl="net.ipv4.conf.all.src_valid_mark=1"''
            ];
        };
    };
}
