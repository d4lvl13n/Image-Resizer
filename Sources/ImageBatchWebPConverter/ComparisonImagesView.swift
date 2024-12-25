import SwiftUI

struct ComparisonImagesView: View {
    let originalImage: NSImage
    let optimizedImage: NSImage
    let originalSize: Int64
    let optimizedSize: Int64
    let zoomLevel: CGFloat
    @State private var showZoomControls: Bool = false
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            HStack(spacing: 0) {
                // Original image
                ComparisonImageView(
                    image: originalImage,
                    size: originalSize,
                    zoomLevel: zoomLevel,
                    label: "Original",
                    showControls: $showZoomControls
                )
                
                // Separator
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 1)
                    .padding(.horizontal)
                
                // Optimized image
                ComparisonImageView(
                    image: optimizedImage,
                    size: optimizedSize,
                    zoomLevel: zoomLevel,
                    label: "Optimized",
                    showControls: $showZoomControls
                )
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct ComparisonImageView: View {
    let image: NSImage
    let size: Int64
    let zoomLevel: CGFloat
    let label: String
    @Binding var showControls: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: image.size.width * zoomLevel,
                           height: image.size.height * zoomLevel)
                    .overlay(
                        Rectangle()
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                if showControls {
                    VStack {
                        Text(label)
                            .font(.caption)
                            .padding(4)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    .padding(8)
                }
            }
            .onHover { hovering in
                showControls = hovering
            }
            
            ImageInfoView(
                size: size,
                dimensions: image.size,
                label: label
            )
        }
    }
} 