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
			{
				"${mod}+Return" = "exec ${terminal}";
            "${mod}+Shift+q" = "kill";
            "${mod}+p" = "exec ${menu}";

            "${mod}+${left}" = "focus left";
            "${mod}+${down}" = "focus down";
            "${mod}+${up}" = "focus up";
            "${mod}+${right}" = "focus right";

            "${mod}+Left" = "focus left";
            "${mod}+Down" = "focus down";
            "${mod}+Up" = "focus up";
            "${mod}+Right" = "focus right";

            "${mod}+Shift+${left}" = "move left";
            "${mod}+Shift+${down}" = "move down";
            "${mod}+Shift+${up}" = "move up";
            "${mod}+Shift+${right}" = "move right";

            "${mod}+Shift+Left" = "move left";
            "${mod}+Shift+Down" = "move down";
            "${mod}+Shift+Up" = "move up";
            "${mod}+Shift+Right" = "move right";

            "${mod}+Shift+space" = "floating toggle";
            "${mod}+space" = "focus mode_toggle";

            "${mod}+1" = "workspace number 1";
            "${mod}+2" = "workspace number 2";
            "${mod}+3" = "workspace number 3";
            "${mod}+4" = "workspace number 4";
            "${mod}+5" = "workspace number 5";
            "${mod}+6" = "workspace number 6";
            "${mod}+7" = "workspace number 7";
            "${mod}+8" = "workspace number 8";
            "${mod}+9" = "workspace number 9";
            "${mod}+0" = "workspace number 10";

            "${mod}+Shift+1" = "move container to workspace number 1";
            "${mod}+Shift+2" = "move container to workspace number 2";
            "${mod}+Shift+3" = "move container to workspace number 3";
            "${mod}+Shift+4" = "move container to workspace number 4";
            "${mod}+Shift+5" = "move container to workspace number 5";
            "${mod}+Shift+6" = "move container to workspace number 6";
            "${mod}+Shift+7" = "move container to workspace number 7";
            "${mod}+Shift+8" = "move container to workspace number 8";
            "${mod}+Shift+9" = "move container to workspace number 9";
            "${mod}+Shift+0" = "move container to workspace number 10";

            "${mod}+i" = "split h";
            "${mod}+v" = "split v";
            "${mod}+f" = "fullscreen toggle";
            "${mod}+comma" = "layout stacking";
            "${mod}+period" = "layout tabbed";
            "${mod}+slash" = "layout toggle split";
            "${mod}+a" = "focus parent";
            "${mod}+s" = "focus child";

            "${mod}+Shift+c" = "reload";
            "${mod}+Shift+r" = "restart";
            # "${mod}+Shift+v" = ''mode "system:  [r]eboot  [p]oweroff  [l]ogout"'';
	    "${mod}+Shift+e" = ''exec swaynag -t warning -m "You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session." -B "Yes, exit sway" "swaymsg exit"'';

            "${mod}+r" = "mode resize";

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
