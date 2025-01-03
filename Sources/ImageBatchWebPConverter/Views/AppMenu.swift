import SwiftUI
import Utils  // Add this import to access WindowManager

struct AppMenu: Commands {
    @ObservedObject private var windowManager = WindowManager.shared
    
    var body: some Commands {
        CommandGroup(after: .windowSize) {
            Button("Show Comparison Window") {
                windowManager.showComparisonWindow()
            }
            .keyboardShortcut("1", modifiers: [.command])
            
            Button("Restore Default Layout") {
                windowManager.restoreDefaultLayout()
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])
            
            Divider()
        }
    }
}