{
  modulesPath,
  lib,
  pkgs,
  ...
}: let
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsaaX1d/7zZHiZIsPFhtvmEChTB0p7sKECk7p6UcUqr";
in rec {
  user = "alberand";

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users."${user}" = {
    isNormalUser = true;
    uid = 1000;
    group = "users";
    openssh.authorizedKeys.keys = [
      key
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    key
  ];

  system.stateVersion = "25.05";
}
