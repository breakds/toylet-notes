{ inputs, ... }:

let
  inherit (inputs) nixpkgs reading-desk;
in {
  flake.overlays.default = reading-desk.overlays.default;

  flake.nixosModules.default = { pkgs, ... }: {
    imports = [ ./services/toylet-note.nix ];

    nixpkgs.overlays = [ reading-desk.overlays.default ];
  };

  perSystem = { system, pkgs, ... }: {
    _module.args.pkgs = import nixpkgs {
      inherit system;
      overlays = [ reading-desk.overlays.default ];
    };
  };
}
