import SwiftUI

struct StatisticsPanel: View {
    let contentType: ImageComparisonView.ImageContentType
    let qualityScore: Double
    let originalSize: Int64
    let optimizedSize: Int64
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Optimization Results")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
            
            ScrollView {
                VStack(spacing: 16) {
                    StatCard(
                        title: "Content Type",
                        value: contentType.rawValue,
                        icon: "doc.viewfinder",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Quality Score",
                        value: "\(Int(qualityScore * 100))%",
                        icon: "gauge.medium",
                        color: qualityColor
                    )
                    
                    StatCard(
                        title: "Size Reduction",
                        value: "\(Int64.calculateReduction(original: originalSize, optimized: optimizedSize))%",
                        icon: "arrow.down.circle",
                        color: .green
                    )
                    
                    // Additional stats
                    DetailRow(
                        label: "Original Size",
                        value: Double(originalSize).formatFileSize()
                    )
                    DetailRow(
                        label: "Optimized Size",
                        value: Double(optimizedSize).formatFileSize()
                    )
                    DetailRow(
                        label: "Space Saved",
                        value: Double(originalSize - optimizedSize).formatFileSize()
                    )
                }
                .padding()
            }
        }
        .frame(width: 250)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var qualityColor: Color {
        switch qualityScore {
        case 0.9...: return .green
        case 0.7...: return .yellow
        default: return .red
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.title2)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlColor))
        .cornerRadius(8)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
} 