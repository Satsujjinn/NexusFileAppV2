//
//  NexusFileAppApp.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import SwiftUI

@main
struct NexusFileAppApp: App {
    @State private var importURL: URL?
    @State private var openFileURL: URL?

    var body: some Scene {
        WindowGroup {
            HomeView(openFileURL: $openFileURL)
                .accentColor(.nexusGreen)
                .background(Color.nexusBackground.ignoresSafeArea())
                .onOpenURL { url in
                    if url.isFileURL {
                        let tmp = FileManager.default.temporaryDirectory
                            .appendingPathComponent(url.lastPathComponent)
                        try? FileManager.default.removeItem(at: tmp)
                        do {
                            try FileManager.default.copyItem(at: url, to: tmp)
                            importURL = tmp
                        } catch {
                            // Ignore copy failures
                        }
                    } else if url.scheme == "nexusfileapp" {
                        let path = url.path.dropFirst()
                        if !path.isEmpty {
                            let dest = SharedFileManager.shared.documentsURL
                                .appendingPathComponent(String(path))
                            openFileURL = dest
                        }
                    }
                }
                .sheet(item: $importURL) { fileURL in
                    ImportFileView(fileURL: fileURL) { saved in
                        importURL = nil
                        openFileURL = saved
                    }
                }
        }
    }
}
