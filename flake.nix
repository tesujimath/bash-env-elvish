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
          bash_env_elvish = pkgs.writeShellScriptBin "bash-env-elvish"
            (builtins.readFile ./bash-env-elvish);
        in
          {
            packages.default = bash_env_elvish;
          }
      );
}
