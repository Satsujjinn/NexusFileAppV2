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

    var body: some Scene {
        WindowGroup {
            HomeView()
                .accentColor(.nexusGreen)
                .background(Color.nexusBackground.ignoresSafeArea())
                .onOpenURL { url in
                    guard url.isFileURL else { return }

                    let tmp = FileManager.default.temporaryDirectory
                        .appendingPathComponent(url.lastPathComponent)
                    try? FileManager.default.removeItem(at: tmp)
                    do {
                        try FileManager.default.copyItem(at: url, to: tmp)
                        importURL = tmp
                    } catch {
                        // Ignore copy failures
                    }
                }
                .sheet(item: $importURL) { fileURL in
                    ImportFileView(fileURL: fileURL) {
                        importURL = nil
                    }
                }
        }
    }
}
