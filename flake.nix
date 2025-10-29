{
  description = "nix flake for building reactor-uc projects for the ESP-IDF platform";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Function to create a dev shell for a specific board
          mkDevShell = board: import ./shell.nix { inherit pkgs board; };
        in
        {
          # Default shell with esp32
          devShells.default = mkDevShell "esp32";

          # Specific shells for different boards
          devShells.esp32 = mkDevShell "esp32";
          devShells.esp32s2 = mkDevShell "esp32s2";
          devShells.esp32c3 = mkDevShell "esp32c3";
          devShells.esp32s3 = mkDevShell "esp32s3";
          devShells.esp32c2 = mkDevShell "esp32c2";
          devShells.esp32c6 = mkDevShell "esp32c6";
          devShells.esp32h2 = mkDevShell "esp32h2";
          devShells.esp32p4 = mkDevShell "esp32p4";
          devShells.esp32c5 = mkDevShell "esp32c5";
          devShells.esp32c61 = mkDevShell "esp32c61";
          devShells.esp32h4 = mkDevShell "esp32h4";
          devShells.all = mkDevShell "all";
        }
      );
}
