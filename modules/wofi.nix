{ pkgs, ... }:

{
	xdg.configFile."wofi/config".text = ''
    		image_size=48
		width=200
		stylesheet=$XDG_CONFIG_HOME/wofi/theme.css
    		columns=3
    		allow_images=true
    		insensitive=true
    		run-always_parse_args=true
    		run-cache_file=/dev/null
    		run-exec_search=true
	'';

	xdg.configFile."wofi/theme.css".source = ../configs/wofi-theme.css;
}
