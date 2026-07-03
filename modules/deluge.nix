{
  config,
  pkgs,
  ...
}: let
  server = "10.175.251.254";
  server_ipv6 = "fd7d:76ee:e68f:a993:ab82:4b25:ee6d:cf20";
  dns = "10.128.0.1";
  mtu = "1320";
  port = 47107;
in {
  age.secrets.deluge-wg = {
    file = ../secrets/deluge-wg.age;
    mode = "400";
    owner = "root";
    group = "root";
  };

  age.secrets.deluge-auth = {
    file = ../secrets/deluge-auth.age;
    mode = "600";
    owner = "media";
    group = "media";
  };

  systemd.tmpfiles.rules = [
    "d /bigdata/media/download 2755 media media -"
    "d /media/cstate/media/var/lib/deluge/.config 2755 media media -"
  ];

  systemd.services."netns@" = {
    description = "%I network namespace";
    # Delay network.target until this unit has finished starting up.
    before = ["network.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      PrivateNetwork = true;
      ExecStart = "${pkgs.writers.writeDash "netns-up" ''
        ${pkgs.iproute2}/bin/ip netns add $1
        ${pkgs.util-linux}/bin/umount /var/run/netns/$1
        ${pkgs.util-linux}/bin/mount --bind /proc/self/ns/net /var/run/netns/$1
      ''} %I";
      ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
      # This is required since systemd commit c2da3bf, shipped in systemd 254.
      # See discussion at https://github.com/systemd/systemd/issues/28686
      PrivateMounts = false;
    };
  };

  systemd.services.deluge-wg = {
    description = "deluge network interface";
    # Absolutely require the wg network namespace to exist.
    bindsTo = ["netns@deluge.service"];
    # Require a network connection.
    requires = [
      "network-online.target"
      "nss-lookup.target"
    ];
    # Start after and stop before those units.
    after = [
      "netns@deluge.service"
      "network-online.target"
      "nss-lookup.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writers.writeDash "wg-up" ''
        ${pkgs.iproute2}/bin/ip link add wg0 type wireguard
        ${pkgs.iproute2}/bin/ip link set wg0 netns deluge
        ${pkgs.iproute2}/bin/ip link set deluge netns deluge
        ${pkgs.iproute2}/bin/ip -n deluge -4 addr add ${server}/32 dev wg0
        ${pkgs.iproute2}/bin/ip -n deluge -6 addr add ${server_ipv6}/128 dev wg0
        ${pkgs.iproute2}/bin/ip -n deluge -4 addr add 10.30.10.10/32 dev deluge
        ${pkgs.iproute2}/bin/ip netns exec deluge \
          ${pkgs.wireguard-tools}/bin/wg setconf wg0 ${config.age.secrets.deluge-wg.path}
        ${pkgs.iproute2}/bin/ip -n deluge link set wg0 up
        ${pkgs.iproute2}/bin/ip -n deluge link set lo up
        ${pkgs.iproute2}/bin/ip -n deluge link set deluge up
        ${pkgs.iproute2}/bin/ip -n deluge route add default dev wg0
        ${pkgs.iproute2}/bin/ip -n deluge link set wg0 mtu ${mtu}
      '';
      ExecStop = pkgs.writers.writeDash "wg-down" ''
        ${pkgs.iproute2}/bin/ip -n deluge link del wg0
        ${pkgs.iproute2}/bin/ip -n deluge route del default dev wg0
      '';
    };
  };

  # Start "deluge" container only after deluge-wg started
  systemd.services."container@deluge" = {
    after = ["deluge-wg.service"];
    requires = ["deluge-wg.service"];
  };

  containers.deluge = {
    autoStart = true;
    ephemeral = false;
    networkNamespace = "/run/netns/deluge";
    bindMounts = {
      "/bigdata" = {
        hostPath = "/bigdata";
        isReadOnly = false;
      };
      "/var/lib" = {
        hostPath = "/media/cstate/media/var/lib";
        isReadOnly = false;
      };
      "/run/deluge-auth" = {
        hostPath = config.age.secrets.deluge-auth.path;
        isReadOnly = false;
      };
    };
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      users.users.media = {
        isNormalUser = true;
        description = "Movies & Shows media user";
        group = "media";
        uid = 3000;
      };

      users.groups.media = {
        name = "media";
        gid = 3000;
      };

      services.deluge = {
        enable = true;
        openFirewall = true;
        user = "media";
        group = "media";
        web.enable = true;
        web.openFirewall = true;
        web.port = 8112;

        declarative = true;
        authFile = "/run/deluge-auth";
        config = {
          download_location = "/bigdata/media/download";
          allow_remote = true;
          daemon_port = 58846;
          listen_interface = "10.175.251.254";
          listen_random_port = false;
          random_port = false;
          listen_ports = [
            28779
            28800
          ];
          pre_allocate_storage = true;
          outgoing_interface = "10.175.251.254";
          max_upload_speed = 5000;
          share_ratio_limit = 2;
          max_connections_global = 200;
          max_download_speed = 5000;
          max_active_seeding = 100;
          max_active_downloading = 10;
          max_active_limit = 100;
          dont_count_slow_torrents = true;
          queue_new_to_top = true;
          stop_seed_at_ratio = true;
          remove_seed_at_ratio = true;
          stop_seed_ratio = 2;
          geoip_db_location = "${pkgs.geolite-legacy}/share/GeoIP/GeoIP.dat";
          enabled_plugins = [
            "Extractor"
            "Label"
            "Blocklist"
          ];
          extraPackages = with pkgs; [
            bzip2
            gnutar
            unzip
            xz
          ];
        };
      };

      systemd.network.enable = true;
      systemd.network.wait-online.enable = false;
      # Need to be removed if NetworkManager is not used anymore
      networking.useNetworkd = true;
      networking.firewall = {
        allowedTCPPorts = [
          8112
          28779
          28800
          58846
        ];
        allowedUDPPorts = [
          28779
          28800
        ];
      };

      systemd.network = {
        networks = {
          "20-cbr-deluge" = {
            matchConfig.Name = "deluge";
            networkConfig = {
              Address = "10.30.10.10/24";
            };
            routes = [
              {
                Source = "10.30.10.0/24";
                Destination = "10.30.10.0/24";
              }
            ];
          };
        };
      };

      networking = {
        nameservers = [dns];
        firewall = {
          enable = true;
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;

      system.stateVersion = "26.05";
    };
  };

  networking = {
    firewall = {
      allowedTCPPorts = [
        port
        58846
      ];
    };
    nftables = {
      enable = true;

      tables.services = {
        enable = true;
        family = "ip";
        content = ''
          chain PREROUTING {
            type nat hook prerouting priority dstnat; policy accept;
            iifname "cbr" tcp dport 8112 dnat to 10.30.10.10:8112
          }
          chain postrouting {
            type nat hook postrouting priority srcnat; policy accept;

            # Masquerade traffic leaving toward deluge's network
            # so return packets come back to the host, not directly to Jellyfin
            # container
            oifname "dc" ip daddr 10.30.10.10 tcp dport 8112 \
                masquerade
          }
        '';
      };
    };
  };
}
