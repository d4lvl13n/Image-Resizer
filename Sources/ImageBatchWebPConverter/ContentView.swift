//
//  ContentView.swift
//  ImageBatchWebPConverter
//
//  Created by Claude and Dam 2024-12-25.
//

import SwiftUI
import AppKit
import Foundation

struct ContentView: View {
    
    @State private var inputFolder: URL?       = nil
    @State private var outputFolder: URL?      = nil
    @State private var widthString: String     = "1600" // default width
    @State private var isConverting: Bool      = false
    @State private var statusMessage: String   = ""
    @State private var progress: Double = 0
    @State private var isSmartMode: Bool = false
    @State private var targetFileSize: Double = 500 // KB
    @State private var optimizationPreset: OptimizationPreset = .balanced
    @State private var showComparison: Bool = false
    @State private var currentComparison: (original: NSImage, optimized: NSImage)? = nil
    @State private var currentAnalysis: (type: ImageComparisonView.ImageContentType, quality: Double)? = nil
    @State private var currentSizes: (original: Int64, optimized: Int64)? = nil
    @State private var processedImages: [(
        original: NSImage,
        optimized: NSImage,
        originalSize: Int64,
        optimizedSize: Int64,
        quality: Double,
        contentType: ImageComparisonView.ImageContentType
    )] = []
    @State private var showLaunchAnimation = true
    @State private var showSuccessPopup = false
    @State private var totalSpaceSaved: Int64 = 0
    
    var body: some View {
        NavigationView {
            // Sidebar
            VStack(spacing: 16) {
                // History header
                HStack {
                    Label("History", systemImage: "clock.fill")
                        .font(.headline)
                    Spacer()
                    Button(action: { processedImages.removeAll() }) {
                        Label("Clear", systemImage: "trash")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .opacity(processedImages.isEmpty ? 0.5 : 1)
                    .disabled(processedImages.isEmpty)
                }
                .padding()
                
                // History list
                List {
                    if processedImages.isEmpty {
                        Text("No processed images")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(processedImages.indices, id: \.self) { index in
                            HistoryItemView(
                                image: processedImages[index],
                                index: index,
                                action: { showComparison(for: index) }
                            )
                        }
                    }
                }
                .listStyle(.plain)
            }
            .frame(minWidth: 250, maxWidth: 300)
            .background(Color(NSColor.controlBackgroundColor))
            
            // Main content
            ScrollView {
                VStack(spacing: 24) {
                    HeaderView()
                        .scaleEffect(showLaunchAnimation ? 0.8 : 1)
                        .opacity(showLaunchAnimation ? 0 : 1)
                        .offset(y: showLaunchAnimation ? -20 : 0)
                    
                    // Input/Output section
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
                    
                    // Image settings section
                    SectionView("Image Settings") {
                        VStack(spacing: 20) {
                            // Width control
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Target Width")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("1600", text: $widthString)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 100)
                                }
                                
                                Spacer()
                            }
                            
                            Divider()
                            
                            // Smart optimization
                            SmartOptimizationView(
                                isEnabled: $isSmartMode,
                                preset: $optimizationPreset,
                                targetFileSize: $targetFileSize
                            )
                        }
                    }
                    .opacity(showLaunchAnimation ? 0 : 1)
                    .offset(y: showLaunchAnimation ? 20 : 0)
                    
                    // Action section
                    VStack(spacing: 16) {
                        // Convert button
                        Button(action: {
                            Task {
                                isConverting = true
                                await startConversion()
                                isConverting = false
                            }
                        }) {
                            if isConverting {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .frame(width: 16, height: 16)
                            } else {
                                Image(systemName: "wand.and.stars")
                            }
                            Text(isConverting ? "Converting..." : "Convert Images")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(isConverting || inputFolder == nil || outputFolder == nil)
                        .frame(maxWidth: .infinity)
                        
                        // Progress bar
                        if isConverting {
                            ProgressView(value: progress)
                                .progressViewStyle(.linear)
                        }
                    }
                    .opacity(showLaunchAnimation ? 0 : 1)
                    .offset(y: showLaunchAnimation ? 20 : 0)
                    
                    // Log section
                    SectionView("Processing Log") {
                        ScrollView {
                            Text(statusMessage)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 200)
                    }
                    .opacity(showLaunchAnimation ? 0 : 1)
                    .offset(y: showLaunchAnimation ? 20 : 0)
                }
                .padding()
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(minWidth: 900, minHeight: 600)
        .sheet(isPresented: $showComparison) {
            if let comparison = currentComparison,
               let analysis = currentAnalysis,
               let sizes = currentSizes {
                ImageComparisonView(
                    originalImage: comparison.original,
                    optimizedImage: comparison.optimized,
                    originalSize: sizes.original,
                    optimizedSize: sizes.optimized,
                    qualityScore: analysis.quality,
                    contentType: analysis.type
                )
            }
        }
        .overlay {
            if showSuccessPopup {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .overlay {
                        SuccessPopup(
                            imagesCount: processedImages.count,
                            totalSaved: totalSpaceSaved,
                            isPresented: $showSuccessPopup
                        )
                    }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showLaunchAnimation = false
            }
        }
    }
    
    // Add method to show comparison for historical images
    private func showComparison(for index: Int) {
        let image = processedImages[index]
        currentComparison = (original: image.original, optimized: image.optimized)
        currentAnalysis = (type: image.contentType, quality: image.quality)
        currentSizes = (original: image.originalSize, optimized: image.optimizedSize)
        showComparison = true
    }
    
    // Update the optimization completion to store processed images
    private func storeProcessedImage(original: NSImage, optimized: NSImage, originalSize: Int64, optimizedSize: Int64, quality: Double, contentType: ImageComparisonView.ImageContentType) {
        processedImages.append((
            original: original,
            optimized: optimized,
            originalSize: originalSize,
            optimizedSize: optimizedSize,
            quality: quality,
            contentType: contentType
        ))
    }
    
    // MARK: - Folder Selection
    
    private func selectFolder(forInput: Bool) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        
        panel.begin { response in
            guard response == .OK else { return }
            if forInput {
                self.inputFolder = panel.url
            } else {
                self.outputFolder = panel.url
            }
        }
    }
    
    // MARK: - Conversion
    
    private func startConversion() async {
        progress = 0
        guard let inFolder = inputFolder,
              let outFolder = outputFolder else {
            return
        }
        
        // Make sure the user typed a valid integer
        guard let targetWidth = Int(widthString), targetWidth > 0 else {
            statusMessage.append("[ERROR] Invalid width: \(widthString)\n")
            return
        }
        
        guard let cwebpPath = findCWebP() else {
            statusMessage.append("[ERROR] cwebp not found. The bundled converter is missing or inaccessible.\n")
            return
        }
        
        isConverting = true
        statusMessage = "Starting conversion...\n"
        
        do {
            // 1) Get all image files in input folder
            let fileManager = FileManager.default
            let items = try fileManager.contentsOfDirectory(at: inFolder,
                                                          includingPropertiesForKeys: nil,
                                                          options: [.skipsHiddenFiles])
            
            // Filter out common image extensions
            let imageExtensions = ["jpg", "jpeg", "png", "bmp", "tif", "tiff"]
            let images = items.filter { url in
                imageExtensions.contains(url.pathExtension.lowercased())
            }
            
            if images.isEmpty {
                await MainActor.run {
                    self.statusMessage.append("No images found in folder.\n")
                    self.isConverting = false
                }
                return
            }
            
            // 2) Create output folder if not existing
            if !fileManager.fileExists(atPath: outFolder.path) {
                try fileManager.createDirectory(at: outFolder, 
                                                withIntermediateDirectories: true)
            }
            
            // 3) Process each image
            for (index, imgURL) in images.enumerated() {
                let filename = imgURL.lastPathComponent
                // remove extension
                let baseName = filename.split(separator: ".").dropLast().joined(separator: ".")
                
                let outWebpURL = outFolder.appendingPathComponent("\(baseName).webp")
                
                // a) Create a temporary file for resized JPEG
                //    because sips can’t directly output .webp
                let tmpResizedURL = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingPathComponent("\(baseName)_temp_\(UUID().uuidString).jpg")
                
                // b) Resize with sips
                let resizeCmd = """
                /usr/bin/sips --resampleWidth \(targetWidth) "\(imgURL.path)" --out "\(tmpResizedURL.path)"
                """
                let resizeResult = shell(resizeCmd)
                
                if isSmartMode {
                    let targetSize = optimizationPreset == .custom ? targetFileSize : optimizationPreset.targetSize
                    let result = await optimizeImage(
                        inputPath: tmpResizedURL.path,
                        outputPath: outWebpURL.path,
                        targetSize: targetSize,
                        cwebpPath: cwebpPath
                    )
                    
                    await MainActor.run {
                        self.statusMessage.append("""
                            [\(index+1)/\(images.count)] Optimized: \(filename)
                            • Quality: \(result.quality)
                            • Size: \(result.size.formatFileSize())
                            
                            """)
                        self.progress = Double(index + 1) / Double(images.count)
                    }
                } else {
                    // Original conversion code
                    let webpCmd = """
                    \(cwebpPath) -q 80 "\(tmpResizedURL.path)" -o "\(outWebpURL.path)"
                    """
                    let webpResult = shell(webpCmd)
                    // Original status update
                    await MainActor.run {
                        self.statusMessage.append("""
                            [\(index+1)/\(images.count)] Processed: \(filename) -> \(outWebpURL.lastPathComponent)\n
                            \(resizeResult.isEmpty ? "" : " sips output: \(resizeResult)\n")
                            \(webpResult.isEmpty ? "" : " cwebp output: \(webpResult)\n")
                            """)
                        self.progress = Double(index + 1) / Double(images.count)
                    }
                }
                
                // d) Remove temporary file
                try? fileManager.removeItem(at: tmpResizedURL)
            }
            
            // Done
            await MainActor.run {
                self.statusMessage.append("All images processed!\n")
                self.isConverting = false
            }
            
        } catch {
            await MainActor.run {
                self.statusMessage.append("Error: \(error.localizedDescription)\n")
                self.isConverting = false
            }
        }
        
        // After conversion is complete:
        let savedSpace = processedImages.reduce(Int64(0)) { total, image in
            total + (image.originalSize - image.optimizedSize)
        }
        
        await MainActor.run {
            self.totalSpaceSaved = savedSpace
            self.showSuccessPopup = true
        }
    }
    
    // MARK: - Shell Helper
    
    /// Executes a shell command and returns its output (stdout + stderr).
    private func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()

        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
        } catch {
            return "Failed to run command: \(error.localizedDescription)"
        }
        
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return ""
        }
        return output
    }
    
    private func findCWebP() -> String? {
        // First try bundled cwebp
        let bundledPath = Bundle.main.path(forResource: "cwebp", ofType: nil)
        if let bundledPath = bundledPath {
            // Make sure it's executable
            _ = shell("chmod +x '\(bundledPath)'")
            return bundledPath
        }
        
        // Fallback to system paths
        let possiblePaths = [
            "/usr/local/bin/cwebp",
            "/opt/homebrew/bin/cwebp",
            "/usr/bin/cwebp"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        // Try to find it in PATH
        let whichResult = shell("which cwebp")
        if !whichResult.isEmpty && FileManager.default.fileExists(atPath: whichResult) {
            return whichResult
        }
        
        return nil
    }
    
    private func optimizeImage(inputPath: String, outputPath: String, targetSize: Double, cwebpPath: String) async -> (quality: Int, size: Double) {
        // Analyze content type first
        let contentType = try? await ImageAnalyzer.analyzeImage(URL(fileURLWithPath: inputPath))
        
        // Adjust quality settings based on content type
        let baseQuality: Int
        switch contentType {
        case .screenshot, .text:
            baseQuality = 90 // Higher quality for text
        case .artwork:
            baseQuality = 85
        default:
            baseQuality = 80
        }
        
        // Use baseQuality as the starting point
        var minQ = max(0, baseQuality - 20)
        var maxQ = min(100, baseQuality + 10)
        var bestQ = baseQuality
        var bestSize = Double.infinity
        var attempts = 0
        
        // Binary search for optimal quality
        while maxQ - minQ > 5 && attempts < 8 {
            attempts += 1
            let q = (minQ + maxQ) / 2
            let tempOutput = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("webp")
                .path
            
            // Add underscore to handle the warning
            _ = shell("\(cwebpPath) -q \(q) '\(inputPath)' -o '\(tempOutput)'")
            
            if let attributes = try? FileManager.default.attributesOfItem(atPath: tempOutput),
               let fileSize = attributes[FileAttributeKey.size] as? Double {
                let sizeKB = fileSize / 1024
                
                // Update best result if this is closer to target
                if abs(sizeKB - targetSize) < abs(bestSize - targetSize) {
                    bestQ = q
                    bestSize = sizeKB
                }
                
                // Adjust search range
                if sizeKB > targetSize {
                    maxQ = q - 1
                } else {
                    minQ = q + 1
                }
            }
            
            try? FileManager.default.removeItem(atPath: tempOutput)
        }
        
        // Add underscore here too
        _ = shell("\(cwebpPath) -q \(bestQ) '\(inputPath)' -o '\(outputPath)'")
        
        // After successful conversion, show comparison
        if let originalImage = NSImage(contentsOfFile: inputPath),
           let optimizedImage = NSImage(contentsOfFile: outputPath) {
            let originalSize = (try? FileManager.default.attributesOfItem(atPath: inputPath)[FileAttributeKey.size] as? Int64) ?? 0
            let optimizedSize = (try? FileManager.default.attributesOfItem(atPath: outputPath)[FileAttributeKey.size] as? Int64) ?? 0
            
            await MainActor.run {
                self.currentComparison = (original: originalImage, optimized: optimizedImage)
                self.currentAnalysis = (type: contentType ?? .photo, 
                                      quality: ImageAnalyzer.calculateQualityScore(
                                        original: originalImage,
                                        optimized: optimizedImage))
                self.currentSizes = (original: originalSize, optimized: optimizedSize)
                self.showComparison = true
                
                // Add this line to store the processed image
                self.storeProcessedImage(
                    original: originalImage,
                    optimized: optimizedImage,
                    originalSize: originalSize,
                    optimizedSize: optimizedSize,
                    quality: ImageAnalyzer.calculateQualityScore(
                        original: originalImage,
                        optimized: optimizedImage),
                    contentType: contentType ?? .photo
                )
            }
        }
        
        return (bestQ, bestSize)
    }
    
    private func trackOptimizationResults(_ results: [(quality: Int, size: Double)]) async {
        let avgQuality = results.map { $0.quality }.reduce(0, +) / results.count
        let avgCompression = results.map { $0.size }.reduce(0, +) / Double(results.count)
        
        await MainActor.run {
            self.statusMessage.append("""
                
                Optimization Summary:
                • Average Quality: \(avgQuality)
                • Average Size: \(avgCompression.formatFileSize())
                • Images Processed: \(results.count)
                
                """)
        }
    }
    
}

// Supporting views
struct FolderSelectionRow: View {
    let label: String
    let folder: URL?
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(label)
                    .fontWeight(.medium)
                if let folder = folder {
                    Text(folder.lastPathComponent)
                        .foregroundColor(.blue)
                } else {
                    Text("No folder selected")
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button("Choose...", action: action)
                .buttonStyle(.bordered)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// First, create a new view for the header
struct HeaderView: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.stack.fill")
                .font(.system(size: 36))
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("WebP Batch Converter")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("Convert and optimize your images")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom, 8)
    }
}

// Create a styled section view
struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            content
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// Add a new view for history items
struct HistoryItemView: View {
    let image: (
        original: NSImage,
        optimized: NSImage,
        originalSize: Int64,
        optimizedSize: Int64,
        quality: Double,
        contentType: ImageComparisonView.ImageContentType
    )
    let index: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Thumbnail
                Image(nsImage: image.optimized)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text("Image \(index + 1)")
                        .fontWeight(.medium)
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption2)
                        Text("\(Int64.calculateReduction(original: image.originalSize, optimized: image.optimizedSize))%")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}