import Testing
@testable import NexusFileApp

struct CalibrationTests {
    @Test func farmerCRUD() async throws {
        let store = CalibrationStore(documentsURL: FileManager.default.temporaryDirectory)
        store.addFarmer(named: "John")
        #expect(store.farmers.count == 1)
        let farmer = store.farmers[0]
        store.rename(farmer: farmer, to: "Jack")
        #expect(store.farmers[0].name == "Jack")
        store.delete(farmer: farmer)
        #expect(store.farmers.isEmpty)
    }

    @Test func recommendationSorting() async throws {
        var farmer = Farmer(name: "Test")
        farmer.recommendations = [
            Recommendation(date: Date(timeIntervalSince1970: 0)),
            Recommendation(date: Date())
        ]
        let sorted = farmer.recommendations.sorted { $0.date > $1.date }
        #expect(sorted.first?.date ?? Date() > sorted.last?.date ?? Date())
    }

    @Test func exportCSV() async throws {
        var farmer = Farmer(name: "CSV")
        farmer.recommendations.append(Recommendation(trekker: "t", rat: "r", revs: "v", tyd: "t", pomp: "p", druk: "d"))
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("test.csv")
        try? CSVExporter.export(farmer: farmer, to: file)
        #expect(FileManager.default.fileExists(atPath: file.path))
    }
}
