import SwiftUI
import AuroraBridge

@main
struct AuroraUIApp: App {
    @StateObject private var kernelManager = KernelManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(kernelManager)
                .frame(minWidth: 600, minHeight: 400)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Aurora OS") {
                    // Show about panel
                }
            }
        }
    }
}
