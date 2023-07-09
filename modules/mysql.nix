{ pkgs, ... }: {
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;
  services.longview.mysqlPasswordFile = ./db-password;
}
