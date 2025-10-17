{ pkgs }:
let
  manifest = pkgs.lib.importTOML ../Cargo.toml;
in
pkgs.rustPlatform.buildRustPackage {
  pname = manifest.package.name;
  version = manifest.package.version;
  src = pkgs.lib.cleanSource ../.;
  cargoLock.lockFile = ../Cargo.lock;

  nativeBuildInputs = with pkgs; [
    pkg-config
    libc
  ];
}
