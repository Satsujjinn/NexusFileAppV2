import Foundation
import SwiftUI

/// Represents a single calibration recommendation.
struct Recommendation: Identifiable, Codable {
    var id = UUID()
    /// Optional header text. If non-nil this row represents a header rather than a recommendation.
    var header: String? = nil
    var trekker: String = ""
    var rat: String = ""
    var revs: String = ""
    var tyd: String = ""
    var pomp: String = ""
    var druk: String = ""

    var isHeader: Bool { header != nil }
}

/// Represents a farmer with a list of calibration recommendations.
struct Farmer: Identifiable, Codable {
    var id = UUID()
    var name: String
    var recommendations: [Recommendation] = []
}

/// Simple data store saved as JSON. This is a placeholder in lieu of Core Data.
@MainActor
class CalibrationStore: ObservableObject {
    @Published private(set) var farmers: [Farmer] = []

    private let saveURL: URL

    init(documentsURL: URL = SharedFileManager.shared.documentsURL) {
        self.saveURL = documentsURL.appendingPathComponent("calibrations.json")
        load()
        sortFarmers()
    }

    func addFarmer(named name: String) {
        let farmer = Farmer(name: name)
        farmers.append(farmer)
        sortFarmers()
        save()
    }

    func rename(farmer: Farmer, to newName: String) {
        guard let idx = farmers.firstIndex(where: { $0.id == farmer.id }) else { return }
        farmers[idx].name = newName
        sortFarmers()
        save()
    }

    func delete(farmer: Farmer) {
        farmers.removeAll { $0.id == farmer.id }
        save()
    }

    func duplicate(farmer: Farmer) {
        let copy = Farmer(name: "\(farmer.name) copy", recommendations: farmer.recommendations)
        farmers.append(copy)
        sortFarmers()
        save()
    }

    func moveFarmers(at offsets: IndexSet, to destination: Int) {
        farmers.move(fromOffsets: offsets, toOffset: destination)
        save()
    }

    func addRecommendation(to farmer: Farmer) {
        guard let idx = farmers.firstIndex(where: { $0.id == farmer.id }) else { return }
        let rec = Recommendation()
        farmers[idx].recommendations.insert(rec, at: 0)
        save()
    }

    func addHeader(_ text: String, to farmer: Farmer) {
        guard let idx = farmers.firstIndex(where: { $0.id == farmer.id }) else { return }
        var header = Recommendation()
        header.header = text
        farmers[idx].recommendations.insert(header, at: 0)
        save()
    }

    func updateRecommendation(_ rec: Recommendation, for farmer: Farmer) {
        guard let fidx = farmers.firstIndex(where: { $0.id == farmer.id }) else { return }
        guard let ridx = farmers[fidx].recommendations.firstIndex(where: { $0.id == rec.id }) else { return }
        farmers[fidx].recommendations[ridx] = rec
        save()
    }

    func deleteRecommendations(at offsets: IndexSet, from farmer: Farmer) {
        guard let idx = farmers.firstIndex(where: { $0.id == farmer.id }) else { return }
        farmers[idx].recommendations.remove(atOffsets: offsets)
        save()
    }

    func moveRecommendations(at offsets: IndexSet, to newOffset: Int, for farmer: Farmer) {
        guard let idx = farmers.firstIndex(where: { $0.id == farmer.id }) else { return }
        farmers[idx].recommendations.move(fromOffsets: offsets, toOffset: newOffset)
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL) else { return }
        if let decoded = try? JSONDecoder().decode([Farmer].self, from: data) {
            self.farmers = decoded
            sortFarmers()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(farmers) {
            try? data.write(to: saveURL)
        }
    }

    private func sortFarmers() {
        farmers.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
