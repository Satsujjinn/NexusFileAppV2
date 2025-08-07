//
//  FileManagerService.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import Foundation
import os.log

class FileManagerService: ObservableObject {
    @Published var items: [DirectoryItem] = []
    @Published var isLoading = false
    @Published var error: AppError?
    
    private let fileManager = FileManager.default
    private let documentsURL: URL
    private(set) var currentURL: URL
    private let logger = Logger(subsystem: "com.leon.NexusFileApp", category: "FileManager")
    
    /// Your top-level categories for agricultural sales
    private let defaultCategories = [
        "Spray Programs",
        "Product Labels",
        "Safety Data",
        "Crop Information",
        "Client Documents",
        "Technical Data"
    ]

    init(startingAt url: URL? = nil,
         documentsURL: URL = SharedFileManager.shared.documentsURL) {
        self.documentsURL = documentsURL
        self.currentURL = url ?? documentsURL

        ensureDefaultCategories()
        loadItems()
    }

    private func ensureDefaultCategories() {
        var isDir: ObjCBool = false
        if !fileManager.fileExists(atPath: documentsURL.path, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(at: documentsURL, withIntermediateDirectories: true)
                logger.info("Created documents directory at \(self.documentsURL.path)")
            } catch {
                logger.error("Failed to create documents directory: \(error.localizedDescription)")
                self.error = AppError.fileOperationFailed("Failed to create documents directory")
            }
        }

        let migrations = [
            (old: "Calibrations", new: "Saved"),
            (old: "Calibration Sheets", new: "Saved"),
            (old: "Crop Information", new: "Crop Info")
        ]

        for (old, new) in migrations {
            let oldURL = documentsURL.appendingPathComponent(old, isDirectory: true)
            let newURL = documentsURL.appendingPathComponent(new, isDirectory: true)
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: oldURL.path, isDirectory: &isDir) {
                if !fileManager.fileExists(atPath: newURL.path, isDirectory: &isDir) {
                    do {
                        try fileManager.moveItem(at: oldURL, to: newURL)
                        logger.info("Migrated \(old) to \(new)")
                    } catch {
                        logger.error("Failed to migrate \(old) to \(new): \(error.localizedDescription)")
                    }
                } else {
                    if let items = try? fileManager.contentsOfDirectory(at: oldURL, includingPropertiesForKeys: nil) {
                        for item in items {
                            let dest = newURL.appendingPathComponent(item.lastPathComponent)
                            if !fileManager.fileExists(atPath: dest.path) {
                                do {
                                    try fileManager.moveItem(at: item, to: dest)
                                } catch {
                                    logger.error("Failed to move item during migration: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                    try? fileManager.removeItem(at: oldURL)
                }
            }
        }

        guard
            let contents = try? fileManager.contentsOfDirectory(
                at: documentsURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ),
            !contents.contains(where: { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false })
        else { return }

        for name in defaultCategories {
            let folderURL = documentsURL.appendingPathComponent(name, isDirectory: true)
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
                logger.info("Created default category: \(name)")
            } catch {
                logger.error("Failed to create default category \(name): \(error.localizedDescription)")
            }
        }
    }

    func loadItems() {
        isLoading = true
        error = nil
        
        let keys: [URLResourceKey] = [.isDirectoryKey, .contentModificationDateKey, .fileSizeKey]
        guard let urls = try? fileManager.contentsOfDirectory(
            at: currentURL,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles]
        ) else {
            items = []
            isLoading = false
            error = AppError.fileOperationFailed("Failed to load directory contents")
            return
        }

        items = urls.map { DirectoryItem(id: $0) }
            .sorted {
                if $0.isDirectory && !$1.isDirectory { return true }
                if !$0.isDirectory && $1.isDirectory { return false }
                return $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
        
        isLoading = false
        logger.info("Loaded \(self.items.count) items from \(self.currentURL.path)")
    }

    /// Load items on a background queue to avoid blocking the UI.
    func loadItemsAsync() {
        isLoading = true
        error = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let keys: [URLResourceKey] = [.isDirectoryKey, .contentModificationDateKey, .fileSizeKey]
            guard let urls = try? self.fileManager.contentsOfDirectory(
                at: self.currentURL,
                includingPropertiesForKeys: keys,
                options: [.skipsHiddenFiles]
            ) else {
                DispatchQueue.main.async {
                    self.items = []
                    self.isLoading = false
                    self.error = AppError.fileOperationFailed("Failed to load directory contents")
                }
                return
            }

            let newItems = urls.map { DirectoryItem(id: $0) }
                .sorted {
                    if $0.isDirectory && !$1.isDirectory { return true }
                    if !$0.isDirectory && $1.isDirectory { return false }
                    return $0.name.localizedStandardCompare($1.name) == .orderedAscending
                }

            DispatchQueue.main.async {
                self.items = newItems
                self.isLoading = false
                self.logger.info("Async loaded \(newItems.count) items from \(self.currentURL.path)")
            }
        }
    }

    func navigate(to item: DirectoryItem) -> FileManagerService {
        FileManagerService(startingAt: item.id, documentsURL: documentsURL)
    }

    func createFolder(named name: String) {
        let newURL = currentURL.appendingPathComponent(name, isDirectory: true)
        do {
            try fileManager.createDirectory(at: newURL, withIntermediateDirectories: true)
            logger.info("Created folder: \(name)")
            loadItems()
            Haptics.success()
        } catch {
            logger.error("Failed to create folder \(name): \(error.localizedDescription)")
            self.error = AppError.fileOperationFailed("Failed to create folder: \(error.localizedDescription)")
            Haptics.error()
        }
    }

    func importFile(from url: URL) {
        let didStart = url.startAccessingSecurityScopedResource()
        defer { if didStart { url.stopAccessingSecurityScopedResource() } }

        let dest = currentURL.appendingPathComponent(url.lastPathComponent)

        if fileManager.fileExists(atPath: dest.path) {
            do {
                try fileManager.removeItem(at: dest)
            } catch {
                logger.error("Failed to remove existing file: \(error.localizedDescription)")
                self.error = AppError.fileOperationFailed("Failed to replace existing file")
                Haptics.error()
                return
            }
        }

        do {
            try fileManager.copyItem(at: url, to: dest)
            logger.info("Imported file: \(url.lastPathComponent)")
            loadItems()
            Haptics.success()
        } catch {
            logger.error("Import failed for \(url.lastPathComponent): \(error.localizedDescription)")
            self.error = AppError.importFailed(error.localizedDescription)
            Haptics.error()
        }
    }

    func delete(item: DirectoryItem) {
        do {
            try fileManager.removeItem(at: item.id)
            logger.info("Deleted item: \(item.name)")
            loadItems()
            Haptics.success()
        } catch {
            logger.error("Failed to delete \(item.name): \(error.localizedDescription)")
            self.error = AppError.fileOperationFailed("Failed to delete item: \(error.localizedDescription)")
            Haptics.error()
        }
    }

    func rename(item: DirectoryItem, to newName: String) {
        let newURL = item.id.deletingLastPathComponent()
            .appendingPathComponent(newName, isDirectory: item.isDirectory)
        do {
            try fileManager.moveItem(at: item.id, to: newURL)
            logger.info("Renamed \(item.name) to \(newName)")
            loadItems()
            Haptics.success()
        } catch {
            logger.error("Failed to rename \(item.name) to \(newName): \(error.localizedDescription)")
            self.error = AppError.fileOperationFailed("Failed to rename item: \(error.localizedDescription)")
            Haptics.error()
        }
    }

    func duplicate(item: DirectoryItem) {
        let originalURL = item.id
        let base = originalURL.deletingPathExtension().lastPathComponent
        let ext = originalURL.pathExtension
        let copyName = "\(base) copy.\(ext)"
        let destURL = currentURL.appendingPathComponent(copyName)
        
        do {
            try fileManager.copyItem(at: originalURL, to: destURL)
            logger.info("Duplicated \(item.name) to \(copyName)")
            loadItems()
            Haptics.success()
        } catch {
            logger.error("Failed to duplicate \(item.name): \(error.localizedDescription)")
            self.error = AppError.fileOperationFailed("Failed to duplicate item: \(error.localizedDescription)")
            Haptics.error()
        }
    }

    func move(item: DirectoryItem, to subfolder: String) {
        let destFolder = documentsURL.appendingPathComponent(subfolder, isDirectory: true)
        do {
            try fileManager.createDirectory(at: destFolder, withIntermediateDirectories: true)
            let destURL = destFolder.appendingPathComponent(item.id.lastPathComponent)
            
            if fileManager.fileExists(atPath: destURL.path) {
                try fileManager.removeItem(at: destURL)
            }
            try fileManager.moveItem(at: item.id, to: destURL)
            logger.info("Moved \(item.name) to \(subfolder)")
            loadItems()
            Haptics.success()
        } catch {
            logger.error("Failed to move \(item.name) to \(subfolder): \(error.localizedDescription)")
            self.error = AppError.fileOperationFailed("Failed to move item: \(error.localizedDescription)")
            Haptics.error()
        }
    }

    func exportAsPDF(item: DirectoryItem) -> URL? {
        do {
            let url = try ExcelPDFExporter.export(at: item.id)
            logger.info("Exported \(item.name) as PDF")
            Haptics.success()
            return url
        } catch {
            logger.error("Failed to export \(item.name) as PDF: \(error.localizedDescription)")
            self.error = AppError.exportFailed(error.localizedDescription)
            Haptics.error()
            return nil
        }
    }


}
