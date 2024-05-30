{lib, ...}: {
  options = {
    user = lib.mkOption {
      type = lib.types.str;
      description = ''
        Main system user
      '';
    };
  };
}
