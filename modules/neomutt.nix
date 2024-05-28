{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # Email client
    neomutt
    # Email indexing and tagging
    notmuch
    # Email fetcher (downloader)
    isync
    # Console browser to see HTML emails
    w3m
    # Open HTML emails in w3m
    mailcap
  ];

  # Configs to add:
  # - .notmuch-config
  # - .muttrc.local (optional)
  # - .mbsyncrc
  home.file = {
    ".muttrc" = {
      source = ../configs/muttrc;
    };
    ".mutt/dracula.muttrc" = {
      source = ../configs/dracula.muttrc;
    };
    ".mutt/signature" = {
      source = ../configs/signature;
    };
    ".mailcap" = {
      source = ../configs/mailcap;
    };
  };

  services.mbsync = {
    enable = true;
    frequency = "*-*-* *:*:00";
  };

  systemd.user.services.mbsync.Service.Environment = [
    "HOME=${config.home.homeDirectory}"
    "PATH=${pkgs.gawk}/bin:${pkgs.gnupg}/bin:${pkgs.notmuch}/bin:/run/wrappers/bin/:$PATH"
  ];
}
