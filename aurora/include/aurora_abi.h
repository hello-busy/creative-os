#ifndef AURORA_ABI_H
#define AURORA_ABI_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Aurora OS ABI Version
#define AURORA_ABI_VERSION_MAJOR 0
#define AURORA_ABI_VERSION_MINOR 1
#define AURORA_ABI_VERSION_PATCH 0

// Error codes
typedef enum {
    AURORA_OK = 0,
    AURORA_ERROR_INVALID_PARAM = -1,
    AURORA_ERROR_NOT_INITIALIZED = -2,
    AURORA_ERROR_ALREADY_INITIALIZED = -3,
    AURORA_ERROR_OUT_OF_MEMORY = -4,
    AURORA_ERROR_UNKNOWN = -99
} aurora_error_t;

// Kernel status structure
typedef struct {
    bool initialized;
    uint32_t version_major;
    uint32_t version_minor;
    uint32_t version_patch;
    uint64_t uptime_ms;
    uint32_t active_threads;
} aurora_kernel_status_t;

// Kernel initialization and control
aurora_error_t aurora_kernel_init(void);
aurora_error_t aurora_kernel_shutdown(void);
aurora_error_t aurora_kernel_get_status(aurora_kernel_status_t* status);

// Thread management (L4 microkernel primitives)
typedef uint32_t aurora_thread_id_t;

aurora_error_t aurora_thread_create(aurora_thread_id_t* thread_id, const char* name);
aurora_error_t aurora_thread_destroy(aurora_thread_id_t thread_id);
aurora_error_t aurora_thread_get_count(uint32_t* count);

// IPC primitives (simplified L4 IPC)
typedef struct {
    uint32_t msg_id;
    uint64_t timestamp;
    char data[256];
    uint32_t data_size;
} aurora_message_t;

aurora_error_t aurora_ipc_send(aurora_thread_id_t target, const aurora_message_t* message);
aurora_error_t aurora_ipc_receive(aurora_thread_id_t* sender, aurora_message_t* message);

// Demo/Test functions callable from Swift UI
aurora_error_t aurora_demo_kernel_call(const char* input, char* output, uint32_t output_size);
const char* aurora_get_version_string(void);

#ifdef __cplusplus
}
#endif

#endif // AURORA_ABI_H
