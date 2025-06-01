import SwiftUI
import UniformTypeIdentifiers

struct DragDropView: View {
    @Binding var inputFolder: URL?
    @Binding var selectedFiles: [URL]
    @State private var isDragging = false
    @State private var isHovered = false
    
    var body: some View {
        ZStack {
            // Background with glass morphism
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    if #available(macOS 12.0, *) {
                        .ultraThinMaterial
                    } else {
                        Color(NSColor.controlBackgroundColor)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(
                            LinearGradient(
                                colors: isDragging ? 
                                    [.blue.opacity(0.8), .blue.opacity(0.4)] : 
                                    [.gray.opacity(0.2), .gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isDragging ? 3 : 2
                        )
                )
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            isDragging ? 
                                .blue.opacity(0.05) : 
                                .clear
                        )
                )
                .scaleEffect(isDragging ? 1.02 : (isHovered ? 1.01 : 1.0))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isDragging)
                .animation(.easeInOut(duration: 0.2), value: isHovered)
            
            VStack(spacing: 32) {
                // Icon with animation
                VStack(spacing: 16) {
                    ZStack {
                        // Background circle
                        Circle()
                            .fill(.blue.opacity(isDragging ? 0.2 : 0.1))
                            .frame(width: 120, height: 120)
                            .scaleEffect(isDragging ? 1.1 : 1.0)
                        
                        // Main icon
                        if #available(macOS 14.0, *) {
                            Image(systemName: isDragging ? "arrow.down.circle.fill" : "plus.circle.fill")
                                .font(.system(size: 56, weight: .light))
                                .foregroundStyle(
                                    isDragging ? 
                                        .blue : 
                                        Color.secondary
                                )
                                .symbolEffect(.bounce, value: isDragging)
                                .symbolEffect(.pulse.wholeSymbol, options: .repeating, value: isDragging)
                        } else {
                            Image(systemName: isDragging ? "arrow.down.circle.fill" : "plus.circle.fill")
                                .font(.system(size: 56, weight: .light))
                                .foregroundStyle(
                                    isDragging ? 
                                        .blue : 
                                        Color.secondary
                                )
                        }
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isDragging)
                }
                
                // Text content
                VStack(spacing: 12) {
                    Text(isDragging ? "Drop to optimize" : "Drop images or folders")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .foregroundColor(isDragging ? .blue : .primary)
                    
                    Group {
                        if !selectedFiles.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("\(selectedFiles.count) files selected")
                            }
                            .font(.title2)
                            .foregroundColor(.green)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                        } else if inputFolder != nil {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Folder selected")
                            }
                            .font(.title2)
                            .foregroundColor(.green)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                        } else {
                            VStack(spacing: 8) {
                                Text("AI will automatically optimize for web use")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Text("Click here to browse files")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedFiles.count)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: inputFolder != nil)
                }
                
                // Remove action buttons completely - the entire zone is now clickable
            }
            .padding(40)
        }
        .frame(height: 360)
        .contentShape(Rectangle())
        .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
            handleDrop(providers: providers)
            return true
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            // Show an alert with options for files or folders
            let alert = NSAlert()
            alert.messageText = "What would you like to select?"
            alert.informativeText = "Choose whether to select individual files or an entire folder containing images."
            
            alert.addButton(withTitle: "Select Files")
            alert.addButton(withTitle: "Select Folder")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            
            switch response {
            case .alertFirstButtonReturn:
                selectFiles()
            case .alertSecondButtonReturn:
                selectFolder()
            default:
                break
            }
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
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
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
        panel.allowedContentTypes = [.jpeg, .png, .bmp, .tiff, .heic, .webp]
        panel.message = "Select image files to convert to WebP format"
        panel.prompt = "Select"
        panel.title = "Choose Images"
        
        // Set a default directory (Desktop or Pictures)
        if let picturesURL = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first {
            panel.directoryURL = picturesURL
        }
        
        panel.begin { response in
            if response == .OK {
                let selectedURLs = panel.urls
                
                // Validate all selected files are images
                let validImageFiles = selectedURLs.filter { url in
                    self.isImageFile(url)
                }
                
                if validImageFiles.isEmpty {
                    // Show error if no valid images
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "No valid image files selected"
                        alert.informativeText = "Please select image files (JPEG, PNG, BMP, TIFF, HEIC, or WebP)."
                        alert.alertStyle = .warning
                        alert.runModal()
                    }
                    return
                }
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    // Clear folder selection when files are selected
                    self.inputFolder = nil
                    self.selectedFiles = validImageFiles
                }
                
                // Show success feedback
                if validImageFiles.count != selectedURLs.count {
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "Some files were filtered out"
                        alert.informativeText = "\(validImageFiles.count) of \(selectedURLs.count) files were valid images and will be processed."
                        alert.alertStyle = .informational
                        alert.runModal()
                    }
                }
            }
        }
    }
    
    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "Select a folder containing images to convert"
        panel.prompt = "Select Folder"
        panel.title = "Choose Image Folder"
        
        // Set a default directory (Desktop or Pictures)
        if let picturesURL = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first {
            panel.directoryURL = picturesURL
        }
        
        panel.begin { response in
            if response == .OK, let selectedFolder = panel.url {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    // Clear file selection when folder is selected
                    self.selectedFiles = []
                    self.inputFolder = selectedFolder
                }
            }
        }
    }
} 