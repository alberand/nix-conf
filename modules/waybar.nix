{ pkgs, ... }:

{
	home.file."wofi/config".text = ''
    		image_size=48
		width=200
    		columns=3
    		allow_images=true
    		insensitive=true
    		run-always_parse_args=true
    		run-cache_file=/dev/null
    		run-exec_search=true
	'';
}
