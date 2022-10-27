{ pkgs, ... }:

{
	wayland.windowManager.sway = {
		enable = true;
		config = rec {
			terminal = "kitty";
			menu = "wofi --show run";
			modifier = "Mod4";

			fonts = {
				names = [ "DroidSansMono" ];
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
		};
	};
}
