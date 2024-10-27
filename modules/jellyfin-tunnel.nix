{...}: {
  networking.wg-quick.interfaces = {
    wg0 = {
      address = ["10.10.10.2/32"];
      privateKeyFile = "/etc/jfwg/client.private";

      peers = [
        {
          publicKey = "MKrNqXfz4sMtRekE44eHLdS/epD0MRZDd/PslJilr1A=";
          allowedIPs = ["0.0.0.0/0"];
          endpoint = "89.221.212.102:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
