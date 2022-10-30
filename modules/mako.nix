{ pkgs, ... }:

{
	systemd.user.services.mako = {
		enable = true;
		borderRadius = 5;
	};
}
