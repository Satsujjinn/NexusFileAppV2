import Foundation

// Conform URL to Identifiable so it can be used with SwiftUI's sheet(item:)
// and similar modifiers.  The URL itself acts as the unique identifier.
extension URL: Identifiable {
    public var id: URL { self }
}
