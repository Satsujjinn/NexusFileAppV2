import Foundation

struct AanbevelingCSVExporter {
    static func export(client: Client, to url: URL) throws {
        let columnHeader = "GEWAS,TEKEN,PRODUK,AKTIEF,DOSIS/LT,DOSIS/TENK,OHP"
        var lines: [String] = ["NEXUSAG", columnHeader]
        for rec in client.recommendations {
            if let header = rec.header {
                lines.append("")
                lines.append("\t" + header)
                lines.append(columnHeader)
            } else {
                let row = [rec.gewas, rec.teken, rec.produk, rec.aktief, rec.dosisLt, rec.dosisTenk, rec.ohp]
                    .map { $0.replacingOccurrences(of: ",", with: " ") }
                    .joined(separator: ",")
                lines.append(row)
            }
        }
        let csv = lines.joined(separator: "\n")
        try csv.data(using: .utf8)?.write(to: url)
    }
}
