//
//  FileManagerService.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import Foundation

class FileManagerService: ObservableObject {
    @Published var items: [DirectoryItem] = []

    private let fileManager = FileManager.default
    private let documentsURL: URL
    private(set) var currentURL: URL

    /// Your six required top-level categories in English
    private let defaultCategories = [
        "Spray Programs",
        "MRL",
        "Labels",
        "Calibration Sheets",
        "Recommendations",
        "Crop Info"
    ]

    init(startingAt url: URL? = nil,
         documentsURL: URL = SharedFileManager.shared.documentsURL) {
        self.documentsURL = documentsURL
        self.currentURL = url ?? documentsURL

        ensureDefaultCategories()
        loadItems()
    }

    private func ensureDefaultCategories() {
        let migrations = [
            (old: "Calibrations", new: "Calibration Sheets"),
            (old: "Crop Information", new: "Crop Info")
        ]

        for (old, new) in migrations {
            let oldURL = documentsURL.appendingPathComponent(old, isDirectory: true)
            let newURL = documentsURL.appendingPathComponent(new, isDirectory: true)
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: oldURL.path, isDirectory: &isDir) {
                if !fileManager.fileExists(atPath: newURL.path, isDirectory: &isDir) {
                    try? fileManager.moveItem(at: oldURL, to: newURL)
                } else {
                    if let items = try? fileManager.contentsOfDirectory(at: oldURL, includingPropertiesForKeys: nil) {
                        for item in items {
                            let dest = newURL.appendingPathComponent(item.lastPathComponent)
                            if !fileManager.fileExists(atPath: dest.path) {
                                try? fileManager.moveItem(at: item, to: dest)
                            }
                        }
                    }
                    try? fileManager.removeItem(at: oldURL)
                }
            }
        }

        for name in defaultCategories {
            let folderURL = documentsURL.appendingPathComponent(name, isDirectory: true)
            var isDir: ObjCBool = false
            if !fileManager.fileExists(atPath: folderURL.path, isDirectory: &isDir) {
                try? fileManager.createDirectory(at: folderURL,
                                                 withIntermediateDirectories: false)
            }
        }
    }

    func loadItems() {
        let keys: [URLResourceKey] = [.isDirectoryKey]
        guard let urls = try? fileManager.contentsOfDirectory(
            at: currentURL,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles]
        ) else {
            items = []
            return
        }

        items = urls.map { DirectoryItem(id: $0) }
            .sorted {
                if $0.isDirectory && !$1.isDirectory { return true }
                if !$0.isDirectory && $1.isDirectory { return false }
                return $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
    }

    func navigate(to item: DirectoryItem) -> FileManagerService {
        FileManagerService(startingAt: item.id, documentsURL: documentsURL)
    }

    func createFolder(named name: String) {
        let newURL = currentURL.appendingPathComponent(name, isDirectory: true)
        try? fileManager.createDirectory(at: newURL, withIntermediateDirectories: false)
        loadItems()
    }

    func importFile(from url: URL) {
        let didStart = url.startAccessingSecurityScopedResource()
        defer { if didStart { url.stopAccessingSecurityScopedResource() } }

        let dest = currentURL.appendingPathComponent(url.lastPathComponent)

        if fileManager.fileExists(atPath: dest.path) {
            try? fileManager.removeItem(at: dest)
        }

        do {
            try fileManager.copyItem(at: url, to: dest)
        } catch {
            print("Import failed: \(error)")
        }

        loadItems()
    }

    func delete(item: DirectoryItem) {
        try? fileManager.removeItem(at: item.id)
        loadItems()
    }

    func rename(item: DirectoryItem, to newName: String) {
        let newURL = item.id.deletingLastPathComponent()
            .appendingPathComponent(newName, isDirectory: item.isDirectory)
        try? fileManager.moveItem(at: item.id, to: newURL)
        loadItems()
    }

    func duplicate(item: DirectoryItem) {
        let originalURL = item.id
        let base = originalURL.deletingPathExtension().lastPathComponent
        let ext = originalURL.pathExtension
        let copyName = "\(base) copy.\(ext)"
        let destURL = currentURL.appendingPathComponent(copyName)
        try? fileManager.copyItem(at: originalURL, to: destURL)
        loadItems()
    }

    func exportAsPDF(item: DirectoryItem) -> URL? {
        try? ExcelPDFExporter.export(at: item.id)
    }

    private var iCloudDocumentsURL: URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents", isDirectory: true)
    }

    func backupToICloud() {
        guard let cloud = iCloudDocumentsURL else { return }
        copyRecursive(from: documentsURL, to: cloud)
    }

    func syncFromICloud() {
        guard let cloud = iCloudDocumentsURL else { return }
        copyRecursive(from: cloud, to: documentsURL)
        loadItems()
    }

    private func copyRecursive(from src: URL, to dest: URL) {
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: src.path, isDirectory: &isDir), isDir.boolValue {
            try? fileManager.createDirectory(at: dest, withIntermediateDirectories: true)
            let contents = (try? fileManager.contentsOfDirectory(at: src, includingPropertiesForKeys: nil, options: [])) ?? []
            for item in contents {
                let destItem = dest.appendingPathComponent(item.lastPathComponent)
                copyRecursive(from: item, to: destItem)
            }
        } else {
            if fileManager.fileExists(atPath: dest.path) {
                try? fileManager.removeItem(at: dest)
            }
            try? fileManager.copyItem(at: src, to: dest)
        }
    }
}
