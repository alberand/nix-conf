{
  config,
  pkgs,
  ...
}: {
  age.secrets.nixbuilder_ed25519.file = ../secrets/nixbuilder_ed25519.age;

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "builder";
        protocol = "ssh-ng";
        sshKey = config.age.secrets.nixbuilder_ed25519.path;
        sshUser = "nixremote";
        system = "x86_64-linux";
        supportedFeatures = ["kvm" "big-parallel"];
      }
    ];
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
