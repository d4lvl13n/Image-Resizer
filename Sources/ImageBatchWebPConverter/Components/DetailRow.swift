import SwiftUI

public struct DetailRow: View {
    let label: String
    let value: String
    let tooltip: String
    
    public init(label: String, value: String, tooltip: String) {
        self.label = label
        self.value = value
        self.tooltip = tooltip
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .help(tooltip)
    }
} 