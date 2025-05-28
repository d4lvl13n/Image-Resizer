import SwiftUI
import Models

struct UserPreset: Codable, Identifiable {
    var id = UUID()
    var name: String
    var width: Int
    var isSmartMode: Bool
    var optimizationPreset: OptimizationPreset
    var targetFileSize: Double
    var icon: String
    var createdAt: Date = Date()
}

class PresetsStore: ObservableObject {
    @Published var presets: [UserPreset] = []
    
    private let saveKey = "UserPresets"
    
    init() {
        loadPresets()
        
        // Add default presets if none exist
        if presets.isEmpty {
            addDefaultPresets()
        }
    }
    
    private func addDefaultPresets() {
        presets = [
            UserPreset(
                name: "Web Standard",
                width: 1200,
                isSmartMode: true,
                optimizationPreset: .balanced,
                targetFileSize: 500,
                icon: "globe"
            ),
            UserPreset(
                name: "Social Media",
                width: 1080,
                isSmartMode: true,
                optimizationPreset: .aggressive,
                targetFileSize: 200,
                icon: "bubble.left.and.bubble.right"
            ),
            UserPreset(
                name: "High Quality",
                width: 1920,
                isSmartMode: true,
                optimizationPreset: .maximum,
                targetFileSize: 1000,
                icon: "sparkles"
            ),
            UserPreset(
                name: "Email Friendly",
                width: 800,
                isSmartMode: true,
                optimizationPreset: .aggressive,
                targetFileSize: 100,
                icon: "envelope"
            )
        ]
        savePresets()
    }
    
    func savePresets() {
        if let encoded = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func loadPresets() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([UserPreset].self, from: data) {
            presets = decoded
        }
    }
    
    func addPreset(_ preset: UserPreset) {
        presets.append(preset)
        savePresets()
    }
    
    func deletePreset(_ preset: UserPreset) {
        presets.removeAll { $0.id == preset.id }
        savePresets()
    }
}

struct PresetsManagerView: View {
    @StateObject private var store = PresetsStore()
    @Binding var widthString: String
    @Binding var isSmartMode: Bool
    @Binding var optimizationPreset: OptimizationPreset
    @Binding var targetFileSize: Double
    
    @State private var showingAddPreset = false
    @State private var newPresetName = ""
    @State private var selectedIcon = "star"
    
    let icons = ["star", "heart", "bolt", "flame", "leaf", "camera", "photo", "sparkles"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Label("Presets", systemImage: "square.stack.3d.up")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showingAddPreset = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
            
            // Presets grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                ForEach(store.presets) { preset in
                    PresetCard(
                        preset: preset,
                        isSelected: false,
                        onSelect: {
                            applyPreset(preset)
                        },
                        onDelete: {
                            store.deletePreset(preset)
                        }
                    )
                }
            }
        }
        .sheet(isPresented: $showingAddPreset) {
            AddPresetView(
                name: $newPresetName,
                selectedIcon: $selectedIcon,
                icons: icons,
                currentSettings: (
                    width: Int(widthString) ?? 1600,
                    isSmartMode: isSmartMode,
                    optimizationPreset: optimizationPreset,
                    targetFileSize: targetFileSize
                ),
                onSave: { preset in
                    store.addPreset(preset)
                    showingAddPreset = false
                },
                onCancel: {
                    showingAddPreset = false
                }
            )
        }
    }
    
    private func applyPreset(_ preset: UserPreset) {
        widthString = String(preset.width)
        isSmartMode = preset.isSmartMode
        optimizationPreset = preset.optimizationPreset
        targetFileSize = preset.targetFileSize
    }
}

struct PresetCard: View {
    let preset: UserPreset
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                Image(systemName: preset.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(spacing: 4) {
                    Text(preset.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text("\(preset.width)px")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(isHovering ? Color.blue.opacity(0.1) : Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.2), lineWidth: 1)
            )
            .overlay(
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding(8),
                alignment: .topTrailing
            )
            .opacity(isHovering ? 1 : 0.9)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

struct AddPresetView: View {
    @Binding var name: String
    @Binding var selectedIcon: String
    let icons: [String]
    let currentSettings: (width: Int, isSmartMode: Bool, optimizationPreset: OptimizationPreset, targetFileSize: Double)
    let onSave: (UserPreset) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Save Current Settings as Preset")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Name input
            VStack(alignment: .leading, spacing: 8) {
                Text("Preset Name")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Enter preset name", text: $name)
                    .textFieldStyle(.roundedBorder)
            }
            
            // Icon selector
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose Icon")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                    ForEach(icons, id: \.self) { icon in
                        Button(action: { selectedIcon = icon }) {
                            Image(systemName: icon)
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .background(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedIcon == icon ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Current settings preview
            VStack(alignment: .leading, spacing: 8) {
                Text("Settings to Save")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Label("\(currentSettings.width)px", systemImage: "arrow.left.and.right")
                    Spacer()
                    if currentSettings.isSmartMode {
                        Label(currentSettings.optimizationPreset.name, systemImage: "sparkles")
                    }
                }
                .font(.caption)
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Action buttons
            HStack {
                Button("Cancel", action: onCancel)
                    .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Save Preset") {
                    let preset = UserPreset(
                        name: name.isEmpty ? "Custom Preset" : name,
                        width: currentSettings.width,
                        isSmartMode: currentSettings.isSmartMode,
                        optimizationPreset: currentSettings.optimizationPreset,
                        targetFileSize: currentSettings.targetFileSize,
                        icon: selectedIcon
                    )
                    onSave(preset)
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty)
            }
        }
        .padding(30)
        .frame(width: 400)
    }
} 