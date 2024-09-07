{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    gleam2nix.url = "github:mtoohey31/gleam2nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      gleam2nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [
          gleam2nix.overlays.default
        ];
        pkgs = import nixpkgs { inherit system overlays; };
        lib = pkgs.lib;
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        test_http_gleam = pkgs.buildGleamProgram {
          src = lib.cleanSource ./.;
        };
      in
      {
        formatter = treefmtEval.config.build.wrapper;

        checks = {
          formatting = treefmtEval.config.build.check self;
        };

        packages = {
          inherit test_http_gleam;
          default =  test_http_gleam;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            # Nix
            pkgs.nil

            # Gleam
            pkgs.gleam
            pkgs.erlang
            pkgs.rebar3
          ];
        };
      }
    );
}
