import Foundation

struct CSVExporter {
    static func export(farmer: Farmer, to url: URL) throws {
        var lines: [String] = [
            "DATE,TREKKER,RAT,REVS,TYD,POMP,DRUK"
        ]
        let df = ISO8601DateFormatter()
        for rec in farmer.recommendations {
            let row = [df.string(from: rec.date), rec.trekker, rec.rat, rec.revs, rec.tyd, rec.pomp, rec.druk]
                .map { $0.replacingOccurrences(of: ",", with: " ") }
                .joined(separator: ",")
            lines.append(row)
        }
        let csv = lines.joined(separator: "\n")
        try csv.data(using: .utf8)?.write(to: url)
    }
}
