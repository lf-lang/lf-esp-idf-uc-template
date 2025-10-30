#!/usr/bin/env bash
set -e

build_test() {
    local program=$1
    local board=$2
    echo "========================================="
    echo "Building $program for $board"
    echo "========================================="
    cmake -Bbuild -DLF_MAIN=$program -DESP_IDF_BOARD=$board -DCMAKE_TOOLCHAIN_FILE=$IDF_PATH/tools/cmake/toolchain-$board.cmake -GNinja
    cmake --build build -j $(nproc)
    rm -rf build src-gen
}

# Activate ESP-IDF env
. /$ESP_IDF_PATH/export.sh

# BOARD to test
BOARD=${ESP_IDF_BOARD}

# Automatically discover all LF examples in src directory (excluding lib subdirectory)
EXAMPLES=()
for lf_file in src/*.lf; do
    if [ -f "$lf_file" ]; then
        # Extract filename without path and extension
        example=$(basename "$lf_file" .lf)
        EXAMPLES+=("$example")
    fi
done

echo "Found examples: ${EXAMPLES[@]}"

export ESP_IDF_BOARD=$board
echo ""
echo "========================================"
echo "Testing board: $board"
echo "========================================"

for example in "${EXAMPLES[@]}"; do
    build_test "$example" "$board"
done

echo ""
echo "========================================"
echo "All tests completed successfully!"
echo "========================================"

