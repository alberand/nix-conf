{config, ...}: {
  systemd.tmpfiles.rules = [
    "d /var/lib/www 0755 caddy caddy - -"
    # Set a mask to allow main system user to have full permission
    "A /var/lib/www - - - - m::rwx"
    # Grant caddy user/group to read/write git storage
    "A+ /var/lib/www - - - - u:caddy:rwx,g:caddy:rwx"
    # Grant main system user permission to read/write git storage
    "A+ /var/lib/www - - - - u:${config.user}:rwx"
  ];

  services.caddy = {
    virtualHosts = {
      "test.nemambyt.com".extraConfig = ''
        encode gzip
        reverse_proxy 100.69.0.2:4242
      '';
      "http://127.0.0.1:6969".extraConfig = ''
        encode gzip
        handle_path /api/* {
          reverse_proxy 10.10.10.69:4242
        }

        handle {
          root * /var/lib/www
          file_server browse
        }
      '';
    };
  };

  networking = {
    firewall.allowedTCPPorts = [
      6969
      4242
    ];
    extraHosts = ''
      10.10.10.69 nemambyt.container
    '';
  };
}
