{ pkgs ? import <nixpkgs> {}
, board ? "esp32"  # Default board, can be: esp32c6, esp32c3, esp32, all, etc.
}:

pkgs.mkShell {
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
  ];

  shellHook = ''
    export ESP_IDF_BOARD="${board}"
    export REACTOR_UC_PATH=../reactor-uc-idf
    export IDF_PATH=./esp-idf
    
    # Check if ESP-IDF tools are installed for this board
    if [ ! -f "$HOME/.espressif/.${board}_installed" ]; then
      echo "Installing ESP-IDF tools for ${board}..."
      (
        cd esp-idf
        ./install.sh ${board}
        touch "$HOME/.espressif/.${board}_installed"
      )
      echo "ESP-IDF tools installed successfully!"
    else
      echo "ESP-IDF tools for ${board} already installed."
    fi
    
    # Source the ESP-IDF export script to set up the environment
    if [ -f "./esp-idf/export.sh" ]; then
      source ./esp-idf/export.sh
    fi
    
    echo ""
    echo "ESP-IDF development environment loaded"
    echo "Board: ${board}"
    echo "IDF_PATH: $IDF_PATH"
    echo "Python version: $(python3 --version)"
  '';
}
