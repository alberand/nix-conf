{
  modulesPath,
  lib,
  pkgs,
  ...
}: let
  keys = [
    # alberand
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsaaX1d/7zZHiZIsPFhtvmEChTB0p7sKECk7p6UcUqr"
    # aalbersh
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMMuyusNaXCAFiYRDo3DdkVp1vvx6YF//ErfgQQ0sKA3DkkaDp6oU4GJ+ix69tBlZf2LSK3WduWm064XNFp75ppiOSRB0PRhwHR/rAgLyZkZJ5OPobaiaUhg5VNlET/MJ/q3/2zoyQg6tsLRpAABykvggIdC0q/QGIl3exp6WrC5Hk+YhayZhmHz3QflWmTSkl2jfCY3seauhaMFczGWnLnirF1RtQ33sPoVhG6kGr4RSnfXOMfi0qDA8eMt/Wart3o5ZiOAvs1tHcKFW7T2E3XwbxMKKFOzqupKcDnjorE15Wm/fGY5MEH+kNbnPpksQzZ+uhKg8jwRRHXKzLQcp/y+ihXRrZaGQjrvNbycd9kAk5uC6HVmcWXYQw039LjZsc+vBJLcYizJP+Iw/tLk0xdJmqWgNMgwKCdVgpIkAhAexc9/S28JNP6PvtVoEoKzTv1a9roUz5gLeXQes7gpMofY8UeiuHVtBeTbzOojj8WXKsQ25tfAj8MrXvnpXNLWs="
  ];
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./hardware-configuration.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      X11Forwarding = true;
      AllowUsers = ["builder" "root"];
    };
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users."builder" = {
    isNormalUser = true;
    uid = 1000;
    group = "users";
    openssh.authorizedKeys.keys = keys;
  };

  users.users.root.openssh.authorizedKeys.keys = keys;

  nix.settings = {
    trusted-users = ["builder"];
  };

  system.stateVersion = "25.05";
}
