import SwiftUI

@main
struct ImageBatchWebPConverterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if !hasSeenOnboarding {
                OnboardingView()
            } else {
                ContentView()
            }
        }
        .commands {
            AppMenu()
        }
    }
} 