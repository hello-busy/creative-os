# Aurora UI - SwiftUI Application

A native macOS application providing a graphical interface to the Aurora microkernel.

## Features

- **Kernel Status Monitoring**: Real-time display of kernel version, uptime, and active threads
- **Thread Management**: Create and destroy kernel threads via UI
- **Demo Kernel Calls**: Interactive testing of kernel ABI functions
- **Native macOS UI**: Built with SwiftUI for modern macOS experience

## Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode 14+ with Swift 5.7+
- Aurora kernel built (see `../aurora/README.md`)

## Building

### Step 1: Build Aurora Kernel

First, build the Aurora kernel library:

```bash
cd ../aurora
./build.sh
```

This creates the static library at `../aurora/build/lib/libaurora_kernel.a`.

### Step 2: Build Swift UI Application

```bash
# From aurora-ui directory
swift build

# Or for release build
swift build -c release
```

## Running

### From Command Line

```bash
swift run
```

### From Xcode

1. Open `Package.swift` in Xcode
2. Select the AuroraUI scheme
3. Click Run (⌘R)

## Usage

### Initializing the Kernel

The kernel automatically initializes when the app launches. The status badge in the header shows whether the kernel is running.

### Testing Kernel Functions

1. **Demo Kernel Call**:
   - Enter text in the demo input field
   - Click "Execute Kernel Call"
   - The kernel will echo your input with status information

2. **Thread Management**:
   - Enter a thread name
   - Click "Create Thread"
   - Created threads appear in the "Active Threads" list
   - Click the trash icon to destroy a thread

3. **Monitoring Status**:
   - Click "Refresh" in the status card to update kernel information
   - Uptime and thread count update automatically

## Architecture

### Swift-C++ Interop

The app uses Swift Package Manager's C interop capabilities:

```
AuroraUI (Swift) 
    ↓
AuroraBridge (module map)
    ↓
aurora_abi.h (C header)
    ↓
libaurora_kernel.a (C++ implementation)
```

The `AuroraBridge` target provides a module map that exposes the C API to Swift.

### Project Structure

```
aurora-ui/
├── Package.swift                 # Swift Package Manager manifest
├── Sources/
│   ├── AuroraBridge/            # C interop bridge
│   │   └── include/
│   │       └── module.modulemap # Maps C headers to Swift
│   └── AuroraUI/                # Swift UI application
│       ├── main.swift           # App entry point
│       ├── ContentView.swift    # Main UI view
│       └── KernelManager.swift  # Kernel interaction logic
└── README.md
```

## Troubleshooting

### "Library not loaded" Error

If you get a library loading error:

```bash
# Ensure the kernel is built
cd ../aurora
./build.sh

# Verify library exists
ls -la build/lib/libaurora_kernel.a
```

### Build Failures

1. **Header not found**: Make sure the aurora kernel headers are at `../aurora/include/aurora_abi.h`
2. **Linker errors**: Verify the kernel library is built in `../aurora/build/lib/`
3. **Swift version errors**: Ensure you're using Swift 5.7+ with Xcode 14+

### Running on Different Architectures

The build is configured for the host architecture (arm64 on Apple Silicon, x86_64 on Intel Macs). Both the kernel and Swift app must be built for the same architecture.

## Development

### Adding New Kernel Features

1. Add functions to `aurora/include/aurora_abi.h`
2. Implement in `aurora/src/kernel/l4_stub.cpp`
3. Rebuild the kernel: `cd ../aurora && ./build.sh`
4. Add Swift wrapper methods to `KernelManager.swift`
5. Add UI controls to `ContentView.swift`

### Testing Changes

After modifying the kernel:

```bash
# Rebuild kernel
cd ../aurora && ./build.sh

# Run Swift app
cd ../aurora-ui && swift run
```

## License

See the main repository LICENSE file.
