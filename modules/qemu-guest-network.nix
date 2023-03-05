{ pkgs, ... }:

{
	networking.interfaces.tap0 = {
		name = "tap0";
		virtual = true;
		virtualType = "tap";
		virtualOwner = "alberand";
	};

	networking.bridges = {
		br0 = {
			interfaces = [ "enp32s0" ];
		};
	};

	networking.interfaces.br0 = {
		ipv4 = {
			addresses = [{
				address = "11.11.11.11";
				prefixLength = 32;
			}];
		};
	};
}
