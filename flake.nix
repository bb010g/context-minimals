{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    context.url = "github:contextgarden/context-mirror/beta";
    context.flake = false;
    binaries.url = "github:usertam/context-minimals/mirror/binaries";
    binaries.flake = false;
    modules.url = "github:usertam/context-minimals/mirror/modules";
    modules.flake = false;
  };

  outputs = { self, ... }@inputs:
    let
      supportedSystems = [
        "aarch64-linux"
        "aarch64-darwin"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;
    in {
      packages = forAllSystems (system: let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.callPackage ./default.nix rec {
          inherit inputs;
          pname = "context-minimals";
          version = "2022.12.15 17:49";
          src = self;
          fonts = [ pkgs.lmodern pkgs.libertinus ];
        };
      });

      apps = forAllSystems (system: let
        mkApp = bin: {
          type = "app";
          program = "${self.packages.${system}.default}/bin/${bin}";
        };
      in {
        context = mkApp "context";
        luametatex = mkApp "luametatex";
        luatex = mkApp "luatex";
        mtxrun = mkApp "mtxrun";
        default = self.apps.${system}.context;
      });
    };
}
