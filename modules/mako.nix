{ pkgs, ... }:

{
	#systemd.user.services.mako.enable = true;
	services.mako = {
		enable = true;
		defaultTimeout = 5000;
	};
}
