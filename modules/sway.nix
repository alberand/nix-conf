{ pkgs, ... }:

{
	wayland.windowManager.sway = {
		enable = true;
		wrapperFeatures.gtk = true;
		config = rec {
			terminal = "kitty";
			menu = "wofi --show run";
			modifier = "Mod1";

			fonts = {
				names = [ "DroidSansMono" "Inconsolata" ];
				size = 11.0;
			};

			gaps = {
				inner = 5;
			};

			input."type:keyboard" = {
				xkb_layout = "us,ru";
				xkb_options = "grp:win_space_toggle";
				xkb_numlock = "enabled";
			};

			# Status bar(s)
			bars = [{
				command = "waybar";
				position = "top";
			}];

			# Display device configuration
			output = {
				Virtual-1 = {
					# Set HIDP scale (pixel integer scaling)
					scale = "1";
					bg = "#000000 solid_color";
					res = "1920x1080";
				};
			};

			floating.criteria = [ 
				{ title = "Steam - Update News"; } 
				{ class = "Pavucontrol"; } 
			];

			startup = [
				{ command = "firefox"; }
				{ command = "kitty"; }
				{ command = "thunderbird"; }
				{ command = "flameshot"; }
			];

        		assigns = {
          			"1" = [ { class = "firefox"; } ];
          			"2" = [ { class = "kitty"; } ];
          			"10" = [ { class = "thunderbird"; } ];
        		};

			keybindings = let 
				mod = "Mod1";
			in
			{
            			"${mod}+p" = "exec ${menu}";

            			"${mod}+0" = "workspace number 10";

            			"${mod}+Shift+0" = "move container to workspace number 10";

            			"${mod}+l" = ''exec ${pkgs.swaylock}/bin/swaylock'';
            			"${mod}+k" = "exec ${pkgs.mako}/bin/makoctl dismiss";
            			"${mod}+Shift+k" = "exec ${pkgs.mako}/bin/makoctl dismiss -a";

            			"XF86AudioMute" = 
					"exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
            			"XF86AudioRaiseVolume" =
              				"exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
            			"XF86AudioLowerVolume" =
              				"exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";

          		};
		};

		extraSessionCommands = ''
			export WLR_NO_HARDWARE_CURSORS=1
		'';
	};
}
