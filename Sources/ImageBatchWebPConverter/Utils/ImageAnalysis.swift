import Foundation
import Models

public struct ImageAnalysis {
    public let contentType: ImageContentType
    public let qualityMetrics: QualityMetrics
    public let optimization: OptimizationMetrics
    
    public struct QualityMetrics {
        public let sharpness: Double
        public let textQuality: Double
        public let faceQuality: Double
        public let colorFidelity: Double
        
        public var overall: Double {
            (sharpness + textQuality + faceQuality + colorFidelity) / 4.0
        }
        
        public init(sharpness: Double, textQuality: Double, faceQuality: Double, colorFidelity: Double) {
            self.sharpness = sharpness
            self.textQuality = textQuality
            self.faceQuality = faceQuality
            self.colorFidelity = colorFidelity
        }
    }
    
    public struct OptimizationMetrics {
        public let sizeReduction: Double
        public let qualityRetention: Double
        public let processingTime: TimeInterval
        
        public init(sizeReduction: Double, qualityRetention: Double, processingTime: TimeInterval) {
            self.sizeReduction = sizeReduction
            self.qualityRetention = qualityRetention
            self.processingTime = processingTime
        }
    }
    
    public init(contentType: ImageContentType, qualityMetrics: QualityMetrics, optimization: OptimizationMetrics) {
        self.contentType = contentType
        self.qualityMetrics = qualityMetrics
        self.optimization = optimization
    }
} 