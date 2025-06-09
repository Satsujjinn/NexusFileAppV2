import Foundation

final class SharedFileManager {
    static let shared = SharedFileManager()
    private let fileManager = FileManager.default
    private init() {}

    /// Identifier for the shared app group used by the app and the
    /// share extension so they operate on the same file container.
    private let appGroupID = "group.com.leon.NexusFileApp"

    /// Base Documents directory inside the shared app group container.
    var documentsURL: URL {
        fileManager
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!
            .appendingPathComponent("Documents", isDirectory: true)
    }

    func listFiles(in subpath: String = "") -> [URL] {
        let baseURL = subpath.isEmpty ? documentsURL : documentsURL.appendingPathComponent(subpath, isDirectory: true)
        return (try? fileManager.contentsOfDirectory(at: baseURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])) ?? []
    }

    func readFile(at url: URL) -> Data? {
        try? Data(contentsOf: url)
    }

    @discardableResult
    func write(_ data: Data, named name: String, in subpath: String = "") throws -> URL {
        let folder = subpath.isEmpty ? documentsURL : documentsURL.appendingPathComponent(subpath, isDirectory: true)
        try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        let dest = folder.appendingPathComponent(name)
        try data.write(to: dest, options: .atomic)
        return dest
    }

    func save(file url: URL, to subfolder: String, named name: String) throws {
        let folder = documentsURL.appendingPathComponent(subfolder, isDirectory: true)
        try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        let dest = folder.appendingPathComponent(name)
        if fileManager.fileExists(atPath: dest.path) {
            try fileManager.removeItem(at: dest)
        }
        try fileManager.copyItem(at: url, to: dest)
    }

    /// Create a subfolder inside an optional parent path
    func createSubfolder(named name: String, in parent: String = "") throws {
        var url = documentsURL
        if !parent.isEmpty {
            url.appendPathComponent(parent, isDirectory: true)
        }
        url.appendPathComponent(name, isDirectory: true)
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }

    /// List subfolders inside an optional relative path
    func listFolders(at subpath: String = "") -> [String] {
        let url = subpath.isEmpty ? documentsURL : documentsURL.appendingPathComponent(subpath, isDirectory: true)
        guard let contents = try? fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        return contents
            .filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false }
            .map { $0.lastPathComponent }
            .sorted()
    }
}
