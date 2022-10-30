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
		};

		extraSessionCommands = ''
			export WLR_NO_HARDWARE_CURSORS=1
		'';
	};
}
