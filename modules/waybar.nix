{ pkgs, ... }:
{
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
          "custom/access"
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
          on-click = "swaymsg input type:keyboard xkb_switch_layout next";
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
          # This requires VPN script to check connectivity
          # exec = vpn-script;
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

        "custom/access" = {
          interval = 2;
          format = "{}";
          min-length = 2;
          tooltip = false;
          return-type = "json";
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
