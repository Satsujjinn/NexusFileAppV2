import Foundation

final class SharedFileManager {
    static let shared = SharedFileManager()
    private let fileManager = FileManager.default
    private init() {}

    var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
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
}
