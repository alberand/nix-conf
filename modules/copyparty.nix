{
  config,
  pkgs,
  ...
}: {
  age.secrets.copyparty = {
    file = ../secrets/nixxy-copyparty.age;
    mode = "400";
    owner = "copyparty";
    group = "copyparty";
  };

  environment.systemPackages = [pkgs.copyparty];

  networking = {
    firewall.allowedTCPPorts = [
      3210
      3211
    ];
  };

  systemd.tmpfiles.rules = [
    "d /media/copyparty 0755 copyparty copyparty - -"
    "A /media/copyparty - - - - m::rwx"
    "A+ /media/copyparty - - - - u:${config.user}:rwx"
  ];

  services.copyparty = {
    enable = true;
    # directly maps to values in the [global] section of the copyparty config.
    # see `copyparty --help` for available options
    settings = {
      i = "0.0.0.0";
      # use lists to set multiple values
      p = [3210 3211];
      # use booleans to set binary flags
      no-reload = true;
      # using 'false' will do nothing and omit the value when generating a config
      ignored-flag = false;
    };

    # create users
    accounts = {
      # specify the account name as the key
      alberand = {
        # provide the path to a file containing the password, keeping it out of /nix/store
        # must be readable by the copyparty service user
        passwordFile = config.age.secrets.copyparty.path;
      };
    };

    # create a volume
    volumes = {
      # create a volume at "/" (the webroot), which will
      "/" = {
        # share the contents of "/srv/copyparty"
        path = "/media/copyparty";
        # see `copyparty --help-accounts` for available options
        access = {
          A = ["alberand"];
        };
        # see `copyparty --help-flags` for available options
        flags = {
          # "fk" enables filekeys (necessary for upget permission) (4 chars long)
          fk = 4;
          # scan for new files every 60sec
          scan = 60;
          # volflag "e2d" enables the uploads database
          e2d = true;
          # "d2t" disables multimedia parsers (in case the uploads are malicious)
          d2t = true;
          # skips hashing file contents if path matches *.iso
          nohash = "\.iso$";
        };
      };
    };
    # you may increase the open file limit for the process
    openFilesLimit = 8192;
  };
}
