{
  description = "Nix package for bash-env-elvish";

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
          bash_env_elvish =
            let
              inherit (pkgs) bash coreutils makeWrapper writeShellScriptBin;
              inherit (pkgs.lib) makeBinPath;
            in
            (writeShellScriptBin "bash-env-elvish" (builtins.readFile ./bash-env-elvish)).overrideAttrs (old: {
              buildInputs = [ bash makeWrapper ];
              buildCommand =
                ''
                  ${old.buildCommand}
                  patchShebangs $out
                  wrapProgram $out/bin/bash-env-elvish --set PATH ${makeBinPath [
                    coreutils
                  ]}
                '';
            });
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = [
              pkgs.bashInteractive
              bash_env_elvish
            ];
          };

          packages.default = bash_env_elvish;
        }
      );
}
