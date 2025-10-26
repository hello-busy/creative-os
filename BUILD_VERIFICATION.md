# Build Verification Checklist

This document provides a comprehensive checklist for verifying that Aurora OS and the web platform build correctly.

## Prerequisites Verification

### macOS (for Aurora OS)
- [ ] macOS 13.0 (Ventura) or later
- [ ] Xcode 14+ installed
- [ ] Command Line Tools installed (`xcode-select --install`)
- [ ] CMake 3.15+ installed (`cmake --version`)
- [ ] Swift 5.7+ available (`swift --version`)

### All Platforms (for Web Platform)
- [ ] Node.js 18+ installed (`node --version`)
- [ ] npm installed (`npm --version`)
- [ ] MongoDB available (locally or via Docker)

## Aurora OS Build Verification

### Phase 1: C++ Kernel Build

```bash
cd aurora
./build.sh
```

**Expected Results:**
- [ ] CMake configuration completes without errors
- [ ] Build completes successfully
- [ ] Three artifacts created:
  - [ ] `build/lib/libaurora_kernel.a` (static library, ~14KB)
  - [ ] `build/lib/libaurora_kernel.so` or `.dylib` (shared library, ~18KB)
  - [ ] `build/bin/aurora_kernel_test` (test executable, ~23KB)

**Verification Commands:**
```bash
# Check library symbols
nm build/lib/libaurora_kernel.a | grep aurora_kernel_init
# Should output: T _aurora_kernel_init (or without underscore on Linux)

# Check shared library dependencies
otool -L build/lib/libaurora_kernel.dylib  # macOS
# OR
ldd build/lib/libaurora_kernel.so          # Linux
# Should show system libraries only

# Verify executable
file build/bin/aurora_kernel_test
# Should show: Mach-O 64-bit executable (macOS) or ELF executable (Linux)
```

### Phase 2: Kernel Tests

```bash
cd aurora/build
./bin/aurora_kernel_test
```

**Expected Output:**
```
=== Aurora Kernel Test ===

Aurora Kernel Version: 0.1.0

Test 1: Initializing kernel...
[Aurora Kernel] Initialized L4 microkernel stub v0.1.0
PASS: Kernel initialized successfully

Test 2: Getting kernel status...
PASS: Status retrieved successfully
  - Initialized: Yes
  - Version: 0.1.0
  - Uptime: 0 ms
  - Active Threads: 0

Test 3: Creating threads...
[Aurora Kernel] Created thread 1: test_thread_1
PASS: Created thread 1 with ID 1
[Aurora Kernel] Created thread 2: test_thread_2
PASS: Created thread 2 with ID 2

Test 4: Checking thread count...
PASS: Thread count is correct: 2

Test 5: Testing demo kernel call...
PASS: Demo call succeeded
  Output: Aurora Kernel Response: 'Hello Aurora!' [uptime: 0 ms, threads: 2]

Test 6: Testing IPC send...
[Aurora IPC] Send to thread 1: msg_id=42, size=12
PASS: IPC message sent successfully

Test 7: Testing IPC receive...
PASS: IPC message received successfully
  From: Thread 0
  Message: Demo message from kernel

Test 8: Destroying threads...
[Aurora Kernel] Destroyed thread 1
PASS: Destroyed thread 1
[Aurora Kernel] Destroyed thread 2
PASS: Destroyed thread 2

Test 9: Shutting down kernel...
[Aurora Kernel] Shutdown complete
PASS: Kernel shut down successfully

=== All Tests Passed! ===
```

**Checklist:**
- [ ] All 9 tests pass
- [ ] No segmentation faults
- [ ] No memory leaks (use `valgrind` on Linux if available)
- [ ] Exit code is 0

### Phase 3: Swift UI Build

```bash
cd ../aurora-ui
swift build
```

**Expected Results:**
- [ ] Swift Package Manager resolves dependencies
- [ ] Compilation completes without errors
- [ ] Executable created at `.build/debug/AuroraUI` or `.build/release/AuroraUI`

**Verification Commands:**
```bash
# Check executable exists
ls -lh .build/debug/AuroraUI

# Check it's executable
file .build/debug/AuroraUI
# Should show: Mach-O 64-bit executable

# Check it can find the kernel library
otool -L .build/debug/AuroraUI | grep aurora
# May show dynamic link or may be statically linked
```

### Phase 4: Swift UI Runtime Test

```bash
swift run
```

**Expected Results:**
- [ ] Application launches
- [ ] Window appears with "Aurora OS" title
- [ ] Status badge shows green "Running" indicator
- [ ] Kernel status card shows:
  - [ ] Version: 0.1.0
  - [ ] Uptime: (some value) ms
  - [ ] Active Threads: 0

**Interactive Tests:**
1. **Demo Kernel Call**
   - [ ] Enter "Hello" in demo input field
   - [ ] Click "Execute Kernel Call"
   - [ ] Output appears: "Aurora Kernel Response: 'Hello' [uptime: X ms, threads: 0]"

2. **Thread Management**
   - [ ] Enter "TestThread" in thread name field
   - [ ] Click "Create Thread"
   - [ ] Thread appears in "Active Threads" list with ID 1
   - [ ] Active threads counter updates to 1
   - [ ] Click trash icon on thread
   - [ ] Thread disappears from list
   - [ ] Active threads counter updates to 0

3. **Status Refresh**
   - [ ] Click "Refresh" button
   - [ ] Uptime value increases
   - [ ] No errors displayed

## Web Platform Build Verification

### Phase 1: Dependency Installation

```bash
cd ../../  # Back to repo root
npm install
```

**Expected Results:**
- [ ] All dependencies installed successfully
- [ ] `node_modules/` directory created
- [ ] No error messages

### Phase 2: Environment Setup

```bash
cp .env.example .env
```

**Verify `.env` contents:**
- [ ] `PORT=3000` (or your preferred port)
- [ ] `MONGODB_URI=mongodb://localhost:27017/hello`
- [ ] `JWT_SECRET` is set (generate with `openssl rand -base64 32`)

### Phase 3: MongoDB

**With Docker:**
```bash
docker-compose up -d mongo
docker ps | grep mongo
```
- [ ] MongoDB container is running

**Or verify local MongoDB:**
```bash
mongosh --eval "db.version()"
```
- [ ] MongoDB responds with version

### Phase 4: Start Web Server

```bash
npm start
```

**Expected Output:**
```
> hello@1.0.0 start
> node src/server.js

MongoDB connected successfully
Server running on http://localhost:3000
```

**Checklist:**
- [ ] Server starts without errors
- [ ] MongoDB connection successful
- [ ] Port 3000 (or configured port) is listening

### Phase 5: Web Interface Tests

1. **Access Homepage**
   - [ ] Navigate to `http://localhost:3000`
   - [ ] Page loads with "Hello" branding
   - [ ] Registration and login forms visible

2. **User Registration**
   - [ ] Fill in username, email, password
   - [ ] Click "Register"
   - [ ] User is created and logged in
   - [ ] Navigation menu appears

3. **Create Post**
   - [ ] Enter post content
   - [ ] Click "Create Post"
   - [ ] Post appears in feed
   - [ ] Points are awarded (check user info)

4. **Gamification**
   - [ ] User level is displayed
   - [ ] Points counter is visible
   - [ ] Badge earned notification (for first post)

## CI/CD Verification

### Local CI Simulation (macOS)

```bash
# Install act (if not already installed)
brew install act

# Run CI workflow locally
act -P macos-latest=-self-hosted
```

### GitHub Actions Verification

After pushing to GitHub:

1. **Navigate to Actions Tab**
   - [ ] Go to `https://github.com/YOUR_USERNAME/creative-os/actions`

2. **Check Workflow Run**
   - [ ] "Aurora OS CI" workflow appears
   - [ ] All jobs complete successfully:
     - [ ] build-kernel (green checkmark)
     - [ ] build-swift-ui (green checkmark)
     - [ ] integration-test (green checkmark)
     - [ ] lint (green checkmark)
     - [ ] build-status (green checkmark)

3. **Review Artifacts**
   - [ ] "aurora-kernel-macos" artifact available for download
   - [ ] "aurora-ui-macos" artifact available for download

4. **Check Build Logs**
   - [ ] No error messages in build logs
   - [ ] All tests pass
   - [ ] Artifacts are uploaded

## Complete System Integration Test

### Test 1: Fresh Clone Build

```bash
# In a temporary directory
git clone https://github.com/YOUR_USERNAME/creative-os.git test-build
cd test-build
./build-all.sh
```

**Verification:**
- [ ] Script completes without errors
- [ ] Both web and Aurora components build
- [ ] All artifacts are created

### Test 2: Simultaneous Execution

```bash
# Terminal 1: Start web server
npm start

# Terminal 2: Start Aurora OS
cd aurora-ui && swift run

# Terminal 3: Run tests
cd aurora/build && ./bin/aurora_kernel_test
```

**Verification:**
- [ ] All three run without conflicts
- [ ] No port conflicts
- [ ] No library conflicts
- [ ] Each component functions independently

## Common Issues and Resolutions

### Issue: CMake not found
**Solution:** `brew install cmake` (macOS) or `apt-get install cmake` (Linux)

### Issue: Swift version too old
**Solution:** Update Xcode from App Store, run `xcode-select --install`

### Issue: Library not loaded
**Solution:** Rebuild kernel: `cd aurora && rm -rf build && ./build.sh`

### Issue: MongoDB connection failed
**Solution:** Start MongoDB: `docker-compose up -d mongo` or `brew services start mongodb-community`

### Issue: Port 3000 in use
**Solution:** Change port in `.env`: `PORT=3001`

### Issue: Kernel test fails
**Solution:** 
1. Check compiler version: `c++ --version` (should support C++17)
2. Rebuild clean: `cd aurora && rm -rf build && ./build.sh`
3. Run test with verbose output: `./build/bin/aurora_kernel_test`

## Performance Benchmarks

### Kernel Performance
- [ ] Initialization: < 1ms
- [ ] Thread creation: < 0.1ms
- [ ] IPC send/receive: < 0.1ms
- [ ] Status query: < 0.01ms

### Build Performance
- [ ] Kernel build (release): < 30 seconds
- [ ] Swift UI build (debug): < 2 minutes
- [ ] Web platform npm install: < 1 minute
- [ ] Full build-all.sh: < 3 minutes

## Final Checklist

- [ ] All Aurora OS components build
- [ ] All kernel tests pass (9/9)
- [ ] Swift UI launches and is functional
- [ ] Web platform builds and runs
- [ ] CI workflow passes on GitHub
- [ ] Documentation is complete and accurate
- [ ] Examples work as described
- [ ] No security warnings or vulnerabilities
- [ ] All acceptance criteria met

## Sign-Off

Date: ________________

Verified by: ________________

Platform: 
- [ ] macOS (version: _______)
- [ ] Linux (distribution: _______)

Component Status:
- Aurora Kernel: [ ] Pass [ ] Fail
- Swift UI: [ ] Pass [ ] Fail [ ] N/A (not macOS)
- Web Platform: [ ] Pass [ ] Fail
- CI/CD: [ ] Pass [ ] Fail

Notes:
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
