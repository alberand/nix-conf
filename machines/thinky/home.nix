{agenix, noctalia}: {
  config,
  pkgs,
  lib,
  ...
}: rec {
  imports = [
    agenix.homeManagerModules.default
    ../../modules/home-base.nix
    ../../modules/neomutt.nix
    ../../modules/redhat-beaker.nix
    ../../modules/noctalia.nix
    noctalia.homeModules.default
    ./modules/maintainer.nix
  ];

  home.username = "aalbersh";
  home.homeDirectory = "/home/aalbersh";

  home.packages = with pkgs; [
    isync
    neomutt
    notmuch
    xfstestsdb
    #kerneloscope
    toolbox
    lynx
    (b4.overrideAttrs (
      final: prev: {
        version = "git";
        # Latest master as of 12.05.25
        src = pkgs.fetchFromGitHub {
          owner = "alberand";
          repo = "b4";
          rev = "ad80ce422da0ca1e3c4f2be8de21faf7421918d0";
          sha256 = "sha256-zrnKEP9W5Cktzw/UaGW1cL4+nVKicnIPCs+7qnEgqzc=";
        };

        propagatedBuildInputs =
          prev.propagatedBuildInputs
          ++ (with python3Packages; [
            packaging
          ]);
      }
    ))
    # Script to open serial console to Beaker machine
    (
      let
        wrapper = writeShellScriptBin "con" (builtins.readFile ./configs/console.sh);
      in
        pkgs.symlinkJoin {
          name = "conserver-bkr";
          paths = [
            (conserver.override {gssapiSupport = true;})
            wrapper
          ];
        }
    )
    # Git script to backport fixes from upstream to downstream
    (writeShellScriptBin "git-bp" (builtins.readFile ./configs/git-bp))
    # Beaker script to reserve machines for testing
    (writeShellScriptBin "machine" (builtins.readFile ./configs/machine))
  ];

  home.file = {
    ".notmuch-config" = {
      source = ./configs/notmuch-config;
    };
    ".redhat/notmuch-hook.sh" = {
      source = ./configs/notmuch-hook.sh;
    };
    ".redhat/neomutt-jira.sh" = {
      source = ./configs/neomutt-jira.sh;
    };
    ".shrc.local" = {
      source = ./configs/shrc.local;
    };
    ".consolerc" = {
      source = ./configs/consolerc;
    };
  };

  programs.gpg = {
    enable = true;
    settings = {
      default-key = "46A7EA18AC33E108";
    };
  };

  programs.git = {
    settings = {
      user = {
        signingkey = "46A7EA18AC33E108";
      };
    };
    ignores = [
      ".envrc"
      # patch -p1
      "*.orig"
      "*.rej"
    ];
  };

  # Prevent Firefox from querying Nitrokey
  #
  # Firefox is setup to query Smart Cards and for that reason it talks to
  # Nitrokey every time you open a new tab. It slows down the browser
  # considerably almost to the point it's unusable.
  home.file = {
    ".config/pkcs11/modules/opensc.module" = {
      source = ./configs/opensc.module;
    };
  };

  programs.rofi = {
    enable = true;
    theme = "sidebar";
    font = "sans-serif";
    package = pkgs.rofi;
    modes = [
      "drun"
      "run"
      "window"
      "ssh"
    ];
    extraConfig = {
      show-icons = true;
    };
  };
}
