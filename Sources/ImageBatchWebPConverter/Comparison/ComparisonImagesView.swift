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
        ZStack {
            // Modern gradient background
            LinearGradient(
                colors: [
                    Color(NSColor.windowBackgroundColor),
                    Color(NSColor.controlBackgroundColor).opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            HSplitter {
                // Main comparison view
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        // Modern window controls with glass morphism
                        HStack(spacing: 16) {
                            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                            .padding(8)
                            .background(
                                if #available(macOS 12.0, *) {
                                    .ultraThinMaterial
                                } else {
                                    Color(NSColor.controlBackgroundColor)
                                }, in: Circle()
                            )
                            
                            Spacer()
                            
                            // Modern mode selector
                            Picker("Mode", selection: $selectedMode) {
                                Label("Side by Side", systemImage: "rectangle.split.2x1")
                                    .tag(ComparisonMode.sideBySide)
                                Label("Slider", systemImage: "slider.horizontal.below.rectangle")
                                    .tag(ComparisonMode.slider)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 200)
                            .background(
                                if #available(macOS 12.0, *) {
                                    .regularMaterial
                                } else {
                                    Color(NSColor.controlBackgroundColor)
                                }, in: Capsule()
                            )
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                // Statistics button
                                Button(action: { showStatistics.toggle() }) {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                                .padding(8)
                                .background(
                                    if #available(macOS 12.0, *) {
                                        .ultraThinMaterial
                                    } else {
                                        Color(NSColor.controlBackgroundColor)
                                    }, in: Circle()
                                )
                                
                                // Fullscreen button
                                Button(action: toggleFullscreen) {
                                    Image(systemName: isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                                .padding(8)
                                .background(
                                    if #available(macOS 12.0, *) {
                                        .ultraThinMaterial
                                    } else {
                                        Color(NSColor.controlBackgroundColor)
                                    }, in: Circle()
                                )
                            }
                        }
                        .padding(20)
                        .background(
                            if #available(macOS 12.0, *) {
                                .ultraThinMaterial
                            } else {
                                Color(NSColor.windowBackgroundColor)
                            }
                        )
                        
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
                                .frame(width: 320, height: 420)
                            }
                        }
                        
                        // Comparison view with modern styling
                        if selectedMode == .sideBySide {
                            HStack(spacing: 1) {
                                ImageView(
                                    image: originalImage,
                                    size: originalSize,
                                    label: "Original",
                                    zoomLevel: zoomLevel
                                )
                                .background(
                                    if #available(macOS 12.0, *) {
                                        .regularMaterial
                                    } else {
                                        Color(NSColor.controlBackgroundColor)
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 0))
                                
                                // Modern divider
                                Rectangle()
                                    .fill(
                                        if #available(macOS 12.0, *) {
                                            .ultraThinMaterial
                                        } else {
                                            Color(NSColor.separatorColor)
                                        }
                                    )
                                    .frame(width: 1)
                                
                                ImageView(
                                    image: optimizedImage,
                                    size: optimizedSize,
                                    label: "Optimized",
                                    zoomLevel: zoomLevel
                                )
                                .background(
                                    if #available(macOS 12.0, *) {
                                        .regularMaterial
                                    } else {
                                        Color(NSColor.controlBackgroundColor)
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 0))
                            }
                        } else {
                            VStack(spacing: 0) {
                                ImageSliderView(
                                    originalImage: originalImage,
                                    optimizedImage: optimizedImage,
                                    zoomLevel: zoomLevel
                                )
                                .background(.regularMaterial)
                                
                                // Modern info bar
                                HStack(spacing: 16) {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(.orange)
                                            .frame(width: 8, height: 8)
                                        Text("Original (\(Double(originalSize).formatFileSize()))")
                                            .font(.callout)
                                            .fontWeight(.medium)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(.green)
                                            .frame(width: 8, height: 8)
                                        Text("Optimized (\(Double(optimizedSize).formatFileSize()))")
                                            .font(.callout)
                                            .fontWeight(.medium)
                                    }
                                }
                                .foregroundColor(.primary)
                                .padding(16)
                                .background(
                                    if #available(macOS 12.0, *) {
                                        .ultraThinMaterial
                                    } else {
                                        Color(NSColor.windowBackgroundColor)
                                    }
                                )
                            }
                        }
                    }
                }
                
                // Modern history sidebar with glass morphism
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("History")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(20)
                    .background(
                        if #available(macOS 12.0, *) {
                            .ultraThinMaterial
                        } else {
                            Color(NSColor.windowBackgroundColor)
                        }
                    )
                    
                    // List with modern styling
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(processedImages.indices, id: \.self) { index in
                                Button(action: { onImageSelected(index) }) {
                                    HStack(spacing: 12) {
                                        // Modern thumbnail
                                        Image(nsImage: processedImages[index].optimized)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                                            )
                                        
                                        // Info with better typography
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Image \(index + 1)")
                                                .font(.callout)
                                                .fontWeight(.semibold)
                                            HStack(spacing: 4) {
                                                Image(systemName: "arrow.down.circle.fill")
                                                    .foregroundColor(.green)
                                                    .font(.caption)
                                                Text("\(Int64.calculateReduction(original: processedImages[index].originalSize, optimized: processedImages[index].optimizedSize))% saved")
                                                    .font(.caption)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(12)
                                    .background(
                                        if #available(macOS 12.0, *) {
                                            .regularMaterial
                                        } else {
                                            Color(NSColor.controlBackgroundColor)
                                        }, in: RoundedRectangle(cornerRadius: 12)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }
                    .background(
                        if #available(macOS 12.0, *) {
                            .ultraThinMaterial
                        } else {
                            Color(NSColor.windowBackgroundColor)
                        }
                    )
                }
                .frame(width: 280)
            }
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