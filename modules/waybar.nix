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
				# output = [
					# "Virtual-1"
				# ];

				modules-left = [ 
					"sway/workspaces" 
					"sway/mode" 
				];

				modules-center = [
        				"clock#time"
					"clock#date"
					#"custom/hello-from-waybar"
				];

				modules-right = [
					"pulseaudio"
					"network"
					"sway/language"
					"tray"
				];

				"sway/workspaces" = {
					all-outputs = true;
				};

				"sway/language" = {
					all-outputs = true;
					on-click = "swaymsg input '16700:8467:Dell_KB216_Wired_Keyboard_Consumer_Control' xkb_switch_layout next";
				};

				"clock#time" = {
					interval = 1;
        				format = "{:%H:%M}";
        				tooltip = false;
    				};

    				"clock#date" = {
      					interval = 10;
      					format = "{:%a, %e %b %Y}";
      					tooltip-format = "{:%a, %e %B %Y}";
    				};

				"network" = {
          				format-wifi = "{essid} ({signalStrength}%) ";
          				format-ethernet = "online";
          				format-linked = "{ifname} (No IP)";
          				format-disconnected = "offline";
					tooltip = false;
        			};
			
				"pulseaudio" = {
        				"reverse-scrolling" = false;
        				"format" = "{volume}% {icon} {format_source}";
        				"format-bluetooth" = "{volume}% {icon} {format_source}";
        				"format-bluetooth-muted" = " {icon} {format_source}";
        				"format-muted" = "婢 {format_source}";
        				"format-source" = "{volume}% ";
        				"format-source-muted" = "";
        				"format-icons" = {
            					"default" = ["奄" "奔" "墳"];
        				};
        				"on-click" = "pavucontrol";
        				"min-length" = 13;
    				};

				"tray" = {
    					"icon-size" = 21;
    					"spacing" = 10;
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
