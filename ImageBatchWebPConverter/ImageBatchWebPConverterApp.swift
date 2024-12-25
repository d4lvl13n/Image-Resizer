//
//  ImageBatchWebPConverterApp.swift
//  ImageBatchWebPConverter
//
//  Created by ChatGPT on 2024-12-25.
//

import SwiftUI

@main
struct ImageBatchWebPConverterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 500, minHeight: 350)
        }
        .windowStyle(TitleBarWindowStyle())
        .commands {
            // Add standard macOS menu commands
            CommandGroup(replacing: .newItem) { }  // Remove New command
            CommandGroup(replacing: .saveItem) { } // Remove Save command
        }
    }
}