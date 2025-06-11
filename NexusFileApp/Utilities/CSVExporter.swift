import Foundation

struct CSVExporter {
    static func export(farmer: Farmer, to url: URL) throws {
        let columnHeader = "DATE,TREKKER,RAT,REVS,TYD,POMP,DRUK"
        var lines: [String] = [columnHeader]
        let df = ISO8601DateFormatter()
        for rec in farmer.recommendations {
            if let header = rec.header {
                lines.append("")
                lines.append(header)
                lines.append(columnHeader)
            } else {
                let row = [df.string(from: rec.date), rec.trekker, rec.rat, rec.revs, rec.tyd, rec.pomp, rec.druk]
                    .map { $0.replacingOccurrences(of: ",", with: " ") }
                    .joined(separator: ",")
                lines.append(row)
            }
        }
        let csv = lines.joined(separator: "\n")
        try csv.data(using: .utf8)?.write(to: url)
    }
}
