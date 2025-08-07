import Foundation

/// Centralized error handling for the app with enhanced App Store compliance
enum AppError: LocalizedError, Identifiable {
    case fileOperationFailed(String)
    case importFailed(String)
    case exportFailed(String)
    case invalidFileType(String)
    case permissionDenied(String)
    case networkError(String)
    case storageFull(String)
    case corruptedData(String)
    case unsupportedOperation(String)
    case unknown(String)
    
    var id: String { localizedDescription }
    
    var errorDescription: String? {
        switch self {
        case .fileOperationFailed(let message):
            return "File operation failed: \(message)"
        case .importFailed(let message):
            return "Import failed: \(message)"
        case .exportFailed(let message):
            return "Export failed: \(message)"
        case .invalidFileType(let message):
            return "Invalid file type: \(message)"
        case .permissionDenied(let message):
            return "Permission denied: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .storageFull(let message):
            return "Storage full: \(message)"
        case .corruptedData(let message):
            return "Data corruption detected: \(message)"
        case .unsupportedOperation(let message):
            return "Unsupported operation: \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .fileOperationFailed:
            return "Please try again or check if the file is accessible. If the problem persists, restart the app."
        case .importFailed:
            return "Make sure the file is not corrupted and try again. Check that you have sufficient storage space."
        case .exportFailed:
            return "Check available storage space and try again. Ensure the file is not being used by another app."
        case .invalidFileType:
            return "This file type is not supported. Please use PDF, Excel, Word, or image files."
        case .permissionDenied:
            return "Please grant the necessary permissions in Settings > Privacy & Security."
        case .networkError:
            return "Check your internet connection and try again. If using cellular data, ensure you have sufficient data allowance."
        case .storageFull:
            return "Free up storage space on your device or iCloud, then try again."
        case .corruptedData:
            return "The file appears to be corrupted. Try importing the original file again."
        case .unsupportedOperation:
            return "This operation is not supported in the current version. Please update the app if available."
        case .unknown:
            return "Please try again or contact support if the problem persists. Include the error details when contacting support."
        }
    }
    
    var errorCode: Int {
        switch self {
        case .fileOperationFailed: return 1001
        case .importFailed: return 1002
        case .exportFailed: return 1003
        case .invalidFileType: return 1004
        case .permissionDenied: return 1006
        case .networkError: return 1007
        case .storageFull: return 1008
        case .corruptedData: return 1009
        case .unsupportedOperation: return 1010
        case .unknown: return 9999
        }
    }
    
    var isUserRecoverable: Bool {
        switch self {
        case .permissionDenied, .storageFull, .networkError:
            return true
        case .fileOperationFailed, .importFailed, .exportFailed:
            return true
        case .invalidFileType, .corruptedData, .unsupportedOperation, .unknown:
            return false
        }
    }
    
    var shouldShowSupportContact: Bool {
        switch self {
        case .corruptedData, .unsupportedOperation, .unknown:
            return true
        default:
            return false
        }
    }
} 