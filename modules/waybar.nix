{ pkgs, ... }: let
  vpn-script = ''
    template='{"text": "$text", "tooltip": "", "class": "$class", "percentage": 0 }'
    country=$(curl https://am.i.mullvad.net/country 2>/dev/null)
    if [[ ! $country ]]; then 
    template=$(echo $template | sed 's/$text/No VPN/' | \
      sed 's/$class/disconnected/'); 
    else 
    template=$(echo $template | sed 's/$text/VPN/' | \
      sed 's/$class/connected/'); 
    fi
    echo $template;
  '';

  chlang-script = ''
    swaymsg input '16700:8467:Dell_KB216_Wired_Keyboard_Consumer_Control' xkb_switch_layout next
  '';
in {
  programs.waybar = {
    enable = true;
    style = "${builtins.readFile ../configs/waybar-style.css}";
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 25;

        modules-left = [
          "sway/workspaces"
          "sway/mode"
        ];

        modules-center = [
          "clock#time"
          "clock#date"
        ];

        modules-right = [
          "custom/suspend"
          "pulseaudio"
          "network"
          "custom/vpn"
          "sway/language"
          "tray"
        ];

        "sway/workspaces" = {
          all-outputs = true;
        };

        "sway/language" = {
          all-outputs = true;
          on-click = chlang-script;
        };

        "clock#time" = {
          interval = 1;
          format = "{:%H:%M}";
          tooltip = false;
        };

        "clock#date" = {
          interval = 10;
          format = "{:%e %b %Y, %a}";
          tooltip-format = "{:%e %B %Y, %a}";
        };

        "network" = {
          interface = "wg0";
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "online";
          format-linked = "{ifname} (No IP)";
          format-disconnected = "offline";
          tooltip = false;
        };

        "custom/vpn" = {
          interval = 5;
          tooltip = false;
          format = "{}";
          return-type = "json";
          exec = vpn-script;
        };

        "pulseaudio" = {
          reverse-scrolling = false;
          format = "{volume}% {icon}  {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
          min-length = 13;
        };

        "custom/suspend" = {
          format = "";
          min-length = 2;
          tooltip = false;
          on-click = "systemctl suspend";
        };

        "tray" = {
          icon-size = 21;
          spacing = 10;
        };

        "custom/hello-from-waybar" = {
          format = "hello {}";
          max-length = 40;
          interval = "once";
          exec = pkgs.writeShellScript "hello-from-waybar" ''
                                        echo "from within waybar"
          '';
        };
      };
    };
  };
}
