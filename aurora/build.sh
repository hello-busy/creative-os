#!/bin/bash

# Aurora Kernel Build Script
set -e

BUILD_TYPE="${1:-Release}"
BUILD_DIR="build"

echo "=== Aurora Kernel Build Script ==="
echo "Build Type: $BUILD_TYPE"
echo ""

# Create build directory
if [ -d "$BUILD_DIR" ]; then
    echo "Cleaning existing build directory..."
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure
echo "Configuring CMake..."
cmake -DCMAKE_BUILD_TYPE="$BUILD_TYPE" ..

# Build
echo "Building..."
cmake --build . --config "$BUILD_TYPE" -j$(sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo ""
echo "=== Build Complete ==="
echo "Static library: $BUILD_DIR/lib/libaurora_kernel.a"
echo "Shared library: $BUILD_DIR/lib/libaurora_kernel.dylib"
echo "Test executable: $BUILD_DIR/bin/aurora_kernel_test"
echo ""
echo "To run tests: ./build/bin/aurora_kernel_test"
