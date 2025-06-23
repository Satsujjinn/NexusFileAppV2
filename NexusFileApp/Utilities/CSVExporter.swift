import Foundation

struct CSVExporter {
    static func export(farmer: Farmer, to url: URL) throws {
        let columnHeader = "TREKKER,RAT,REVS,TYD,LT/HA,POMP,DRUK"
        var lines: [String] = ["NEXUSAG", columnHeader]
        for rec in farmer.recommendations {
            if let header = rec.header {
                lines.append("")
                lines.append("\t" + header)
                lines.append(columnHeader)
            } else {
                let row = [rec.trekker, rec.rat, rec.revs, rec.tyd, rec.ltHa, rec.pomp, rec.druk]
                    .map { $0.replacingOccurrences(of: ",", with: " ") }
                    .joined(separator: ",")
                lines.append(row)
            }
        }
        let csv = lines.joined(separator: "\n")
        try csv.data(using: .utf8)?.write(to: url)
    }
}
