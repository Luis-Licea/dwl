{
  # Install with `nix profile install`.
  description = "Install customized DWL.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";
    utils.url = "github:numtide/flake-utils";
    utils.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) getExe;
      in {
        packages.default = pkgs.callPackage ./derivation.nix pkgs;

        defaultPackage = self.packages.${system}.dwl;

        apps.dwl = {
          type = "app";
          program = getExe self.packages.${system}.dwl;
        };

        defaultApp = self.apps.${system}.dwl;
        devShells.default = import ./shell.nix {inherit pkgs;};
      }
    );
}
# Minimal equivalent code:
#   let
#     system = "x86_64-linux";
#     pkgs = import nixpkgs {inherit system;};
#   in {
#     packages.x86_64-linux.dwl = pkgs.callPackage ./derivation.nix pkgs;
#     packages.x86_64-linux.default = self.packages.x86_64-linux.dwl;
#   };
# }
