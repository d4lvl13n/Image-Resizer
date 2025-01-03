import SwiftUI

public struct MetricBadge: View {
    let icon: String
    let count: Int
    let label: String
    
    public init(icon: String, count: Int, label: String) {
        self.icon = icon
        self.count = count
        self.label = label
    }
    
    public var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)")
                    .font(.headline)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
} 