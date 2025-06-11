import Testing
import PDFKit
@testable import NexusFileApp

struct CalibrationTests {
    @Test func farmerCRUD() async throws {
        let store = CalibrationStore(documentsURL: FileManager.default.temporaryDirectory)
        store.addFarmer(named: "John")
        store.addFarmer(named: "Adam")
        #expect(store.farmers.first?.name == "Adam")
        let farmer = store.farmers[0]
        store.rename(farmer: farmer, to: "Zack")
        #expect(store.farmers.last?.name == "Zack")
        store.duplicate(farmer: store.farmers[0])
        #expect(store.farmers.count == 3)
        store.moveFarmers(at: IndexSet(integer: 0), to: 2)
        #expect(store.farmers[2].name.contains("Adam"))
        store.delete(farmer: store.farmers[2])
        #expect(store.farmers.count == 2)
    }

    @Test func addRecommendationOrder() async throws {
        let store = CalibrationStore(documentsURL: FileManager.default.temporaryDirectory)
        store.addFarmer(named: "Tester")
        guard let farmer = store.farmers.first else { throw TestError("missing farmer") }
        store.addRecommendation(to: farmer)
        let firstID = store.farmers[0].recommendations.first?.id
        store.addRecommendation(to: farmer)
        let newFirstID = store.farmers[0].recommendations.first?.id
        #expect(firstID != newFirstID)
        #expect(store.farmers[0].recommendations.last?.id == firstID)
    }

    @Test func exportCSV() async throws {
        var farmer = Farmer(name: "CSV")
        farmer.recommendations.append(Recommendation(header: "Section 1"))
        farmer.recommendations.append(Recommendation(trekker: "t", rat: "r", revs: "v", tyd: "t", pomp: "p", druk: "d"))
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("test.csv")
        try? CSVExporter.export(farmer: farmer, to: file)
        let contents = (try? String(contentsOf: file)) ?? ""
        #expect(contents.contains("Section 1"))
        #expect(contents.contains("NEXUSAG"))
    }

    @Test func exportPDF() async throws {
        var farmer = Farmer(name: "PDF")
        farmer.recommendations.append(Recommendation(header: "Header A"))
        farmer.recommendations.append(Recommendation())
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("test.pdf")
        try? PDFExporter.export(farmer: farmer, to: file)
        let doc = PDFDocument(url: file)
        #expect(doc?.string?.contains("Header A") == true)
        #expect(doc?.string?.contains("NEXUSAG") == true)
    }
}
