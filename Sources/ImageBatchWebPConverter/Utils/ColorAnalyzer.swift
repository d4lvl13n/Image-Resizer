import Foundation
import AppKit
import CoreGraphics

public struct ColorAnalyzer {
    public struct ColorHistogram {
        let red: [Double]
        let green: [Double]
        let blue: [Double]
        private let bins = 256
        
        init(image: CGImage) {
            var red = Array(repeating: 0.0, count: bins)
            var green = Array(repeating: 0.0, count: bins)
            var blue = Array(repeating: 0.0, count: bins)
            
            let width = image.width
            let height = image.height
            let totalPixels = Double(width * height)
            
            guard let data = image.dataProvider?.data,
                  let ptr = CFDataGetBytePtr(data) else {
                self.red = red
                self.green = green
                self.blue = blue
                return
            }
            
            let bytesPerPixel = 4
            let bytesPerRow = bytesPerPixel * width
            
            for y in 0..<height {
                for x in 0..<width {
                    let offset = y * bytesPerRow + x * bytesPerPixel
                    red[Int(ptr[offset])] += 1
                    green[Int(ptr[offset + 1])] += 1
                    blue[Int(ptr[offset + 2])] += 1
                }
            }
            
            // Normalize
            self.red = red.map { $0 / totalPixels }
            self.green = green.map { $0 / totalPixels }
            self.blue = blue.map { $0 / totalPixels }
        }
        
        func compare(to other: ColorHistogram) -> Double {
            let redDiff = zip(red, other.red).map { abs($0 - $1) }.reduce(0, +)
            let greenDiff = zip(green, other.green).map { abs($0 - $1) }.reduce(0, +)
            let blueDiff = zip(blue, other.blue).map { abs($0 - $1) }.reduce(0, +)
            
            let totalDiff = (redDiff + greenDiff + blueDiff) / 3.0
            return 1.0 - totalDiff  // Convert difference to similarity
        }
    }
    
    public static func compareImages(_ original: CGImage, _ optimized: CGImage) -> Double {
        let originalHist = ColorHistogram(image: original)
        let optimizedHist = ColorHistogram(image: optimized)
        return originalHist.compare(to: optimizedHist)
    }
} 