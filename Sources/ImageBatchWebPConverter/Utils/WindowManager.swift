import AppKit
import SwiftUI

public class WindowManager: ObservableObject {
    public static let shared = WindowManager()
    
    @Published public var comparisonWindow: NSWindow?
    
    private let defaults = UserDefaults.standard
    private let comparisonWindowFrameKey = "comparisonWindowFrame"
    
    private init() {}
    
    public func saveWindowState() {
        guard let window = comparisonWindow else { return }
        let frameString = NSStringFromRect(window.frame)
        defaults.set(frameString, forKey: comparisonWindowFrameKey)
    }
    
    public func restoreWindowState(for window: NSWindow) {
        if let frameString = defaults.string(forKey: comparisonWindowFrameKey),
           !frameString.isEmpty {
            let frame = NSRectFromString(frameString)
            // Validate that the frame is on screen
            if NSScreen.screens.contains(where: { $0.frame.intersects(frame) }) {
                window.setFrame(frame, display: true)
            }
        }
    }
    
    public func createComparisonWindow(content: some View) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1400, height: 900),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Image Comparison"
        window.contentView = NSHostingView(rootView: content)
        
        // Restore previous position/size or use default
        if let frameString = defaults.string(forKey: comparisonWindowFrameKey),
           !frameString.isEmpty {
            let frame = NSRectFromString(frameString)
            // Only restore if the frame is on screen
            if NSScreen.screens.contains(where: { $0.frame.intersects(frame) }) {
                window.setFrame(frame, display: false)
            } else {
                setDefaultPosition(for: window)
            }
        } else {
            setDefaultPosition(for: window)
        }
        
        // Save window position/size when moved or resized
        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.saveWindowState()
        }
        
        NotificationCenter.default.addObserver(
            forName: NSWindow.didResizeNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.saveWindowState()
        }
        
        comparisonWindow = window
        return window
    }
    
    private func setDefaultPosition(for window: NSWindow) {
        window.center()
        if let mainWindow = NSApp.mainWindow {
            let mainFrame = mainWindow.frame
            var newFrame = window.frame
            newFrame.origin.x = mainFrame.maxX + 20
            newFrame.origin.y = mainFrame.origin.y
            window.setFrame(newFrame, display: false)
        }
    }
    
    public func restoreDefaultLayout() {
        guard let window = comparisonWindow,
              let mainWindow = NSApp.mainWindow else { return }
        
        let mainFrame = mainWindow.frame
        var newFrame = NSRect(x: 0, y: 0, width: 1400, height: 900)
        newFrame.origin.x = mainFrame.maxX + 20
        newFrame.origin.y = mainFrame.origin.y
        
        window.setFrame(newFrame, display: true, animate: true)
        saveWindowState()
    }
    
    public func showComparisonWindow() {
        comparisonWindow?.makeKeyAndOrderFront(nil)
    }
}