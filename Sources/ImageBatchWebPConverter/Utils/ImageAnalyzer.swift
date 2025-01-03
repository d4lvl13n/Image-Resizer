import Foundation
import Vision
import AppKit
import Models

@MainActor
public class ImageAnalyzer {
    public enum AnalysisError: Error {
        case imageLoadFailed
    }
    
    public static func analyzeImage(_ image: NSImage) async throws -> ImageContentType {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw AnalysisError.imageLoadFailed
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        // Multiple analysis requests
        let textRequest = VNRecognizeTextRequest()
        let rectangleRequest = VNDetectRectanglesRequest()
        let sceneRequest = VNClassifyImageRequest()
        let faceRequest = VNDetectFaceRectanglesRequest()
        
        try requestHandler.perform([textRequest, rectangleRequest, sceneRequest, faceRequest])
        
        // Enhanced analysis
        let hasText = (textRequest.results?.count ?? 0) > 0
        let hasRectangles = (rectangleRequest.results?.count ?? 0) > 3
        let hasFaces = (faceRequest.results?.count ?? 0) > 0
        let sceneClassification = sceneRequest.results?.first?.identifier ?? ""
        
        // More sophisticated content type determination
        if hasFaces {
            return .photo
        } else if hasText && hasRectangles {
            return .screenshot
        } else if hasText {
            return .text
        } else if sceneClassification.contains("artwork") || sceneClassification.contains("graphic") {
            return .artwork
        } else {
            return .photo
        }
    }
    
    public static func calculateQualityScore(original: NSImage, optimized: NSImage) async throws -> Float {
        guard let originalCG = original.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let optimizedCG = optimized.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return 0.0
        }
        
        let originalHandler = VNImageRequestHandler(cgImage: originalCG)
        let optimizedHandler = VNImageRequestHandler(cgImage: optimizedCG)
        
        // Multiple quality metrics
        let sharpnessScore = await analyzeSharpness(originalHandler, optimizedHandler)
        let textQualityScore = await analyzeTextQuality(originalHandler, optimizedHandler)
        let faceQualityScore = await analyzeFaceQuality(originalHandler, optimizedHandler)
        let colorScore = await analyzeColorFidelity(originalCG, optimizedCG)
        
        // Weight the scores based on content type
        let contentType = try? await analyzeImage(original)
        switch contentType {
        case .text:
            return textQualityScore * 0.7 + sharpnessScore * 0.3
        case .photo:
            return sharpnessScore * 0.4 + colorScore * 0.4 + faceQualityScore * 0.2
        case .screenshot:
            return textQualityScore * 0.5 + sharpnessScore * 0.5
        default:
            return (sharpnessScore + colorScore) / 2
        }
    }
    
    private static func analyzeSharpness(_ original: VNImageRequestHandler, _ optimized: VNImageRequestHandler) async -> Float {
        let request = VNGenerateAttentionBasedSaliencyImageRequest()
        
        try? original.perform([request])
        let originalSharpness = request.results?.first?.salientObjects?.reduce(0.0) { $0 + $1.confidence } ?? 0.0
        
        try? optimized.perform([request])
        let optimizedSharpness = request.results?.first?.salientObjects?.reduce(0.0) { $0 + $1.confidence } ?? 0.0
        
        return Float(min(1.0, optimizedSharpness / originalSharpness))
    }
    
    private static func analyzeTextQuality(_ original: VNImageRequestHandler, _ optimized: VNImageRequestHandler) async -> Float {
        let request = VNRecognizeTextRequest()
        
        try? original.perform([request])
        let originalConfidence = request.results?.reduce(0.0) { $0 + ($1.confidence) } ?? 0.0
        
        try? optimized.perform([request])
        let optimizedConfidence = request.results?.reduce(0.0) { $0 + ($1.confidence) } ?? 0.0
        
        return Float(min(1.0, optimizedConfidence / originalConfidence))
    }
    
    private static func analyzeFaceQuality(_ original: VNImageRequestHandler, _ optimized: VNImageRequestHandler) async -> Float {
        let request = VNDetectFaceLandmarksRequest()
        
        try? original.perform([request])
        let originalQuality = request.results?.reduce(0.0) { $0 + ($1.confidence) } ?? 0.0
        
        try? optimized.perform([request])
        let optimizedQuality = request.results?.reduce(0.0) { $0 + ($1.confidence) } ?? 0.0
        
        return Float(min(1.0, optimizedQuality / originalQuality))
    }
    
    private static func analyzeColorFidelity(_ original: CGImage, _ optimized: CGImage) async -> Float {
        return Float(ColorAnalyzer.compareImages(original, optimized))
    }
    
    public static func analyzeImageDetails(_ image: NSImage) async throws -> ImageDetails {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw AnalysisError.imageLoadFailed
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        let faceRequest = VNDetectFaceLandmarksRequest()
        let textRequest = VNRecognizeTextRequest()
        let rectangleRequest = VNDetectRectanglesRequest()
        let saliencyRequest = VNGenerateAttentionBasedSaliencyImageRequest()
        
        try handler.perform([faceRequest, textRequest, rectangleRequest, saliencyRequest])
        
        return ImageDetails(
            faces: (faceRequest.results ?? []).map { FaceRegion(landmarks: $0) },
            textRegions: (textRequest.results ?? []).map { TextRegion(observation: $0) },
            objects: (rectangleRequest.results ?? []).map { ObjectRegion(observation: $0) },
            salientAreas: (saliencyRequest.results?.first?.salientObjects ?? []).map { SalientRegion(observation: $0) }
        )
    }
} 