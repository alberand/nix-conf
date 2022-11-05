{ pkgs, ... }:

{
	programs.waybar = {
		settings = {
			mainBar = {
				layer = "top";
				position = "top";
				height = 25;
				output = [
					"Virtual-1"
				];
				modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
				modules-center = [ "custom/hello-from-waybar" ];
				modules-right = [ "mpd" "custom/mymodule#with-css-id" "temperature" ];
				
				"sway/workspaces" = {
					disable-scroll = true;
					all-outputs = true;
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
