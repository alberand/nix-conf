{ config, pkgs, ... }:
{
  nix = {
    distributedBuilds = false;
    buildMachines = [
      {
        hostName = "fedora-vm";
        protocol = "ssh-ng";
        sshKey = "/home/alberand/.ssh/id_rsa";
        sshUser = "root";
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
