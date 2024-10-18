{
  description = "Nix developer and CI tooling for bash-env-elvish";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    bash-env-json = {
      url = "github:tesujimath/bash-env-json/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, flake-utils, bash-env-json, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
          flakePkgs = {
            bash-env-json = bash-env-json.packages.${system}.default;
          };
        in
        {
          devShells =
            let
              inherit (pkgs) bashInteractive elvish yq mkShell;
              ci-packages =
                [
                  elvish
                  yq
                  flakePkgs.bash-env-json
                ];
            in
            {
              default = mkShell { buildInputs = ci-packages ++ [ bashInteractive ]; };

              ci = mkShell { buildInputs = ci-packages; };
            };
        }
      );
}
