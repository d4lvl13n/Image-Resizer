import SwiftUI

struct EnhancedProgressView: View {
    let currentImage: String
    let progress: Double
    let imagesProcessed: Int
    let totalImages: Int
    let estimatedTimeRemaining: TimeInterval
    let currentImagePreview: NSImage?
    let spaceSaved: Int64
    
    @State private var animateProgress = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                if #available(macOS 15.0, *) {
                    Image(systemName: "gearshape.2.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .symbolEffect(.rotate, value: animateProgress)
                } else {
                    Image(systemName: "gearshape.2.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(animateProgress ? 360 : 0))
                        .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: animateProgress)
                }
                
                Text("Processing Images")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Cancel button
                Button(action: {}) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            // Progress bar with percentage
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(imagesProcessed) of \(totalImages)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(CustomProgressViewStyle())
                    .animation(.linear, value: progress)
            }
            
            // Current image preview
            if let preview = currentImagePreview {
                HStack(spacing: 16) {
                    Image(nsImage: preview)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentImage)
                            .font(.caption)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        Label("Processing...", systemImage: "arrow.triangle.2.circlepath")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatBox(
                    icon: "clock",
                    title: "Time Remaining",
                    value: formatTimeRemaining(estimatedTimeRemaining)
                )
                
                StatBox(
                    icon: "arrow.down.circle",
                    title: "Space Saved",
                    value: formatBytes(spaceSaved)
                )
                
                StatBox(
                    icon: "speedometer",
                    title: "Speed",
                    value: "\(imagesProcessed > 0 ? imagesProcessed * 60 / max(1, Int(Date().timeIntervalSinceReferenceDate)) : 0) img/min"
                )
                
                StatBox(
                    icon: "checkmark.circle",
                    title: "Completed",
                    value: "\(imagesProcessed)"
                )
            }
        }
        .padding(24)
        .frame(width: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10)
        .onAppear {
            animateProgress = true
        }
    }
    
    private func formatTimeRemaining(_ seconds: TimeInterval) -> String {
        if seconds < 60 {
            return "\(Int(seconds))s"
        } else if seconds < 3600 {
            return "\(Int(seconds / 60))m"
        } else {
            return "\(Int(seconds / 3600))h"
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct StatBox: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct CustomProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.blue.gradient)
                    .frame(width: geometry.size.width * (configuration.fractionCompleted ?? 0), height: 8)
            }
        }
        .frame(height: 8)
    }
} 