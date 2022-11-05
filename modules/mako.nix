{ pkgs, ... }:

{
	#systemd.user.services.mako.enable = true;
	programs.mako = {
		borderRadius = 5;
	};
}
