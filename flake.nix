{
  description = "ESP32 Rust";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

    outputs = {
    self,
    nixpkgs,
    nixpkgs-esp-dev,
    flake-parts,
    systems,
    rust-overlay,
    ...
  }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;
      perSystem = { config, self', pkgs, lib, system, ... }: 
      let 
      esp-rs = pkgs.callPackage ./default.nix {
        inherit pkgs;
      };
      nixpkgs-esp-dev = nixpkgs-esp-dev.legacyPackages.${system};
      in {
        packages.default = esp-rs;
        devShells.default = pkgs.mkShell  {
          name = "esp-rs";
          buildInputs = with pkgs; [ 
            esp-rs 
            probe-rs
            rustup 
            espflash 
            rust-analyzer
            
            pkg-config 
            stdenv.cc 
            bacon 
            systemdMinimal 
          ];

          shellHook = ''
          export PS1="(esp-rs)$PS1"
          # this is important - it tells rustup where to find the esp toolchain,
          # without needing to copy it into your local ~/.rustup/ folder.
          export RUSTUP_TOOLCHAIN=${esp-rs}
          '';
      };
    };
  };
}
