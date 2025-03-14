{...}: {
  services.squid = {
    enable = true;
    proxyAddress = "192.168.0.101";
    proxyPort = 3333;
    extraConfig = ''
      acl localhost src 192.168.0.100 # lonmoun
      # Adapt localnet in the ACL section to list your (internal) IP networks
      # from where browsing should be allowed
      http_access allow localhost
      http_access deny all
    '';
  };
}
