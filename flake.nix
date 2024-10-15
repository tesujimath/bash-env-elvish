{
  description = "Nix package for bash-env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
          bash_env =
            let
              inherit (pkgs) bash coreutils gnused jq makeWrapper writeShellScriptBin;
              inherit (pkgs.lib) makeBinPath;
            in
            (writeShellScriptBin "bash-env.sh" (builtins.readFile ./bash-env.sh)).overrideAttrs (old: {
              buildInputs = [ bash jq makeWrapper ];
              buildCommand =
                ''
                  ${old.buildCommand}
                  patchShebangs $out
                  wrapProgram $out/bin/bash-env.sh --prefix PATH : ${makeBinPath [
                    coreutils
                    gnused
                    jq
                  ]}
                '';
            });
        in
        {
          devShells.default = with pkgs;
            mkShell {
              buildInputs = [
                bashInteractive

                bash_env
              ];
            };

          packages.default = bash_env;
        }
      );
}
