import Foundation
import PDFKit
import UIKit

enum ExcelPDFExportError: Error {
    case unsupportedFormat
    case pdfCreationFailed
}

struct ExcelPDFExporter {
    static func export(at url: URL) throws -> URL {
        guard url.pathExtension.lowercased().contains("xls") else {
            throw ExcelPDFExportError.unsupportedFormat
        }
        let outputURL = url.deletingPathExtension().appendingPathExtension("pdf")

        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let message = "Excel to PDF conversion is unavailable."
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14)
            ]
            message.draw(in: CGRect(x: 20, y: 20,
                                    width: pageRect.width - 40,
                                    height: pageRect.height - 40),
                         withAttributes: attrs)
        }

        guard let doc = PDFDocument(data: data) else {
            throw ExcelPDFExportError.pdfCreationFailed
        }
        doc.write(to: outputURL)
        return outputURL
    }
}
