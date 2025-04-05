{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "dashboard";

  src = ./.;

  phases = ["installPhase"];

  installPhase = ''
    mkdir -p $out/dashboard
    cp -r $src/static $out/dashboard/static
    cp $src/index.html $out/dashboard/index.html
  '';
}
