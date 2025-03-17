{
  config,
  pkgs,
  ...
}: {
  age.secrets.nixbuilder_ed25519 = {
    file = ../secrets/nixbuilder_ed25519.age;
    path = "/root/.ssh/nixbuilder_ed25519";
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "builder";
        sshKey = config.age.secrets.nixbuilder_ed25519.path;
        system = "x86_64-linux";
        supportedFeatures = ["kvm" "big-parallel"];
      }
    ];
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
