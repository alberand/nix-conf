{ pkgs, ... }:

{
	#systemd.user.services.mako.enable = true;
	programs.mako = {
        enable = true;
        defaultTimeout = 5000;
	};
}
