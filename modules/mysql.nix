{pkgs, ...}: {
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureUsers = [
      {
        name = "forgejo";
        ensurePermissions = {
          "forgejo.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.longview.mysqlPasswordFile = ./db-password;
}
