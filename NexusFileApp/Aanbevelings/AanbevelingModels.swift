import Foundation
import SwiftUI

/// Represents a single spray recommendation.
struct Aanbeveling: Identifiable, Codable {
    var id = UUID()
    /// Optional header text. If non-nil this row represents a header rather than a recommendation.
    var header: String? = nil
    var gewas: String = ""
    var teken: String = ""
    var produk: String = ""
    var aktief: String = ""
    /// Liters per hectare value
    var dosisLt: String = ""
    var dosisTenk: String = ""
    var ohp: String = ""

    var isHeader: Bool { header != nil }
}

/// Represents a client with a list of spray aanbevelings.
struct Client: Identifiable, Codable {
    var id = UUID()
    var name: String
    var aanbevelings: [Aanbeveling] = []
}

/// Simple data store saved as JSON. This is a placeholder in lieu of Core Data.
@MainActor
class AanbevelingStore: ObservableObject {
    @Published private(set) var clients: [Client] = []

    private let saveURL: URL
    private let documentsURL: URL

    init(documentsURL: URL = SharedFileManager.shared.documentsURL) {
        self.saveURL = documentsURL.appendingPathComponent("aanbevelings.json")
        self.documentsURL = documentsURL
        load()
        sortClients()
    }

    func addClient(named name: String) {
        let client = Client(name: name)
        clients.append(client)
        sortClients()
        save()
    }

    func rename(client: Client, to newName: String) {
        guard let idx = clients.firstIndex(where: { $0.id == client.id }) else { return }
        let oldName = clients[idx].name
        clients[idx].name = newName
        sortClients()
        save()

        let fm = FileManager.default
        let base = documentsURL
            .appendingPathComponent("Saved", isDirectory: true)
        let oldURL = base.appendingPathComponent(oldName, isDirectory: true)
        let newURL = base.appendingPathComponent(newName, isDirectory: true)
        if fm.fileExists(atPath: oldURL.path) {
            try? fm.moveItem(at: oldURL, to: newURL)
        }
    }

    func delete(client: Client) {
        clients.removeAll { $0.id == client.id }
        save()
    }

    func duplicate(client: Client) {
        let copy = Client(name: "\(client.name) copy", aanbevelings: client.aanbevelings)
        clients.append(copy)
        sortClients()
        save()
    }

    func moveClients(at offsets: IndexSet, to destination: Int) {
        clients.move(fromOffsets: offsets, toOffset: destination)
        save()
    }

    func addAanbeveling(to client: Client) {
        guard let idx = clients.firstIndex(where: { $0.id == client.id }) else { return }
        let rec = Aanbeveling()
        clients[idx].aanbevelings.insert(rec, at: 0)
        save()
    }

    func addHeader(_ text: String, count: Int, to client: Client) {
        guard let idx = clients.firstIndex(where: { $0.id == client.id }) else { return }
        var items: [Aanbeveling] = []
        var header = Aanbeveling()
        header.header = text
        items.append(header)
        if count > 0 {
            for _ in 0..<count { items.append(Aanbeveling()) }
        }
        clients[idx].aanbevelings.insert(contentsOf: items, at: 0)
        save()
    }

    func updateAanbeveling(_ rec: Aanbeveling, for client: Client) {
        guard let fidx = clients.firstIndex(where: { $0.id == client.id }) else { return }
        guard let ridx = clients[fidx].aanbevelings.firstIndex(where: { $0.id == rec.id }) else { return }
        clients[fidx].aanbevelings[ridx] = rec
        save()
    }

    func deleteRecommendations(at offsets: IndexSet, from client: Client) {
        guard let idx = clients.firstIndex(where: { $0.id == client.id }) else { return }
        clients[idx].aanbevelings.remove(atOffsets: offsets)
        save()
    }

    func deleteRecommendations(with ids: Set<UUID>, from client: Client) {
        guard let idx = clients.firstIndex(where: { $0.id == client.id }) else { return }
        clients[idx].aanbevelings.removeAll { ids.contains($0.id) }
        save()
    }

    func moveRecommendations(at offsets: IndexSet, to newOffset: Int, for client: Client) {
        guard let idx = clients.firstIndex(where: { $0.id == client.id }) else { return }
        clients[idx].aanbevelings.move(fromOffsets: offsets, toOffset: newOffset)
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL) else { return }
        if let decoded = try? JSONDecoder().decode([Client].self, from: data) {
            self.clients = decoded
            sortClients()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(clients) {
            try? data.write(to: saveURL)
        }
    }

    private func sortClients() {
        clients.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
