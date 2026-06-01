{agenix, noctalia}: {
  config,
  pkgs,
  lib,
  ...
}: rec {
  imports = [
    ../../modules/home-base.nix
    ../../modules/noctalia.nix
    noctalia.homeModules.default
    agenix.homeManagerModules.default
  ];

  home.username = "alberand";
  home.homeDirectory = "/home/alberand";
  age.identityPaths = [ "${home.homeDirectory}/.ssh/id_agenix" ];

  xdg.desktopEntries = {
    workfox = {
      name = "workfox";
      exec = "workfox";
      genericName = "Work Web Browser";
      icon = "firefox";
      categories = ["Network" "WebBrowser"];
      terminal = false;
      startupNotify = true;
    };
  };

  home.packages = with pkgs; let
    workfox =
      writeShellScriptBin "workfox"
      "exec -a $0 ${firefox}/bin/firefox -P RedHat $@";
    work =
      writeShellScriptBin "work"
      "exec -a $0 ${kitty}/bin/kitty sh -c '${kitty}/bin/kitten ssh work'";
  in [
    cargo
    (discord.override {nss = pkgs.nss_latest;})
    freecad
    gimp
    inkscape
    prismlauncher # Minecraft launcher
    rust-analyzer
    steam
    telegram-desktop
    thunderbird
    libreoffice
    rustfmt
    openrgb
    vlc
    workfox
    work
    typescript-language-server
    lua-language-server
    pyright
    agenix.packages.${system}.default
    noctalia.packages.${system}.default
  ];

  home.file = {
    ".shrc.local" = {source = ./configs/shrc.local;};
  };

  # Shinjira
  xdg.desktopEntries = {
    shinjira = {
      name = "Shinjira";
      genericName = "Shinjira";
      comment = "Handle URL Scheme shinjira://";
      exec = "/home/alberand/Projects/shin/echo.sh %u";
      terminal = false;
      type = "Application";
      mimeType = ["x-scheme-handler/shinjira"];
      icon = "potato-icon";
      categories = ["Development" "Utility"];
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        forwardAgent = true;
        serverAliveInterval = 15;
        serverAliveCountMax = 3;
        userKnownHostsFile = "~/.ssh/known_hosts";
      };
      door = {
        hostname = "77.90.6.241";
        user = "alberand";
        identitiesOnly = true;
        identityFile = "~/.ssh/id_ed25519";
      };
      hetzner-backup = {
        hostname = "u486743.your-storagebox.de";
        user = "u486743";
        port = 23;
        addressFamily = "inet";
      };
      nemambyt = {
        hostname = "89.221.212.102";
        user = "root";
        port = 42424;
        identitiesOnly = true;
        identityFile = "~/.ssh/id_ed25519";
      };
      nemambytc = {
        hostname = "10.10.10.200";
        user = "root";
        identitiesOnly = true;
        identityFile = "~/.ssh/id_ed25519";
        proxyJump = "nemambyt";
      };
      work = {
        hostname = "100.69.0.3";
        user = "aalbersh";
        identitiesOnly = true;
        identityFile = "~/.ssh/id_ed25519";
      };
      tester = {
        hostname = "fs-i40c-09.fast.eng.rdu2.dc.redhat.com";
        user = "aalbersh";
        identitiesOnly = true;
        identityFile = "~/.ssh/id_ed25519";
        proxyJump = "work";
      };
      rpi-zero-lan = {
        hostname = "192.168.0.104";
        user = "alberand";
        identitiesOnly = true;
        identityFile = "~/.ssh/id_ed25519";
      };
      rpi-zero = {
        hostname = "100.69.0.11";
        user = "alberand";
        identitiesOnly = true;
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}
