import SwiftUI
import AppKit
import Vision
import Models
import Utils
import Components

public struct EnhancedStatisticsPanel: View {
    let contentType: ImageContentType
    let qualityScore: Float
    let originalSize: Int64
    let optimizedSize: Int64
    let imageDetails: ImageDetails?
    
    public var body: some View {
        VStack(spacing: 0) {
            Text("Analysis Results")
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
                        color: .blue,
                        tooltip: "Type of content detected - affects optimization strategy"
                    )
                    
                    StatCard(
                        title: "Quality Score",
                        value: "\(Int(qualityScore * 100))%",
                        icon: "gauge.medium",
                        color: qualityColor,
                        tooltip: "How well the optimized image preserves details compared to original"
                    )
                    
                    StatCard(
                        title: "Size Reduction",
                        value: "\(Int64.calculateReduction(original: originalSize, optimized: optimizedSize))%",
                        icon: "arrow.down.circle",
                        color: .green,
                        tooltip: "Storage space saved while maintaining quality"
                    )
                    
                    // Content Analysis section
                    if let details = imageDetails {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Content Analysis")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            ForEach(details.textRegions, id: \.observation) { region in
                                if !region.text.isEmpty {
                                    DetailRow(
                                        label: "Detected Text",
                                        value: region.text,
                                        tooltip: "Text content found in the image"
                                    )
                                }
                            }
                            
                            if !details.faces.isEmpty {
                                DetailRow(
                                    label: "Face Detection",
                                    value: "\(details.faces.count) faces found",
                                    tooltip: "Number of faces detected in the image"
                                )
                            }
                        }
                        .padding()
                        .background(Color(NSColor.controlColor))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        .frame(width: 300)
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