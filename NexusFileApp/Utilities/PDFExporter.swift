import Foundation
import PDFKit
import UIKit

struct PDFExporter {
    static func export(farmer: Farmer, to url: URL) throws {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = 20
            let columnHeader = "TREKKER,RAT,REVS,TYD,POMP,DRUK"
            draw(columnHeader, at: &y, pageRect: pageRect)
            for rec in farmer.recommendations {
                if let header = rec.header {
                    if y > pageRect.height - 40 {
                        ctx.beginPage()
                        y = 20
                    }
                    y += 20
                    draw(header, at: &y, pageRect: pageRect)
                    draw(columnHeader, at: &y, pageRect: pageRect)
                } else {
                    let row = [rec.trekker, rec.rat, rec.revs, rec.tyd, rec.pomp, rec.druk]
                        .map { $0.replacingOccurrences(of: ",", with: " ") }
                        .joined(separator: ",")
                    if y > pageRect.height - 20 {
                        ctx.beginPage()
                        y = 20
                    }
                    draw(row, at: &y, pageRect: pageRect)
                }
            }
        }
        try data.write(to: url)
    }

    private static func draw(_ text: String, at y: inout CGFloat, pageRect: CGRect) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12)
        ]
        let rect = CGRect(x: 20, y: y, width: pageRect.width - 40, height: 20)
        text.draw(in: rect, withAttributes: attrs)
        y += 20
    }
}
