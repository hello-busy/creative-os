# Extending Aurora OS

This guide shows how to add new features to Aurora OS, including kernel functions and Swift UI integration.

## Example: Adding a Memory Management Feature

Let's add a simple memory allocation tracking feature to demonstrate the complete workflow.

### Step 1: Extend the C ABI Header

Edit `aurora/include/aurora_abi.h`:

```c
// Add to the header file

// Memory tracking structure
typedef struct {
    uint64_t total_allocated;
    uint64_t total_freed;
    uint32_t active_allocations;
} aurora_memory_stats_t;

// Memory management functions
aurora_error_t aurora_memory_allocate(uint32_t size, void** ptr);
aurora_error_t aurora_memory_free(void* ptr);
aurora_error_t aurora_memory_get_stats(aurora_memory_stats_t* stats);
```

### Step 2: Implement in C++ Kernel

Edit `aurora/src/kernel/l4_stub.cpp`:

```cpp
// Add to the KernelState class
class KernelState {
private:
    // ... existing members ...
    uint64_t m_total_allocated;
    uint64_t m_total_freed;
    std::map<void*, uint32_t> m_allocations;

public:
    KernelState() : 
        m_initialized(false), 
        m_next_thread_id(1),
        m_total_allocated(0),
        m_total_freed(0) {}

    // Add memory management methods
    aurora_error_t allocate_memory(uint32_t size, void** ptr) {
        std::lock_guard<std::mutex> lock(m_mutex);
        if (!m_initialized) {
            return AURORA_ERROR_NOT_INITIALIZED;
        }
        
        *ptr = malloc(size);
        if (!*ptr) {
            return AURORA_ERROR_OUT_OF_MEMORY;
        }
        
        m_allocations[*ptr] = size;
        m_total_allocated += size;
        return AURORA_OK;
    }

    aurora_error_t free_memory(void* ptr) {
        std::lock_guard<std::mutex> lock(m_mutex);
        if (!m_initialized) {
            return AURORA_ERROR_NOT_INITIALIZED;
        }
        
        auto it = m_allocations.find(ptr);
        if (it == m_allocations.end()) {
            return AURORA_ERROR_INVALID_PARAM;
        }
        
        m_total_freed += it->second;
        m_allocations.erase(it);
        free(ptr);
        return AURORA_OK;
    }

    aurora_memory_stats_t get_memory_stats() const {
        std::lock_guard<std::mutex> lock(const_cast<std::mutex&>(m_mutex));
        aurora_memory_stats_t stats;
        stats.total_allocated = m_total_allocated;
        stats.total_freed = m_total_freed;
        stats.active_allocations = m_allocations.size();
        return stats;
    }
};

// Add C API implementations
extern "C" {

aurora_error_t aurora_memory_allocate(uint32_t size, void** ptr) {
    if (!ptr) {
        return AURORA_ERROR_INVALID_PARAM;
    }
    return aurora::kernel::g_kernel.allocate_memory(size, ptr);
}

aurora_error_t aurora_memory_free(void* ptr) {
    if (!ptr) {
        return AURORA_ERROR_INVALID_PARAM;
    }
    return aurora::kernel::g_kernel.free_memory(ptr);
}

aurora_error_t aurora_memory_get_stats(aurora_memory_stats_t* stats) {
    if (!stats) {
        return AURORA_ERROR_INVALID_PARAM;
    }
    if (!aurora::kernel::g_kernel.is_initialized()) {
        return AURORA_ERROR_NOT_INITIALIZED;
    }
    *stats = aurora::kernel::g_kernel.get_memory_stats();
    return AURORA_OK;
}

} // extern "C"
```

### Step 3: Rebuild the Kernel

```bash
cd aurora
./build.sh
```

### Step 4: Add Swift Wrapper

Edit `aurora-ui/Sources/AuroraUI/KernelManager.swift`:

```swift
// Add to KernelManager class

@Published var memoryStats: MemoryStats?

struct MemoryStats {
    let totalAllocated: UInt64
    let totalFreed: UInt64
    let activeAllocations: UInt32
}

func updateMemoryStats() {
    guard isInitialized else { return }
    
    var stats = aurora_memory_stats_t()
    let result = aurora_memory_get_stats(&stats)
    
    if result == AURORA_OK {
        memoryStats = MemoryStats(
            totalAllocated: stats.total_allocated,
            totalFreed: stats.total_freed,
            activeAllocations: stats.active_allocations
        )
        lastError = nil
    } else {
        lastError = "Failed to get memory stats: \(errorToString(result))"
    }
}

func allocateMemory(size: UInt32) -> UnsafeMutableRawPointer? {
    guard isInitialized else {
        lastError = "Kernel not initialized"
        return nil
    }
    
    var ptr: UnsafeMutableRawPointer?
    let result = aurora_memory_allocate(size, &ptr)
    
    if result == AURORA_OK {
        updateMemoryStats()
        lastError = nil
        return ptr
    } else {
        lastError = "Failed to allocate memory: \(errorToString(result))"
        return nil
    }
}

func freeMemory(_ ptr: UnsafeMutableRawPointer) {
    guard isInitialized else {
        lastError = "Kernel not initialized"
        return
    }
    
    let result = aurora_memory_free(ptr)
    
    if result == AURORA_OK {
        updateMemoryStats()
        lastError = nil
    } else {
        lastError = "Failed to free memory: \(errorToString(result))"
    }
}
```

### Step 5: Add UI Components

Edit `aurora-ui/Sources/AuroraUI/ContentView.swift`:

```swift
// Add to ContentView body

private var memoryStatsCard: some View {
    VStack(alignment: .leading, spacing: 12) {
        HStack {
            Image(systemName: "memorychip")
                .foregroundColor(.indigo)
            Text("Memory Statistics")
                .font(.headline)
            Spacer()
            Button("Refresh") {
                kernelManager.updateMemoryStats()
            }
            .buttonStyle(.bordered)
        }
        
        if let stats = kernelManager.memoryStats {
            VStack(spacing: 8) {
                StatusRow(label: "Total Allocated", 
                         value: "\(stats.totalAllocated) bytes")
                StatusRow(label: "Total Freed", 
                         value: "\(stats.totalFreed) bytes")
                StatusRow(label: "Active Allocations", 
                         value: "\(stats.activeAllocations)")
                StatusRow(label: "Current Usage", 
                         value: "\(stats.totalAllocated - stats.totalFreed) bytes")
            }
        } else {
            Text("No memory statistics available")
                .foregroundColor(.secondary)
        }
    }
    .padding()
    .background(Color(NSColor.controlBackgroundColor))
    .cornerRadius(10)
}
```

### Step 6: Rebuild Swift UI

```bash
cd aurora-ui
swift build
```

### Step 7: Test the New Feature

```bash
swift run
```

In the UI, you should now see a "Memory Statistics" card showing allocation tracking.

## Testing New Features

### Add Kernel Tests

Edit `aurora/src/kernel/test_main.cpp`:

```cpp
// Add new test
std::cout << "Test X: Testing memory management..." << std::endl;

// Allocate memory
void* ptr1 = nullptr;
result = aurora_memory_allocate(1024, &ptr1);
if (result != AURORA_OK || !ptr1) {
    std::cerr << "FAIL: Memory allocation failed" << std::endl;
    return 1;
}
std::cout << "PASS: Allocated 1024 bytes" << std::endl;

// Get stats
aurora_memory_stats_t stats;
result = aurora_memory_get_stats(&stats);
if (result != AURORA_OK || stats.total_allocated != 1024) {
    std::cerr << "FAIL: Memory stats incorrect" << std::endl;
    return 1;
}
std::cout << "PASS: Memory stats correct" << std::endl;

// Free memory
result = aurora_memory_free(ptr1);
if (result != AURORA_OK) {
    std::cerr << "FAIL: Memory free failed" << std::endl;
    return 1;
}
std::cout << "PASS: Memory freed successfully" << std::endl;
```

Run tests:
```bash
cd aurora/build
./bin/aurora_kernel_test
```

## Best Practices

### 1. Always Use C ABI for Interop

Swift can only call C functions directly, not C++. Always use `extern "C"` blocks:

```cpp
extern "C" {
    aurora_error_t my_function(int param);
}
```

### 2. Handle Errors Properly

Always return error codes and check them in Swift:

```swift
let result = my_kernel_function(param)
if result != AURORA_OK {
    lastError = "Function failed: \(errorToString(result))"
    return
}
```

### 3. Use Thread-Safe Code

The kernel may be called from multiple Swift threads. Always use locks:

```cpp
std::lock_guard<std::mutex> lock(m_mutex);
// ... critical section ...
```

### 4. Document Your APIs

Add documentation comments to both C headers and Swift wrappers:

```c
/// Allocates memory from the kernel heap
/// @param size Number of bytes to allocate
/// @param ptr Output pointer to allocated memory
/// @return AURORA_OK on success, error code otherwise
aurora_error_t aurora_memory_allocate(uint32_t size, void** ptr);
```

```swift
/// Allocates memory from the Aurora kernel
/// - Parameter size: Number of bytes to allocate
/// - Returns: Pointer to allocated memory, or nil on failure
func allocateMemory(size: UInt32) -> UnsafeMutableRawPointer?
```

### 5. Update CI Tests

After adding features, ensure CI still passes:

```yaml
# .github/workflows/ci.yml
- name: Test New Features
  working-directory: aurora/build
  run: |
    ./bin/aurora_kernel_test
    # Add specific new feature tests
```

## Common Patterns

### Pattern 1: Stateful Kernel Operations

```cpp
// In KernelState class
private:
    std::map<uint32_t, MyState> m_states;

public:
    aurora_error_t create_state(uint32_t* id) {
        std::lock_guard<std::mutex> lock(m_mutex);
        *id = m_next_id++;
        m_states[*id] = MyState();
        return AURORA_OK;
    }
```

### Pattern 2: Async Operations (Future Enhancement)

```cpp
// Return operation ID for later checking
aurora_error_t aurora_async_operation(uint32_t* op_id);
aurora_error_t aurora_check_operation(uint32_t op_id, bool* completed);
```

### Pattern 3: Callback Registration

```cpp
typedef void (*aurora_callback_t)(void* context, const char* message);
aurora_error_t aurora_register_callback(aurora_callback_t callback, void* context);
```

## Resources

- **C ABI Reference**: `aurora/include/aurora_abi.h`
- **Kernel Implementation**: `aurora/src/kernel/l4_stub.cpp`
- **Swift Bridge**: `aurora-ui/Sources/AuroraBridge/`
- **UI Examples**: `aurora-ui/Sources/AuroraUI/ContentView.swift`

## Contributing

When adding features:

1. Create a feature branch
2. Add tests for new functionality
3. Update documentation
4. Ensure CI passes
5. Submit a pull request

See CONTRIBUTING.md for full guidelines.
