{
  description = "eheap";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;

    zig-overlay.url = github:mitchellh/zig-overlay;
    zig-overlay.inputs.nixpkgs.follows = "nixpkgs";
    zig-overlay.inputs.flake-utils.follows = "flake-utils";

    zls-flake.url = github:zigtools/zls/0.13.0;
    zls-flake.inputs.nixpkgs.follows = "nixpkgs";
    zls-flake.inputs.flake-utils.follows = "flake-utils";
    zls-flake.inputs.zig-overlay.follows = "zig-overlay";
    zls-flake.inputs.gitignore.follows = "gitignore";

    gitignore.url = github:hercules-ci/gitignore.nix;
    gitignore.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    zig-overlay,
    zls-flake,
    gitignore,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      zig = zig-overlay.packages.${system}."0.13.0";
      zls = zls-flake.packages.${system}.zls;
      gitignoreSource = gitignore.lib.gitignoreSource;
    in rec {
      formatter = pkgs.alejandra;

      packages.default = pkgs.stdenvNoCC.mkDerivation {
        name = "eheap";
        version = "main";
        src = gitignoreSource ./.;
        nativeBuildInputs = [zig zls];
        dontConfigure = true;
        dontInstall = true;
        doCheck = true;
        buildPhase = ''
          mkdir -p .cache
          zig build install --cache-dir $(pwd)/.zig-cache --global-cache-dir $(pwd)/.cache -Doptimize=ReleaseSafe --prefix $out
        '';
        checkPhase = ''
          zig build test --cache-dir $(pwd)/.zig-cache --global-cache-dir $(pwd)/.cache
        '';
      };
    });
}
