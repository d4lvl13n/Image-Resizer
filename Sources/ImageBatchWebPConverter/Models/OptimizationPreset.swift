import Foundation

public enum OptimizationPreset: String, CaseIterable {
    case maximum = "Maximum Quality"
    case balanced = "Balanced"
    case aggressive = "Aggressive Compression"
    case custom = "Custom"
    
    public var targetSize: Double {
        switch self {
        case .maximum: return 1000    // 1MB
        case .balanced: return 500     // 500KB
        case .aggressive: return 200   // 200KB
        case .custom: return 0         // User defined
        }
    }
    
    public var icon: String {
        switch self {
        case .maximum: return "star.circle.fill"
        case .balanced: return "equal.circle.fill"
        case .aggressive: return "arrow.down.circle.fill"
        case .custom: return "slider.horizontal.3"
        }
    }
    
    public var baseQuality: Int {
        switch self {
        case .maximum: return 90
        case .balanced: return 80
        case .aggressive: return 70
        case .custom: return 80
        }
    }
    
    public var name: String {
        rawValue
    }
    
    public var description: String {
        switch self {
        case .maximum: return "1MB target"
        case .balanced: return "500KB target"
        case .aggressive: return "200KB target"
        case .custom: return ""
        }
    }
} 