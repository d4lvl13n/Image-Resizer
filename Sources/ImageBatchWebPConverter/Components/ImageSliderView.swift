import SwiftUI
import AppKit

public struct ImageSliderView: View {
    let originalImage: NSImage
    let optimizedImage: NSImage
    @State private var sliderPosition: CGFloat = 0.5
    let zoomLevel: CGFloat
    
    public init(originalImage: NSImage, optimizedImage: NSImage, zoomLevel: CGFloat) {
        self.originalImage = originalImage
        self.optimizedImage = optimizedImage
        self.zoomLevel = zoomLevel
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Original image
                Image(nsImage: originalImage)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: geometry.size.width * zoomLevel,
                        height: geometry.size.height * zoomLevel
                    )
                
                // Optimized image with clip mask
                Image(nsImage: optimizedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: geometry.size.width * zoomLevel,
                        height: geometry.size.height * zoomLevel
                    )
                    .clipShape(
                        Rectangle()
                            .offset(x: geometry.size.width * (sliderPosition - 1))
                    )
                
                // Slider line
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2)
                    .offset(x: geometry.size.width * (sliderPosition - 0.5))
                    .shadow(radius: 2)
                
                // Slider handle
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(radius: 2)
                    .offset(x: geometry.size.width * (sliderPosition - 0.5))
                    .overlay(
                        Image(systemName: "arrow.left.and.right")
                            .font(.caption2)
                            .foregroundColor(.black)
                    )
                    .offset(x: geometry.size.width * (sliderPosition - 0.5))
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newPosition = value.location.x / geometry.size.width
                        sliderPosition = max(0, min(1, newPosition))
                    }
            )
        }
    }
} 