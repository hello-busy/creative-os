import SwiftUI
import AuroraBridge

struct ContentView: View {
    @EnvironmentObject var kernelManager: KernelManager
    @State private var threadName: String = ""
    @State private var demoInput: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Main content
            ScrollView {
                VStack(spacing: 20) {
                    // Kernel Status Card
                    statusCard
                    
                    // Demo Call Card
                    demoCard
                    
                    // Thread Management Card
                    threadManagementCard
                    
                    // Active Threads List
                    if !kernelManager.threads.isEmpty {
                        threadsListCard
                    }
                    
                    // Error Display
                    if let error = kernelManager.lastError {
                        errorCard(error)
                    }
                }
                .padding()
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        HStack {
            Image(systemName: "gearshape.2.fill")
                .font(.title)
                .foregroundColor(.blue)
            
            Text("Aurora OS")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            statusBadge
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(kernelManager.isInitialized ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            Text(kernelManager.isInitialized ? "Running" : "Stopped")
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    
    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Kernel Status")
                    .font(.headline)
                Spacer()
                Button("Refresh") {
                    kernelManager.updateKernelStatus()
                }
                .buttonStyle(.bordered)
            }
            
            if let status = kernelManager.kernelStatus {
                VStack(spacing: 8) {
                    StatusRow(label: "Version", value: status.version)
                    StatusRow(label: "Uptime", value: "\(status.uptime) ms")
                    StatusRow(label: "Active Threads", value: "\(status.activeThreads)")
                }
            } else {
                Text("Kernel not initialized")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
    
    private var demoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "play.circle.fill")
                    .foregroundColor(.green)
                Text("Demo Kernel Call")
                    .font(.headline)
            }
            
            TextField("Enter demo input...", text: $demoInput)
                .textFieldStyle(.roundedBorder)
            
            Button("Execute Kernel Call") {
                kernelManager.runDemoCall(input: demoInput)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!kernelManager.isInitialized || demoInput.isEmpty)
            
            if !kernelManager.demoOutput.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Output:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(kernelManager.demoOutput)
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
    
    private var threadManagementCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "cpu")
                    .foregroundColor(.purple)
                Text("Thread Management")
                    .font(.headline)
            }
            
            HStack {
                TextField("Thread name...", text: $threadName)
                    .textFieldStyle(.roundedBorder)
                
                Button("Create Thread") {
                    kernelManager.createThread(name: threadName)
                    threadName = ""
                }
                .buttonStyle(.borderedProminent)
                .disabled(!kernelManager.isInitialized || threadName.isEmpty)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
    
    private var threadsListCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.orange)
                Text("Active Threads")
                    .font(.headline)
                Spacer()
                Text("\(kernelManager.threads.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
            }
            
            ForEach(kernelManager.threads) { thread in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(thread.name)
                            .font(.body)
                            .fontWeight(.medium)
                        Text("ID: \(thread.id)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        kernelManager.destroyThread(id: thread.id)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.borderless)
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
    
    private func errorCard(_ error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(error)
                .foregroundColor(.red)
            Spacer()
            Button("Dismiss") {
                kernelManager.lastError = nil
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
    }
}

struct StatusRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .font(.system(.body, design: .monospaced))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(KernelManager())
    }
}
