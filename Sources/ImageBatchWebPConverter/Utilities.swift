import Foundation

extension Int64 {
    static func calculateReduction(original: Int64, optimized: Int64) -> Int {
        let reduction = Double(original - optimized) / Double(original) * 100
        return Int(reduction)
    }
}

extension Double {
    func formatFileSize() -> String {
        if self >= 1_048_576 { // 1024 * 1024
            return String(format: "%.1f MB", self / 1_048_576)
        } else {
            return String(format: "%.0f KB", self / 1024)
        }
    }
} 