# Aurora OS Kernel

A minimal L4-inspired microkernel implementation providing basic thread management and IPC primitives.

## Architecture

Aurora is built on microkernel principles with:
- **Minimal kernel**: Thread management, IPC, basic scheduling
- **L4-inspired design**: Fast IPC, capability-based security model
- **C++ implementation**: Modern C++17 with C ABI for interoperability

## Building the Kernel

### Prerequisites

- CMake 3.15 or later
- C++17 compatible compiler (Clang on macOS recommended)
- For Swift integration: Xcode 14+ with Swift 5.7+

### Build Instructions

```bash
# From the aurora directory
mkdir build
cd build
cmake ..
cmake --build .

# Or use the provided script
./build.sh
```

This will create:
- `lib/libaurora_kernel.a` - Static library for linking
- `lib/libaurora_kernel.dylib` - Shared library for dynamic loading
- `bin/aurora_kernel_test` - Test executable

### Build Options

```bash
# Debug build
cmake -DCMAKE_BUILD_TYPE=Debug ..

# Release build (optimized)
cmake -DCMAKE_BUILD_TYPE=Release ..

# Specify install prefix
cmake -DCMAKE_INSTALL_PREFIX=/usr/local ..
```

## API Overview

### Kernel Initialization

```c
#include "aurora_abi.h"

// Initialize the kernel
aurora_kernel_init();

// Get kernel status
aurora_kernel_status_t status;
aurora_kernel_get_status(&status);

// Shutdown
aurora_kernel_shutdown();
```

### Thread Management

```c
// Create a thread
aurora_thread_id_t thread_id;
aurora_thread_create(&thread_id, "worker_thread");

// Destroy a thread
aurora_thread_destroy(thread_id);

// Get active thread count
uint32_t count;
aurora_thread_get_count(&count);
```

### IPC (Inter-Process Communication)

```c
// Send a message
aurora_message_t msg;
msg.msg_id = 1;
strcpy(msg.data, "Hello from thread");
msg.data_size = strlen(msg.data);
aurora_ipc_send(target_thread_id, &msg);

// Receive a message
aurora_thread_id_t sender;
aurora_message_t received;
aurora_ipc_receive(&sender, &received);
```

### Demo Functions

```c
// Call kernel with demo input
char output[256];
aurora_demo_kernel_call("Hello Aurora", output, sizeof(output));

// Get version string
const char* version = aurora_get_version_string();
```

## Integration with Swift

See the `aurora-ui/` directory for Swift UI application that demonstrates calling into the kernel.

The kernel provides a C ABI that can be easily bridged to Swift:

1. Import the C headers via bridging header
2. Call C functions directly from Swift
3. Handle kernel responses in Swift UI

## Testing

Run the test executable:

```bash
./build/bin/aurora_kernel_test
```

## Error Handling

All kernel functions return `aurora_error_t`:
- `AURORA_OK` (0) - Success
- `AURORA_ERROR_INVALID_PARAM` (-1) - Invalid parameter
- `AURORA_ERROR_NOT_INITIALIZED` (-2) - Kernel not initialized
- `AURORA_ERROR_ALREADY_INITIALIZED` (-3) - Already initialized
- `AURORA_ERROR_OUT_OF_MEMORY` (-4) - Memory allocation failed
- `AURORA_ERROR_UNKNOWN` (-99) - Unknown error

## Performance Considerations

This is a demonstration stub. A production microkernel would include:
- Real scheduling algorithms
- Memory protection
- Capability-based security
- Optimized IPC paths
- Device driver framework
- Virtual memory management

## License

See the main repository LICENSE file.
