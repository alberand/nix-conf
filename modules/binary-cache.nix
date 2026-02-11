{config, ...}: {
  age.secrets.cache-private-key.file = ../secrets/cache-private-key.age;

  # test with
  #   $ nix store info --store https://cache.alberand.com
  #
  # on the cache server
  #   $ nix-build '<nixpkgs>' -A pkgs.hello
  #     this path will be fetched (0.05 MiB download, 0.22 MiB unpacked):
  #     /nix/store/071v7r87n3v93zx9g94zjf1fd1riir4h-hello-2.12.1
  #     copying path '/nix/store/071v7r87n3v93zx9g94zjf1fd1riir4h-hello-2.12.1' from 'https://cache.nixos.org'...
  #     /nix/store/071v7r87n3v93zx9g94zjf1fd1riir4h-hello-2.12.1
  #   $ curl https://cache.alberand.com/071v7r87n3v93zx9g94zjf1fd1riir4h.narinfo
  services.nix-serve = {
    enable = true;
    port = 5000;
    secretKeyFile = config.age.secrets.cache-private-key.path;
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "cache.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy ${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}
      '';
    };
  };
}
