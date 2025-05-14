{
  pkgs,
  config,
  ...
}: {
  networking.wg-quick.interfaces = {
    wg0 = {
      address = ["10.10.10.2"];
      privateKeyFile = "/etc/jfwg/client.private";

      peers = [
        {
          publicKey = "MKrNqXfz4sMtRekE44eHLdS/epD0MRZDd/PslJilr1A=";
          allowedIPs = ["10.10.10.0/30"];
          endpoint = "89.221.212.102:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  services.home-assistant.extraComponents = ["jellyfin"];

  # Media group to access media storage
  users.groups.media = {
    name = "media";
    gid = 8096;
    members = [config.user "jellyfin" "sonarr" "radarr" "jackett"];
  };

  users.users.deluge = {
    isNormalUser = true;
    description = "Deluge";
    extraGroups = ["media"];
    uid = 1002;
  };

  users.users.jellyfin = {
    description = "JellyFin";
    extraGroups = ["media" "render" "video"];
  };

  environment.systemPackages = with pkgs; [jellyfin-ffmpeg];

  networking.firewall.allowedTCPPorts = [55686];

  services.radarr = {
    enable = true;
  };

  services.jackett = {
    enable = true;
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.jellyseerr = {
    enable = true;
    port = 5055;
    openFirewall = true;
  };

  services.sonarr = {
    enable = true;
    group = "media";
  };
}
