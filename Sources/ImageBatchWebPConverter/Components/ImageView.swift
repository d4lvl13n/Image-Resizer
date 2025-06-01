import SwiftUI
import AppKit
import Utils

public struct ImageView: View {
    let image: NSImage
    let size: Int64
    let label: String
    let zoomLevel: CGFloat
    
    public init(image: NSImage, size: Int64, label: String, zoomLevel: CGFloat) {
        self.image = image
        self.size = size
        self.label = label
        self.zoomLevel = zoomLevel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Modern header with glass morphism
            HStack {
                Text(label)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(Double(size).formatFileSize())
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        if #available(macOS 12.0, *) {
                            Material.regularMaterial
                        } else {
                            Color(NSColor.controlBackgroundColor)
                        }, in: Capsule()
                    )
            }
            .padding(16)
            .background(
                if #available(macOS 12.0, *) {
                    Material.ultraThinMaterial
                } else {
                    Color(NSColor.windowBackgroundColor)
                }
            )
            
            // Image container
            GeometryReader { geometry in
                ScrollView([.horizontal, .vertical]) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: geometry.size.width * zoomLevel,
                            height: geometry.size.height * zoomLevel
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .background(
                    if #available(macOS 12.0, *) {
                        Material.regularMaterial
                    } else {
                        Color(NSColor.controlBackgroundColor)
                    }
                )
            }
        }
    }
} 