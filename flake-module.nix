{
  perSystem = { config, pkgs, lib, inputs, ... }: {
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
        esp-rs-flake.outputs.devShell = import ./shell.nix {inherit pkgs;};

      };
  };
}
