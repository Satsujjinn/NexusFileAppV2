import Foundation

struct AanbevelingExporter {
    static func export(client: Client, format: ExportFormat) throws -> URL {
        let folder = SharedFileManager.shared.documentsURL
            .appendingPathComponent("Saved", isDirectory: true)
            .appendingPathComponent("Aanbevelings", isDirectory: true)
            .appendingPathComponent(client.name, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        var filename = "\(client.name)_\(dateFormatter.string(from: Date()))"
        switch format {
        case .csv: filename += ".csv"
        case .pdf: filename += ".pdf"
        }
        let fileURL = folder.appendingPathComponent(filename)
        switch format {
        case .csv:
            try AanbevelingCSVExporter.export(client: client, to: fileURL)
        case .pdf:
            try AanbevelingPDFExporter.export(client: client, to: fileURL)
        }
        return fileURL
    }

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        return df
    }()
}
