{
  config,
  pkgs,
  ...
}: {
  age.secrets.restic-hetzner-key = {
    file = ../secrets/restic-hetzner-key.age;
    mode = "400";
    owner = "restic";
    group = "restic";
  };

  age.secrets.restic-password = {
    file = ../secrets/restic-password.age;
    mode = "400";
    owner = "restic";
    group = "restic";
  };

  users.users.restic = {
    isNormalUser = true;
    description = "Restic backups to Hetzner";
    uid = 1004;
    openssh.authorizedKeys.keyFiles = [
      ../secrets/restic_ed25519.pub
    ];
    extraGroups = ["media" "immich"];
  };
  users.groups.restic.gid = 1004;

  systemd.tmpfiles.rules = [
    "d /media/backup 0755 restic restic - -"
    "A /media/backup - - - - m::rwx"
    "A+ /media/backup - - - - u:restic:rwx,g:restic:rwx"
    "A+ /media/backup - - - - u:${config.user}:rwx"
  ];

  fileSystems."/media/backup/photos" = {
    depends = [
      "/media"
    ];
    device = "/media/photos";
    fsType = "none";
    options = [
      "bind"
      "ro"
    ];
  };

  programs.ssh = {
    knownHosts = let
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
    in {
      "hetzner".publicKey = key;
      "u486743.your-storagebox.de".publicKey = key;
    };

    extraConfig = ''
      Host hetzner
          Hostname u486743.your-storagebox.de
          User u486743
          Port 23
          AddressFamily inet
          IdentityFile ${config.age.secrets.restic-hetzner-key.path}
    '';
  };

  environment.systemPackages = [
    pkgs.restic
  ];

  services.restic.backups = {
    daily = {
      initialize = true;
      user = "restic";
      passwordFile = config.age.secrets.restic-password.path;
      repository = "sftp:hetzner:backup";

      paths = [
        "/media/backup"
        "/var/lib/minecraft/Our World"
      ];

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
      ];
    };
  };
}
