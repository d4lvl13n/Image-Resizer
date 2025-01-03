import SwiftUI

public struct AnalysisMetricsBar: View {
    let faces: Int
    let textRegions: Int
    let salientAreas: Int
    
    public init(faces: Int, textRegions: Int, salientAreas: Int) {
        self.faces = faces
        self.textRegions = textRegions
        self.salientAreas = salientAreas
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            MetricBadge(
                icon: "face.smiling",
                count: faces,
                label: "Faces"
            )
            
            MetricBadge(
                icon: "text.viewfinder",
                count: textRegions,
                label: "Text Regions"
            )
            
            MetricBadge(
                icon: "sparkles.rectangle.stack",
                count: salientAreas,
                label: "Points of Interest"
            )
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor))
    }
} 