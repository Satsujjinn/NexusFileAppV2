//
//  NexusFileAppApp.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import SwiftUI
import os.log

@main
struct NexusFileAppApp: App {
    @State private var importURL: URL?
    @State private var openFileURL: URL?
    @State private var showError = false
    @State private var appError: AppError?
    
    private let logger = Logger(subsystem: "com.leon.NexusFileApp", category: "App")

    var body: some Scene {
        WindowGroup {
            HomeView(openFileURL: $openFileURL)
                .accentColor(.nexusGreen)
                .background(Color.white.ignoresSafeArea())
                .onOpenURL { url in
                    handleOpenURL(url)
                }
                .sheet(item: $importURL) { fileURL in
                    ImportFileView(fileURL: fileURL) { saved in
                        importURL = nil
                        openFileURL = saved
                    }
                }
                .alert("Error", isPresented: $showError) {
                    Button("OK") {
                        showError = false
                        appError = nil
                    }
                } message: {
                    if let error = appError {
                        Text(error.errorDescription ?? "An unknown error occurred")
                    }
                }
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Configure logging
        logger.info("NexusFileApp started")
        
        // Ensure documents directory exists
        do {
            let documentsURL = SharedFileManager.shared.documentsURL
            try FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true)
            logger.info("Documents directory ready at \(documentsURL.path)")
        } catch {
            logger.error("Failed to create documents directory: \(error.localizedDescription)")
            appError = AppError.fileOperationFailed("Failed to initialize app")
            showError = true
        }
    }
    
    private func handleOpenURL(_ url: URL) {
        logger.info("Handling open URL: \(url)")
        
        if url.isFileURL {
            handleFileURL(url)
        } else if url.scheme == "nexusfileapp" {
            handleCustomURL(url)
        } else {
            logger.warning("Unknown URL scheme: \(url.scheme ?? "nil")")
        }
    }
    
    private func handleFileURL(_ url: URL) {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent(url.lastPathComponent)
        
        do {
            try FileManager.default.removeItem(at: tmp)
        } catch {
            // Ignore removal errors
        }
        
        do {
            try FileManager.default.copyItem(at: url, to: tmp)
            importURL = tmp
            logger.info("Successfully imported file: \(url.lastPathComponent)")
        } catch {
            logger.error("Failed to import file: \(error.localizedDescription)")
            appError = AppError.importFailed(error.localizedDescription)
            showError = true
        }
    }
    
    private func handleCustomURL(_ url: URL) {
        let path = url.path.dropFirst()
        if !path.isEmpty {
            let dest = SharedFileManager.shared.documentsURL
                .appendingPathComponent(String(path))
            openFileURL = dest
            logger.info("Opening file via custom URL: \(dest.path)")
        }
    }
}
