import Foundation

enum OptimizationPreset: String, CaseIterable {
    case maximum = "Maximum Quality"
    case balanced = "Balanced"
    case aggressive = "Aggressive Compression"
    case custom = "Custom"
    
    var targetSize: Double {
        switch self {
            case .maximum: return 1000    // 1MB
            case .balanced: return 500     // 500KB
            case .aggressive: return 200   // 200KB
            case .custom: return 0         // User defined
        }
    }
    
    var icon: String {
        switch self {
        case .maximum: return "star.circle.fill"
        case .balanced: return "equal.circle.fill"
        case .aggressive: return "arrow.down.circle.fill"
        case .custom: return "slider.horizontal.3"
        }
    }
    
    var name: String {
        switch self {
        case .maximum: return "Maximum"
        case .balanced: return "Balanced"
        case .aggressive: return "Aggressive"
        case .custom: return "Custom"
        }
    }
    
    var description: String {
        switch self {
        case .maximum: return "1MB target"
        case .balanced: return "500KB target"
        case .aggressive: return "200KB target"
        case .custom: return ""
        }
    }
} 