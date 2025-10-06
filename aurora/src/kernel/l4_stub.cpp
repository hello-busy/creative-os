/*
 * Aurora OS - L4 Microkernel Stub Implementation
 * 
 * This is a minimal L4-inspired microkernel stub for demonstration purposes.
 * It provides basic thread management and IPC primitives.
 */

#include "aurora_abi.h"
#include <cstring>
#include <cstdio>
#include <chrono>
#include <vector>
#include <mutex>
#include <memory>

// Internal kernel state
namespace aurora {
namespace kernel {

struct Thread {
    aurora_thread_id_t id;
    char name[64];
    bool active;
};

class KernelState {
private:
    bool m_initialized;
    std::chrono::steady_clock::time_point m_start_time;
    std::vector<std::unique_ptr<Thread>> m_threads;
    std::mutex m_mutex;
    aurora_thread_id_t m_next_thread_id;

public:
    KernelState() : m_initialized(false), m_next_thread_id(1) {}

    bool is_initialized() const { return m_initialized; }

    aurora_error_t initialize() {
        std::lock_guard<std::mutex> lock(m_mutex);
        if (m_initialized) {
            return AURORA_ERROR_ALREADY_INITIALIZED;
        }
        m_initialized = true;
        m_start_time = std::chrono::steady_clock::now();
        printf("[Aurora Kernel] Initialized L4 microkernel stub v%d.%d.%d\n",
               AURORA_ABI_VERSION_MAJOR, AURORA_ABI_VERSION_MINOR, AURORA_ABI_VERSION_PATCH);
        return AURORA_OK;
    }

    aurora_error_t shutdown() {
        std::lock_guard<std::mutex> lock(m_mutex);
        if (!m_initialized) {
            return AURORA_ERROR_NOT_INITIALIZED;
        }
        m_threads.clear();
        m_initialized = false;
        printf("[Aurora Kernel] Shutdown complete\n");
        return AURORA_OK;
    }

    uint64_t get_uptime_ms() const {
        if (!m_initialized) return 0;
        auto now = std::chrono::steady_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(now - m_start_time);
        return static_cast<uint64_t>(duration.count());
    }

    aurora_error_t create_thread(aurora_thread_id_t* thread_id, const char* name) {
        std::lock_guard<std::mutex> lock(m_mutex);
        if (!m_initialized) {
            return AURORA_ERROR_NOT_INITIALIZED;
        }
        
        auto thread = std::make_unique<Thread>();
        thread->id = m_next_thread_id++;
        strncpy(thread->name, name ? name : "unnamed", sizeof(thread->name) - 1);
        thread->name[sizeof(thread->name) - 1] = '\0';
        thread->active = true;

        *thread_id = thread->id;
        printf("[Aurora Kernel] Created thread %u: %s\n", *thread_id, thread->name);
        m_threads.push_back(std::move(thread));
        
        return AURORA_OK;
    }

    aurora_error_t destroy_thread(aurora_thread_id_t thread_id) {
        std::lock_guard<std::mutex> lock(m_mutex);
        if (!m_initialized) {
            return AURORA_ERROR_NOT_INITIALIZED;
        }

        for (auto it = m_threads.begin(); it != m_threads.end(); ++it) {
            if ((*it)->id == thread_id) {
                printf("[Aurora Kernel] Destroyed thread %u\n", thread_id);
                m_threads.erase(it);
                return AURORA_OK;
            }
        }
        return AURORA_ERROR_INVALID_PARAM;
    }

    uint32_t get_active_thread_count() const {
        std::lock_guard<std::mutex> lock(const_cast<std::mutex&>(m_mutex));
        return static_cast<uint32_t>(m_threads.size());
    }
};

// Global kernel state
static KernelState g_kernel;

} // namespace kernel
} // namespace aurora

// C API Implementation
extern "C" {

aurora_error_t aurora_kernel_init(void) {
    return aurora::kernel::g_kernel.initialize();
}

aurora_error_t aurora_kernel_shutdown(void) {
    return aurora::kernel::g_kernel.shutdown();
}

aurora_error_t aurora_kernel_get_status(aurora_kernel_status_t* status) {
    if (!status) {
        return AURORA_ERROR_INVALID_PARAM;
    }

    if (!aurora::kernel::g_kernel.is_initialized()) {
        return AURORA_ERROR_NOT_INITIALIZED;
    }

    status->initialized = true;
    status->version_major = AURORA_ABI_VERSION_MAJOR;
    status->version_minor = AURORA_ABI_VERSION_MINOR;
    status->version_patch = AURORA_ABI_VERSION_PATCH;
    status->uptime_ms = aurora::kernel::g_kernel.get_uptime_ms();
    status->active_threads = aurora::kernel::g_kernel.get_active_thread_count();

    return AURORA_OK;
}

aurora_error_t aurora_thread_create(aurora_thread_id_t* thread_id, const char* name) {
    if (!thread_id) {
        return AURORA_ERROR_INVALID_PARAM;
    }
    return aurora::kernel::g_kernel.create_thread(thread_id, name);
}

aurora_error_t aurora_thread_destroy(aurora_thread_id_t thread_id) {
    return aurora::kernel::g_kernel.destroy_thread(thread_id);
}

aurora_error_t aurora_thread_get_count(uint32_t* count) {
    if (!count) {
        return AURORA_ERROR_INVALID_PARAM;
    }
    
    if (!aurora::kernel::g_kernel.is_initialized()) {
        return AURORA_ERROR_NOT_INITIALIZED;
    }

    *count = aurora::kernel::g_kernel.get_active_thread_count();
    return AURORA_OK;
}

aurora_error_t aurora_ipc_send(aurora_thread_id_t target, const aurora_message_t* message) {
    if (!message) {
        return AURORA_ERROR_INVALID_PARAM;
    }
    
    if (!aurora::kernel::g_kernel.is_initialized()) {
        return AURORA_ERROR_NOT_INITIALIZED;
    }

    // Stub implementation - just log the message
    printf("[Aurora IPC] Send to thread %u: msg_id=%u, size=%u\n",
           target, message->msg_id, message->data_size);
    return AURORA_OK;
}

aurora_error_t aurora_ipc_receive(aurora_thread_id_t* sender, aurora_message_t* message) {
    if (!sender || !message) {
        return AURORA_ERROR_INVALID_PARAM;
    }
    
    if (!aurora::kernel::g_kernel.is_initialized()) {
        return AURORA_ERROR_NOT_INITIALIZED;
    }

    // Stub implementation - return a demo message
    *sender = 0;
    message->msg_id = 1;
    message->timestamp = aurora::kernel::g_kernel.get_uptime_ms();
    strncpy(message->data, "Demo message from kernel", sizeof(message->data) - 1);
    message->data_size = strlen(message->data);
    return AURORA_OK;
}

aurora_error_t aurora_demo_kernel_call(const char* input, char* output, uint32_t output_size) {
    if (!input || !output || output_size == 0) {
        return AURORA_ERROR_INVALID_PARAM;
    }

    if (!aurora::kernel::g_kernel.is_initialized()) {
        return AURORA_ERROR_NOT_INITIALIZED;
    }

    // Demo function that echoes input with kernel info
    snprintf(output, output_size, 
             "Aurora Kernel Response: '%s' [uptime: %llu ms, threads: %u]",
             input,
             static_cast<unsigned long long>(aurora::kernel::g_kernel.get_uptime_ms()),
             aurora::kernel::g_kernel.get_active_thread_count());

    return AURORA_OK;
}

const char* aurora_get_version_string(void) {
    static char version[32];
    snprintf(version, sizeof(version), "%d.%d.%d",
             AURORA_ABI_VERSION_MAJOR, AURORA_ABI_VERSION_MINOR, AURORA_ABI_VERSION_PATCH);
    return version;
}

} // extern "C"
