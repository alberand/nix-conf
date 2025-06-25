# sudo nix run 'github:nix-community/disko/latest#disko-install' -- --flake .#nixxy --disk <disk-name> <disk-device>
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              label = "boot";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                label = "luks";
                extraOpenArgs = [];
                settings = {
                  # if you want to use the key for interactive login be sure
                  # there is no trailing newline for example use
                  # `echo -n "password" > /tmp/secret.key`
                  keyFile = "/tmp/secret.key";
                  allowDiscards = true;
                };
                content = {
                  type = "lvm_pv";
                  vg = "pool";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          swap = {
            size = "8G";
            content = {
              type = "swap";
              randomEncryption = true;
              priority = 100; # prefer to encrypt as long as we have space for it
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
        };
      };
    };
  };
}
