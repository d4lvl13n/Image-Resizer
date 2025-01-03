import SwiftUI
import AppKit
import Models

struct SmartOptimizationView: View {
    @Binding var isEnabled: Bool
    @Binding var preset: OptimizationPreset
    @Binding var targetFileSize: Double
    
    var body: some View {
        VStack(spacing: 0) {
            // Header section with toggle
            HStack(spacing: 16) {
                if #available(macOS 12.0, *) {
                    Image(systemName: "sparkles.square.filled.on.square")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(isEnabled ? .blue : .gray)
                        .font(.system(size: 28))
                } else {
                    Image(systemName: "sparkles")
                        .foregroundColor(isEnabled ? .blue : .gray)
                        .font(.system(size: 28))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Smart Optimization")
                        .font(.headline)
                    Text("AI-powered quality optimization")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .toggleStyle(SwitchToggleStyle())
                    .scaleEffect(0.8)
            }
            .padding()
            .contentShape(Rectangle())
            .background(Color(NSColor.controlBackgroundColor))
            
            // Presets section
            if isEnabled {
                VStack(alignment: .leading, spacing: 16) {
                    // Preset buttons
                    HStack(spacing: 8) {
                        ForEach(OptimizationPreset.allCases, id: \.self) { presetOption in
                            PresetButton(
                                preset: presetOption,
                                isSelected: preset == presetOption,
                                action: { preset = presetOption }
                            )
                        }
                    }
                    
                    // Target size input (only for custom preset)
                    if preset == .custom {
                        HStack(spacing: 12) {
                            Text("Target Size")
                                .foregroundColor(.secondary)
                            
                            TextField("", value: $targetFileSize, formatter: NumberFormatter())
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            
                            Text("KB")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isEnabled ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

struct PresetButton: View {
    let preset: OptimizationPreset
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: preset.icon)
                    .font(.system(size: 16))
                Text(preset.name)
                    .font(.caption)
                if !preset.description.isEmpty {
                    Text(preset.description)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(isSelected ? Color.blue.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
} 