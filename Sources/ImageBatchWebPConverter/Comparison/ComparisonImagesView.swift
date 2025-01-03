import SwiftUI
import AppKit
import Models
import Components

public struct ComparisonImagesView: View {
    let originalImage: NSImage
    let optimizedImage: NSImage
    let originalSize: Int64
    let optimizedSize: Int64
    let zoomLevel: CGFloat
    let processedImages: [(
        original: NSImage,
        optimized: NSImage,
        originalSize: Int64,
        optimizedSize: Int64,
        quality: Float,
        contentType: ImageContentType
    )]
    @Binding var selectedMode: ComparisonMode
    let onImageSelected: (Int) -> Void
    
    @State private var isShowingOriginal: Bool = false
    @State private var showZoomControls: Bool = false
    @State private var isFullscreen: Bool = false
    @State private var showStatistics = false
    @State private var currentIndex: Int = 0
    @Environment(\.presentationMode) var presentationMode
    
    public init(
        originalImage: NSImage,
        optimizedImage: NSImage,
        originalSize: Int64,
        optimizedSize: Int64,
        zoomLevel: CGFloat,
        processedImages: [(original: NSImage, optimized: NSImage, originalSize: Int64, optimizedSize: Int64, quality: Float, contentType: ImageContentType)],
        selectedMode: Binding<ComparisonMode>,
        onImageSelected: @escaping (Int) -> Void
    ) {
        self.originalImage = originalImage
        self.optimizedImage = optimizedImage
        self.originalSize = originalSize
        self.optimizedSize = optimizedSize
        self.zoomLevel = zoomLevel
        self.processedImages = processedImages
        self._selectedMode = selectedMode
        self.onImageSelected = onImageSelected
    }
    
    public var body: some View {
        HSplitter {
            // Main comparison view
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Window controls
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        // Mode selector
                        Picker("Mode", selection: $selectedMode) {
                            Image(systemName: "rectangle.split.2x1")
                                .tag(ComparisonMode.sideBySide)
                            Image(systemName: "slider.horizontal.below.rectangle")
                                .tag(ComparisonMode.slider)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 100)
                        
                        Spacer()
                        
                        // Add Statistics button
                        Button(action: { showStatistics.toggle() }) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: toggleFullscreen) {
                            Image(systemName: isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .background(Color(NSColor.windowBackgroundColor))
                    
                    // Add the statistics panel as a sheet
                    .sheet(isPresented: $showStatistics) {
                        if !processedImages.isEmpty {
                            EnhancedStatisticsPanel(
                                contentType: processedImages[currentIndex].contentType,
                                qualityScore: processedImages[currentIndex].quality,
                                originalSize: processedImages[currentIndex].originalSize,
                                optimizedSize: processedImages[currentIndex].optimizedSize,
                                imageDetails: nil
                            )
                            .frame(width: 300, height: 400)
                        }
                    }
                    
                    // Comparison view
                    if selectedMode == .sideBySide {
                        HStack(spacing: 0) {
                            ImageView(
                                image: originalImage,
                                size: originalSize,
                                label: "Original",
                                zoomLevel: zoomLevel
                            )
                            
                            Divider()
                            
                            ImageView(
                                image: optimizedImage,
                                size: optimizedSize,
                                label: "Optimized",
                                zoomLevel: zoomLevel
                            )
                        }
                    } else {
                        VStack {
                            ImageSliderView(
                                originalImage: originalImage,
                                optimizedImage: optimizedImage,
                                zoomLevel: zoomLevel
                            )
                            
                            HStack {
                                Text("Original (\(Double(originalSize).formatFileSize()))")
                                Spacer()
                                Text("Optimized (\(Double(optimizedSize).formatFileSize()))")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                        }
                    }
                }
            }
            
            // History sidebar
            VStack {
                Text("History")
                    .font(.headline)
                    .padding()
                
                List {
                    ForEach(processedImages.indices, id: \.self) { index in
                        Button(action: { onImageSelected(index) }) {
                            HStack(spacing: 12) {
                                // Thumbnail
                                Image(nsImage: processedImages[index].optimized)
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
                                        Text("\(Int64.calculateReduction(original: processedImages[index].originalSize, optimized: processedImages[index].optimizedSize))%")
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
                .listStyle(.plain)
            }
            .frame(width: 250)
        }
        .onChange(of: isFullscreen) { newValue in
            if let window = NSApp.windows.first(where: { $0.isKeyWindow }) {
                if newValue {
                    window.toggleFullScreen(nil)
                } else if window.styleMask.contains(.fullScreen) {
                    window.toggleFullScreen(nil)
                }
            }
        }
    }
    
    private func toggleFullscreen() {
        isFullscreen.toggle()
    }
} 