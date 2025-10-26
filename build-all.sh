#!/bin/bash

# Creative OS - Master Build Script
# Builds both Aurora OS and web platform components

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================"
echo "  Creative OS - Complete Build System  "
echo "========================================"
echo ""

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
BUILD_WEB=true
BUILD_AURORA=true
BUILD_TYPE="Release"

while [[ $# -gt 0 ]]; do
    case $1 in
        --web-only)
            BUILD_AURORA=false
            shift
            ;;
        --aurora-only)
            BUILD_WEB=false
            shift
            ;;
        --debug)
            BUILD_TYPE="Debug"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --web-only      Build only web platform"
            echo "  --aurora-only   Build only Aurora OS"
            echo "  --debug         Build in debug mode"
            echo "  --help          Show this help message"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Build Aurora OS (C++ Kernel + Swift UI)
if [ "$BUILD_AURORA" = true ]; then
    echo -e "${BLUE}=== Building Aurora OS ===${NC}"
    echo ""
    
    # Build C++ Kernel
    echo -e "${YELLOW}Building C++ Kernel...${NC}"
    cd "$SCRIPT_DIR/aurora"
    
    if [ -d "build" ]; then
        echo "Cleaning previous build..."
        rm -rf build
    fi
    
    ./build.sh "$BUILD_TYPE"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Kernel build successful${NC}"
    else
        echo "✗ Kernel build failed"
        exit 1
    fi
    echo ""
    
    # Build Swift UI
    echo -e "${YELLOW}Building Swift UI Application...${NC}"
    cd "$SCRIPT_DIR/aurora-ui"
    
    if [ "$BUILD_TYPE" = "Debug" ]; then
        swift build
    else
        swift build -c release
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Swift UI build successful${NC}"
    else
        echo "✗ Swift UI build failed"
        exit 1
    fi
    echo ""
fi

# Build Web Platform
if [ "$BUILD_WEB" = true ]; then
    echo -e "${BLUE}=== Building Web Platform ===${NC}"
    echo ""
    
    cd "$SCRIPT_DIR"
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}Installing npm dependencies...${NC}"
        npm install
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Dependencies installed${NC}"
        else
            echo "✗ Dependency installation failed"
            exit 1
        fi
    else
        echo "Dependencies already installed"
    fi
    echo ""
fi

# Summary
echo ""
echo "========================================"
echo -e "${GREEN}    Build Complete!${NC}"
echo "========================================"
echo ""

if [ "$BUILD_AURORA" = true ]; then
    echo "Aurora OS Artifacts:"
    echo "  Kernel Library:  aurora/build/lib/libaurora_kernel.a"
    echo "  Swift UI App:    aurora-ui/.build/release/AuroraUI"
    echo ""
    echo "To run Aurora OS:"
    echo "  cd aurora-ui && swift run"
    echo ""
fi

if [ "$BUILD_WEB" = true ]; then
    echo "Web Platform:"
    echo "  Start server:    npm start"
    echo "  Start dev mode:  npm run dev"
    echo "  With Docker:     docker-compose up"
    echo ""
fi

echo "For more information, see README.md"
