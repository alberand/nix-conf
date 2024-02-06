{ pkgs, ... }: {
  services.nginx = {
    enable = false;
    virtualHosts.localhost = {
      listen = [{
        addr = "127.0.0.1";
      }];
      locations."/shared/" = {
        alias = "/srv/www/shared/";
      };
    };
  };
}
