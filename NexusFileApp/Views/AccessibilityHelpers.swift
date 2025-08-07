import SwiftUI

/// Accessibility helpers for better user experience
struct AccessibilityHelpers {
    
    /// Add accessibility labels to file items
    static func fileAccessibilityLabel(for item: DirectoryItem) -> String {
        if item.isDirectory {
            return "Folder: \(item.name)"
        } else {
            return "File: \(item.name), \(item.formattedFileSize), modified \(item.formattedDate)"
        }
    }
    
    /// Add accessibility hints for actions
    static func accessibilityHint(for action: String) -> String {
        switch action {
        case "delete":
            return "Double tap to delete this item"
        case "rename":
            return "Double tap to rename this item"
        case "share":
            return "Double tap to share this item"
        case "move":
            return "Double tap to move this item to another folder"
        case "duplicate":
            return "Double tap to create a copy of this item"
        default:
            return "Double tap to perform this action"
        }
    }
    
    /// Add accessibility traits for different file types
    static func accessibilityTraits(for item: DirectoryItem) -> AccessibilityTraits {
        if item.isDirectory {
            return [.isButton, .isHeader]
        } else {
            return [.isButton]
        }
    }
}

/// Extension to add accessibility to common views
extension View {
    func accessibleFileItem(_ item: DirectoryItem) -> some View {
        self
            .accessibilityLabel(AccessibilityHelpers.fileAccessibilityLabel(for: item))
    }
    
    func accessibleAction(_ action: String) -> some View {
        self
            .accessibilityHint(AccessibilityHelpers.accessibilityHint(for: action))
    }
    
    func accessibleButton(_ label: String, action: String) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(AccessibilityHelpers.accessibilityHint(for: action))
    }
} 