# ssh-keygen -f ssh_key -t ed25519 -C "Borg Backup"
# nix-shell -p python39Packages.xkcdpass --run 'xkcdpass -n 12' > passphrase
# Home structure:
# .
# └── borgbackup
#     ├── passphrase
#     ├── ssh_key
#     └── ssh_key.pub
{
  config,
  pkgs,
  ...
}: {
  services.borgbackup.jobs."borgbase" = {
    paths = ["/var/lib/minecraft/Our World"];

    exclude = [];
    repo = "w7r073yg@w7r073yg.repo.borgbase.com:repo";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /root/borgbackup/passphrase";
    };
    environment.BORG_RSH = "ssh -i /root/borgbackup/ssh_key";
    compression = "auto,lzma";
    startAt = "daily";
  };
}
