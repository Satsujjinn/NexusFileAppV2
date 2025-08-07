import Testing
@testable import NexusFileApp

struct FileManagerServiceTests {
    
    private func makeService() throws -> FileManagerService {
        let fm = FileManager.default
        let tempRoot = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fm.createDirectory(at: tempRoot, withIntermediateDirectories: true)
        return FileManagerService(startingAt: tempRoot, documentsURL: tempRoot)
    }
    
    @Test func createFolder() throws {
        let service = try makeService()
        let fm = FileManager.default
        service.createFolder(named: "Test")
        let path = service.currentURL.appendingPathComponent("Test").path
        #expect(fm.fileExists(atPath: path))
    }
    
    @Test func createFolderWithSpecialCharacters() throws {
        let service = try makeService()
        let fm = FileManager.default
        service.createFolder(named: "Test Folder (1)")
        let path = service.currentURL.appendingPathComponent("Test Folder (1)").path
        #expect(fm.fileExists(atPath: path))
    }
    
    @Test func importFile() throws {
        let service = try makeService()
        let fm = FileManager.default
        let src = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".txt")
        try "hello".write(to: src, atomically: true, encoding: .utf8)
        service.importFile(from: src)
        let dest = service.currentURL.appendingPathComponent(src.lastPathComponent).path
        #expect(fm.fileExists(atPath: dest))
    }
    
    @Test func importFileWithExistingFile() throws {
        let service = try makeService()
        let fm = FileManager.default
        let src = fm.temporaryDirectory.appendingPathComponent("test.txt")
        try "hello".write(to: src, atomically: true, encoding: .utf8)
        
        // Import first time
        service.importFile(from: src)
        let dest = service.currentURL.appendingPathComponent("test.txt")
        #expect(fm.fileExists(atPath: dest.path))
        
        // Import again (should replace)
        try "world".write(to: src, atomically: true, encoding: .utf8)
        service.importFile(from: src)
        let content = try String(contentsOf: dest)
        #expect(content == "world")
    }
    
    @Test func rename() throws {
        let service = try makeService()
        let fm = FileManager.default
        let file = service.currentURL.appendingPathComponent("file.txt")
        try "data".write(to: file, atomically: true, encoding: .utf8)
        service.loadItems()
        let item = DirectoryItem(id: file)
        service.rename(item: item, to: "renamed.txt")
        let newURL = service.currentURL.appendingPathComponent("renamed.txt")
        #expect(fm.fileExists(atPath: newURL.path))
        #expect(!fm.fileExists(atPath: file.path))
    }
    
    @Test func delete() throws {
        let service = try makeService()
        let fm = FileManager.default
        let file = service.currentURL.appendingPathComponent("todelete.txt")
        try "bye".write(to: file, atomically: true, encoding: .utf8)
        service.loadItems()
        let item = DirectoryItem(id: file)
        service.delete(item: item)
        #expect(!fm.fileExists(atPath: file.path))
    }
    
    @Test func move() throws {
        let service = try makeService()
        let fm = FileManager.default
        let src = service.currentURL.appendingPathComponent("src.txt")
        try "data".write(to: src, atomically: true, encoding: .utf8)
        service.loadItems()
        service.createFolder(named: "Dest")
        let item = DirectoryItem(id: src)
        service.move(item: item, to: "Dest")
        let dest = service.currentURL.appendingPathComponent("Dest/src.txt")
        #expect(fm.fileExists(atPath: dest.path))
        #expect(!fm.fileExists(atPath: src.path))
    }
    
    @Test func duplicate() throws {
        let service = try makeService()
        let fm = FileManager.default
        let file = service.currentURL.appendingPathComponent("original.txt")
        try "original content".write(to: file, atomically: true, encoding: .utf8)
        service.loadItems()
        let item = DirectoryItem(id: file)
        service.duplicate(item: item)
        let copy = service.currentURL.appendingPathComponent("original copy.txt")
        #expect(fm.fileExists(atPath: copy.path))
        #expect(fm.fileExists(atPath: file.path))
    }
    
    @Test func loadItemsAsync() throws {
        let service = try makeService()
        let fm = FileManager.default
        
        // Create some test files
        let file1 = service.currentURL.appendingPathComponent("test1.txt")
        let file2 = service.currentURL.appendingPathComponent("test2.txt")
        try "content1".write(to: file1, atomically: true, encoding: .utf8)
        try "content2".write(to: file2, atomically: true, encoding: .utf8)
        
        service.loadItemsAsync()
        
        // Wait a bit for async operation
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        #expect(service.items.count >= 2)
        #expect(service.items.contains { $0.name == "test1.txt" })
        #expect(service.items.contains { $0.name == "test2.txt" })
    }
    
    @Test func directoryItemProperties() throws {
        let service = try makeService()
        let fm = FileManager.default
        let file = service.currentURL.appendingPathComponent("test.txt")
        try "test content".write(to: file, atomically: true, encoding: .utf8)
        
        let item = DirectoryItem(id: file)
        #expect(item.name == "test.txt")
        #expect(!item.isDirectory)
        #expect(item.fileExtension == "txt")
        #expect(item.isText)
        #expect(!item.isPDF)
        #expect(!item.isExcel)
        #expect(item.fileSize > 0)
        #expect(item.modificationDate > Date.distantPast)
    }
    
    @Test func directoryItemSorting() throws {
        let service = try makeService()
        let fm = FileManager.default
        
        // Create files and folders
        let folder = service.currentURL.appendingPathComponent("folder")
        let file1 = service.currentURL.appendingPathComponent("a.txt")
        let file2 = service.currentURL.appendingPathComponent("b.txt")
        
        try fm.createDirectory(at: folder, withIntermediateDirectories: true)
        try "content1".write(to: file1, atomically: true, encoding: .utf8)
        try "content2".write(to: file2, atomically: true, encoding: .utf8)
        
        service.loadItems()
        
        let directories = service.items.filter(\.isDirectory)
        let files = service.items.filter { !$0.isDirectory }
        
        #expect(directories.count >= 1)
        #expect(files.count >= 2)
        
        // Check that directories come before files
        let sortedItems = service.items
        let firstDirectoryIndex = sortedItems.firstIndex { $0.isDirectory }
        let firstFileIndex = sortedItems.firstIndex { !$0.isDirectory }
        
        if let dirIndex = firstDirectoryIndex, let fileIndex = firstFileIndex {
            #expect(dirIndex < fileIndex)
        }
    }
} 