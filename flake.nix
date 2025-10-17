{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      forAllSystems =
        function:
        with nixpkgs;
        lib.genAttrs [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ] (
          system: function legacyPackages.${system}
        );
    in
    {
      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);

      packages = forAllSystems (pkgs: rec {
        netzkarte-backend = import ./nix/package.nix { inherit pkgs; };
        default = netzkarte-backend;
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            cargo
            rustc
            rustfmt
            rustPackages.clippy
            bacon
            rust-analyzer

            sqlite

            pkg-config
            libc
          ];
          RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
		  DATABASE_URL = "cell_towers.db";
        };
      });
    };
}
