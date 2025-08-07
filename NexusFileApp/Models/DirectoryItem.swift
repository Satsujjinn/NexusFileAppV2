import Foundation

struct DirectoryItem: Identifiable, Hashable {
    let id: URL
    
    var name: String { id.lastPathComponent }
    
    var isDirectory: Bool {
        (try? id.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
    }
    
    var fileSize: Int64 {
        Int64((try? id.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
    }
    
    var modificationDate: Date {
        (try? id.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
    }
    
    var creationDate: Date {
        (try? id.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
    }
    
    var fileExtension: String {
        id.pathExtension.lowercased()
    }
    
    var isImage: Bool {
        ["jpg", "jpeg", "png", "gif", "heic", "heif"].contains(fileExtension)
    }
    
    var isPDF: Bool {
        fileExtension == "pdf"
    }
    
    var isExcel: Bool {
        ["xls", "xlsx", "xlsm"].contains(fileExtension)
    }
    
    var isWord: Bool {
        ["doc", "docx"].contains(fileExtension)
    }
    
    var isText: Bool {
        ["txt", "rtf", "md"].contains(fileExtension)
    }
    
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: modificationDate)
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DirectoryItem, rhs: DirectoryItem) -> Bool {
        lhs.id == rhs.id
    }
}
