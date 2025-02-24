{
  perSystem = { config, pkgs, lib, ... }: {
    options =
      let
        inherit (lib) types;
      in
      {
        esp-rs-flake = lib.mkOption {
          default = { };
          type = types.submoduleWith {
            specialArgs = { inherit pkgs; };
            modules = [{
              # imports = [
              #   ./default.nix
              # ];

              options = {


                outputs.devShell = lib.mkOption {
                  type = lib.types.package;
                  readOnly = true;
                  description = ''
                    The output devShell to include in `inputsFrom`.
                  '';
                };
              };
            }];
          };
        };
      };
    config =
      let
        cfg = config.esp-rs-flake;
      in
      {
        esp-rs-flake.outputs.devShell =
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