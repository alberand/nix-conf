{config, ...}: {
  networking.firewall.allowedTCPPorts = [config.services.paperless.port];
  services.paperless = {
    enable = true;
    consumptionDirIsPublic = true;
    address = "192.168.0.100";
    settings = {
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [".DS_STORE/*" "desktop.ini"];
      PAPERLESS_OCR_LANGUAGE = "ces+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
    };
  };
}
