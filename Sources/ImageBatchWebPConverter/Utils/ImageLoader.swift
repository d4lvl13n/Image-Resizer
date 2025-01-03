import Foundation
import AppKit

@globalActor
public final actor ImageLoader {
    public static let shared = ImageLoader()
    private init() {}
    
    public func loadImage(from url: URL) async throws -> NSImage {
        guard let image = NSImage(contentsOf: url) else {
            throw ImageLoaderError.failedToLoadImage
        }
        return image
    }
    
    public enum ImageLoaderError: Error {
        case failedToLoadImage
    }
} 