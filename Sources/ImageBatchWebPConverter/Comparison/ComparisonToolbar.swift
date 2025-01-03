import SwiftUI

struct ComparisonToolbar: View {
    @Binding var zoomLevel: CGFloat
    var dismissAction: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Title
            HStack(spacing: 8) {
                Image(systemName: "rectangle.on.rectangle")
                    .foregroundColor(.secondary)
                Text("Image Comparison")
                    .font(.headline)
            }
            
            Spacer()
            
            // Center - Zoom controls
            ZoomControls(zoomLevel: $zoomLevel)
            
            // Right side - Close button
            Button(action: dismissAction) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .controlSize(.small)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct ZoomControls: View {
    @Binding var zoomLevel: CGFloat
    
    private var zoomPercentage: String {
        String(format: "%.0f%%", zoomLevel * 100)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: { zoomLevel = max(0.1, zoomLevel - 0.1) }) {
                Image(systemName: "minus.magnifyingglass")
            }
            .controlSize(.small)
            .disabled(zoomLevel <= 0.1)
            
            Group {
                if #available(macOS 12.0, *) {
                    Text(zoomPercentage)
                        .monospacedDigit()
                        .frame(width: 50)
                } else {
                    Text(zoomPercentage)
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 50)
                }
            }
            .font(.caption)
            
            Button(action: { zoomLevel = min(2.0, zoomLevel + 0.1) }) {
                Image(systemName: "plus.magnifyingglass")
            }
            .controlSize(.small)
            .disabled(zoomLevel >= 2.0)
            
            Divider()
                .frame(height: 12)
            
            Group {
                Button(action: { zoomLevel = 0.5 }) {
                    Text("50%")
                }
                Button(action: { zoomLevel = 1.0 }) {
                    Text("100%")
                }
            }
            .controlSize(.small)
            .buttonStyle(.bordered)
        }
        .padding(4)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }
} 