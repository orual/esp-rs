{
  pkgs ? import <nixpkgs> {
      overlays = [
          (import (fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"))
      ];
    },
  archname ? "x86_64-linux-gnu",
}:
let
    esp-rust-build = pkgs.callPackage ./rust.nix { inherit pkgs; };
    esp-xtensa-gcc = pkgs.callPackage ./xtensa-gcc.nix { inherit pkgs; };
    esp-riscv32-gcc = pkgs.callPackage ./riscv32-gcc.nix { inherit pkgs; };
in
# this package is actually the 'rust-src' part of the esp-rs release - it's installed last, over the top
# of the esp-rs and xtensa-gcc files.
pkgs.stdenv.mkDerivation rec {
    name = "esp-rs";
    version = "1.84.0.0";

    nativeBuildInputs = with pkgs; [ autoPatchelfHook zlib pkg-config gcc stdenv.cc.cc ];
    buildInputs = [ esp-rust-build esp-xtensa-gcc esp-riscv32-gcc ];
    autoPatchelfIgnoreMissingDeps = [ "*" ];

    src = pkgs.fetchzip {
            url = "https://github.com/esp-rs/rust-build/releases/download/v${version}/rust-src-${version}.tar.xz";
            sha256 = "sha256-74Jv+a/sJfZpemhvLzBow/jQ92Ag8nRjSknZZ3hEpA4=";
            # sha256 = "0000000000000000000000000000000000000000000000000000";
          };

    patchPhase = ''
    patchShebangs ./install.sh
    '';

    outputs = [ "out" ];

    installPhase = ''
    mkdir -p $out

    # copy across all of esp-rust into our own output
    cp -r ${esp-rust-build}/* $out
    chmod -R u+rw $out
    cp -r ${esp-xtensa-gcc}/* $out
    chmod -R u+rw $out
    cp -r ${esp-riscv32-gcc}/* $out
    chmod -R u+rw $out

    # install onto it!
    ./install.sh --destdir=$out --prefix="" --disable-ldconfig

    runHook postInstall
    '';
}
