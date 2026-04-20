{
  config,
  pkgs,
  ...
}: {
  age.secrets.transmission-wg = {
    file = ../secrets/transmission-wg.age;
    mode = "400";
    owner = "root";
    group = "root";
  };

  systemd.tmpfiles.rules = [
    "d /bigdata/transmission                    2755 media media -"
    "d /bigdata/transmission/download           2755 media media -"
    "d /bigdata/transmission/download/watch     2755 media media -"
    "d /bigdata/media/download                  2755 media media -"
    "d /bigdata/media/incomplete                2755 media media -"
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

  systemd.services.transmission-wg = {
    description = "transmission network interface";
    # Absolutely require the wg network namespace to exist.
    bindsTo = ["netns@transmission.service"];
    # Require a network connection.
    requires = [
      "network-online.target"
      "nss-lookup.target"
    ];
    # Start after and stop before those units.
    after = [
      "netns@transmission.service"
      "network-online.target"
      "nss-lookup.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writers.writeDash "wg-up" ''
        ${pkgs.iproute2}/bin/ip link add wg0 type wireguard
        ${pkgs.iproute2}/bin/ip link set wg0 netns transmission
        ${pkgs.iproute2}/bin/ip link set transmission netns transmission
        ${pkgs.iproute2}/bin/ip -n transmission -4 addr add 10.73.91.65/32 dev wg0
        ${pkgs.iproute2}/bin/ip -n transmission -6 addr add fc00:bbbb:bbbb:bb01::a:5b40/128 dev wg0
        ${pkgs.iproute2}/bin/ip -n transmission -4 addr add 10.30.10.10/32 dev transmission
        ${pkgs.iproute2}/bin/ip netns exec transmission \
          ${pkgs.wireguard-tools}/bin/wg setconf wg0 ${config.age.secrets.transmission-wg.path}
        ${pkgs.iproute2}/bin/ip -n transmission link set wg0 up
        ${pkgs.iproute2}/bin/ip -n transmission link set lo up
        ${pkgs.iproute2}/bin/ip -n transmission link set transmission up
        ${pkgs.iproute2}/bin/ip -n transmission route add default dev wg0
        ${pkgs.iproute2}/bin/ip -n transmission link set wg0 mtu 1420
      '';
      ExecStop = pkgs.writers.writeDash "wg-down" ''
        ${pkgs.iproute2}/bin/ip -n transmission link del wg0
        ${pkgs.iproute2}/bin/ip -n transmission route del default dev wg0
      '';
    };
  };

  # Start "transmission" container only after transmission-wg started
  systemd.services."container@transmission" = {
    after = ["transmission-wg.service"];
    requires = ["transmission-wg.service"];
  };

  containers.transmission = {
    autoStart = true;
    ephemeral = false;
    networkNamespace = "/run/netns/transmission";
    bindMounts = {
      "/bigdata" = {
        hostPath = "/bigdata";
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

      # See https://github.com/NixOS/nixpkgs/issues/258793
      systemd.services.transmission.serviceConfig = {
        RootDirectoryStartOnly = lib.mkForce null;
        RootDirectory = lib.mkForce null;
      };

      services.transmission = {
        user = "media";
        group = "media";
        home = "/bigdata/transmission";
        enable = true;
        openFirewall = true;
        openRPCPort = true;
        downloadDirPermissions = "750";

        settings = {
          watch-dir-enabled = true;
          watch-dir = "/bigdata/transmission/download/watch";
          incomplete-dir-enabled = true;
          incomplete-dir = "/bigdata/media/incomplete";
          download-dir = "/bigdata/media/download";
          umask = "022";
          message-level = 5;
          rpc-bind-address = "10.30.10.10";
          rpc-port = 9091;
          rpc-whitelist-enabled = true;
          rpc-host-whitelist-enabled = true;
          rpc-whitelist = "127.0.0.1,10.30.10.*,transmission.alberand.com";
          rpc-host-whitelist = "127.0.0.1,10.30.10.*,transmission.alberand.com";
          blocklist-enabled = true;
          blocklist-url = "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";
        };
      };

      systemd.network.enable = true;
      systemd.network.wait-online.enable = false;
      # Need to be removed if NetworkManager is not used anymore
      networking.useNetworkd = true;

      systemd.network = {
        networks = {
          "20-cbr-transmission" = {
            matchConfig.Name = "transmission";
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
        nameservers = ["10.64.0.1"];
        firewall = {
          enable = true;
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;

      system.stateVersion = "25.11";
    };
  };

  networking.nftables = {
    enable = true;

    tables.services = {
      enable = true;
      family = "ip";
      content = ''
        chain PREROUTING {
          type nat hook prerouting priority dstnat; policy accept;
          iifname "cbr" tcp dport 9091 dnat to 10.30.10.10:9091
        }
        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;

          # Masquerade traffic leaving toward Transmission's network
          # so return packets come back to the host, not directly to Jellyfin
          # container
          oifname "tc" ip daddr 10.30.10.10 tcp dport 9091 \
              masquerade
        }
      '';
    };
  };
}
