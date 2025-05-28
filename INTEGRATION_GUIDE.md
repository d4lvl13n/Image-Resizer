# Integration Guide for New UI Components

This guide shows how to integrate the new UI components into your existing ContentView.

## 1. Add Onboarding to App.swift

```swift
import SwiftUI

@main
struct ImageBatchWebPConverterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if !hasSeenOnboarding {
                OnboardingView(showOnboarding: .constant(true))
            } else {
                ContentView()
            }
        }
        .commands {
            AppMenu()
        }
    }
}
```

## 2. Update ContentView Structure

Add these state variables to ContentView:

```swift
@State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
@State private var showEnhancedProgress = false
@State private var currentProcessingImage = ""
@State private var processingStartTime = Date()
```

## 3. Replace Input/Output Section with Drag & Drop

Replace the current folder selection UI with:

```swift
// Input/Output section
if inputFolder == nil {
    DragDropView(inputFolder: $inputFolder)
        .opacity(showLaunchAnimation ? 0 : 1)
        .offset(y: showLaunchAnimation ? 20 : 0)
} else {
    SectionView("File Settings") {
        VStack(spacing: 16) {
            FolderSelectionRow(
                label: "Input Folder",
                folder: inputFolder,
                action: { selectFolder(forInput: true) }
            )
            
            Divider()
            
            FolderSelectionRow(
                label: "Output Folder", 
                folder: outputFolder,
                action: { selectFolder(forInput: false) }
            )
        }
    }
    .opacity(showLaunchAnimation ? 0 : 1)
    .offset(y: showLaunchAnimation ? 20 : 0)
}
```

## 4. Add Quick Actions Bar

Add this right after the HeaderView:

```swift
// Quick Actions Bar
QuickActionsBar(
    widthString: $widthString,
    isSmartMode: $isSmartMode,
    optimizationPreset: $optimizationPreset,
    onConvert: {
        Task {
            isConverting = true
            await startConversion(isFinalResult: true)
            isConverting = false
        }
    }
)
.opacity(showLaunchAnimation ? 0 : 1)
.offset(y: showLaunchAnimation ? -20 : 0)
```

## 5. Add Presets Section

Add this after the Image Settings section:

```swift
// Presets section
SectionView("Presets") {
    PresetsManagerView(
        widthString: $widthString,
        isSmartMode: $isSmartMode,
        optimizationPreset: $optimizationPreset,
        targetFileSize: $targetFileSize
    )
}
.opacity(showLaunchAnimation ? 0 : 1)
.offset(y: showLaunchAnimation ? 20 : 0)
```

## 6. Replace Progress View

During conversion, show the enhanced progress view as a sheet:

```swift
.sheet(isPresented: $showEnhancedProgress) {
    EnhancedProgressView(
        currentImage: currentProcessingImage,
        progress: progress,
        imagesProcessed: Int(progress * Double(totalImages)),
        totalImages: totalImages,
        estimatedTimeRemaining: estimateTimeRemaining(),
        currentImagePreview: currentImagePreview,
        spaceSaved: totalSpaceSaved
    )
}
```

## 7. Update startConversion Method

Add these updates to track progress:

```swift
private func startConversion(isFinalResult: Bool = true) async {
    processingStartTime = Date()
    showEnhancedProgress = true
    
    // ... existing code ...
    
    // Update current image being processed
    await MainActor.run {
        self.currentProcessingImage = filename
        self.currentImagePreview = NSImage(contentsOfFile: imgURL.path)
    }
    
    // ... rest of conversion logic ...
}

private func estimateTimeRemaining() -> TimeInterval {
    let elapsed = Date().timeIntervalSince(processingStartTime)
    let rate = progress > 0 ? elapsed / progress : 0
    return rate * (1 - progress)
}
```

## 8. Add Onboarding Sheet

Add this to ContentView:

```swift
.sheet(isPresented: $showOnboarding) {
    OnboardingView(showOnboarding: $showOnboarding)
}
```

## 9. Update Window Size

Update the frame to accommodate new UI:

```swift
.frame(minWidth: 1000, minHeight: 700)
```

## Complete Example Structure

```swift
struct ContentView: View {
    // ... existing state variables ...
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    @State private var showEnhancedProgress = false
    
    var body: some View {
        NavigationView {
            // Sidebar (existing)
            
            // Main content
            ScrollView {
                VStack(spacing: 24) {
                    HeaderView()
                    
                    QuickActionsBar(...) // New
                    
                    if inputFolder == nil {
                        DragDropView(...) // New
                    } else {
                        // Existing folder selection
                    }
                    
                    // Image settings (existing)
                    
                    PresetsManagerView(...) // New
                    
                    // Action section (existing)
                    
                    // Log section (existing)
                }
            }
        }
        .sheet(isPresented: $showOnboarding) { ... }
        .sheet(isPresented: $showEnhancedProgress) { ... }
    }
}
```

This integration maintains all existing functionality while adding the new improved UI components! 