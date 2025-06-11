//
//  NexusFileAppTests.swift
//  NexusFileAppTests
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import Testing
@testable import NexusFileApp

struct NexusFileAppTests {

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

    @Test func importFile() throws {
        let service = try makeService()
        let fm = FileManager.default
        let src = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".txt")
        try "hello".write(to: src, atomically: true, encoding: .utf8)
        service.importFile(from: src)
        let dest = service.currentURL.appendingPathComponent(src.lastPathComponent).path
        #expect(fm.fileExists(atPath: dest))
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

}
