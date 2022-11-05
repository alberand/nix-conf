{ pkgs, ... }:

{
	wayland.windowManager.sway = {
		enable = true;
		wrapperFeatures.gtk = true;
		config = rec {
			terminal = "kitty";
			menu = "wofi --show run";
			modifier = "Mod1";

			# fonts = {
				# names = [ "DroidSansMono" "Inconsolata" ];
				# size = 11.0;
			# };
			fonts = { names = [ "Fira Code" ]; size = 9.0; style = "Normal"; };

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
				{ command = "telegram-desktop"; }
			];

        		assigns = {
          			"1" = [ { class = "firefox"; } ];
          			"9" = [ { class = "telegram-desktop"; } ];
          			"10" = [ { class = "thunderbird"; } ];
        		};

			keybindings = let 
				mod = "Mod1";
				left = "h";
        			down = "j";
        			up = "k";
        			right = "l";
				inherit terminal menu;
			in
			
				[(builtins.readFile ../configs/sway-keybindings)]
          		;
		};

		extraSessionCommands = ''
			export WLR_NO_HARDWARE_CURSORS=1
			export XDG_SESSION_TYPE=wayland
			export XDG_CURRENT_DESKTOP=sway
			export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
			export QT_AUTO_SCREEN_SCALE_FACTOR=0
			export QT_SCALE_FACTOR=1
			export GDK_SCALE=1
			export GDK_DPI_SCALE=1
			export MOZ_ENABLE_WAYLAND=1
			export _JAVA_AWT_WM_NONREPARENTING=1
		'';
	};
}
