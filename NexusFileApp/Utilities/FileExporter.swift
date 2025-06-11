import Foundation

/// Supported export formats.
enum ExportFormat {
    case csv
    case pdf
}

/// Errors that can occur during file export.
enum FileExporterError: LocalizedError {
    case missingFarmer

    var errorDescription: String? {
        switch self {
        case .missingFarmer:
            return "Unable to access farmer data."
        }
    }
}

/// Helper responsible for creating export files.
struct FileExporter {
    static func export(farmer: Farmer, format: ExportFormat) throws -> URL {
        let folder = SharedFileManager.shared.documentsURL
            .appendingPathComponent("Calibration Sheets", isDirectory: true)
            .appendingPathComponent(farmer.name, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        var filename = "\(farmer.name)_Trekker Inligting_\(dateFormatter.string(from: Date()))"
        switch format {
        case .csv:
            filename += ".csv"
        case .pdf:
            filename += ".pdf"
        }
        let fileURL = folder.appendingPathComponent(filename)
        switch format {
        case .csv:
            try CSVExporter.export(farmer: farmer, to: fileURL)
        case .pdf:
            try PDFExporter.export(farmer: farmer, to: fileURL)
        }
        return fileURL
    }

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        return df
    }()
}
