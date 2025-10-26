/*
 * Aurora OS Kernel Test Program
 * 
 * This program tests the basic functionality of the Aurora kernel.
 */

#include "aurora_abi.h"
#include <iostream>
#include <cstring>

int main() {
    std::cout << "=== Aurora Kernel Test ===" << std::endl;
    std::cout << std::endl;
    
    // Test 1: Get version before init
    const char* version = aurora_get_version_string();
    std::cout << "Aurora Kernel Version: " << version << std::endl;
    std::cout << std::endl;
    
    // Test 2: Initialize kernel
    std::cout << "Test 1: Initializing kernel..." << std::endl;
    aurora_error_t result = aurora_kernel_init();
    if (result != AURORA_OK) {
        std::cerr << "FAIL: Kernel initialization failed with error " << result << std::endl;
        return 1;
    }
    std::cout << "PASS: Kernel initialized successfully" << std::endl;
    std::cout << std::endl;
    
    // Test 3: Get kernel status
    std::cout << "Test 2: Getting kernel status..." << std::endl;
    aurora_kernel_status_t status;
    result = aurora_kernel_get_status(&status);
    if (result != AURORA_OK) {
        std::cerr << "FAIL: Failed to get kernel status" << std::endl;
        return 1;
    }
    std::cout << "PASS: Status retrieved successfully" << std::endl;
    std::cout << "  - Initialized: " << (status.initialized ? "Yes" : "No") << std::endl;
    std::cout << "  - Version: " << status.version_major << "." 
              << status.version_minor << "." << status.version_patch << std::endl;
    std::cout << "  - Uptime: " << status.uptime_ms << " ms" << std::endl;
    std::cout << "  - Active Threads: " << status.active_threads << std::endl;
    std::cout << std::endl;
    
    // Test 4: Create threads
    std::cout << "Test 3: Creating threads..." << std::endl;
    aurora_thread_id_t thread1, thread2;
    
    result = aurora_thread_create(&thread1, "test_thread_1");
    if (result != AURORA_OK) {
        std::cerr << "FAIL: Failed to create thread 1" << std::endl;
        return 1;
    }
    std::cout << "PASS: Created thread 1 with ID " << thread1 << std::endl;
    
    result = aurora_thread_create(&thread2, "test_thread_2");
    if (result != AURORA_OK) {
        std::cerr << "FAIL: Failed to create thread 2" << std::endl;
        return 1;
    }
    std::cout << "PASS: Created thread 2 with ID " << thread2 << std::endl;
    std::cout << std::endl;
    
    // Test 5: Get thread count
    std::cout << "Test 4: Checking thread count..." << std::endl;
    uint32_t count;
    result = aurora_thread_get_count(&count);
    if (result != AURORA_OK || count != 2) {
        std::cerr << "FAIL: Expected 2 threads, got " << count << std::endl;
        return 1;
    }
    std::cout << "PASS: Thread count is correct: " << count << std::endl;
    std::cout << std::endl;
    
    // Test 6: Demo kernel call
    std::cout << "Test 5: Testing demo kernel call..." << std::endl;
    char output[256];
    result = aurora_demo_kernel_call("Hello Aurora!", output, sizeof(output));
    if (result != AURORA_OK) {
        std::cerr << "FAIL: Demo kernel call failed" << std::endl;
        return 1;
    }
    std::cout << "PASS: Demo call succeeded" << std::endl;
    std::cout << "  Output: " << output << std::endl;
    std::cout << std::endl;
    
    // Test 7: IPC send
    std::cout << "Test 6: Testing IPC send..." << std::endl;
    aurora_message_t msg;
    msg.msg_id = 42;
    msg.timestamp = 1234567890;
    strncpy(msg.data, "Test message", sizeof(msg.data) - 1);
    msg.data_size = strlen(msg.data);
    
    result = aurora_ipc_send(thread1, &msg);
    if (result != AURORA_OK) {
        std::cerr << "FAIL: IPC send failed" << std::endl;
        return 1;
    }
    std::cout << "PASS: IPC message sent successfully" << std::endl;
    std::cout << std::endl;
    
    // Test 8: IPC receive
    std::cout << "Test 7: Testing IPC receive..." << std::endl;
    aurora_thread_id_t sender;
    aurora_message_t received;
    result = aurora_ipc_receive(&sender, &received);
    if (result != AURORA_OK) {
        std::cerr << "FAIL: IPC receive failed" << std::endl;
        return 1;
    }
    std::cout << "PASS: IPC message received successfully" << std::endl;
    std::cout << "  From: Thread " << sender << std::endl;
    std::cout << "  Message: " << received.data << std::endl;
    std::cout << std::endl;
    
    // Test 9: Destroy threads
    std::cout << "Test 8: Destroying threads..." << std::endl;
    result = aurora_thread_destroy(thread1);
    if (result != AURORA_OK) {
        std::cerr << "FAIL: Failed to destroy thread 1" << std::endl;
        return 1;
    }
    std::cout << "PASS: Destroyed thread 1" << std::endl;
    
    result = aurora_thread_destroy(thread2);
    if (result != AURORA_OK) {
        std::cerr << "FAIL: Failed to destroy thread 2" << std::endl;
        return 1;
    }
    std::cout << "PASS: Destroyed thread 2" << std::endl;
    std::cout << std::endl;
    
    // Test 10: Shutdown kernel
    std::cout << "Test 9: Shutting down kernel..." << std::endl;
    result = aurora_kernel_shutdown();
    if (result != AURORA_OK) {
        std::cerr << "FAIL: Kernel shutdown failed" << std::endl;
        return 1;
    }
    std::cout << "PASS: Kernel shut down successfully" << std::endl;
    std::cout << std::endl;
    
    std::cout << "=== All Tests Passed! ===" << std::endl;
    return 0;
}
