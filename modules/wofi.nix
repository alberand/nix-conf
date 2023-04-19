{ pkgs, ... }: {
  xdg.configFile."wofi/config".text = ''
                width=200
  '';

  xdg.configFile."wofi/style.css".source = ../configs/wofi-theme.css;
}
