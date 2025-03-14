{config, ...}: {
  age.secrets.binary-cache-key.file = ../secrets/binary-cache-key.age;

  services.nix-serve = {
    enable = true;
    port = 5000;
    secretKeyFile = config.age.secrets.binary-cache-key.path;
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "192.168.0.100:80".extraConfig = ''
        encode gzip
        reverse_proxy ${config.services.nix-serve.bindAddress}:${
          toString config.services.nix-serve.port
        }
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [80];
}
