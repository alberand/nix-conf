{ config, pkgs, ... }:
{
  nix = {
    distributedBuilds = false;
    buildMachines = [
      {
        hostName = "builder";
        protocol = "ssh-ng";
        sshKey = "/home/alberand/.ssh/nixremote";
        sshUser = "nixremote";
        system = "x86_64-linux";
        supportedFeatures = [
          "kvm"
          "big-parallel"
        ];
      }
    ];
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
