{ pkgs, ... }:

let
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
					format = "{:%a, %e %b %Y}";
					tooltip-format = "{:%a, %e %B %Y}";
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
					format = "{volume}% {icon} {format_source}";
					format-bluetooth = "{volume}% {icon} {format_source}";
					format-bluetooth-muted = " {icon} {format_source}";
					format-muted = "婢 {format_source}";
					format-source = "{volume}% ";
					format-source-muted = "";
					format-icons = {
						default = ["奄" "奔" "墳"];
					};
					on-click = "pavucontrol";
					min-length = 13;
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
