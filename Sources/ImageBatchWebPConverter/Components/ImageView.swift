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
        VStack {
            Text(label)
                .font(.headline)
                .padding()
            
            GeometryReader { geometry in
                ScrollView([.horizontal, .vertical]) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: geometry.size.width * zoomLevel,
                            height: geometry.size.height * zoomLevel
                        )
                }
            }
            
            Text(Double(size).formatFileSize())
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
} 