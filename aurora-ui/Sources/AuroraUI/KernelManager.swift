import Foundation
import AuroraBridge

/// Manager class for Aurora Kernel operations
class KernelManager: ObservableObject {
    @Published var isInitialized: Bool = false
    @Published var kernelStatus: KernelStatus?
    @Published var lastError: String?
    @Published var threads: [ThreadInfo] = []
    @Published var demoOutput: String = ""
    
    struct KernelStatus {
        let version: String
        let uptime: UInt64
        let activeThreads: UInt32
    }
    
    struct ThreadInfo: Identifiable {
        let id: UInt32
        let name: String
    }
    
    init() {
        // Automatically initialize kernel on startup
        initializeKernel()
    }
    
    deinit {
        shutdownKernel()
    }
    
    // MARK: - Kernel Operations
    
    func initializeKernel() {
        let result = aurora_kernel_init()
        if result == AURORA_OK {
            isInitialized = true
            lastError = nil
            updateKernelStatus()
        } else {
            lastError = "Failed to initialize kernel: \(errorToString(result))"
        }
    }
    
    func shutdownKernel() {
        if isInitialized {
            aurora_kernel_shutdown()
            isInitialized = false
            kernelStatus = nil
            threads = []
        }
    }
    
    func updateKernelStatus() {
        guard isInitialized else { return }
        
        var status = aurora_kernel_status_t()
        let result = aurora_kernel_get_status(&status)
        
        if result == AURORA_OK {
            let version = String(cString: aurora_get_version_string())
            kernelStatus = KernelStatus(
                version: version,
                uptime: status.uptime_ms,
                activeThreads: status.active_threads
            )
            lastError = nil
        } else {
            lastError = "Failed to get kernel status: \(errorToString(result))"
        }
    }
    
    // MARK: - Thread Operations
    
    func createThread(name: String) {
        guard isInitialized else {
            lastError = "Kernel not initialized"
            return
        }
        
        var threadId: aurora_thread_id_t = 0
        let result = aurora_thread_create(&threadId, name)
        
        if result == AURORA_OK {
            threads.append(ThreadInfo(id: threadId, name: name))
            updateKernelStatus()
            lastError = nil
        } else {
            lastError = "Failed to create thread: \(errorToString(result))"
        }
    }
    
    func destroyThread(id: UInt32) {
        guard isInitialized else {
            lastError = "Kernel not initialized"
            return
        }
        
        let result = aurora_thread_destroy(id)
        
        if result == AURORA_OK {
            threads.removeAll { $0.id == id }
            updateKernelStatus()
            lastError = nil
        } else {
            lastError = "Failed to destroy thread: \(errorToString(result))"
        }
    }
    
    // MARK: - Demo Operations
    
    func runDemoCall(input: String) {
        guard isInitialized else {
            lastError = "Kernel not initialized"
            demoOutput = "Error: Kernel not initialized"
            return
        }
        
        var output = [CChar](repeating: 0, count: 256)
        let result = aurora_demo_kernel_call(input, &output, 256)
        
        if result == AURORA_OK {
            demoOutput = String(cString: output)
            lastError = nil
            updateKernelStatus()
        } else {
            demoOutput = "Error: \(errorToString(result))"
            lastError = "Demo call failed: \(errorToString(result))"
        }
    }
    
    // MARK: - Helper Methods
    
    private func errorToString(_ error: aurora_error_t) -> String {
        switch error {
        case AURORA_OK:
            return "Success"
        case AURORA_ERROR_INVALID_PARAM:
            return "Invalid parameter"
        case AURORA_ERROR_NOT_INITIALIZED:
            return "Not initialized"
        case AURORA_ERROR_ALREADY_INITIALIZED:
            return "Already initialized"
        case AURORA_ERROR_OUT_OF_MEMORY:
            return "Out of memory"
        default:
            return "Unknown error (\(error))"
        }
    }
}
