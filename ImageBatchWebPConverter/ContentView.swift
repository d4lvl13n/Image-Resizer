//
//  ContentView.swift
//  ImageBatchWebPConverter
//
//  Created by ChatGPT on 2024-12-25.
//

import SwiftUI
import AppKit

struct ContentView: View {
    
    @State private var inputFolder: URL?       = nil
    @State private var outputFolder: URL?      = nil
    @State private var widthString: String     = "1600" // default width
    @State private var isConverting: Bool      = false
    @State private var statusMessage: String   = ""
    @State private var progress: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Batch Resize & Convert to .webp")
                .font(.title)
                .padding(.bottom, 10)
            
            Group {
                // 1. Select input folder
                HStack {
                    Text("Input Folder:")
                    Spacer()
                    if let folder = inputFolder {
                        Text(folder.lastPathComponent)
                            .foregroundColor(.blue)
                    } else {
                        Text("No folder selected")
                            .foregroundColor(.secondary)
                    }
                    Button("Choose...") { selectFolder(forInput: true) }
                }
                
                // 2. Select output folder
                HStack {
                    Text("Output Folder:")
                    Spacer()
                    if let folder = outputFolder {
                        Text(folder.lastPathComponent)
                            .foregroundColor(.blue)
                    } else {
                        Text("No folder selected")
                            .foregroundColor(.secondary)
                    }
                    Button("Choose...") { selectFolder(forInput: false) }
                }
                
                // 3. Enter target width
                HStack {
                    Text("Target Width:")
                    TextField("1600", text: $widthString)
                        .frame(width: 60)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            // 4. Action buttons
            HStack {
                Button(action: startConversion) {
                    Text("Convert to .webp")
                }
                .disabled(isConverting || inputFolder == nil || outputFolder == nil)
                
                Button(action: {
                    statusMessage = ""
                }) {
                    Text("Clear Log")
                }
            }
            
            // 5. Status or progress
            if isConverting {
                ProgressView(value: progress)
                    .padding(.vertical, 8)
            }
            
            ScrollView {
                Text(statusMessage)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
                    .padding(.top, 8)
            }
            .border(Color.gray.opacity(0.5), width: 1)
            .frame(maxHeight: 200)
            
        }
        .padding(20)
        .frame(minWidth: 500, minHeight: 350)
    }
    
    // MARK: - Folder Selection
    
    private func selectFolder(forInput: Bool) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        
        panel.begin { response in
            guard response == .OK else { return }
            if forInput {
                self.inputFolder = panel.url
            } else {
                self.outputFolder = panel.url
            }
        }
    }
    
    // MARK: - Conversion
    
    private func startConversion() {
        progress = 0
        guard let inFolder = inputFolder,
              let outFolder = outputFolder else {
            return
        }
        
        // Make sure the user typed a valid integer
        guard let targetWidth = Int(widthString), targetWidth > 0 else {
            statusMessage.append("[ERROR] Invalid width: \(widthString)\n")
            return
        }
        
        guard FileManager.default.fileExists(atPath: "/usr/local/bin/cwebp") else {
            statusMessage.append("[ERROR] cwebp not found. Please install WebP tools using Homebrew:\nbrew install webp\n")
            return
        }
        
        isConverting = true
        statusMessage = "Starting conversion...\n"
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // 1) Get all image files in input folder
                let fileManager = FileManager.default
                let items = try fileManager.contentsOfDirectory(at: inFolder,
                                                                includingPropertiesForKeys: nil,
                                                                options: [.skipsHiddenFiles])
                
                // Filter out common image extensions
                let imageExtensions = ["jpg", "jpeg", "png", "bmp", "tif", "tiff"]
                let images = items.filter { url in
                    imageExtensions.contains(url.pathExtension.lowercased())
                }
                
                if images.isEmpty {
                    DispatchQueue.main.async {
                        self.statusMessage.append("No images found in folder.\n")
                        self.isConverting = false
                    }
                    return
                }
                
                // 2) Create output folder if not existing
                if !fileManager.fileExists(atPath: outFolder.path) {
                    try fileManager.createDirectory(at: outFolder, 
                                                    withIntermediateDirectories: true)
                }
                
                // 3) Process each image
                for (index, imgURL) in images.enumerated() {
                    let filename = imgURL.lastPathComponent
                    // remove extension
                    let baseName = filename.split(separator: ".").dropLast().joined(separator: ".")
                    
                    let outWebpURL = outFolder.appendingPathComponent("\(baseName).webp")
                    
                    // a) Create a temporary file for resized JPEG
                    //    because sips can’t directly output .webp
                    let tmpResizedURL = URL(fileURLWithPath: NSTemporaryDirectory())
                        .appendingPathComponent("\(baseName)_temp_\(UUID().uuidString).jpg")
                    
                    // b) Resize with sips
                    let resizeCmd = """
                    /usr/bin/sips --resampleWidth \(targetWidth) "\(imgURL.path)" --out "\(tmpResizedURL.path)"
                    """
                    let resizeResult = shell(resizeCmd)
                    
                    // c) Convert to webp with cwebp
                    let webpCmd = """
                    /usr/local/bin/cwebp -q 80 "\(tmpResizedURL.path)" -o "\(outWebpURL.path)"
                    """
                    let webpResult = shell(webpCmd)
                    
                    // d) Remove temporary file
                    try? fileManager.removeItem(at: tmpResizedURL)
                    
                    // e) Update status
                    DispatchQueue.main.async {
                        self.statusMessage.append("""
                            [\(index+1)/\(images.count)] Processed: \(filename) -> \(outWebpURL.lastPathComponent)\n
                            \(resizeResult.isEmpty ? "" : " sips output: \(resizeResult)\n")
                            \(webpResult.isEmpty ? "" : " cwebp output: \(webpResult)\n")
                            """)
                        self.progress = Double(index + 1) / Double(images.count)
                    }
                }
                
                // Done
                DispatchQueue.main.async {
                    self.statusMessage.append("All images processed!\n")
                    self.isConverting = false
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.statusMessage.append("Error: \(error.localizedDescription)\n")
                    self.isConverting = false
                }
            }
        }
    }
    
    // MARK: - Shell Helper
    
    /// Executes a shell command and returns its output (stdout + stderr).
    private func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()

        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
        } catch {
            return "Failed to run command: \(error.localizedDescription)"
        }
        
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return ""
        }
        return output
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}