{
  description = "Break's notes collection for reading-desk";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    reading-desk.url = "github:breakds/reading-desk";
    reading-desk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-darwin" ];

    perSystem = { system, pkgs, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.reading-desk.overlays.default ];
      };

      devShells.default = pkgs.mkShell {
        name = "toylet-notes";
        packages = with pkgs; [
          reading-desk
          (python3.withPackages (p: with p; [
            matplotlib
            numpy
            pillow
          ]))
        ];
      };
    };
  };
}
