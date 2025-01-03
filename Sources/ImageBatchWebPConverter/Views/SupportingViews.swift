import SwiftUI

struct ImageInfoView: View {
    let size: Int64
    let dimensions: CGSize
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.headline)
            Text("\(Int(dimensions.width))×\(Int(dimensions.height))")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(Double(size).formatFileSize())
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct HSplitter<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            content
        }
    }
} 