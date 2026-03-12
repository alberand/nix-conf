{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/home-base.nix
  ];

  home.username = "alberand";
  home.homeDirectory = "/home/alberand";

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
    kicad
    prismlauncher # Minecraft launcher
    rust-analyzer
    steam
    #telegram-desktop
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
  ];

  home.file = {
    ".shrc.local" = {source = ./configs/shrc.local;};
  };

  # Script to check work VPN connectivity
  programs.waybar.settings.mainBar."custom/vpn".exec =
    builtins.readFile ./configs/vpn-check.sh;

  wayland.windowManager.sway.config = {
    startup = [
      {command = "swaymsg 'workspace 1; exec firefox'";}
      {command = "swaymsg 'workspace 2; exec kitty'";}
      {command = "swaymsg 'workspace 10; exec thunderbird'";}
      {command = "swaymsg 'exec \"sleep 1; flameshot\"'";}
    ];
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
        categories = [ "Development" "Utility" ];
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
        hostname = "10.233.2.2";
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
    };
  };
}
