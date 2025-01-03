import SwiftUI
import AppKit
import Models
import Utils
import Components

struct AnalysisVisualizerView: View {
    let image: NSImage
    let details: ImageDetails
    @State private var showOverlay = true
    
    var body: some View {
        ZStack {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            if showOverlay {
                GeometryReader { geometry in
                    ZStack {
                        // Face regions
                        ForEach(details.faces, id: \.landmarks) { face in
                            RegionOverlay(
                                bounds: face.bounds,
                                color: .blue,
                                label: "Face: \(Int(face.confidence * 100))%"
                            )
                        }
                        
                        // Text regions
                        ForEach(details.textRegions, id: \.observation) { region in
                            RegionOverlay(
                                bounds: region.bounds,
                                color: .green,
                                label: "Text: \(region.text)"
                            )
                        }
                        
                        // Salient regions
                        ForEach(details.salientAreas, id: \.observation) { area in
                            RegionOverlay(
                                bounds: area.bounds,
                                color: .yellow,
                                label: "Interest: \(Int(area.confidence * 100))%"
                            )
                        }
                    }
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            Toggle("Show Analysis", isOn: $showOverlay)
                .padding()
        }
    }
}

struct RegionOverlay: View {
    let bounds: CGRect
    let color: Color
    let label: String
    
    var body: some View {
        Rectangle()
            .stroke(color, lineWidth: 2)
            .frame(
                width: bounds.width,
                height: bounds.height
            )
            .position(
                x: bounds.midX,
                y: bounds.midY
            )
            .overlay(
                Text(label)
                    .font(.caption)
                    .padding(4)
                    .background(color.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(4),
                alignment: .top
            )
    }
} 