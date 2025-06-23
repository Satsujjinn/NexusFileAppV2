import Foundation
import PDFKit
import UIKit

struct AanbevelingPDFExporter {
    static func export(client: Client, to url: URL) throws {
        let pageRect = CGRect(x: 0, y: 0, width: 700, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = 20
            drawCentered("NEXUSAG", at: &y, pageRect: pageRect, underline: true)
            y += 20
            let columnHeader = "GEWAS,TEKEN,PRODUK,AKTIEF,DOSIS/LT,DOSIS/TENK,OHP"
            draw(columnHeader, at: &y, pageRect: pageRect, underline: true)
            for rec in client.recommendations {
                if let header = rec.header {
                    if y > pageRect.height - 40 {
                        ctx.beginPage()
                        y = 20
                    }
                    y += 20
                    drawCentered(header, at: &y, pageRect: pageRect, underline: true)
                    y += 20
                    draw(columnHeader, at: &y, pageRect: pageRect, underline: true)
                } else {
                    let row = [rec.gewas, rec.teken, rec.produk, rec.aktief, rec.dosisLt, rec.dosisTenk, rec.ohp]
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

    private static func draw(_ text: String, at y: inout CGFloat, pageRect: CGRect, underline: Bool = false, centered: Bool = false) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        let rect = CGRect(x: 20, y: y, width: pageRect.width - 40, height: 20)
        var attributes = attrs
        if centered {
            let p = NSMutableParagraphStyle()
            p.alignment = .center
            attributes[.paragraphStyle] = p
        }
        text.draw(in: rect, withAttributes: attributes)
        if underline {
            let ctx = UIGraphicsGetCurrentContext()
            ctx?.setStrokeColor(UIColor.black.cgColor)
            ctx?.setLineWidth(1)
            ctx?.move(to: CGPoint(x: rect.minX, y: rect.maxY - 2))
            ctx?.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 2))
            ctx?.strokePath()
        }
        UIBezierPath(rect: rect).stroke()
        y += 20
    }

    private static func drawCentered(_ text: String, at y: inout CGFloat, pageRect: CGRect, underline: Bool = false) {
        draw(text, at: &y, pageRect: pageRect, underline: underline, centered: true)
    }
}
