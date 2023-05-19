let
    nixpkgs = pin.nixpkgs {};
    pin = import ./chr/pin.nix;
in
    {
        pkgs ? nixpkgs,
    }
    :
    pkgs.stdenv.mkDerivation
        {
            installPhase = pkgs.lib.readFile ./scr/instl.sh;
            name = "traverse";
            phases = ["installPhase"];
            src = ./src;
        }
