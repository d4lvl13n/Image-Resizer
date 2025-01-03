import SwiftUI
import AppKit
import Vision
import Models
import Utils
import Components

struct ImageComparisonView: View {
    let originalImage: NSImage
    let optimizedImage: NSImage
    let originalSize: Int64
    let optimizedSize: Int64
    let qualityScore: Float
    let contentType: ImageContentType
    let isFinalResult: Bool
    let totalSpaceSaved: Int64
    
    @State private var zoomLevel: CGFloat = 0.5
    @State private var isShowingOriginal: Bool = false
    @State private var showZoomControls: Bool = false
    @State private var selectedMode: ComparisonMode = .sideBySide
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var imageDetails: ImageDetails?
    @State private var showSuccessPopup = false
    @State private var isAnalyzing = true
    
    var body: some View {
        VStack(spacing: 0) {
            ComparisonToolbar(
                zoomLevel: $zoomLevel,
                dismissAction: { presentationMode.wrappedValue.dismiss() }
            )
            
            HSplitter {
                // Main content area
                VStack {
                    TabView(selection: $selectedTab) {
                        // Side by side comparison
                        ComparisonImagesView(
                            originalImage: originalImage,
                            optimizedImage: optimizedImage,
                            originalSize: originalSize,
                            optimizedSize: optimizedSize,
                            zoomLevel: zoomLevel,
                            processedImages: [(
                                original: originalImage,
                                optimized: optimizedImage,
                                originalSize: originalSize,
                                optimizedSize: optimizedSize,
                                quality: qualityScore,
                                contentType: contentType
                            )],
                            selectedMode: $selectedMode,
                            onImageSelected: { _ in }  // Single image comparison, no selection needed
                        )
                        .tag(0)
                        .tabItem {
                            Label("Compare", systemImage: "rectangle.split.2x1")
                        }
                        
                        // Analysis view
                        if let details = imageDetails {
                            AnalysisVisualizerView(
                                image: originalImage,
                                details: details
                            )
                            .tag(1)
                            .tabItem {
                                Label("Analysis", systemImage: "wand.and.stars")
                            }
                        }
                    }
                }
                
                // Info panel
                EnhancedStatisticsPanel(
                    contentType: contentType,
                    qualityScore: qualityScore,
                    originalSize: originalSize,
                    optimizedSize: optimizedSize,
                    imageDetails: imageDetails
                )
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(idealWidth: 1400, idealHeight: 900)
        .frame(minWidth: 1000, minHeight: 700)
        .overlay {
            if showSuccessPopup && isFinalResult {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .overlay {
                        SuccessPopup(
                            imagesCount: 1,
                            totalSaved: totalSpaceSaved,
                            isPresented: $showSuccessPopup
                        )
                    }
            }
        }
        .onAppear {
            if isFinalResult {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showSuccessPopup = true
                }
            }
        }
        .task {
            do {
                imageDetails = try await ImageAnalyzer.analyzeImageDetails(originalImage)
                isAnalyzing = false
            } catch {
                print("Failed to analyze image: \(error)")
                isAnalyzing = false
            }
        }
    }
} 