{ config, ... }: {
  networking.interfaces.tap0 = {
    name = "tap0";
    virtual = true;
    virtualType = "tap";
    virtualOwner = config.user;
  };

  networking.interfaces.tap0 = {
    ipv4 = {
      addresses = [{
        address = "192.168.10.1";
        prefixLength = 32;
      }];
    };
  };
}
