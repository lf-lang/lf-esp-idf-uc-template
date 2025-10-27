{ pkgs ? import <nixpkgs> {}
, board ? "esp32c6"  # Default board, can be: esp32c6, esp32c3, esp32, all, etc.
}:

let
  esp-idf = pkgs.stdenv.mkDerivation {
    name = "esp-idf-5.5.1-${board}";
    src = ./esp-idf;
    
    nativeBuildInputs = with pkgs; [
      python3
      python3Packages.pip
      python3Packages.virtualenv
      git
      wget
      flex
      bison
      gperf
      cmake
      ninja
    ];

    buildInputs = with pkgs; [
      libffi
      openssl
      libusb1
    ];

    configurePhase = ''
      export HOME=$TMPDIR
      # Run the ESP-IDF install script for the specified board
      echo "Installing ESP-IDF for board: ${board}"
      ./install.sh ${board}
    '';

    buildPhase = "true";  # No build phase needed

    installPhase = ''
      mkdir -p $out
      cp -r . $out/
      
      # Create a wrapper script that sets up the environment
      mkdir -p $out/bin
      cat > $out/bin/idf-env <<EOF
      #!/bin/sh
      export IDF_PATH=$out
      source $out/export.sh
      EOF
      chmod +x $out/bin/idf-env
    '';

    meta = {
      description = "ESP-IDF framework for ${board}";
      platforms = pkgs.lib.platforms.linux;
    };
  };

in pkgs.mkShell {
  buildInputs = with pkgs; [
    git
    wget
    flex
    bison
    gperf
    python3
    python3Packages.pip
    python3Packages.virtualenv
    cmake
    ninja
    ccache
    libffi
    openssl
    dfu-util
    libusb1
    esp-idf
  ];

  shellHook = ''
    export REACTOR_UC_PATH=../reactor-uc-idf
    export IDF_PATH=${esp-idf}
    
    # Source the ESP-IDF export script to set up the environment
    source ${esp-idf}/export.sh
    
    echo "ESP-IDF development environment loaded"
    echo "IDF_PATH: $IDF_PATH"
    echo "Python version: $(python3 --version)"
  '';
}
