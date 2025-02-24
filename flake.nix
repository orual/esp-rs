{
  description = "ESP32 Rustc fork flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

    outputs = _: {
    flakeModule = import ./flake-module.nix;
  };
}
