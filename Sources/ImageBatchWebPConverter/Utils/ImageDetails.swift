import Vision
import AppKit

public struct ImageDetails {
    public let faces: [FaceRegion]
    public let textRegions: [TextRegion]
    public let objects: [ObjectRegion]
    public let salientAreas: [SalientRegion]
    
    public init(faces: [FaceRegion], textRegions: [TextRegion], objects: [ObjectRegion], salientAreas: [SalientRegion]) {
        self.faces = faces
        self.textRegions = textRegions
        self.objects = objects
        self.salientAreas = salientAreas
    }
}

public struct FaceRegion {
    public let landmarks: VNFaceObservation
    public let bounds: CGRect
    public let confidence: Float
    
    public init(landmarks: VNFaceObservation) {
        self.landmarks = landmarks
        self.bounds = landmarks.boundingBox
        self.confidence = landmarks.confidence
    }
}

public struct TextRegion {
    public let observation: VNRecognizedTextObservation
    public let bounds: CGRect
    public let text: String
    
    public init(observation: VNRecognizedTextObservation) {
        self.observation = observation
        self.bounds = observation.boundingBox
        self.text = observation.topCandidates(1).first?.string ?? ""
    }
}

public struct ObjectRegion {
    public let observation: VNRectangleObservation
    public let bounds: CGRect
    public let confidence: Float
    
    public init(observation: VNRectangleObservation) {
        self.observation = observation
        self.bounds = observation.boundingBox
        self.confidence = observation.confidence
    }
}

public struct SalientRegion {
    public let observation: VNDetectedObjectObservation
    public let bounds: CGRect
    public let confidence: Float
    
    public init(observation: VNDetectedObjectObservation) {
        self.observation = observation
        self.bounds = observation.boundingBox
        self.confidence = observation.confidence
    }
} 