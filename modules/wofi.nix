{ pkgs, ... }:

{
	home.file.".config/wofi/config".text = ''
    		image_size=48
		width=200
		stylesheet=~/.config/wofi/theme.css
    		columns=3
    		allow_images=true
    		insensitive=true
    		run-always_parse_args=true
    		run-cache_file=/dev/null
    		run-exec_search=true
	'';

	home.file.".config/wofi/theme.css".source = configs/wofi-theme.css;
}
