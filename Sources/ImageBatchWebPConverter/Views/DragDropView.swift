import SwiftUI
import UniformTypeIdentifiers

struct DragDropView: View {
    @Binding var inputFolder: URL?
    @State private var isDragging = false
    @State private var draggedImages: [URL] = []
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(isDragging ? Color.accentColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            style: StrokeStyle(
                                lineWidth: 2,
                                dash: isDragging ? [10, 5] : [15, 10]
                            )
                        )
                        .foregroundColor(isDragging ? .accentColor : .gray.opacity(0.3))
                        .animation(.easeInOut(duration: 0.3), value: isDragging)
                )
            
            VStack(spacing: 20) {
                if #available(macOS 14.0, *) {
                    Image(systemName: isDragging ? "arrow.down.doc.fill" : "arrow.down.doc")
                        .font(.system(size: 60))
                        .foregroundColor(isDragging ? .accentColor : .gray)
                        .symbolEffect(.bounce, value: isDragging)
                } else {
                    Image(systemName: isDragging ? "arrow.down.doc.fill" : "arrow.down.doc")
                        .font(.system(size: 60))
                        .foregroundColor(isDragging ? .accentColor : .gray)
                }
                
                VStack(spacing: 8) {
                    Text("Drop images or folders here")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("or click to browse")
                        .foregroundColor(.secondary)
                    
                    if !draggedImages.isEmpty {
                        Text("\(draggedImages.count) images ready")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.top, 4)
                    }
                }
                
                // Quick action buttons
                HStack(spacing: 12) {
                    Button(action: selectPhotosLibrary) {
                        Label("Photos Library", systemImage: "photo.on.rectangle")
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: selectDesktop) {
                        Label("Desktop", systemImage: "desktopcomputer")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top)
            }
            .padding(40)
        }
        .frame(height: 300)
        .contentShape(Rectangle())
        .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
            handleDrop(providers: providers)
            return true
        }
        .onTapGesture {
            selectFolder()
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    DispatchQueue.main.async {
                        // Check if it's a directory
                        var isDirectory: ObjCBool = false
                        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                            if isDirectory.boolValue {
                                self.inputFolder = url
                            } else if isImageFile(url) {
                                // Handle individual image files
                                self.draggedImages.append(url)
                                // Set parent directory as input folder
                                self.inputFolder = url.deletingLastPathComponent()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func isImageFile(_ url: URL) -> Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "bmp", "tif", "tiff", "heic", "webp"]
        return imageExtensions.contains(url.pathExtension.lowercased())
    }
    
    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "Select a folder containing images to convert"
        
        panel.begin { response in
            if response == .OK {
                self.inputFolder = panel.url
            }
        }
    }
    
    private func selectPhotosLibrary() {
        if let photosURL = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first {
            inputFolder = photosURL
        }
    }
    
    private func selectDesktop() {
        if let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first {
            inputFolder = desktopURL
        }
    }
} 