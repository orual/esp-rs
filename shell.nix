{ pkgs ? import <nixpkgs> {
    overlays = [
        (import (fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"))
    ];
  }
}:
let
  esp-rs = pkgs.callPackage ./default.nix {
    inherit pkgs;
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    esp-rs
    probe-rs
    rustup
    espflash
    rust-analyzer
  ];
  shellHook = ''
    export PS1="(esp-rs)$PS1"
    # this is important - it tells rustup where to find the esp toolchain,
    # without needing to copy it into your local ~/.rustup/ folder.
    export RUSTUP_TOOLCHAIN=${esp-rs}
    '';
}
