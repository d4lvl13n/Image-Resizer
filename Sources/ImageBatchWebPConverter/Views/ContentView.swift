import SwiftUI
import AppKit
import Models
import Utils
import Components

@MainActor
struct ContentView: View {
    
    @State private var inputFolder: URL?       = nil
    @State private var selectedFiles: [URL]   = []  // New: track individual files
    @State private var outputFolder: URL?      = nil
    @State private var widthString: String     = "1600" // default width
    @State private var isConverting: Bool      = false
    @State private var statusMessage: String   = ""
    @State private var progress: Double = 0
    @State private var isSmartMode: Bool = true  // AI ON by default
    @State private var targetFileSize: Double = 500 // KB
    @State private var optimizationPreset: OptimizationPreset = .balanced
    @State private var showComparison: Bool = false
    @State private var currentComparison: (original: NSImage, optimized: NSImage)? = nil
    @State private var currentAnalysis: (type: ImageContentType, quality: Float)? = nil
    @State private var currentSizes: (original: Int64, optimized: Int64)? = nil
    @State private var processedImages: [(
        original: NSImage,
        optimized: NSImage,
        originalSize: Int64,
        optimizedSize: Int64,
        quality: Float,
        contentType: ImageContentType
    )] = []
    @State private var showLaunchAnimation = true
    @State private var totalSpaceSaved: Int64 = 0
    @State private var showSuccessPopup = false
    @State private var comparisonMode: ComparisonMode = .sideBySide
    @StateObject private var windowManager = WindowManager.shared
    @State private var showProMode = false  // Pro mode for advanced settings
    @State private var hoveredCard: String? = nil
    
    // Computed property to determine if we're in file mode or folder mode
    private var isFileMode: Bool {
        !selectedFiles.isEmpty
    }
    
    private var hasInput: Bool {
        inputFolder != nil || !selectedFiles.isEmpty
    }
    
    // Helper to get a display name for the input
    private var inputDisplayName: String {
        if isFileMode {
            if selectedFiles.count == 1 {
                return selectedFiles.first?.lastPathComponent ?? "Unknown file"
            } else {
                return "\(selectedFiles.count) files"
            }
        } else {
            return inputFolder?.lastPathComponent ?? "No folder selected"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [
                        Color(NSColor.windowBackgroundColor),
                        Color(NSColor.windowBackgroundColor).opacity(0.95),
                        Color(NSColor.controlBackgroundColor).opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if hasInput {
                    // Processing Interface
                    processingInterface
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    // Hero Landing Interface
                    heroInterface
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                }
                
                // Floating History Panel (always visible if has history)
                if !processedImages.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            historyPanel
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            Spacer()
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("")
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                showLaunchAnimation = false
            }
        }
        .onChange(of: showComparison) { newValue in
            if newValue, 
               let comparison = currentComparison,
               let sizes = currentSizes {
                let window = windowManager.createComparisonWindow(content: 
                    ComparisonImagesView(
                        originalImage: comparison.original,
                        optimizedImage: comparison.optimized,
                        originalSize: sizes.original,
                        optimizedSize: sizes.optimized,
                        zoomLevel: 1.0,
                        processedImages: processedImages,
                        selectedMode: $comparisonMode,
                        onImageSelected: { index in
                            let image = processedImages[index]
                            currentComparison = (image.original, image.optimized)
                            currentSizes = (image.originalSize, image.optimizedSize)
                            currentAnalysis = (image.contentType, image.quality)
                        }
                    )
                )
                window.makeKeyAndOrderFront(nil)
            }
        }
        .sheet(isPresented: $showSuccessPopup) {
            SuccessPopup(
                imagesCount: processedImages.count,
                totalSaved: totalSpaceSaved,
                isPresented: $showSuccessPopup
            )
        }
    }
    
    // MARK: - Hero Interface
    private var heroInterface: some View {
        VStack(spacing: 0) {
            // Hero Header
            VStack(spacing: 24) {
                // App Icon & Title
                HStack(spacing: 16) {
                    if #available(macOS 14.0, *) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(.blue.gradient)
                            .symbolEffect(.variableColor.iterative, value: showLaunchAnimation)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(.blue.gradient)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("WebP Optimizer")
                            .font(.system(size: 48, weight: .light, design: .default))
                        Text("AI-powered image optimization")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                }
                .opacity(showLaunchAnimation ? 0 : 1)
                .offset(y: showLaunchAnimation ? -30 : 0)
                
                // Stats Cards
                HStack(spacing: 20) {
                    statsCard("Processed", "\(processedImages.count)", "photo.stack")
                    statsCard("Saved", Double(totalSpaceSaved).formatFileSize(), "arrow.down.circle")
                    statsCard("Quality", "AI Optimized", "sparkles")
                }
                .opacity(showLaunchAnimation ? 0 : 1)
                .offset(y: showLaunchAnimation ? 20 : 0)
            }
            .padding(.top, 60)
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Main Drop Zone
            modernDragDropZone
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: - Processing Interface
    private var processingInterface: some View {
        VStack(spacing: 24) {
            // Header with selected files
            selectedFilesHeader
                .padding(.horizontal, 40)
                .padding(.top, 30)
            
            // AI Optimization Panel
            aiOptimizationPanel
                .padding(.horizontal, 40)
            
            // Action Area
            actionArea
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Processing Log (if converting)
            if isConverting || !statusMessage.isEmpty {
                processingLog
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
            }
        }
    }
    
    // MARK: - Components
    private func statsCard(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .frame(width: 120, height: 100)
        .background(
            if #available(macOS 12.0, *) {
                .regularMaterial
            } else {
                Color(NSColor.controlBackgroundColor)
            }, in: RoundedRectangle(cornerRadius: 12)
        )
    }
    
    private var modernDragDropZone: some View {
        DragDropView(inputFolder: $inputFolder, selectedFiles: $selectedFiles)
            .scaleEffect(showLaunchAnimation ? 0.9 : 1.0)
            .opacity(showLaunchAnimation ? 0 : 1)
            .onChange(of: inputFolder) { newValue in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    if let input = newValue, outputFolder == nil {
                        outputFolder = input.deletingLastPathComponent()
                            .appendingPathComponent("\(input.lastPathComponent)-optimized")
                    }
                }
            }
            .onChange(of: selectedFiles) { newValue in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    if !newValue.isEmpty, outputFolder == nil {
                        if let firstFile = newValue.first {
                            outputFolder = firstFile.deletingLastPathComponent()
                                .appendingPathComponent("optimized-images")
                        }
                    }
                }
            }
    }
    
    private var selectedFilesHeader: some View {
        HStack {
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    inputFolder = nil
                    selectedFiles = []
                    outputFolder = nil
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Ready to Optimize")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                HStack(spacing: 8) {
                    Image(systemName: isFileMode ? "doc.on.doc.fill" : "folder.fill")
                        .foregroundColor(.blue)
                    Text(inputDisplayName)
                        .foregroundColor(.secondary)
                }
                .font(.title3)
            }
            
            Spacer()
        }
    }
    
    private var aiOptimizationPanel: some View {
        VStack(spacing: 16) {
            // AI Status
            HStack {
                HStack(spacing: 12) {
                    if #available(macOS 14.0, *) {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundStyle(.blue.gradient)
                            .symbolEffect(.variableColor.iterative.reversing, value: isSmartMode)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundStyle(.blue.gradient)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI Optimization")
                            .font(.title)
                        Text("\(optimizationPreset.name) preset • Smart quality detection")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Preset Selector
                Menu {
                    ForEach(OptimizationPreset.allCases, id: \.self) { preset in
                        Button(preset.name) {
                            optimizationPreset = preset
                        }
                    }
                } label: {
                    Text(optimizationPreset.name)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            if #available(macOS 12.0, *) {
                                .regularMaterial
                            } else {
                                Color(NSColor.controlBackgroundColor)
                            }, in: Capsule()
                        )
                }
                .menuStyle(.borderlessButton)
            }
            
            // Pro Mode Toggle
            DisclosureGroup("Pro Settings", isExpanded: $showProMode) {
                VStack(spacing: 12) {
                    HStack {
                        Text("Target Width")
                            .font(.callout)
                        Spacer()
                        TextField("1600", text: $widthString)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                        Text("px")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    
                    if optimizationPreset == .custom {
                        HStack {
                            Text("Target Size")
                                .font(.callout)
                            Spacer()
                            TextField("500", value: $targetFileSize, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Text("KB")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .font(.title3)
        }
        .padding(20)
        .background(
            if #available(macOS 12.0, *) {
                .regularMaterial
            } else {
                Color(NSColor.controlBackgroundColor)
            }, in: RoundedRectangle(cornerRadius: 16)
        )
    }
    
    private var actionArea: some View {
        Button(action: {
            Task {
                isConverting = true
                await startConversion(isFinalResult: true)
                isConverting = false
            }
        }) {
            HStack(spacing: 16) {
                if isConverting {
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "wand.and.stars")
                        .font(.title)
                }
                
                Text(isConverting ? "Optimizing with AI..." : "Start Optimization")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        }
        .background {
            if isConverting {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        if #available(macOS 12.0, *) {
                            .regularMaterial
                        } else {
                            Color(NSColor.controlBackgroundColor)
                        }
                    )
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        }
        .foregroundColor(isConverting ? .primary : .white)
        .disabled(isConverting)
        .buttonStyle(.plain)
        .scaleEffect(isConverting ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isConverting)
    }
    
    private var processingLog: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Processing Log")
                    .font(.title2)
                Spacer()
                if isConverting {
                    ProgressView(value: progress)
                        .frame(width: 200)
                }
            }
            
            ScrollView {
                Text(statusMessage)
                    .font(.system(.caption, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 120)
            .padding(12)
            .background(
                if #available(macOS 12.0, *) {
                    .regularMaterial
                } else {
                    Color(NSColor.controlBackgroundColor)
                }, in: RoundedRectangle(cornerRadius: 8)
            )
        }
    }
    
    private var historyPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent")
                    .font(.title2)
                Spacer()
                Button("View All") {
                    // Could open a dedicated history window
                }
                .font(.subheadline)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(processedImages.prefix(5).indices, id: \.self) { index in
                        historyThumbnail(for: index)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(16)
        .frame(width: 320)
        .background(
            if #available(macOS 12.0, *) {
                .ultraThinMaterial
            } else {
                Color(NSColor.windowBackgroundColor)
            }, in: RoundedRectangle(cornerRadius: 16)
        )
    }
    
    private func historyThumbnail(for index: Int) -> some View {
        let image = processedImages[index]
        
        return Button(action: { showComparison(for: index) }) {
            VStack(spacing: 6) {
                Image(nsImage: image.optimized)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text("\(Int64.calculateReduction(original: image.originalSize, optimized: image.optimizedSize))%")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(hoveredCard == "history-\(index)" ? 1.05 : 1.0)
        .onHover { isHovered in
            withAnimation(.easeInOut(duration: 0.2)) {
                hoveredCard = isHovered ? "history-\(index)" : nil
            }
        }
    }
    
    // MARK: - Quick Actions - REMOVED
    // Quick actions have been removed to simplify the interface
    // Users should use drag and drop or click on the drop zone to open finder
    
    // MARK: - Conversion
    
    private func startConversion(isFinalResult: Bool = true) async {
        progress = 0
        
        // Create and show comparison window at the start
        await MainActor.run {
            if windowManager.comparisonWindow == nil {
                let window = windowManager.createComparisonWindow(content: 
                    ComparisonImagesView(
                        originalImage: NSImage(),  // Will be updated with first image
                        optimizedImage: NSImage(),
                        originalSize: 0,
                        optimizedSize: 0,
                        zoomLevel: 1.0,
                        processedImages: processedImages,
                        selectedMode: $comparisonMode,
                        onImageSelected: { index in
                            let image = processedImages[index]
                            currentComparison = (image.original, image.optimized)
                            currentSizes = (image.originalSize, image.optimizedSize)
                            currentAnalysis = (image.contentType, image.quality)
                        }
                    )
                )
                window.makeKeyAndOrderFront(nil)
            }
        }
        
        // Determine images to process
        let imagesToProcess: [URL]
        let baseOutputFolder: URL
        
        if isFileMode {
            // File mode: process only selected files
            imagesToProcess = selectedFiles
            
            // Create output folder based on first file's location
            if let firstFile = selectedFiles.first {
                baseOutputFolder = outputFolder ?? firstFile.deletingLastPathComponent()
                    .appendingPathComponent("optimized-images")
            } else {
                await MainActor.run {
                    self.statusMessage.append("[ERROR] No files selected.\n")
                    self.isConverting = false
                }
                return
            }
        } else {
            // Folder mode: process all images in the folder
            guard let inFolder = inputFolder else {
                await MainActor.run {
                    self.statusMessage.append("[ERROR] No input folder selected.\n")
                    self.isConverting = false
                }
                return
            }
            
            // Auto-create output folder if not set
            baseOutputFolder = outputFolder ?? inFolder.deletingLastPathComponent()
                .appendingPathComponent("\(inFolder.lastPathComponent)-optimized")
            
            // Get all image files in input folder
            do {
                let fileManager = FileManager.default
                let items = try fileManager.contentsOfDirectory(at: inFolder,
                                                              includingPropertiesForKeys: nil,
                                                              options: [.skipsHiddenFiles])
                
                // Filter out common image extensions
                let imageExtensions = ["jpg", "jpeg", "png", "bmp", "tif", "tiff"]
                imagesToProcess = items.filter { url in
                    imageExtensions.contains(url.pathExtension.lowercased())
                }
            } catch {
                await MainActor.run {
                    self.statusMessage.append("Error reading folder: \(error.localizedDescription)\n")
                    self.isConverting = false
                }
                return
            }
        }
        
        if imagesToProcess.isEmpty {
            await MainActor.run {
                self.statusMessage.append("No images found to process.\n")
                self.isConverting = false
            }
            return
        }
        
        // Make sure the user typed a valid integer
        guard let targetWidth = Int(widthString), targetWidth > 0 else {
            await MainActor.run {
                self.statusMessage.append("[ERROR] Invalid width: \(widthString)\n")
                self.isConverting = false
            }
            return
        }
        
        guard let cwebpPath = findCWebP() else {
            await MainActor.run {
                self.statusMessage.append("[ERROR] cwebp not found. The bundled converter is missing or inaccessible.\n")
                self.isConverting = false
            }
            return
        }
        
        isConverting = true
        await MainActor.run {
            self.statusMessage = "🚀 Starting AI-powered optimization...\n"
        }
        
        var results: [(quality: Int, size: Double)] = []
        var savedSpace: Int64 = 0
        
        do {
            // Create output folder if not existing
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: baseOutputFolder.path) {
                try fileManager.createDirectory(at: baseOutputFolder, 
                                                withIntermediateDirectories: true)
            }
            
            // Process each image
            for (index, imgURL) in imagesToProcess.enumerated() {
                let filename = imgURL.lastPathComponent
                // remove extension
                let baseName = filename.split(separator: ".").dropLast().joined(separator: ".")
                
                let outWebpURL = baseOutputFolder.appendingPathComponent("\(baseName).webp")
                
                // a) Create a temporary file for resized JPEG
                //    because sips can't directly output .webp
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
                    
                    results.append(result)
                    
                    // Calculate saved space
                    if let originalSize = try? FileManager.default.attributesOfItem(atPath: imgURL.path)[FileAttributeKey.size] as? Int64,
                       let optimizedSize = try? FileManager.default.attributesOfItem(atPath: outWebpURL.path)[FileAttributeKey.size] as? Int64 {
                        savedSpace += (originalSize - optimizedSize)
                        
                        await MainActor.run {
                            self.statusMessage.append("""
                                ✅ [\(index+1)/\(imagesToProcess.count)] \(filename)
                                • AI Quality: \(result.quality)
                                • Saved: \(Int64.calculateReduction(original: originalSize, optimized: optimizedSize))%
                                
                                """)
                            self.progress = Double(index + 1) / Double(imagesToProcess.count)
                        }
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
                            [\(index+1)/\(imagesToProcess.count)] Processed: \(filename) -> \(outWebpURL.lastPathComponent)\n
                            \(resizeResult.isEmpty ? "" : " sips output: \(resizeResult)\n")
                            \(webpResult.isEmpty ? "" : " cwebp output: \(webpResult)\n")
                            """)
                        self.progress = Double(index + 1) / Double(imagesToProcess.count)
                    }
                }
                
                // d) Remove temporary file
                try? fileManager.removeItem(at: tmpResizedURL)
            }
            
            // Show success popup only after ALL images are processed
            if let lastProcessed = processedImages.last {
                await MainActor.run {
                    self.currentComparison = (original: lastProcessed.original, optimized: lastProcessed.optimized)
                    self.currentAnalysis = (type: lastProcessed.contentType, quality: lastProcessed.quality)
                    self.currentSizes = (original: lastProcessed.originalSize, optimized: lastProcessed.optimizedSize)
                    self.showComparison = true
                    
                    // Show the success popup only at the end
                    if isFinalResult {
                        self.showSuccessPopup = true
                    }
                }
            }
            
            await trackOptimizationResults(results)
            await MainActor.run {
                self.isConverting = false
            }
            
        } catch {
            await MainActor.run {
                self.statusMessage.append("Error: \(error.localizedDescription)\n")
                self.isConverting = false
            }
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
        @MainActor
        func loadImage(from path: String) async -> NSImage? {
            NSImage(contentsOfFile: path)
        }
        
        // Only analyze the first image or when in smart mode
        let contentType = if isSmartMode {
            if let image = await loadImage(from: inputPath) {
                if let analyzedType = try? await ImageAnalyzer.analyzeImage(image) {
                    analyzedType
                } else {
                    ImageContentType.photo
                }
            } else {
                ImageContentType.photo
            }
        } else {
            ImageContentType.photo
        }
        
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
        
        // Load images for comparison only when needed
        if let (originalImage, optimizedImage, qualityScore) = try? await loadAndCompare(
            inputPath: inputPath,
            outputPath: outputPath
        ) {
            let originalSize = (try? FileManager.default.attributesOfItem(atPath: inputPath)[FileAttributeKey.size] as? Int64) ?? 0
            let optimizedSize = (try? FileManager.default.attributesOfItem(atPath: outputPath)[FileAttributeKey.size] as? Int64) ?? 0
            
            await MainActor.run {
                processedImages.append((
                    original: originalImage,
                    optimized: optimizedImage,
                    originalSize: originalSize,
                    optimizedSize: optimizedSize,
                    quality: qualityScore,
                    contentType: contentType
                ))
                
                // Update comparison window content
                if let window = windowManager.comparisonWindow {
                    window.contentView = NSHostingView(rootView: 
                        ComparisonImagesView(
                            originalImage: originalImage,
                            optimizedImage: optimizedImage,
                            originalSize: originalSize,
                            optimizedSize: optimizedSize,
                            zoomLevel: 1.0,
                            processedImages: processedImages,
                            selectedMode: $comparisonMode,
                            onImageSelected: { index in
                                let image = processedImages[index]
                                currentComparison = (image.original, image.optimized)
                                currentSizes = (image.originalSize, image.optimizedSize)
                                currentAnalysis = (image.contentType, image.quality)
                            }
                        )
                    )
                }
                
                // Update current comparison state
                self.currentComparison = (original: originalImage, optimized: optimizedImage)
                self.currentAnalysis = (type: contentType, quality: qualityScore)
                self.currentSizes = (original: originalSize, optimized: optimizedSize)
                self.totalSpaceSaved += (originalSize - optimizedSize)
            }
        }
        
        return (bestQ, bestSize)
    }
    
    private func trackOptimizationResults(_ results: [(quality: Int, size: Double)]) async {
        let avgQuality = results.map { $0.quality }.reduce(0, +) / results.count
        let avgCompression = results.map { $0.size }.reduce(0, +) / Double(results.count)
        
        await MainActor.run {
            self.statusMessage.append("""
                
                🎉 Optimization Complete!
                • AI Quality: \(avgQuality)
                • Average Size: \(avgCompression.formatFileSize())
                • Images Optimized: \(results.count)
                • Total Space Saved: \(Double(self.totalSpaceSaved).formatFileSize())
                
                """)
        }
    }
    
    @MainActor
    private func loadAndCompare(inputPath: String, outputPath: String) async throws -> (NSImage, NSImage, Float)? {
        guard let originalImage = NSImage(contentsOfFile: inputPath),
              let optimizedImage = NSImage(contentsOfFile: outputPath) else {
            return nil
        }
        
        let qualityScore = try await ImageAnalyzer.calculateQualityScore(
            original: originalImage,
            optimized: optimizedImage
        )
        
        return (originalImage, optimizedImage, qualityScore)
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
        quality: Float,
        contentType: ImageContentType
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