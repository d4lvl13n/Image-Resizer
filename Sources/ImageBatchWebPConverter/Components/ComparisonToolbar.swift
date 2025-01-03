import SwiftUI

struct ComparisonToolbar: View {
    @Binding var zoomLevel: CGFloat
    let dismissAction: () -> Void
    
    var body: some View {
        HStack {
            Button(action: dismissAction) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Zoom controls
            HStack(spacing: 8) {
                Button(action: { zoomLevel = max(0.1, zoomLevel - 0.1) }) {
                    Image(systemName: "minus.magnifyingglass")
                }
                .buttonStyle(.plain)
                
                Text("\(Int(zoomLevel * 100))%")
                    .monospacedDigit()
                    .frame(width: 50)
                
                Button(action: { zoomLevel = min(2.0, zoomLevel + 0.1) }) {
                    Image(systemName: "plus.magnifyingglass")
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
} 