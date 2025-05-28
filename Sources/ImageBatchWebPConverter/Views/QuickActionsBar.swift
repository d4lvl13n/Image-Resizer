import SwiftUI
import Models

struct QuickActionsBar: View {
    @Binding var widthString: String
    @Binding var isSmartMode: Bool
    @Binding var optimizationPreset: OptimizationPreset
    let onConvert: () -> Void
    
    @State private var showPresets = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Quick size presets
            Menu {
                Button("Original Size") {
                    widthString = "0" // We'll handle this in conversion logic
                }
                Divider()
                ForEach([640, 800, 1200, 1600, 1920], id: \.self) { width in
                    Button("\(width)px") {
                        widthString = String(width)
                    }
                }
            } label: {
                Label("Size: \(widthString)px", systemImage: "arrow.left.and.right")
                    .frame(minWidth: 120)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            
            Divider()
                .frame(height: 20)
            
            // Quick optimization toggle
            Button(action: { isSmartMode.toggle() }) {
                HStack(spacing: 6) {
                    Image(systemName: isSmartMode ? "sparkles" : "sparkles.slash")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(isSmartMode ? .blue : .gray)
                    Text(isSmartMode ? "Smart ON" : "Smart OFF")
                        .font(.caption)
                }
            }
            .buttonStyle(.accessoryBar)
            
            // Quick preset selector
            if isSmartMode {
                Menu {
                    ForEach(OptimizationPreset.allCases, id: \.self) { preset in
                        Button(action: { optimizationPreset = preset }) {
                            Label(preset.name, systemImage: preset == optimizationPreset ? "checkmark" : "")
                        }
                    }
                } label: {
                    Label(optimizationPreset.name, systemImage: "slider.horizontal.3")
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            }
            
            Spacer()
            
            // Quick convert button
            Button(action: onConvert) {
                Label("Quick Convert", systemImage: "bolt.fill")
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.return, modifiers: .command)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// Custom button style for accessory bar
struct AccessoryBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(configuration.isPressed ? Color.gray.opacity(0.2) : Color.clear)
            .cornerRadius(6)
    }
}

extension ButtonStyle where Self == AccessoryBarButtonStyle {
    static var accessoryBar: AccessoryBarButtonStyle {
        AccessoryBarButtonStyle()
    }
} 