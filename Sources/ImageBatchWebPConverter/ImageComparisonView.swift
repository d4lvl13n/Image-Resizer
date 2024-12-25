import SwiftUI
import Vision

@available(macOS 11.0, *)
struct ImageComparisonView: View {
    let originalImage: NSImage
    let optimizedImage: NSImage
    let originalSize: Int64
    let optimizedSize: Int64
    let qualityScore: Double
    let contentType: ImageContentType
    
    @State private var zoomLevel: CGFloat = 0.5
    @State private var isShowingOriginal: Bool = false
    @State private var showZoomControls: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    enum ImageContentType: String {
        case photo = "Photo"
        case screenshot = "Screenshot"
        case artwork = "Artwork"
        case text = "Text Document"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ComparisonToolbar(
                zoomLevel: $zoomLevel,
                dismissAction: { presentationMode.wrappedValue.dismiss() }
            )
            
            HSplitter {
                ComparisonImagesView(
                    originalImage: originalImage,
                    optimizedImage: optimizedImage,
                    originalSize: originalSize,
                    optimizedSize: optimizedSize,
                    zoomLevel: zoomLevel
                )
                
                // Statistics panel
                StatisticsPanel(
                    contentType: contentType,
                    qualityScore: qualityScore,
                    originalSize: originalSize,
                    optimizedSize: optimizedSize
                )
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(minWidth: 1200, minHeight: 800)
    }
} 