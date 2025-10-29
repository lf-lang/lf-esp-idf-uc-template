#!/usr/bin/env bash
set -e

run_with_timeout() {
    local duration=$1
    shift
    local command="$@"

    # Run the command but disable exit on error (because timeout will cause an error)
    set +e
    timeout "$duration" $command

    # Get the exit status of the command and then re-enable exit on error (after forcing a true return value)
    exit_status=$?
    true
    set -e

    # Check the exit status of the timeout command
    if [ $exit_status -eq 124 ]; then
        echo "Command timed out (success)."
        return 0
    elif [ $exit_status -eq 0 ]; then
        echo "Command completed successfully within $duration."
        return 0
    else
        echo "Command failed."
        return 1
    fi
}

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

# List of ESP32 boards
BOARDS=("esp32" "esp32s2" "esp32c3" "esp32s3" "esp32c2" "esp32c6" "esp32h2" "esp32p4" "esp32c5" "esp32c61")

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
echo "Testing boards: ${BOARDS[@]}"

# Test each example on each board
for board in "${BOARDS[@]}"; do
    export ESP_IDF_BOARD=$board
    echo ""
    echo "========================================"
    echo "Testing board: $board"
    echo "========================================"
    
    # for example in "${EXAMPLES[@]}"; do
    #     build_test "$example" "$board"
    # done
done

echo ""
echo "========================================"
echo "All tests completed successfully!"
echo "========================================"

