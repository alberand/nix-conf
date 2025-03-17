{
  config,
  pkgs,
  ...
}: {
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "builder";
        protocol = "ssh-ng";
        sshKey = "/home/alberand/.ssh/nixremote";
        sshUser = "nixremote";
        system = "x86_64-linux";
        supportedFeatures = ["kvm" "big-parallel"];
      }
      {
        hostName = "lonmoun";
        protocol = "ssh-ng";
        sshKey = "/home/alberand/.ssh/nixbuilder_ed25519";
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
