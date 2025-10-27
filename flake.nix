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
          # Default shell with esp32c6
          devShells.default = mkDevShell "esp32c6";
          
          # Specific shells for different boards
          devShells.esp32c6 = mkDevShell "esp32c6";
          devShells.esp32c3 = mkDevShell "esp32c3";
          devShells.esp32 = mkDevShell "esp32";
          devShells.all = mkDevShell "all";
        }
      );
}
