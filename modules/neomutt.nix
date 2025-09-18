{
  config,
  pkgs,
  ...
}: {
  age.secrets.neomutt-passwords = {
    file = ../secrets/thinky-neomutt.age;
  };

  home.packages = with pkgs; [
    # Email client
    neomutt
    (writeShellScriptBin "nn" ''
      source ${config.age.secrets.neomutt-passwords.path}
      ${neomutt}/bin/neomutt
    '')
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
    "${config.xdg.configHome}/neomutt/neomuttrc" = {
      source = ../configs/neomuttrc;
    };
    "${config.xdg.configHome}/neomutt/dracula.muttrc" = {
      source = ../configs/dracula.muttrc;
    };
    "${config.xdg.configHome}/neomutt/signature.korg" = {
      source = ../configs/signature;
    };
    "${config.xdg.configHome}/neomutt/signature.redhat" = {
      source = ../configs/signature;
    };
    ".mailcap" = {
      source = ../configs/mailcap;
    };
    "${config.xdg.configHome}/neomutt/profile.redhat" = {
      source = ../configs/profile.redhat;
    };
    "${config.xdg.configHome}/neomutt/profile.korg" = {
      source = ../configs/profile.korg;
    };
  };

  programs.zsh.shellAliases = {
    neomutt-korg = "neomutt -F ${config.xdg.configHome}/neomutt/profile.korg";
    neomutt-redhat = "neomutt -F ${config.xdg.configHome}/neomutt/profile.redhat";
  };

  services.mbsync.configFile = ../configs/mbsyncrc;
  services.mbsync.postExec = "${pkgs.bash}/bin/sh ${config.home.homeDirectory}/.redhat/notmuch-hook.sh";

  services.mbsync = {
    enable = true;
    frequency = "*-*-* *:*:00";
  };

  systemd.user.services.mbsync.Service.Environment = [
    "HOME=${config.home.homeDirectory}"
    "PATH=${pkgs.gawk}/bin:${pkgs.gnupg}/bin:${pkgs.notmuch}/bin:/run/wrappers/bin/:$PATH"
  ];
}
