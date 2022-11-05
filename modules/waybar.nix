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
				output = [
					"Virtual-1"
				];

				modules-left = [ 
					"sway/workspaces" 
					"sway/mode" 
					"wlr/taskbar"
				];

				modules-center = [
					"custom/hello-from-waybar"
				];

				modules-right = [
					"mpd"
					"custom/mymodule#with-css-id"
					"temperature"
				];

				modules = {
					"sway/workspaces" = {
						disable-scroll = false;
						all-outputs = true;
						format = "{name}: {icon}";
						format-icons = {
							"1" = "🍑";
							"2" = "🍌";
							"3" = "🍒";
							"4" = "🍓";
							"5" = "🍆";
							"6" = "🍄";
							"7" = "🍀";
							"8" = "🍇";
							"9" = "🌵";
							"10" = "🌟";
							"urgent" = "";
							"focused" = "";
							"default" = "";
						};
					};
				};
				
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
