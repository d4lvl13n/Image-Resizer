import Vision
import AppKit

class ImageAnalyzer {
    enum AnalysisError: Error {
        case imageLoadFailed
        case analysisFailed
    }
    
    static func analyzeImage(_ url: URL) async throws -> ImageComparisonView.ImageContentType {
        guard let image = NSImage(contentsOf: url) else {
            throw AnalysisError.imageLoadFailed
        }
        
        // Convert NSImage to CGImage
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw AnalysisError.imageLoadFailed
        }
        
        // Create request handler
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        // Text detection request
        let textRequest = VNRecognizeTextRequest()
        let rectangleRequest = VNDetectRectanglesRequest()
        
        // Update the request execution
        return await withCheckedContinuation { continuation in
            do {
                try requestHandler.perform([textRequest, rectangleRequest])
                
                // Analyze results
                let hasText = (textRequest.results?.count ?? 0) > 0
                let hasRectangles = (rectangleRequest.results?.count ?? 0) > 3
                
                if hasText && hasRectangles {
                    continuation.resume(returning: .screenshot)
                } else if hasText {
                    continuation.resume(returning: .text)
                } else {
                    continuation.resume(returning: .photo)
                }
            } catch {
                continuation.resume(returning: .photo) // Default to photo on error
            }
        }
    }
    
    static func calculateQualityScore(original: NSImage, optimized: NSImage) -> Double {
        // Basic implementation - could be enhanced with more sophisticated metrics
        guard let originalCG = original.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let optimizedCG = optimized.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return 0.0
        }
        
        // Simple pixel comparison for now
        // This should be replaced with SSIM or other proper quality metrics
        let score = compareImages(originalCG, optimizedCG)
        return score
    }
    
    private static func compareImages(_ original: CGImage, _ optimized: CGImage) -> Double {
        // Simplified comparison - should be replaced with proper SSIM implementation
        return 0.85 // Placeholder
    }
} 