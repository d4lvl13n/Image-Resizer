import SwiftUI

public struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let tooltip: String
    
    public init(title: String, value: String, icon: String, color: Color, tooltip: String) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.tooltip = tooltip
    }
    
    public var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .help(tooltip)
    }
} 