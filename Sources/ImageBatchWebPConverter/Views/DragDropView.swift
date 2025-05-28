import SwiftUI
import UniformTypeIdentifiers

struct DragDropView: View {
    @Binding var inputFolder: URL?
    @Binding var selectedFiles: [URL]
    @State private var isDragging = false
    
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
                    
                    if !selectedFiles.isEmpty {
                        Text("\(selectedFiles.count) files selected")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.top, 4)
                    } else if inputFolder != nil {
                        Text("Folder selected")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.top, 4)
                    }
                }
                
                // Quick action buttons
                HStack(spacing: 12) {
                    Button(action: selectFiles) {
                        Label("Select Files", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: selectFolder) {
                        Label("Select Folder", systemImage: "folder")
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
            selectFiles()
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        var droppedFiles: [URL] = []
        var droppedFolder: URL? = nil
        
        let group = DispatchGroup()
        
        for provider in providers {
            group.enter()
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                defer { group.leave() }
                
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    
                    var isDirectory: ObjCBool = false
                    if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                        if isDirectory.boolValue {
                            droppedFolder = url
                        } else if isImageFile(url) {
                            droppedFiles.append(url)
                        }
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            // Clear previous selection
            self.selectedFiles = []
            self.inputFolder = nil
            
            // Prioritize folder if both files and folder are dropped
            if let folder = droppedFolder {
                self.inputFolder = folder
            } else if !droppedFiles.isEmpty {
                self.selectedFiles = droppedFiles
            }
        }
    }
    
    private func isImageFile(_ url: URL) -> Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "bmp", "tif", "tiff", "heic", "webp"]
        return imageExtensions.contains(url.pathExtension.lowercased())
    }
    
    private func selectFiles() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.jpeg, .png, .bmp, .tiff, .heic]
        panel.message = "Select image files to convert"
        
        panel.begin { response in
            if response == .OK {
                // Clear folder selection when files are selected
                self.inputFolder = nil
                self.selectedFiles = panel.urls
            }
        }
    }
    
    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "Select a folder containing images to convert"
        
        panel.begin { response in
            if response == .OK {
                // Clear file selection when folder is selected
                self.selectedFiles = []
                self.inputFolder = panel.url
            }
        }
    }
} 