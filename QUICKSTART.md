# Creative OS Quick Start Guide

This guide helps you get started with both components of Creative OS: the web platform (Hello) and Aurora OS.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Quick Start Options](#quick-start-options)
- [Build Instructions](#build-instructions)
- [Running the Applications](#running-the-applications)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### For Web Platform
- Node.js 18+ and npm
- MongoDB (or Docker)

### For Aurora OS (macOS only)
- macOS 13.0 (Ventura) or later
- Xcode 14+ with Command Line Tools
- CMake 3.15+
- Swift 5.7+

## Quick Start Options

### Option 1: Web Platform Only (All Platforms)

```bash
# Clone the repository
git clone https://github.com/hello-busy/creative-os.git
cd creative-os

# Install dependencies
npm install

# Setup environment
cp .env.example .env

# Start with Docker (recommended)
docker-compose up -d

# OR start manually (requires MongoDB running)
npm start

# Access at http://localhost:3000
```

### Option 2: Aurora OS Only (macOS)

```bash
# Clone the repository
git clone https://github.com/hello-busy/creative-os.git
cd creative-os

# Build everything
./build-all.sh --aurora-only

# Run the Swift UI app
cd aurora-ui
swift run
```

### Option 3: Build Everything (macOS)

```bash
# Clone the repository
git clone https://github.com/hello-busy/creative-os.git
cd creative-os

# Build all components
./build-all.sh

# Run web platform
npm start &

# Run Aurora OS
cd aurora-ui && swift run
```

## Build Instructions

### Building the C++ Kernel

```bash
cd aurora
./build.sh         # Release build
./build.sh Debug   # Debug build

# Verify build
ls -lh build/lib/libaurora_kernel.a
ls -lh build/bin/aurora_kernel_test

# Run tests
./build/bin/aurora_kernel_test
```

**Expected output:**
```
=== Aurora Kernel Test ===
Aurora Kernel Version: 0.1.0
Test 1: Initializing kernel...
PASS: Kernel initialized successfully
...
=== All Tests Passed! ===
```

### Building the Swift UI

```bash
cd aurora-ui

# Debug build
swift build

# Release build  
swift build -c release

# Verify build
ls -lh .build/release/AuroraUI
```

### Using the Master Build Script

```bash
# Build everything
./build-all.sh

# Build only web platform
./build-all.sh --web-only

# Build only Aurora OS
./build-all.sh --aurora-only

# Build in debug mode
./build-all.sh --debug
```

## Running the Applications

### Web Platform

**With Docker:**
```bash
docker-compose up -d
# Access at http://localhost:3000
```

**Manual:**
```bash
# Ensure MongoDB is running
npm start
# OR for development with auto-reload
npm run dev
```

### Aurora OS

**From Swift Package:**
```bash
cd aurora-ui
swift run
```

**From Built Executable:**
```bash
cd aurora-ui
./.build/release/AuroraUI
```

The Aurora UI will launch with a native macOS window showing:
- Kernel status monitoring
- Thread management interface
- Demo kernel call functionality

## Verification

### Verify Web Platform

1. Access http://localhost:3000
2. Register a new account
3. Create a post
4. Check that gamification points are awarded

### Verify Aurora OS

**Test 1: Kernel Library**
```bash
cd aurora/build
nm lib/libaurora_kernel.a | grep aurora_kernel_init
# Should show the symbol is defined
```

**Test 2: Run Kernel Tests**
```bash
cd aurora/build
./bin/aurora_kernel_test
# All 9 tests should pass
```

**Test 3: Swift UI**
```bash
cd aurora-ui
swift run
# UI should launch
```

In the UI:
1. Check that status badge shows "Running" (green)
2. Enter "Test" in demo input and click "Execute Kernel Call"
3. Verify output shows kernel response
4. Create a thread named "test"
5. Verify it appears in Active Threads list

## Troubleshooting

### Common Issues

#### 1. CMake not found
```bash
# macOS
brew install cmake

# Linux
sudo apt-get install cmake
```

#### 2. Swift version too old
```bash
# macOS - install latest Xcode from App Store
xcode-select --install
swift --version  # Should be 5.7+
```

#### 3. Library not loaded error
```bash
# Rebuild kernel first
cd aurora
./build.sh

# Then rebuild Swift UI
cd ../aurora-ui
swift build
```

#### 4. MongoDB connection failed
```bash
# With Docker
docker-compose up -d mongo

# Or install locally
brew install mongodb-community
brew services start mongodb-community
```

#### 5. Port 3000 already in use
```bash
# Edit .env file
PORT=3001
```

### Getting Help

- **Issues**: https://github.com/hello-busy/creative-os/issues
- **Documentation**: See README.md
- **Architecture**: See ARCHITECTURE.md
- **Contributing**: See CONTRIBUTING.md

### Build Status

Check CI status at: https://github.com/hello-busy/creative-os/actions

The CI pipeline:
- ✓ Builds C++ kernel on macOS
- ✓ Builds Swift UI on macOS  
- ✓ Runs kernel tests
- ✓ Verifies Swift-C++ integration

## Next Steps

### For Web Platform Development
1. Review API.md for endpoint documentation
2. Check USAGE_GUIDE.md for features
3. See CONTRIBUTING.md for contribution guidelines

### For Aurora OS Development
1. Read aurora/README.md for kernel details
2. Read aurora-ui/README.md for UI architecture
3. Explore the kernel ABI in aurora/include/aurora_abi.h
4. Add new kernel features following the Swift-C interop pattern

## Quick Reference

### Project Structure
```
creative-os/
├── aurora/              # C++ kernel
├── aurora-ui/           # Swift UI
├── src/                 # Web backend
├── public/              # Web frontend
├── .github/workflows/   # CI/CD
└── build-all.sh         # Master build script
```

### Key Commands
```bash
# Build everything
./build-all.sh

# Test kernel
aurora/build/bin/aurora_kernel_test

# Run web platform
npm start

# Run Aurora OS
cd aurora-ui && swift run

# Run CI locally (macOS)
act -P macos-latest=-self-hosted
```

## License

See LICENSE file for details.
