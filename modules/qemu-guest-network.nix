{ pkgs, ... }:

{
	systemd.network.netdevs.tap0 = {
		enable = true;
		netdevConfig = {
			Name = "tap-qemu-guest";
			Kind = "tap";
		};
	};
}
