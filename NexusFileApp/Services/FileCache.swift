import Foundation
import os.log

/// Cache for file metadata to improve performance
final class FileCache: ObservableObject {
    private let logger = Logger(subsystem: "com.leon.NexusFileApp", category: "FileCache")
    private var cache: [URL: DirectoryItem] = [:]
    private let queue = DispatchQueue(label: "com.leon.NexusFileApp.cache", qos: .utility)
    
    func getItem(for url: URL) -> DirectoryItem? {
        queue.sync {
            return cache[url]
        }
    }
    
    func setItem(_ item: DirectoryItem, for url: URL) {
        queue.async {
            self.cache[url] = item
        }
    }
    
    func removeItem(for url: URL) {
        queue.async {
            self.cache.removeValue(forKey: url)
        }
    }
    
    func clearCache() {
        queue.async {
            self.cache.removeAll()
            self.logger.info("Cache cleared")
        }
    }
    
    func preloadItems(for urls: [URL]) {
        queue.async {
            for url in urls {
                if self.cache[url] == nil {
                    let item = DirectoryItem(id: url)
                    self.cache[url] = item
                }
            }
            self.logger.info("Preloaded \(urls.count) items")
        }
    }
    
    func getCacheSize() -> Int {
        queue.sync {
            return cache.count
        }
    }
} 