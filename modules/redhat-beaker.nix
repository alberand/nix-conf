{ config, pkgs, ... }:
let
  beaker-common = with pkgs.python3Packages; buildPythonPackage rec {
    pname = "beaker-common";
    version = "28.3";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-vLBEfKsczPJdcFENe69z8LF3JEZd3DRi+9lnz4BG1Z4=";
    };
    doCheck = false;
  };
  beaker-client = with pkgs.python3Packages; buildPythonPackage rec {
    pname = "beaker-client";
    version = "28.3";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-MrxZ4jOlkTZdeRbvRW3OG473El7G+CHLInhFeP0mOzo=";
    };
    doCheck = false;
    propagatedBuildInputs = [
      beaker-common
      six
      lxml
      requests
      prettytable
      jinja2
      gssapi
    ];
  };
in {
  home.packages = with pkgs; [
    beaker-client
  ];

  home.file = {
    ".beaker_client/config" = {
      source = ../configs/beaker-config;
    };
  };

  # Already done in work-vpn
  #security.pki.certificates = let
  #  certfile = builtins.readFile ../openvpn/RedHatInternalCA.pem;
  #in [
  #  certfile
  #];
}
